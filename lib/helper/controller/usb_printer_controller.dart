import 'dart:convert';

import 'package:auto_printing/data/model/order_details_model.dart';
import 'package:auto_printing/view/hompage.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:get/get.dart';

import '../../util/api_list.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

class UsbPrinterController extends GetxController {
  final printerManager = PrinterManager.instance;
  final RxList<PrinterDevice> devices = <PrinterDevice>[].obs;
  final Rx<PrinterDevice?> selectedUSBDevice = Rx<PrinterDevice?>(null);
  OrderDetailsModel orderDetailsModel = OrderDetailsModel();

  void scanDevices(PrinterType type, {bool isBle = false}) {
    devices.clear();

    PrinterManager.instance.discovery(type: type, isBle: isBle).listen((
      device,
    ) {
      final isAlreadyAdded = devices.any(
        (d) =>
            d.name == device.name &&
            d.vendorId == device.vendorId &&
            d.productId == device.productId,
      );

      if (!isAlreadyAdded) {
        devices.add(device);
      }
    });
  }

  connectDeviceAndPrint(
    PrinterDevice selectedPrinter,
    PrinterType type, {
    bool reconnect = false,
    bool isBle = false,
    String? ipAddress,
  }) async {
    switch (type) {
      // only windows and android

      case PrinterType.usb:
        bool isConnected = await PrinterManager.instance.connect(
          type: type,
          model: UsbPrinterInput(
            name: selectedPrinter.name,
            productId: selectedPrinter.productId,
            vendorId: selectedPrinter.vendorId,
          ),
        );
        if (isConnected) {
          if (box.read('roleId') == 5) {
            printInvoice();
          } else {
            printInvoiceForKitchen();
          }
        }
        break;
      // only iOS and android
      case PrinterType.bluetooth:
        await PrinterManager.instance.connect(
          type: type,
          model: BluetoothPrinterInput(
            name: selectedPrinter.name,
            address: selectedPrinter.address!,
            isBle: isBle,
            autoConnect: reconnect,
          ),
        );
        break;
      case PrinterType.network:
        await PrinterManager.instance.connect(
          type: type,
          model: TcpPrinterInput(
            ipAddress: ipAddress ?? selectedPrinter.address!,
          ),
        );
        break;
    }
  }

  Future<void> fetchOrderDetails({required String orderId}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiList.orderDetails(orderId: orderId)),
        headers: {
          'x-api-key': ApiList.licenseCode.toString(),
          'content-type': 'application/json',
        },
      );

      print("orderDetails = ${response.body}");

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

    bytes += generator.text(
      'Branch Name',
      styles: PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
      ),
    );
    bytes += generator.text('--------------------------------');
    bytes += generator.row([
      PosColumn(text: 'Qty', width: 2),
      PosColumn(text: 'Item Name', width: 8),
      PosColumn(
        text: 'Total',
        width: 2,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.text('--------------------------------');

    for (var item in orderDetailsModel.data?.orderItems ?? []) {
      bytes += generator.row([
        PosColumn(text: '${item.quantity}', width: 2),
        PosColumn(text: item.itemName ?? '', width: 8),
        PosColumn(
          text: item.totalCurrencyPrice.toString(),
          width: 2,
          styles: PosStyles(align: PosAlign.right),
        ),
      ]);

      for (var variation in item.itemVariations ?? []) {
        bytes += generator.text(
          '  ${variation.variationName}: ${variation.name}',
          styles: PosStyles(fontType: PosFontType.fontB),
        );
      }

      for (var extra in item.itemExtras ?? []) {
        bytes += generator.text(
          '  Extra: ${extra.name}',
          styles: PosStyles(fontType: PosFontType.fontB),
        );
      }

      if ((item.instruction ?? '').isNotEmpty) {
        bytes += generator.text(
          '  Instruction: ${item.instruction}',
          styles: PosStyles(align: PosAlign.left),
        );
      }

      bytes += generator.feed(1);
    }

    final order = orderDetailsModel.data;

    // Totals
    bytes += generator.text('--------------------------------');
    bytes += generator.row([
      PosColumn(text: 'Subtotal:', width: 10),
      PosColumn(
        text: order?.subtotalWithoutTaxCurrencyPrice.toString() ?? '',
        width: 2,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(text: 'Tax:', width: 10),
      PosColumn(
        text: order?.totalTaxCurrencyPrice.toString() ?? '',
        width: 2,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(text: 'Discount:', width: 10),
      PosColumn(
        text: order?.discountCurrencyPrice.toString() ?? '',
        width: 2,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(text: 'Total:', width: 10),
      PosColumn(
        text: order?.totalCurrencyPrice.toString() ?? '',
        width: 2,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);

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

    const maxChars = 32;

    final order = orderDetailsModel.data;

    // ---------- Header ----------
    bytes += generator.text(
      order?.branch?.name ?? '',
      styles: PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    bytes += generator.text(
      "KITCHEN COPY",
      styles: PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.text("-" * maxChars);

    bytes += generator.text("Order #: ${order?.orderSerialNo ?? ''}");
    bytes += generator.text(
      "${order?.orderDate ?? ''} ${order?.orderTime ?? ''}",
    );
    bytes += generator.text("-" * maxChars);
    bytes += generator.feed(1);

    // ---------- Items ----------
    for (var item in order?.orderItems ?? []) {
      bytes +=
          bytes += generator.row([
            PosColumn(text: '${item.quantity}', width: 2),
            PosColumn(text: item.itemName ?? '', width: 8),
          ]);

      for (var variation in item.itemVariations ?? []) {
        bytes += generator.text(
          '  ${variation.variationName}: ${variation.name}',
          styles: PosStyles(fontType: PosFontType.fontB),
        );
      }

      for (var extra in item.itemExtras ?? []) {
        bytes += generator.text(
          '  Extra: ${extra.name}',
          styles: PosStyles(fontType: PosFontType.fontB),
        );
      }

      if ((item.instruction ?? '').isNotEmpty) {
        bytes += generator.text(
          '  Instruction: ${item.instruction}',
          styles: PosStyles(align: PosAlign.left),
        );
      }

      bytes += generator.feed(1);
    }

    bytes += generator.text("-" * maxChars);

    // ---------- Customer ----------
    bytes += generator.text(
      "Customer: ${order?.user?.firstName ?? ''} ${order?.user?.lastName ?? ''}",
    );
    bytes += generator.text("Phone: ${order?.user?.phone ?? ''}");
    bytes += generator.text("Order Type: Pickup");
    bytes += generator.text("Delivery Time: ${order?.deliveryTime ?? ''}");

    // ---------- Totals ----------
    bytes += generator.text("-" * maxChars);
    bytes += generator.row([
      PosColumn(text: "Subtotal:", width: 10),
      PosColumn(
        text: order?.subtotalWithoutTaxCurrencyPrice.toString() ?? '',
        width: 2,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(text: "Tax:", width: 10),
      PosColumn(
        text: order?.totalTaxCurrencyPrice.toString() ?? '',
        width: 2,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(text: "Discount:", width: 10),
      PosColumn(
        text: order?.discountCurrencyPrice.toString() ?? '',
        width: 2,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(text: "Total:", width: 10),
      PosColumn(
        text: order?.totalCurrencyPrice.toString() ?? '',
        width: 2,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);

    // ---------- Footer ----------
    bytes += generator.feed(2);
    bytes += generator.text(
      "Thank you!",
      styles: PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.text(
      "Visit Again",
      styles: PosStyles(align: PosAlign.center),
    );
    bytes += generator.feed(2);
    bytes += generator.cut();

    return bytes;
  }

  void printInvoice() async {
    try {
      final bytes = await buildInvoice(PaperSize.mm80); // Invoice content
      await printerManager.send(type: PrinterType.usb, bytes: bytes);
      print("✅ Invoice printed successfully");
    } catch (e) {
      print("❌ Failed to print invoice: $e");
    }
  }

  void printInvoiceForKitchen() async {
    try {
      final bytes = await buildInvoiceKitchen(
        PaperSize.mm80,
      ); // Invoice content
      await printerManager.send(type: PrinterType.usb, bytes: bytes);
      print("✅ Invoice printed successfully");
    } catch (e) {
      print("❌ Failed to print invoice: $e");
    }
  }
}
