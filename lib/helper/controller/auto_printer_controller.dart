import 'dart:convert';

import 'package:auto_printing/data/model/order_details_model.dart';
import 'package:auto_printing/util/api_list.dart';
import 'package:auto_printing/widget/custom_snackbar.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

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
        // -----------------[ START - Invoice Design ]---------------------

        // Header section:
        printer.printCustom("Your Shop Name", 3, 1); // 3 = size, 1 = center
        printer.printCustom("Address line", 1, 1);
        printer.printCustom("Phone: 0123456789", 1, 1);
        printer.printNewLine();

        // Invoice details:
        printer.printLeftRight("Invoice: #12345", "Date: 22-05-2025", 1);
        printer.printLeftRight("Cashier: John", "Time: 12:45 PM", 1);
        printer.printNewLine();

        //Table Header:
        printer.printCustom("--------------------------------", 1, 1);
        printer.printLeftRight("Item", "Total", 1);
        printer.printCustom("--------------------------------", 1, 1);

        // Item Loop:
        for (var item in orderDetailsModel.data!.orderItems!) {
          String itemLine = "${item.itemName} x${item.quantity}";
          String totalPrice = item.totalCurrencyPrice.toString();
          printer.printLeftRight(itemLine, totalPrice, 1);
        }
        printer.printCustom("--------------------------------", 1, 1);

        // Summary Table:
        printer.printLeftRight("Subtotal", "150.00", 1);
        printer.printLeftRight("Discount", "-10.00", 1);
        printer.printLeftRight("Total", "140.00", 1);
        printer.printLeftRight("Paid", "200.00", 1);
        printer.printLeftRight("Change", "60.00", 1);
        printer.printNewLine();

        // Footer:
        printer.printCustom("Thank you!", 2, 1);
        printer.printCustom("Visit Again", 1, 1);
        printer.printNewLine();
        printer.paperCut(); // if supported

        // -----------------[ END - Invoice Design ]---------------------
      } else {
        debugPrint("No data found");
      }
    } else {
      debugPrint("Printer not found");
    }
  }
}
