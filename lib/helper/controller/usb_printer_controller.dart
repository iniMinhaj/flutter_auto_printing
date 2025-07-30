import 'dart:convert';

import 'package:auto_printing/data/model/order_details_model.dart';
import 'package:auto_printing/helper/notification/model/selectable_printer.dart';
import 'package:auto_printing/view/hompage.dart';
import 'package:auto_printing/widget/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thermal_printer_plus/esc_pos_utils_platform/src/capability_profile.dart';
import 'package:thermal_printer_plus/esc_pos_utils_platform/src/enums.dart';
import 'package:thermal_printer_plus/esc_pos_utils_platform/src/generator.dart';
import 'package:thermal_printer_plus/esc_pos_utils_platform/src/pos_column.dart';
import 'package:thermal_printer_plus/esc_pos_utils_platform/src/pos_styles.dart';
import 'package:thermal_printer_plus/thermal_printer.dart';
import '../../util/api_list.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

class UsbPrinterController extends GetxController {
  final printerManager = PrinterManager.instance;
  final RxList<SelectablePrinter> devices = <SelectablePrinter>[].obs;
  final Rx<SelectablePrinter?> selectedPrinterDevice = Rx<SelectablePrinter?>(
    null,
  );

  OrderDetailsModel orderDetailsModel = OrderDetailsModel();

  void scanDevices(PrinterType type) {
    devices.clear();

    printerManager.discovery(type: type).listen((device) {
      final isAlreadyAdded = devices.any(
        (d) =>
            d.device.name == device.name &&
            d.device.vendorId == device.vendorId &&
            d.device.productId == device.productId,
      );

      if (!isAlreadyAdded) {
        devices.add(SelectablePrinter(device: device, type: type));
      }
    });
  }

  void selectPrinter(SelectablePrinter printer) {
    selectedPrinterDevice.value = printer;
  }

  Future<void> connectDeviceAndPrint() async {
    try {
      final selected = selectedPrinterDevice.value;

      if (selected == null) {
        customSnackbar("Printer Status", "❌ No printer selected", Colors.red);
        return;
      }

      final type = selected.type;
      final device = selected.device;

      switch (type) {
        case PrinterType.usb:
          bool isConnected = await printerManager.connect(
            type: PrinterType.usb,
            model: UsbPrinterInput(
              name: device.name,
              productId: device.productId,
              vendorId: device.vendorId,
            ),
          );

          if (isConnected) {
            _printBasedOnRole(PrinterType.usb);
          } else {
            //  print("❌ USB connect failed");
            await customSnackbar("USB Connect", "Failed", Colors.red);
          }

          break;

        case PrinterType.bluetooth:
          bool isConnected = await printerManager.connect(
            type: PrinterType.bluetooth,
            model: BluetoothPrinterInput(
              name: device.name,
              address: device.address!,
              autoConnect: false,
              isBle: false,
            ),
          );
          if (isConnected) {
            _printBasedOnRole(PrinterType.bluetooth);
          }
          break;

        default:
          debugPrint("❌ Unsupported printer type: $type");
      }
    } catch (e) {
      customSnackbar("Exception", e.toString(), Colors.red);
    }
  }

  void _printBasedOnRole(PrinterType type) {
    if (box.read('roleId') == 5) {
      printInvoice(type);
    } else {
      printInvoiceForKitchen(type);
    }
  }

  Future<void> fetchOrderDetails({required String orderId}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiList.orderDetails(orderId: orderId)),
        headers: {'content-type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        orderDetailsModel = OrderDetailsModel.fromJson(data);
      } else {
        debugPrint(response.body);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<List<int>> buildInvoice(PaperSize paper) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(paper, profile);

    List<int> bytes = [];

    final order = orderDetailsModel.data;

    // Estimate max characters per line based on paper size
    final charsPerLine = paper == PaperSize.mm80 ? 64 : 52;
    final lineSeparator = '-' * charsPerLine;

    String truncate(String text, int max) {
      return text.length > max ? '${text.substring(0, max - 3)}...' : text;
    }

    void addLineSeparator() {
      bytes += generator.text(
        lineSeparator,
        styles: PosStyles(align: PosAlign.left),
      );
    }

    // Header
    bytes += generator.text(
      order?.branch?.name ?? '',
      styles: PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
      ),
    );
    addLineSeparator();

    bytes += generator.text("Order #: ${order?.orderSerialNo ?? ''}");
    bytes += generator.text(
      "${order?.orderDate ?? ''} ${order?.orderTime ?? ''}",
    );
    addLineSeparator();

    // Table header
    bytes += generator.row([
      PosColumn(text: 'Qty', width: 2, styles: PosStyles(align: PosAlign.left)),
      PosColumn(
        text: 'Item Name',
        width: 6,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: 'Total',
        width: 4,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);
    addLineSeparator();

    // Items
    for (OrderItem item in orderDetailsModel.data?.orderItems ?? []) {
      final itemName = truncate(item.itemName ?? '', 24);
      final itemTotal = item.totalCurrencyPrice ?? '';

      bytes += generator.row([
        PosColumn(
          text: '${item.quantity}',
          width: 2,
          styles: PosStyles(fontType: PosFontType.fontB),
        ),
        PosColumn(
          text: itemName,
          width: 6,
          styles: PosStyles(fontType: PosFontType.fontB),
        ),
        PosColumn(
          text: itemTotal,
          width: 4,
          styles: PosStyles(align: PosAlign.right, fontType: PosFontType.fontB),
        ),
      ]);

      // Variations
      for (var variation in item.itemVariations ?? []) {
        bytes += generator.row([
          PosColumn(text: '', width: 2),
          PosColumn(
            text: '  ${variation.variationName}: ${variation.name}',
            width: 10,
            styles: PosStyles(fontType: PosFontType.fontB),
          ),
        ]);
      }

      // Extras
      for (var extra in item.itemExtras ?? []) {
        bytes += generator.row([
          PosColumn(text: '', width: 2),
          PosColumn(
            text: '  Extra: ${extra.name}',
            width: 10,
            styles: PosStyles(fontType: PosFontType.fontB),
          ),
        ]);
      }

      // Instructions
      if ((item.instruction ?? '').isNotEmpty) {
        bytes += generator.row([
          PosColumn(text: '', width: 2),
          PosColumn(
            text: '  Instruction: ${item.instruction}',
            width: 10,
            styles: PosStyles(fontType: PosFontType.fontB),
          ),
        ]);
      }

      bytes += generator.feed(1);
    }

    // Totals
    addLineSeparator();
    bytes += generator.row([
      PosColumn(text: 'Subtotal:', width: 6),
      PosColumn(
        text: order?.subtotalWithoutTaxCurrencyPrice.toString() ?? '',
        width: 6,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'Tax:', width: 6),
      PosColumn(
        text: order?.totalTaxCurrencyPrice.toString() ?? '',
        width: 6,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'Discount:', width: 6),
      PosColumn(
        text: order?.discountCurrencyPrice.toString() ?? '',
        width: 6,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'Total:', width: 6),
      PosColumn(
        text: order?.totalCurrencyPrice.toString() ?? '',
        width: 6,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);

    addLineSeparator();

    bytes += generator.text(
      "Customer: ${order?.user?.firstName ?? ''} ${order?.user?.lastName ?? ''}",
    );
    bytes += generator.text("Phone: ${order?.user?.phone ?? ''}");
    bytes += generator.text("Order Type: Pickup");
    bytes += generator.text("Delivery Time: ${order?.deliveryTime ?? ''}");

    // Footer
    bytes += generator.feed(2);
    bytes += generator.text(
      'Thank you!',
      styles: PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.feed(2);
    bytes += generator.cut();

    return bytes;
  }

  Future<List<int>> buildInvoiceKitchen(PaperSize paper) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(paper, profile);
    List<int> bytes = [];

    final order = orderDetailsModel.data;

    // Dynamic line separator based on paper size
    final charsPerLine = paper == PaperSize.mm80 ? 64 : 52;
    final separatorLine = '-' * charsPerLine;

    // Helper function for consistent line separator
    void addLineSeparator() {
      bytes += generator.text(
        separatorLine,
        styles: PosStyles(align: PosAlign.left),
      );
    }

    // ---------- Header ----------
    bytes += generator.text(
      order?.branch?.name ?? '',
      styles: PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
      ),
    );
    bytes += generator.text(
      "KITCHEN COPY",
      styles: PosStyles(align: PosAlign.center, bold: true),
    );
    addLineSeparator();

    bytes += generator.text("Order #: ${order?.orderSerialNo ?? ''}");
    bytes += generator.text(
      "${order?.orderDate ?? ''} ${order?.orderTime ?? ''}",
    );
    addLineSeparator();
    bytes += generator.row([
      PosColumn(text: 'Qty', width: 1),
      PosColumn(text: 'Item Name', width: 11),
    ]);
    addLineSeparator();
    // ---------- Items ----------
    for (var item in order?.orderItems ?? []) {
      // Main item row
      bytes += generator.row([
        PosColumn(text: '${item.quantity}', width: 1),
        PosColumn(text: item.itemName ?? '', width: 11),
      ]);

      // Variations
      for (var variation in item.itemVariations ?? []) {
        bytes += generator.row([
          PosColumn(text: '', width: 1),
          PosColumn(
            text: '  ${variation.variationName}: ${variation.name}',
            width: 11,
            styles: PosStyles(fontType: PosFontType.fontB),
          ),
        ]);
      }

      // Extras
      for (var extra in item.itemExtras ?? []) {
        bytes += generator.row([
          PosColumn(text: '', width: 1),
          PosColumn(
            text: '  Extra: ${extra.name}',
            width: 11,
            styles: PosStyles(fontType: PosFontType.fontB),
          ),
        ]);
      }

      // Instruction
      if ((item.instruction ?? '').isNotEmpty) {
        bytes += generator.row([
          PosColumn(text: '', width: 1),
          PosColumn(text: '  Instruction: ${item.instruction}', width: 11),
        ]);
      }

      bytes += generator.feed(1);
    }

    addLineSeparator();

    // ---------- Customer ----------
    bytes += generator.text(
      "Customer: ${order?.user?.firstName ?? ''} ${order?.user?.lastName ?? ''}",
    );
    bytes += generator.text("Phone: ${order?.user?.phone ?? ''}");
    bytes += generator.text("Order Type: Pickup");
    bytes += generator.text("Delivery Time: ${order?.deliveryTime ?? ''}");

    // ---------- Footer ----------
    bytes += generator.feed(2);

    bytes += generator.text(
      'Thank you!',
      styles: PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.text(
      'Visit Again',
      styles: PosStyles(align: PosAlign.center, bold: true),
    );

    bytes += generator.feed(2);
    bytes += generator.cut();

    return bytes;
  }

  void printInvoice(PrinterType type) async {
    try {
      final bytes = await buildInvoice(PaperSize.mm80); // Invoice content
      await printerManager.send(type: type, bytes: bytes);
    } catch (e, stack) {
      debugPrint("❌ Failed to print invoice: $e");
      debugPrint("📚 Stack: $stack");
      await customSnackbar("Print Error", e.toString(), Colors.red);
    }
  }

  void printInvoiceForKitchen(PrinterType type) async {
    try {
      final bytes = await buildInvoiceKitchen(
        PaperSize.mm80,
      ); // Invoice content
      await printerManager.send(type: type, bytes: bytes);
      debugPrint("✅ Invoice printed successfully");
    } catch (e) {
      debugPrint("❌ Failed to print invoice: $e");
    }
  }
}
