import 'dart:convert';

import 'package:auto_printing/model/show_order_model.dart';
import 'package:auto_printing/model/setting_model.dart';
import 'package:auto_printing/util/api_list.dart';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

class SettingRepo {
  Future<Either<String, SettingModel>> getSettings() async {
    try {
      final response = await http.get(Uri.parse(ApiList.settings));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Right(SettingModel.fromJson(data));
      } else {
        return Left(response.body);
      }
    } catch (e) {
      return Left(e.toString());
    }
  }
}
