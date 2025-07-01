import 'package:auto_printing/view/hompage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../helper/controller/setting_controller.dart';
import '../helper/controller/show_order_controller.dart';
import '../helper/controller/usb_printer_controller.dart';

class KitchenPage extends StatefulWidget {
  const KitchenPage({super.key});

  @override
  State<KitchenPage> createState() => _KitchenPageState();
}

class _KitchenPageState extends State<KitchenPage> {
  final showOrderController = Get.find<ShowOrderController>();
  final settingController = Get.find<SettingController>();
  final usbPrinterController = Get.find<UsbPrinterController>();
  @override
  void initState() {
    showOrderController.getSalesOrderList();
    settingController.getSettings();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 24.h),
          Obx(
            () => Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                settingController.settingModel.value.data?.companyName ?? "",
                style: GoogleFonts.rubik(
                  fontSize: 16.sp,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Image.asset("assets/order_icon.jpeg", height: 80.h),
          SizedBox(height: 16.h),
          Expanded(
            child: Obx(
              () => ListView.builder(
                shrinkWrap: true,
                itemCount: showOrderController.salesOrderList.length,
                itemBuilder: (context, index) {
                  final order = showOrderController.salesOrderList;
                  return Padding(
                    padding: EdgeInsets.all(8.r),
                    child: Container(
                      height: 60.h,
                      width: double.infinity,

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: GestureDetector(
                        onTap: () async {
                          await usbPrinterController.fetchOrderDetails(
                            orderId: order[index].id.toString(),
                          );

                          await usbPrinterController.connectDeviceAndPrint();
                        },
                        child: Padding(
                          padding: EdgeInsets.all(8.r),
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "#${order[index].orderSerialNo.toString()}",
                                    style: GoogleFonts.rubik(
                                      fontSize: 14.sp,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(order[index].orderDatetime.toString()),
                                ],
                              ),
                              Positioned(
                                top: 4.h,
                                right: 0.w,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 4.h,
                                    ),
                                    child: Text(
                                      'Print',
                                      style: GoogleFonts.rubik(
                                        fontSize: 14.sp,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
