class ApiEndpoints {
  // Toggle this according to active host
  // Standard Android Emulator maps loopback to 10.0.2.2 instead of localhost
  static const String baseUrl = "http://localhost:8000/api/v1"; 
  static const String emulatorBaseUrl = "http://10.0.2.2:8000/api/v1";

  // Auth endpoints
  static const String login = "/auth/login";
  static const String me = "/auth/me";

  // Catalog endpoints
  static const String categories = "/categories";
  static const String products = "/products";

  // Cart endpoints
  static const String cart = "/cart";
  static const String cartAdd = "/cart/add";
  static const String cartClear = "/cart/clear";
  static const String cartRemove = "/cart/remove";

  // Order endpoints
  static const String orders = "/orders";
  static const String ordersCreate = "/orders/create";
  static const String myOrders = "/orders/my";

  // Admin endpoints
  static const String adminDashboard = "/admin/dashboard";
  static const String adminOrders = "/admin/orders";
}
