import 'package:auto_printing/data/dummy_data.dart';
import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';

class PaymentSuccess extends StatefulWidget {
  const PaymentSuccess({super.key});

  @override
  State<PaymentSuccess> createState() => _PaymentSuccessState();
}

class _PaymentSuccessState extends State<PaymentSuccess> {
  final BlueThermalPrinter printer = BlueThermalPrinter.instance;
  List printList = [];

  Future<List<BluetoothDevice>> connectAndPrint({
    required String modelName,
  }) async {
    List<BluetoothDevice> devices = await printer.getBondedDevices();

    BluetoothDevice? myPrinter = devices.firstWhere(
      (d) => d.name != null && d.name!.contains(modelName),

      orElse: () {
        final error = BluetoothDevice(null, null);
        return error;
      },
    );

    print("Connected Device: ${myPrinter.name}");

    if (myPrinter.name != null) {
      bool isConnected = await printer.isConnected ?? false;

      if (!isConnected) {
        await printer.connect(myPrinter);
      } else {
        print("Already connected to a printer");
      }

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
      for (var item in items) {
        String itemLine = "${item.name} x${item.qty}";
        String totalPrice = item.total.toStringAsFixed(2);
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
      print("Printer not found");
    }

    return devices;
  }

  initPrinter() async {
    await connectAndPrint(modelName: 'PT-210');
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await initPrinter();
    });
    return Scaffold(appBar: AppBar(title: Text("Payment Successful")));
  }
}
