// ignore_for_file: empty_catches, unnecessary_new, prefer_const_constructors, no_leading_underscores_for_local_identifiers, depend_on_referenced_packages, unnecessary_null_comparison, avoid_print, unused_local_variable

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:auto_printing/helper/controller/usb_printer_controller.dart';
import 'package:auto_printing/helper/notification/model/notification_body.dart';
import 'package:auto_printing/view/hompage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../widget/custom_snackbar.dart';

final usbPrinterController = Get.put(UsbPrinterController());

class NotificationHelper {
  void notificationPermission() async {
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    NotificationSettings settings = await FirebaseMessaging.instance
        .requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint("User granted permission");
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint("User granted provisional permission");
    } else {
      debugPrint("User denied permission");
    }
  }

  static Future<void> initialize(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  ) async {
    var androidInitialize = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    var iOSInitialize = new DarwinInitializationSettings();
    var initializationsSettings = new InitializationSettings(
      android: androidInitialize,
      iOS: iOSInitialize,
    );

    flutterLocalNotificationsPlugin.initialize(
      initializationsSettings,
      onDidReceiveNotificationResponse: (payload) async {},
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      NotificationHelper.showNotification(
        message,
        flutterLocalNotificationsPlugin,
        false,
      );

      print('🔥 [onMessage] Received a notification');
      await customSnackbar("Success", "Received a notification", primaryColor);
      print("📦 Message Body: ${message.notification?.body}");
      print("📨 Full Message: ${message.toMap()}");

      if (message.notification?.body != null) {
        final orderId = message.notification!.body!;
        print("🧾 Order ID received: $orderId");

        print("📥 Fetching order details...");
        await usbPrinterController.fetchOrderDetails(orderId: orderId);

        final selectedPrinter =
            usbPrinterController.selectedPrinterDevice.value?.device;
        final selectedType =
            usbPrinterController.selectedPrinterDevice.value?.type;

        print("🖨️ Selected Printer: $selectedPrinter");
        print("🧭 Printer Type: $selectedType");

        if (selectedPrinter == null || selectedType == null) {
          await customSnackbar("ERROR", "No printer was selected", Colors.red);
          return;
        }

        print("🖨️ Auto Printing started...");
        await usbPrinterController.connectDeviceAndPrint();
      } else {
        print("⚠️ No valid notification body found.");
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? message) async {
      print('Full Message: ${message!.toMap()}');

      if (message != null) {
        print("Auto Printing started onMessageOpenedApp.....");
      } else {
        print("kichu pai nai...");
      }
    });
  }

  static Future<void> showNotification(
    RemoteMessage message,
    FlutterLocalNotificationsPlugin fln,
    bool data,
  ) async {
    if (!GetPlatform.isIOS) {
      String? _title;
      String? _body;
      String? _image;
      String playLoad = jsonEncode(message.data);
      if (data) {
        _title = message.data['title'];
        _body = message.data['body'];
        _image =
            (message.data['image'] != null && message.data['image'].isNotEmpty)
                ? message.data['image']
                : null;
      } else {
        _title = message.notification!.title;
        _body = message.notification!.body;
        _image =
            (message.data['image'] != null && message.data['image'].isNotEmpty)
                ? message.data['image']
                : null;
        if (GetPlatform.isAndroid) {
          _image =
              (message.notification!.android!.imageUrl != null &&
                      message.notification!.android!.imageUrl!.isNotEmpty)
                  ? message.notification!.android!.imageUrl!.startsWith('http')
                      ? message.notification!.android!.imageUrl
                      : message.data['image']
                  : null;
        } else if (GetPlatform.isIOS) {
          _image =
              (message.notification!.apple!.imageUrl != null &&
                      message.notification!.apple!.imageUrl!.isNotEmpty)
                  ? message.notification!.apple!.imageUrl!.startsWith('http')
                      ? message.notification!.apple!.imageUrl
                      : message.data['image']
                  : null;
        }
      }

      if (_image != null && _image.isNotEmpty) {
        try {
          await showBigPictureNotificationHiddenLargeIcon(
            _title!,
            _body!,
            playLoad,
            _image,
            fln,
          );
        } catch (e) {
          await showBigTextNotification(_title!, _body!, playLoad, '', fln);
        }
      } else {
        await showBigTextNotification(_title!, _body!, playLoad, '', fln);
      }
    }
  }

  static Future<void> showBigTextNotification(
    String title,
    String body,
    String payload,
    String image,
    FlutterLocalNotificationsPlugin fln,
  ) async {
    BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
      body,
      htmlFormatBigText: true,
      contentTitle: title,
      htmlFormatContentTitle: true,
    );

    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          Random.secure().nextInt(10000).toString(),
          'High Importance Notifications',
          importance: Importance.max,
          priority: Priority.max,
        );
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await fln.show(1, title, body, platformChannelSpecifics, payload: payload);
  }

  static Future<void> showBigPictureNotificationHiddenLargeIcon(
    String title,
    String body,
    String payload,
    String image,
    FlutterLocalNotificationsPlugin fln,
  ) async {
    final String largeIconPath = await _downloadAndSaveFile(image, 'largeIcon');
    final String bigPicturePath = await _downloadAndSaveFile(
      image,
      'bigPicture',
    );
    final BigPictureStyleInformation bigPictureStyleInformation =
        BigPictureStyleInformation(
          FilePathAndroidBitmap(bigPicturePath),
          hideExpandedLargeIcon: true,
          contentTitle: title,
          htmlFormatContentTitle: true,
          summaryText: body,
          htmlFormatSummaryText: true,
        );

    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          Random.secure().nextInt(10000).toString(),
          'High Importance Notifications',
          importance: Importance.max,
          priority: Priority.max,
          largeIcon: FilePathAndroidBitmap(largeIconPath),
          styleInformation: bigPictureStyleInformation,
        );
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await fln.show(1, title, body, platformChannelSpecifics, payload: payload);
  }

  static NotificationBody convertNotification(Map<String, dynamic> data) {
    return NotificationBody.fromJson(data);
  }

  static Future<String> _downloadAndSaveFile(
    String url,
    String fileName,
  ) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }
}

Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
  var androidInitialize = new AndroidInitializationSettings(
    'notification_icon',
  );
  var iOSInitialize = new DarwinInitializationSettings();
  var initializationsSettings = new InitializationSettings(
    android: androidInitialize,
    iOS: iOSInitialize,
  );
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  flutterLocalNotificationsPlugin.initialize(initializationsSettings);
  NotificationHelper.showNotification(
    message,
    flutterLocalNotificationsPlugin,
    true,
  );
}
