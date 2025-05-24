import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

final postToken = 'https://web.inilabs.dev/api/frontend/device-token/mobile';
final licenseCode = "t8l57bk3-k4d6-48z9-3331-h708j46098r124";
final authorizationToken =
    "Bearer 7|CrvNC3KgLNC4I1wLZTOQGSRztZaqOWGkbv5Or3oV6bd4b0ed";

class DeviceTokenController extends GetxController {
  bool loader = false;
  Future postDeviceToken(token) async {
    loader = true;
    update();
    Map body = {'token': token};
    // String jsonBody = json.encode(body);
    try {
      http
          .post(
            Uri.parse(postToken),
            body: jsonEncode({'token': token}),
            headers: _getHttpHeaders(),
          )
          .then((response) {
            print(response.body);
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
    headers['Authorization'] = authorizationToken;
    headers['x-api-key'] = licenseCode;
    headers['Content-Type'] = 'application/json';
    headers['Accept'] = 'application/json';

    return headers;
  }
}
