import 'package:auto_printing/helper/controller/auto_printer_controller.dart';
import 'package:auto_printing/helper/controller/device_token_controller.dart';
import 'package:auto_printing/widget/custom_snackbar.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/instance_manager.dart';
import 'package:get_storage/get_storage.dart';

final box = GetStorage();
const primaryColor = Color.fromRGBO(0, 179, 165, 1.0);

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
      appBar: AppBar(title: Text("Auto Printer")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 80),
          Obx(
            () => Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Text("SELECT PRINTER:"),
                  Container(
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      //   border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12.withAlpha(10),
                          blurRadius: 2,
                          spreadRadius: .5,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButton<BluetoothDevice>(
                        underline: SizedBox(),
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
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 60),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: InkWell(
                        onTap: () async {
                          if (autoPrintController.selectedPrinter.value?.name ==
                              null) {
                            return customSnackbar(
                              "ERROR",
                              "Please Select Printer First.",
                              Colors.red,
                            );
                          }
                          final id =
                              await deviceTokenController.getDeviceToken();
                          await box.write('roleId', 5);
                          await deviceTokenController.postDeviceToken(
                            deviceId: id,
                            printRoleId: 5,
                          );
                        },
                        child: Ink(
                          height: 56,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              "Salesman",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16),

              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: InkWell(
                        onTap: () async {
                          if (autoPrintController.selectedPrinter.value?.name ==
                              null) {
                            return customSnackbar(
                              "ERROR",
                              "Please Select Printer First.",
                              Colors.red,
                            );
                          }
                          final id =
                              await deviceTokenController.getDeviceToken();
                          await box.write('roleId', 10);
                          await deviceTokenController.postDeviceToken(
                            deviceId: id,
                            printRoleId: 10,
                          );
                        },
                        child: Ink(
                          height: 56,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              "Kitchen",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ElevatedButton(
          //   onPressed: () async {
          //     if (autoPrintController.selectedPrinter.value?.name == null) {
          //       return customSnackbar(
          //         "ERROR",
          //         "Please Select Printer First.",
          //         Colors.red,
          //       );
          //     }
          //     final id = await deviceTokenController.getDeviceToken();
          //     await box.write('roleId', 5);
          //     await deviceTokenController.postDeviceToken(
          //       deviceId: id,
          //       printRoleId: 5,
          //     );
          //   },
          //   child: Text("Salesman"),
          // ),
          // ElevatedButton(
          //   onPressed: () async {
          //     if (autoPrintController.selectedPrinter.value?.name == null) {
          //       return customSnackbar(
          //         "ERROR",
          //         "Please Select Printer First.",
          //         Colors.red,
          //       );
          //     }
          //     final id = await deviceTokenController.getDeviceToken();
          //     await box.write('roleId', 10);
          //     await deviceTokenController.postDeviceToken(
          //       deviceId: id,
          //       printRoleId: 10,
          //     );
          //   },
          //   child: Text("Kitchen"),
          // ),
        ],
      ),
    );
  }
}
