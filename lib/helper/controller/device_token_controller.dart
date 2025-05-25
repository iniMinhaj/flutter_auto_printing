import 'dart:convert';

import 'package:auto_printing/data/repository/device_token_repo.dart';
import 'package:auto_printing/util/api_list.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

final postToken = 'https://web.inilabs.dev/api/frontend/device-token/mobile';
final licenseCode = "t8l57bk3-k4d6-48z9-3331-h708j46098r124";
final authorizationToken =
    "Bearer 7|CrvNC3KgLNC4I1wLZTOQGSRztZaqOWGkbv5Or3oV6bd4b0ed";

class DeviceTokenController extends GetxController {
  final tokenRepo = DeviceTokenRepo();
  bool loader = false;

  Future<String> getDeviceToken() async {
    final deviceId = await tokenRepo.getDeviceToken() ?? "";
    return deviceId;
  }

  Future postDeviceToken({
    required String deviceId,
    required int printRoleId,
  }) async {
    loader = true;
    update();
    Map<String, dynamic> body = {
      'device_id': deviceId,
      'print_role_id': printRoleId,
    };
    try {
      print("Auto Print Body: ${jsonEncode(body)}");
      http
          .post(
            Uri.parse(ApiList.autoPrint),
            body: jsonEncode(body),
            headers: _getHttpHeaders(),
          )
          .then((response) {
            print('Submit Token status: ${response.statusCode}');
            if (response.statusCode == 200) {
              print(response.body);
              loader = false;
              update();
            } else {
              loader = false;
              update();
            }
          });
    } catch (e) {
      debugPrint(e.toString());
      loader = false;
      update();
    }
    loader = false;
    update();
  }

  static Map<String, String> _getHttpHeaders() {
    Map<String, String> headers = <String, String>{};
    // headers['Authorization'] = authorizationToken;
    headers['x-api-key'] = ApiList.licenseCode.toString();
    headers['content-type'] = 'application/json';

    return headers;
  }
}
