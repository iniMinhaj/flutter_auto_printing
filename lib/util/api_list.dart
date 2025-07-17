class ApiList {
  static String baseUrl = "https://web.inilabs.dev";
  static String autoPrint = "$baseUrl/api/auto-print";
  static String orderDetails({required String orderId}) =>
      "$baseUrl/api/auto-print/order/$orderId";
  static String salesOrderApi = "$baseUrl/api/auto-print/old-orders";
  static String settings = "$baseUrl/api/auto-print/company";
  static String readyToPickup({required int oderId}) =>
      "$baseUrl/api/auto-print/change-status/$oderId";
}
