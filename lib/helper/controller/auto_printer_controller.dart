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

      if (orderDetailsModel.data != null) {
        // printForKitchen();
        printForSalesman();
      } else {
        debugPrint("No data found");
      }
    } else {
      debugPrint("Printer not found");
    }
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

  void printItemNameForSales(
    String qnty,
    String itemName,
    String itemTotal,
    int maxChars,
  ) {
    while (itemName.length > maxChars) {
      printer.print3Column(
        qnty,
        itemName.substring(0, maxChars),
        itemTotal,
        1,
      ); // size = 1
      itemName = itemName.substring(maxChars);
    }

    if (itemName.isNotEmpty) {
      printer.print3Column(qnty, itemName, itemTotal, 1);
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

  dateFormatter(String input) {
    String inputDate = input; // "26-05-2025"

    DateTime date = DateFormat("dd-MM-yyyy").parse(inputDate);

    String formattedDate = DateFormat("d MMMM, yyyy").format(date);

    return formattedDate; // Output: 26 May, 2025
  }

  printForSalesman() {
    final order = orderDetailsModel.data;
    // -----------------[ START - Invoice Design ]---------------------

    // Header section:
    printer.printCustom("${order?.branch?.name}", 3, 1); // 3 = size, 1 = center
    printer.printNewLine();
    printer.printCustom("--------------------------------", 1, 1);
    printer.printCustom("Order #${order?.orderSerialNo}", 1, 0);
    printer.printLeftRight(order?.orderDate ?? "", order?.orderTime ?? "", 1);
    printer.printCustom("--------------------------------", 1, 1);
    // //printer.printCustom("TAKEOUT", 3, 1);
    // printer.printCustom("--------------------------------", 1, 1);
    // printer.printCustom("Address line", 1, 1);
    // printer.printCustom("Phone: 0123456789", 1, 1);
    printer.printNewLine();

    // // Invoice details:
    // printer.printLeftRight("Invoice: #12345", "Date: 22-05-2025", 1);
    // printer.printLeftRight("Cashier: John", "Time: 12:45 PM", 1);
    // printer.printNewLine();

    // //Table Header:
    printer.printCustom("--------------------------------", 1, 1);
    printer.print3Column("Qnty", "Item", "Total", 1);
    printer.printCustom("--------------------------------", 1, 1);

    // Item Loop:
    for (var item in orderDetailsModel.data!.orderItems!) {
      String qnty = "${item.quantity}";
      String itemName = "${item.itemName}";
      String totalPrice = item.totalCurrencyPrice.toString();
      printItemNameForSales(qnty, itemName, totalPrice, 16);

      // Handle variations
      if (item.itemVariations != null && item.itemVariations!.isNotEmpty) {
        for (var variation in item.itemVariations!) {
          String variationText =
              "${variation.variationName}: ${variation.name}";
          printText(variationText, 16, 0);
        }
      }

      // Item extras
      if (item.itemExtras != null && item.itemExtras!.isNotEmpty) {
        for (var extra in item.itemExtras!) {
          String extraLine = "Extra: ${extra.name}";
          printText(extraLine, 16, 0);
        }
      }

      // Optional: If instruction or extras exist, show here as well
      if (item.instruction != null && item.instruction!.isNotEmpty) {
        printText("Instruction: ${item.instruction}", 32, 0);
      }

      // Add a line gap between items if needed
      printer.printNewLine();
    }
    printer.printCustom("--------------------------------", 1, 1);

    // // Summary Table:
    printer.printLeftRight(
      "Subtotal:",
      order?.subtotalWithoutTaxCurrencyPrice.toString() ?? "",
      1,
    );

    printer.printLeftRight("Total Tax:", order?.totalTaxCurrencyPrice ?? "", 1);
    printer.printLeftRight("Discount:", order?.discountCurrencyPrice ?? "", 1);
    printer.printLeftRight("Total:", order?.totalCurrencyPrice ?? "", 1);
    printer.printNewLine();
    printer.printCustom("--------------------------------", 1, 1);

    printer.printCustom("Order Type:  Pickup", 1, 0);
    printer.printCustom(
      "Payment Type:  ${order?.transaction?.paymentMethod}}",
      1,
      0,
    );
    printer.printCustom("Delivery Time:  ${order?.deliveryTime}", 1, 0);

    printer.printCustom("--------------------------------", 1, 1);
    printer.printCustom(
      "Customer:  ${order?.user?.firstName} ${order?.user?.lastName}",
      1,
      0,
    );
    printer.printCustom("Phone:  ${order?.user?.phone}", 1, 0);

    printer.printCustom("--------------------------------", 1, 1);

    // // Footer:
    printer.printCustom("Thank you!", 2, 1);
    printer.printCustom("Visit Again", 1, 1);

    printer.printNewLine();
    printer.printNewLine();

    printer.paperCut(); // if supported

    // -----------------[ END - Invoice Design ]---------------------
  }

  printForKitchen() {
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
    //  printItemName(orderDetailsModel.data.or, 32);
    // //  printer.printCustom("1 × THE CALIFORNIA", 2, 0);
    // printer.printCustom("Full Sandwich", 1, 0);
    // printer.printCustom("Sourdough Bread", 1, 0);
    // printer.printCustom("Pepper Jack", 1, 0);

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
