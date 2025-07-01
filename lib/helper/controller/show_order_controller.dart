import 'package:auto_printing/data/repository/sales_order_repo.dart';
import 'package:auto_printing/model/sales_order_model.dart';
import 'package:get/get.dart';

class ShowOrderController extends GetxController {
  final SalesOrderRepo _salesOrderRepo = SalesOrderRepo();
  final salesOrderList = <SalesOrderModel>[].obs;

  Future<void> getSalesOrderList() async {
    final result = await _salesOrderRepo.getSalesOrderList();
    result.fold((error) {}, (orders) {
      salesOrderList.value = orders;
    });
  }
}
