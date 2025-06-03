import 'dart:convert';

import 'package:auto_printing/data/model/order_details_model.dart';
import 'package:auto_printing/util/api_list.dart';
import 'package:auto_printing/widget/custom_snackbar.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../view/hompage.dart';

class AutoPrintingController extends GetxController {
  final BlueThermalPrinter printer = BlueThermalPrinter.instance;
  OrderDetailsModel orderDetailsModel = OrderDetailsModel();
  final RxList<BluetoothDevice> devices = <BluetoothDevice>[].obs;
  final Rx<BluetoothDevice?> selectedPrinter = Rx<BluetoothDevice?>(null);

  Future<void> fetchPairedPrinters() async {
    List<BluetoothDevice> pairedDevices = await printer.getBondedDevices();
    if (pairedDevices.isNotEmpty) {
      devices.clear();
      devices.addAll(pairedDevices);
    } else {
      customSnackbar("ERROR", "No Printer Found.", Colors.red);
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

  Future<void> connectAndPrint({required String modelName}) async {
    if (selectedPrinter.value!.name != null) {
      bool isConnected = await printer.isConnected ?? false;

      if (!isConnected) {
        await printer.connect(selectedPrinter.value!);
      } else {
        debugPrint("Already connected to a printer");
      }

      if (orderDetailsModel.data != null && box.read('roleId') != null) {
        if (box.read('roleId') == 5) {
          invoiceForSalesman();
        } else {
          invoiceForKitchen();
        }
      } else {
        debugPrint("No data found");
      }
    } else {
      debugPrint("Printer not found");
    }
  }

  // Utility function to wrap and print text
  void wrapAndPrintText(String text, int maxCharsPerLine, int align) {
    List<String> words = text.split(' ');
    String currentLine = '';

    for (String word in words) {
      if ((currentLine + word).length + (currentLine.isEmpty ? 0 : 1) <=
          maxCharsPerLine) {
        currentLine += (currentLine.isEmpty ? '' : ' ') + word;
      } else {
        printer.printCustom(currentLine, 0, align);
        currentLine = word;
      }
    }

    if (currentLine.isNotEmpty) {
      printer.printCustom(currentLine, 0, align);
    }
  }

  void invoiceForSalesman() {
    final order = orderDetailsModel.data;
    const maxLineLength = 32; // Make this dynamic later based on printer width

    // -------- HEADER --------
    printer.printCustom("${order?.branch?.name}", 3, 1);
    printer.printNewLine();
    printer.printCustom("-" * maxLineLength, 1, 1);
    printer.printCustom("Order #${order?.orderSerialNo}", 1, 0);
    printer.printLeftRight(order?.orderDate ?? "", order?.orderTime ?? "", 1);
    printer.printCustom("-" * maxLineLength, 1, 1);
    printer.printNewLine();

    // -------- TABLE HEADER --------
    printer.printCustom("-" * maxLineLength, 1, 1);
    printer.print3Column("Qnty", "Item Desc", "Total", 1);
    printer.printCustom("-" * maxLineLength, 1, 1);

    // -------- ITEM LOOP --------
    for (var item in order?.orderItems ?? []) {
      String qnty = "${item.quantity}";
      String itemName = "${item.itemName}";
      String totalPrice = item.totalCurrencyPrice.toString();
      printItemNameForSales(qnty, itemName, totalPrice);

      // Handle variations
      for (var variation in item.itemVariations ?? []) {
        final variationText = "${variation.variationName}: ${variation.name}";
        wrapAndPrintText(variationText, maxLineLength - 8, 0);
      }

      // Handle extras
      for (var extra in item.itemExtras ?? []) {
        final extraText = "Extra: ${extra.name}";
        wrapAndPrintText(extraText, maxLineLength - 8, 0);
      }

      // Handle instructions
      if (item.instruction != null && item.instruction!.isNotEmpty) {
        final instructionText = "Instruction: ${item.instruction}";
        wrapAndPrintText(instructionText, maxLineLength, 0);
      }

      printer.printNewLine();
    }

    printer.printCustom("-" * maxLineLength, 1, 1);

    // -------- SUMMARY --------
    printer.printLeftRight(
      "Subtotal:",
      order?.subtotalWithoutTaxCurrencyPrice.toString() ?? "",
      1,
    );
    printer.printLeftRight("Total Tax:", order?.totalTaxCurrencyPrice ?? "", 1);
    printer.printLeftRight("Discount:", order?.discountCurrencyPrice ?? "", 1);
    printer.printLeftRight("Total:", order?.totalCurrencyPrice ?? "", 1);

    printer.printNewLine();
    printer.printCustom("-" * maxLineLength, 1, 1);

    // -------- PAYMENT & CUSTOMER INFO --------
    wrapAndPrintText("Order Type: Pickup", maxLineLength, 0);
    wrapAndPrintText(
      "Payment Type: ${order?.transaction?.paymentMethod}",
      maxLineLength,
      0,
    );
    wrapAndPrintText("Delivery Time: ${order?.deliveryTime}", maxLineLength, 0);
    printer.printCustom("-" * maxLineLength, 1, 1);

    wrapAndPrintText(
      "Customer: ${order?.user?.firstName} ${order?.user?.lastName}",
      maxLineLength,
      0,
    );
    wrapAndPrintText("Phone: ${order?.user?.phone}", maxLineLength, 0);
    printer.printCustom("-" * maxLineLength, 1, 1);

    // -------- FOOTER --------
    printer.printCustom("Thank you!", 2, 1);
    printer.printCustom("Visit Again", 1, 1);
    printer.printNewLine();
    printer.printNewLine();
    printer.paperCut();
  }

  void printItemNameForKitchen(String itemName, int maxChars) {
    while (itemName.length > maxChars) {
      printer.printCustom(itemName.substring(0, maxChars), 1, 0); // size = 1
      itemName = itemName.substring(maxChars);
    }

    if (itemName.isNotEmpty) {
      printer.printCustom(itemName, 1, 0);
    }
  }

  void printItemNameForSales(String qnty, String itemName, String itemTotal) {
    const int totalWidth = 32;
    const int leftMax = 20;

    List<String> words = itemName.split(' ');
    List<String> lines = [];
    String currentLine = '';

    for (String word in words) {
      if (('$currentLine $word').trim().length <= leftMax) {
        currentLine = ('$currentLine $word').trim();
      } else {
        lines.add(currentLine);
        currentLine = word;
      }
    }
    if (currentLine.isNotEmpty) {
      lines.add(currentLine);
    }

    for (int i = 0; i < lines.length; i++) {
      String left = (i == 0) ? '$qnty ${lines[i]}' : lines[i];
      String right = (i == 0) ? itemTotal : '';

      // Make sure the line fits total width
      int spaceCount = totalWidth - left.length - right.length;
      spaceCount = spaceCount.clamp(1, totalWidth); // Ensure at least 1 space

      String line = left + ' ' * spaceCount + right;
      printer.printCustom(
        line,
        1,
        0,
      ); // Adjust this line based on your printer function
    }
  }

  void printText(String insruction, int maxChars, int size) {
    while (insruction.length > maxChars) {
      printer.printCustom(
        insruction.substring(0, maxChars),
        size,
        0,
      ); // size = 1
      insruction = insruction.substring(maxChars);
    }

    if (insruction.isNotEmpty) {
      printer.printCustom(insruction, size, 0);
    }
  }

  String formatColumnText(String text, int width) {
    if (text.length > width) {
      return text.substring(0, width); // truncate
    } else {
      return text.padRight(width); // pad if less
    }
  }

  dateFormatter(String input) {
    String inputDate = input; // "26-05-2025"

    DateTime date = DateFormat("dd-MM-yyyy").parse(inputDate);

    String formattedDate = DateFormat("d MMMM, yyyy").format(date);

    return formattedDate; // Output: 26 May, 2025
  }

  // invoiceForSalesman() {
  //   final order = orderDetailsModel.data;
  //   // -----------------[ START - Invoice Design ]---------------------

  //   // Header section:
  //   printer.printCustom("${order?.branch?.name}", 3, 1); // 3 = size, 1 = center
  //   printer.printNewLine();
  //   printer.printCustom("--------------------------------", 1, 1);
  //   printer.printCustom("Order #${order?.orderSerialNo}", 1, 0);
  //   printer.printLeftRight(order?.orderDate ?? "", order?.orderTime ?? "", 1);
  //   printer.printCustom("--------------------------------", 1, 1);
  //   // //printer.printCustom("TAKEOUT", 3, 1);
  //   // printer.printCustom("--------------------------------", 1, 1);
  //   // printer.printCustom("Address line", 1, 1);
  //   // printer.printCustom("Phone: 0123456789", 1, 1);
  //   printer.printNewLine();

  //   // // Invoice details:
  //   // printer.printLeftRight("Invoice: #12345", "Date: 22-05-2025", 1);
  //   // printer.printLeftRight("Cashier: John", "Time: 12:45 PM", 1);
  //   // printer.printNewLine();

  //   // //Table Header:
  //   printer.printCustom("--------------------------------", 1, 1);
  //   printer.print3Column("Qnty", "Item Desc", "Total", 1);
  //   printer.printCustom("--------------------------------", 1, 1);

  //   // Item Loop:
  //   for (var item in orderDetailsModel.data!.orderItems!) {
  //     String qnty = "${item.quantity}";
  //     String itemName = "${item.itemName}";
  //     String totalPrice = item.totalCurrencyPrice.toString();
  //     printItemNameForSales(qnty, itemName, totalPrice);

  //     // Handle variations
  //     if (item.itemVariations != null && item.itemVariations!.isNotEmpty) {
  //       for (var variation in item.itemVariations!) {
  //         String variationText =
  //             "${variation.variationName}: ${variation.name}";
  //         printText(variationText, 16, 0);
  //       }
  //     }

  //     // Item extras
  //     if (item.itemExtras != null && item.itemExtras!.isNotEmpty) {
  //       for (var extra in item.itemExtras!) {
  //         String extraLine = "Extra: ${extra.name}";
  //         printText(extraLine, 16, 0);
  //       }
  //     }

  //     // Optional: If instruction or extras exist, show here as well
  //     if (item.instruction != null && item.instruction!.isNotEmpty) {
  //       printText("Instruction: ${item.instruction}", 32, 0);
  //     }

  //     // Add a line gap between items if needed
  //     printer.printNewLine();
  //   }
  //   printer.printCustom("--------------------------------", 1, 1);

  //   // // Summary Table:
  //   printer.printLeftRight(
  //     "Subtotal:",
  //     order?.subtotalWithoutTaxCurrencyPrice.toString() ?? "",
  //     1,
  //   );

  //   printer.printLeftRight("Total Tax:", order?.totalTaxCurrencyPrice ?? "", 1);
  //   printer.printLeftRight("Discount:", order?.discountCurrencyPrice ?? "", 1);
  //   printer.printLeftRight("Total:", order?.totalCurrencyPrice ?? "", 1);
  //   printer.printNewLine();
  //   printer.printCustom("--------------------------------", 1, 1);

  //   printer.printCustom("Order Type:  Pickup", 1, 0);
  //   printer.printCustom(
  //     "Payment Type:  ${order?.transaction?.paymentMethod}}",
  //     1,
  //     0,
  //   );
  //   printer.printCustom("Delivery Time:  ${order?.deliveryTime}", 1, 0);

  //   printer.printCustom("--------------------------------", 1, 1);
  //   printer.printCustom(
  //     "Customer:  ${order?.user?.firstName} ${order?.user?.lastName}",
  //     1,
  //     0,
  //   );
  //   printer.printCustom("Phone:  ${order?.user?.phone}", 1, 0);

  //   printer.printCustom("--------------------------------", 1, 1);

  //   // // Footer:
  //   printer.printCustom("Thank you!", 2, 1);
  //   printer.printCustom("Visit Again", 1, 1);

  //   printer.printNewLine();
  //   printer.printNewLine();

  //   printer.paperCut(); // if supported

  //   // -----------------[ END - Invoice Design ]---------------------
  // }

  invoiceForKitchen() {
    printer.printNewLine();

    // Header
    printer.printCustom(
      orderDetailsModel.data?.branch?.name ?? "",
      2,
      0,
    ); // Size: 3, Center aligned

    // Date & Time
    printer.printLeftRight(
      dateFormatter(orderDetailsModel.data?.orderDate ?? ""),
      orderDetailsModel.data?.orderTime ?? "",
      1,
    );

    printer.printCustom("--------------------------------", 1, 1);

    // Takeout or Dine-in
    printer.printCustom("TAKEOUT", 1, 1);
    printer.printCustom("--------------------------------", 1, 1);
    printer.printNewLine();

    // Order Item
    // Item Loop:
    for (var item in orderDetailsModel.data!.orderItems!) {
      String itemLine = "${item.quantity} x ${item.itemName}";
      printItemNameForKitchen(itemLine, 32);

      // Handle variations
      if (item.itemVariations != null && item.itemVariations!.isNotEmpty) {
        for (var variation in item.itemVariations!) {
          String variationText =
              "${variation.variationName}: ${variation.name}";
          printText(variationText, 32, 0);
        }
      }

      // Item extras
      if (item.itemExtras != null && item.itemExtras!.isNotEmpty) {
        for (var extra in item.itemExtras!) {
          String extraLine = "Extra: ${extra.name}";
          printText(extraLine, 32, 0);
        }
      }

      // Optional: If instruction or extras exist, show here as well
      if (item.instruction != null && item.instruction!.isNotEmpty) {
        printText("Instruction: ${item.instruction}", 32, 0);
      }

      // Add a line gap between items if needed
      printer.printNewLine();
    }

    printer.printCustom("...............................", 1, 0);
    printer.printCustom("*Kettle Chips", 1, 0);

    printer.printNewLine();

    // Device and reprint info
    printer.printCustom("IN PERSON TICKETS", 1, 0);
    printer.printCustom("Square Register No. 1", 1, 0);
    printer.printNewLine();
    printer.printCustom(
      "PRINT AT ${DateFormat('h.mm.ss a').format(DateTime.now())}",
      1,
      1,
    );

    printer.printNewLine();
    printer.printNewLine();
    printer.paperCut();
  }
}
