// To parse this JSON data, do
//
//     final orderDetailsModel = orderDetailsModelFromJson(jsonString);

import 'dart:convert';

OrderDetailsModel orderDetailsModelFromJson(String str) =>
    OrderDetailsModel.fromJson(json.decode(str));

String orderDetailsModelToJson(OrderDetailsModel data) =>
    json.encode(data.toJson());

class OrderDetailsModel {
  final Data? data;

  OrderDetailsModel({this.data});

  factory OrderDetailsModel.fromJson(Map<String, dynamic> json) =>
      OrderDetailsModel(
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"data": data?.toJson()};
}

class Data {
  final int? id;
  final String? orderSerialNo;
  final dynamic token;
  final String? subtotalCurrencyPrice;
  final String? subtotalWithoutTaxCurrencyPrice;
  final String? discountCurrencyPrice;
  final String? deliveryChargeCurrencyPrice;
  final String? totalCurrencyPrice;
  final String? totalTaxCurrencyPrice;
  final int? orderType;
  final String? orderDatetime;
  final String? orderDate;
  final String? orderTime;
  final String? deliveryDate;
  final String? deliveryTime;
  final int? paymentMethod;
  final int? paymentStatus;
  final int? isAdvanceOrder;
  final int? preparationTime;
  final int? status;
  final String? statusName;
  final dynamic reason;
  final User? user;
  final OrderAddress? orderAddress;
  final Branch? branch;
  final dynamic deliveryBoy;
  final dynamic coupon;
  final Transaction? transaction;
  final List<OrderItem>? orderItems;
  final dynamic posPaymentMethod;
  final dynamic posPaymentNote;

  Data({
    this.id,
    this.orderSerialNo,
    this.token,
    this.subtotalCurrencyPrice,
    this.subtotalWithoutTaxCurrencyPrice,
    this.discountCurrencyPrice,
    this.deliveryChargeCurrencyPrice,
    this.totalCurrencyPrice,
    this.totalTaxCurrencyPrice,
    this.orderType,
    this.orderDatetime,
    this.orderDate,
    this.orderTime,
    this.deliveryDate,
    this.deliveryTime,
    this.paymentMethod,
    this.paymentStatus,
    this.isAdvanceOrder,
    this.preparationTime,
    this.status,
    this.statusName,
    this.reason,
    this.user,
    this.orderAddress,
    this.branch,
    this.deliveryBoy,
    this.coupon,
    this.transaction,
    this.orderItems,
    this.posPaymentMethod,
    this.posPaymentNote,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    orderSerialNo: json["order_serial_no"],
    token: json["token"],
    subtotalCurrencyPrice: json["subtotal_currency_price"],
    subtotalWithoutTaxCurrencyPrice:
        json["subtotal_without_tax_currency_price"],
    discountCurrencyPrice: json["discount_currency_price"],
    deliveryChargeCurrencyPrice: json["delivery_charge_currency_price"],
    totalCurrencyPrice: json["total_currency_price"],
    totalTaxCurrencyPrice: json["total_tax_currency_price"],
    orderType: json["order_type"],
    orderDatetime: json["order_datetime"],
    orderDate: json["order_date"],
    orderTime: json["order_time"],
    deliveryDate: json["delivery_date"],
    deliveryTime: json["delivery_time"],
    paymentMethod: json["payment_method"],
    paymentStatus: json["payment_status"],
    isAdvanceOrder: json["is_advance_order"],
    preparationTime: json["preparation_time"],
    status: json["status"],
    statusName: json["status_name"],
    reason: json["reason"],
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    orderAddress:
        json["order_address"] == null
            ? null
            : OrderAddress.fromJson(json["order_address"]),
    branch: json["branch"] == null ? null : Branch.fromJson(json["branch"]),
    deliveryBoy: json["delivery_boy"],
    coupon: json["coupon"],
    transaction:
        json["transaction"] == null
            ? null
            : Transaction.fromJson(json["transaction"]),
    orderItems:
        json["order_items"] == null
            ? []
            : List<OrderItem>.from(
              json["order_items"]!.map((x) => OrderItem.fromJson(x)),
            ),
    posPaymentMethod: json["pos_payment_method"],
    posPaymentNote: json["pos_payment_note"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "order_serial_no": orderSerialNo,
    "token": token,
    "subtotal_currency_price": subtotalCurrencyPrice,
    "subtotal_without_tax_currency_price": subtotalWithoutTaxCurrencyPrice,
    "discount_currency_price": discountCurrencyPrice,
    "delivery_charge_currency_price": deliveryChargeCurrencyPrice,
    "total_currency_price": totalCurrencyPrice,
    "total_tax_currency_price": totalTaxCurrencyPrice,
    "order_type": orderType,
    "order_datetime": orderDatetime,
    "order_date": orderDate,
    "order_time": orderTime,
    "delivery_date": deliveryDate,
    "delivery_time": deliveryTime,
    "payment_method": paymentMethod,
    "payment_status": paymentStatus,
    "is_advance_order": isAdvanceOrder,
    "preparation_time": preparationTime,
    "status": status,
    "status_name": statusName,
    "reason": reason,
    "user": user?.toJson(),
    "order_address": orderAddress?.toJson(),
    "branch": branch?.toJson(),
    "delivery_boy": deliveryBoy,
    "coupon": coupon,
    "transaction": transaction?.toJson(),
    "order_items":
        orderItems == null
            ? []
            : List<dynamic>.from(orderItems!.map((x) => x.toJson())),
    "pos_payment_method": posPaymentMethod,
    "pos_payment_note": posPaymentNote,
  };
}

class Branch {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? latitude;
  final String? longitude;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? address;
  final int? status;
  final String? thumb;
  final String? cover;

  Branch({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.latitude,
    this.longitude,
    this.city,
    this.state,
    this.zipCode,
    this.address,
    this.status,
    this.thumb,
    this.cover,
  });

  factory Branch.fromJson(Map<String, dynamic> json) => Branch(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    phone: json["phone"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    city: json["city"],
    state: json["state"],
    zipCode: json["zip_code"],
    address: json["address"],
    status: json["status"],
    thumb: json["thumb"],
    cover: json["cover"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "phone": phone,
    "latitude": latitude,
    "longitude": longitude,
    "city": city,
    "state": state,
    "zip_code": zipCode,
    "address": address,
    "status": status,
    "thumb": thumb,
    "cover": cover,
  };
}

class OrderAddress {
  final int? id;
  final int? userId;
  final String? label;
  final String? address;
  final String? apartment;
  final String? latitude;
  final String? longitude;

  OrderAddress({
    this.id,
    this.userId,
    this.label,
    this.address,
    this.apartment,
    this.latitude,
    this.longitude,
  });

  factory OrderAddress.fromJson(Map<String, dynamic> json) => OrderAddress(
    id: json["id"],
    userId: json["user_id"],
    label: json["label"],
    address: json["address"],
    apartment: json["apartment"],
    latitude: json["latitude"],
    longitude: json["longitude"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "label": label,
    "address": address,
    "apartment": apartment,
    "latitude": latitude,
    "longitude": longitude,
  };
}

class OrderItem {
  final int? id;
  final int? orderId;
  final int? branchId;
  final int? itemId;
  final String? itemName;
  final String? itemImage;
  final int? quantity;
  final String? discount;
  final String? price;
  final List<dynamic>? itemVariations;
  final List<dynamic>? itemExtras;
  final String? itemVariationCurrencyTotal;
  final String? itemExtraCurrencyTotal;
  final double? totalConvertPrice;
  final String? totalCurrencyPrice;
  final String? instruction;
  final String? taxType;
  final String? taxRate;
  final String? taxCurrencyRate;
  final String? taxName;
  final String? taxCurrencyAmount;
  final String? totalWithoutTaxCurrencyPrice;

  OrderItem({
    this.id,
    this.orderId,
    this.branchId,
    this.itemId,
    this.itemName,
    this.itemImage,
    this.quantity,
    this.discount,
    this.price,
    this.itemVariations,
    this.itemExtras,
    this.itemVariationCurrencyTotal,
    this.itemExtraCurrencyTotal,
    this.totalConvertPrice,
    this.totalCurrencyPrice,
    this.instruction,
    this.taxType,
    this.taxRate,
    this.taxCurrencyRate,
    this.taxName,
    this.taxCurrencyAmount,
    this.totalWithoutTaxCurrencyPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    id: json["id"],
    orderId: json["order_id"],
    branchId: json["branch_id"],
    itemId: json["item_id"],
    itemName: json["item_name"],
    itemImage: json["item_image"],
    quantity: json["quantity"],
    discount: json["discount"],
    price: json["price"],
    itemVariations:
        json["item_variations"] == null
            ? []
            : List<dynamic>.from(json["item_variations"]!.map((x) => x)),
    itemExtras:
        json["item_extras"] == null
            ? []
            : List<dynamic>.from(json["item_extras"]!.map((x) => x)),
    itemVariationCurrencyTotal: json["item_variation_currency_total"],
    itemExtraCurrencyTotal: json["item_extra_currency_total"],
    totalConvertPrice: json["total_convert_price"]?.toDouble(),
    totalCurrencyPrice: json["total_currency_price"],
    instruction: json["instruction"],
    taxType: json["tax_type"],
    taxRate: json["tax_rate"],
    taxCurrencyRate: json["tax_currency_rate"],
    taxName: json["tax_name"],
    taxCurrencyAmount: json["tax_currency_amount"],
    totalWithoutTaxCurrencyPrice: json["total_without_tax_currency_price"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "order_id": orderId,
    "branch_id": branchId,
    "item_id": itemId,
    "item_name": itemName,
    "item_image": itemImage,
    "quantity": quantity,
    "discount": discount,
    "price": price,
    "item_variations":
        itemVariations == null
            ? []
            : List<dynamic>.from(itemVariations!.map((x) => x)),
    "item_extras":
        itemExtras == null ? [] : List<dynamic>.from(itemExtras!.map((x) => x)),
    "item_variation_currency_total": itemVariationCurrencyTotal,
    "item_extra_currency_total": itemExtraCurrencyTotal,
    "total_convert_price": totalConvertPrice,
    "total_currency_price": totalCurrencyPrice,
    "instruction": instruction,
    "tax_type": taxType,
    "tax_rate": taxRate,
    "tax_currency_rate": taxCurrencyRate,
    "tax_name": taxName,
    "tax_currency_amount": taxCurrencyAmount,
    "total_without_tax_currency_price": totalWithoutTaxCurrencyPrice,
  };
}

class Transaction {
  final int? id;
  final int? orderId;
  final String? orderSerialNo;
  final String? transactionNo;
  final String? amount;
  final String? paymentMethod;
  final String? type;
  final String? sign;
  final String? date;

  Transaction({
    this.id,
    this.orderId,
    this.orderSerialNo,
    this.transactionNo,
    this.amount,
    this.paymentMethod,
    this.type,
    this.sign,
    this.date,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json["id"],
    orderId: json["order_id"],
    orderSerialNo: json["order_serial_no"],
    transactionNo: json["transaction_no"],
    amount: json["amount"],
    paymentMethod: json["payment_method"],
    type: json["type"],
    sign: json["sign"],
    date: json["date"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "order_id": orderId,
    "order_serial_no": orderSerialNo,
    "transaction_no": transactionNo,
    "amount": amount,
    "payment_method": paymentMethod,
    "type": type,
    "sign": sign,
    "date": date,
  };
}

class User {
  final int? id;
  final String? name;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? email;
  final String? username;
  final String? studentId;
  final String? proxId;
  final String? balance;
  final String? currencyBalance;
  final String? diningDollarsBalance;
  final String? currencyDiningDollarsBalance;
  final String? image;
  final int? roleId;
  final String? countryCode;
  final int? order;
  final String? createDate;
  final String? updateDate;

  User({
    this.id,
    this.name,
    this.firstName,
    this.lastName,
    this.phone,
    this.email,
    this.username,
    this.studentId,
    this.proxId,
    this.balance,
    this.currencyBalance,
    this.diningDollarsBalance,
    this.currencyDiningDollarsBalance,
    this.image,
    this.roleId,
    this.countryCode,
    this.order,
    this.createDate,
    this.updateDate,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    name: json["name"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    phone: json["phone"],
    email: json["email"],
    username: json["username"],
    studentId: json["student_id"],
    proxId: json["prox_id"],
    balance: json["balance"],
    currencyBalance: json["currency_balance"],
    diningDollarsBalance: json["dining_dollars_balance"],
    currencyDiningDollarsBalance: json["currency_dining_dollars_balance"],
    image: json["image"],
    roleId: json["role_id"],
    countryCode: json["country_code"],
    order: json["order"],
    createDate: json["create_date"],
    updateDate: json["update_date"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "first_name": firstName,
    "last_name": lastName,
    "phone": phone,
    "email": email,
    "username": username,
    "student_id": studentId,
    "prox_id": proxId,
    "balance": balance,
    "currency_balance": currencyBalance,
    "dining_dollars_balance": diningDollarsBalance,
    "currency_dining_dollars_balance": currencyDiningDollarsBalance,
    "image": image,
    "role_id": roleId,
    "country_code": countryCode,
    "order": order,
    "create_date": createDate,
    "update_date": updateDate,
  };
}
