import 'dart:convert';

import 'package:auto_printing/model/show_order_model.dart';
import 'package:auto_printing/util/api_list.dart';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

class ShowOrderRepo {
  Future<Either<String, List<ShowOrderModel>>> getOrderList() async {
    try {
      final response = await http.get(Uri.parse(ApiList.salesOrderApi));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'] as List<dynamic>;
        return Right(data.map((e) => ShowOrderModel.fromJson(e)).toList());
      } else {
        return Left(response.body);
      }
    } catch (e) {
      return Left(e.toString());
    }
  }
}
