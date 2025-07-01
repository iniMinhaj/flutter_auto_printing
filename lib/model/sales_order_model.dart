class SalesOrderModel {
  final int? id;
  final String? orderSerialNo;
  final String? orderDatetime;

  SalesOrderModel({this.id, this.orderSerialNo, this.orderDatetime});

  factory SalesOrderModel.fromJson(Map<String, dynamic> json) =>
      SalesOrderModel(
        id: json["id"],
        orderSerialNo: json["order_serial_no"],
        orderDatetime: json["order_datetime"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "order_serial_no": orderSerialNo,
    "order_datetime": orderDatetime,
  };
}
