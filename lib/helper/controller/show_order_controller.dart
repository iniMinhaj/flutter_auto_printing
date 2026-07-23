import 'dart:convert';

import 'package:auto_printing/data/repository/sales_order_repo.dart';
import 'package:auto_printing/model/show_order_model.dart';
import 'package:auto_printing/util/api_list.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../view/hompage.dart';

class ShowOrderController extends GetxController {
  final ShowOrderRepo _showOrderRepo = ShowOrderRepo();
  final orderList = <ShowOrderModel>[].obs;

  Future<void> getOrderList() async {
    final result = await _showOrderRepo.getOrderList();
    result.fold((error) {}, (orders) {
      orderList.value = orders;
    });
  }

  Future<bool> readyToPickup({required int orderId}) async {
    final response = await http.post(
      Uri.parse(ApiList.readyToPickup(oderId: orderId)),
      headers: {'Content-Type': 'application/json'},
    );

    print('response: ${response.body}');
    print('status code: ${response.statusCode}');

    if (response.statusCode == 200) {
      final orderStatus = jsonDecode(response.body)['data']['order_status'];

      // Handle the response data as needed
      box.write('orderStatus', orderStatus);
      return true;
    } else {
      // Handle error
      throw Exception('Failed to update order status');
    }
  }
}
