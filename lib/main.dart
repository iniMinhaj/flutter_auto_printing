import 'package:auto_printing/helper/controller/usb_printer_controller.dart';
import 'package:auto_printing/helper/notification/notification.dart';
import 'package:auto_printing/view/kitchen_page.dart';
import 'package:auto_printing/view/salesman_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'helper/controller/setting_controller.dart';
import 'helper/controller/show_order_controller.dart';
import 'view/hompage.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  Get.put(ShowOrderController());
  Get.put(SettingController());
  Get.put(UsbPrinterController());
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage.init();

  try {
    final RemoteMessage? remoteMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (remoteMessage != null) {}
    await NotificationHelper.initialize(flutterLocalNotificationsPlugin);
  } catch (e) {
    debugPrint(e.toString());
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(360, 800),
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Auto Printer',
        home: Homepage(),
      ),
    );
  }
}
