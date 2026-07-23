class ShowOrderModel {
  final int? id;
  final String? orderSerialNo;
  final String? orderDatetime;
  final int? orderStatus;

  ShowOrderModel({
    this.id,
    this.orderSerialNo,
    this.orderDatetime,
    this.orderStatus,
  });

  factory ShowOrderModel.fromJson(Map<String, dynamic> json) => ShowOrderModel(
    id: json["id"],
    orderSerialNo: json["order_serial_no"],
    orderDatetime: json["order_datetime"],
    orderStatus: json["order_status"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "order_serial_no": orderSerialNo,
    "order_datetime": orderDatetime,
  };
}
