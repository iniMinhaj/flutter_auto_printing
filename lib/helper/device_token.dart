import 'package:auto_printing/helper/controller/device_token_controller.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

class DeviceToken {
  Future<String?> getDeviceToken() async {
    String? deviceToken = '@';
    try {
      deviceToken = await FirebaseMessaging.instance.getToken();
    } catch (e) {
      print(e.toString());
    }
    if (deviceToken != null) {
      debugPrint('--------Device Token---------- ' + deviceToken);

      await Get.put(DeviceTokenController()).postDeviceToken(deviceToken);
    }
    return deviceToken;
  }
}
