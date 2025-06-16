import 'package:auto_printing/helper/controller/device_token_controller.dart';
import 'package:auto_printing/helper/controller/usb_printer_controller.dart';
import 'package:auto_printing/helper/notification/model/selectable_printer.dart';
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
    // usbPrinterController.scanDevices(PrinterType.bluetooth);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Auto Printer")),
      body: RefreshIndicator(
        color: primaryColor,
        onRefresh: () async {
          usbPrinterController.scanDevices(PrinterType.usb);
          //usbPrinterController.scanDevices(PrinterType.bluetooth);
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
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
                          child: DropdownButton<SelectablePrinter>(
                            underline: SizedBox(),
                            isExpanded: true,
                            hint: Text("Select Printer"),
                            value:
                                usbPrinterController.devices.contains(
                                      usbPrinterController
                                          .selectedPrinterDevice
                                          .value,
                                    )
                                    ? usbPrinterController
                                        .selectedPrinterDevice
                                        .value
                                    : null,
                            onChanged: (printer) {
                              if (printer != null) {
                                usbPrinterController.selectPrinter(printer);
                              }
                            },
                            items:
                                usbPrinterController.devices.map((printer) {
                                  return DropdownMenuItem(
                                    value: printer,
                                    child: Text(
                                      "${printer.device.name} (${printer.type.name})",
                                    ),
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
                    child: _buildRoleButton(
                      label: "Salesman",
                      roleId: 5,
                      padding: const EdgeInsets.only(left: 16),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildRoleButton(
                      label: "Kitchen",
                      roleId: 10,
                      padding: const EdgeInsets.only(right: 16),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(deviceTokenController.printResponse.value),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton({
    required String label,
    required int roleId,
    required EdgeInsets padding,
  }) {
    return Padding(
      padding: padding,
      child: InkWell(
        onTap: () async {
          final selectedPrinter =
              usbPrinterController.selectedPrinterDevice.value?.device;
          final selectedType =
              usbPrinterController.selectedPrinterDevice.value?.type;

          if (selectedPrinter == null || selectedType == null) {
            return customSnackbar(
              "ERROR",
              "Please select and connect printer first.",
              Colors.red,
            );
          }

          // Check connection before posting
          bool isConnected = await PrinterManager.instance.connect(
            type: selectedType,
            model: UsbPrinterInput(
              name: selectedPrinter.name,
              vendorId: selectedPrinter.vendorId,
              productId: selectedPrinter.productId,
            ),
            // model: BluetoothPrinterInput(
            //   name: selectedPrinter.name,
            //   address: selectedPrinter.address ?? '',
            //   autoConnect: false,
            //   isBle: false,
            // ),
          );

          if (!isConnected) {
            return customSnackbar(
              "ERROR",
              "Printer is not connected. Please connect first.",
              Colors.red,
            );
          }

          final id = await deviceTokenController.getDeviceToken();
          await box.write('roleId', roleId);
          await deviceTokenController.postDeviceToken(
            deviceId: id,
            printRoleId: roleId,
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
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
