class ApiList {
  static String baseUrl = "https://web.inilabs.dev";
  static String licenseCode = "t8l57bk3-k4d6-48z9-3331-h708j46098r124";
  static String autoPrint = "$baseUrl/api/auto-print";
  static String orderDetails({required String orderId}) =>
      "$baseUrl/api/auto-print/order/$orderId";
}
