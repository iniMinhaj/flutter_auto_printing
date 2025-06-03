import 'package:auto_printing/helper/controller/device_token_controller.dart';
import 'package:auto_printing/helper/controller/usb_printer_controller.dart';
import 'package:auto_printing/widget/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
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
  final usbPrinterController = Get.put(UsbPrinterController());

  @override
  void initState() {
    super.initState();
    usbPrinterController.scanDevices(PrinterType.usb);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Auto Printer")),
      body: RefreshIndicator(
        color: primaryColor,
        onRefresh: () async {
          usbPrinterController.scanDevices(PrinterType.usb);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 80),
            Obx(
              () => Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                        child: DropdownButton<PrinterDevice>(
                          underline: SizedBox(),
                          isExpanded: true,
                          hint: Text("Select Printer"),
                          value: usbPrinterController.selectedUSBDevice.value,
                          onChanged: (device) {
                            usbPrinterController.selectedUSBDevice.value =
                                device;
                          },
                          items:
                              usbPrinterController.devices.map((device) {
                                return DropdownMenuItem(
                                  value: device,
                                  child: Text(device.name),
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
                            if (usbPrinterController
                                    .selectedUSBDevice
                                    .value
                                    ?.name ==
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
                            if (usbPrinterController
                                    .selectedUSBDevice
                                    .value
                                    ?.name ==
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
          ],
        ),
      ),
    );
  }
}
