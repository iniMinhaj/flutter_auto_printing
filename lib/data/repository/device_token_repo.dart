import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class DeviceTokenRepo {
  Future<String?> getDeviceToken() async {
    String? deviceToken = '@';
    try {
      deviceToken = await FirebaseMessaging.instance.getToken();
    } catch (e) {
      debugPrint(e.toString());
    }
    if (deviceToken != null) {
      debugPrint('--------Device Token---------- $deviceToken');
    }
    return deviceToken;
  }
}
