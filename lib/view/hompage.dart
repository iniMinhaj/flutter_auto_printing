import 'package:auto_printing/helper/controller/auto_printer_controller.dart';
import 'package:auto_printing/helper/controller/device_token_controller.dart';
import 'package:auto_printing/widget/custom_snackbar.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/instance_manager.dart';
import 'package:get_storage/get_storage.dart';

final box = GetStorage();

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final deviceTokenController = Get.put(DeviceTokenController());
  final autoPrintController = Get.put(AutoPrintingController());

  @override
  void initState() {
    super.initState();
    autoPrintController.fetchPairedPrinters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Auto Printing")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(
              () => Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("SELECT PRINTER:"),
                    DropdownButton<BluetoothDevice>(
                      isExpanded: true,
                      hint: Text("Select Printer"),
                      value: autoPrintController.selectedPrinter.value,
                      onChanged: (device) {
                        autoPrintController.selectedPrinter.value = device;
                      },
                      items:
                          autoPrintController.devices.map((device) {
                            return DropdownMenuItem(
                              value: device,
                              child: Text(device.name ?? 'Unknown'),
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 60),

            ElevatedButton(
              onPressed: () async {
                if (autoPrintController.selectedPrinter.value?.name == null) {
                  return customSnackbar(
                    "ERROR",
                    "Please Select Printer First.",
                    Colors.red,
                  );
                }
                final id = await deviceTokenController.getDeviceToken();
                await box.write('roleId', 5);
                await deviceTokenController.postDeviceToken(
                  deviceId: id,
                  printRoleId: 5,
                );
              },
              child: Text("Salesman"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (autoPrintController.selectedPrinter.value?.name == null) {
                  return customSnackbar(
                    "ERROR",
                    "Please Select Printer First.",
                    Colors.red,
                  );
                }
                final id = await deviceTokenController.getDeviceToken();
                await box.write('roleId', 10);
                await deviceTokenController.postDeviceToken(
                  deviceId: id,
                  printRoleId: 10,
                );
              },
              child: Text("Kitchen"),
            ),
          ],
        ),
      ),
    );
  }
}
