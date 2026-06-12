class ApiEndpoints {
  // ── Host configuration ────────────────────────────────────────────────
  // Set this to the PC's current local Wi-Fi IP so a physical phone on the
  // same network can reach the backend. Find it with `ipconfig` (IPv4 Address).
  static const String _host = "192.168.1.37";

  // Base URL used by physical devices / web / desktop.
  static const String baseUrl = "http://$_host:8000/api/v1";

  // Android emulator reaches the host machine via 10.0.2.2. If you test on a
  // physical Android phone instead, change this to the same value as [baseUrl].
  static const String emulatorBaseUrl = "http://$_host:8000/api/v1";

  // Auth endpoints
  static const String login = "/auth/login";
  static const String signup = "/auth/signup";
  static const String me = "/auth/me";

  // Catalog endpoints
  static const String categories = "/categories";
  static const String products = "/products";
  static const String banners = "/banners";

  // Cart endpoints
  static const String cart = "/cart";
  static const String cartAdd = "/cart/add";
  static const String cartClear = "/cart/clear";
  static const String cartRemove = "/cart/remove"; // append /{product_id}
  static const String cartUpdate = "/cart"; // append /{cart_id}

  // Favorites endpoints
  static const String favorites = "/favorites"; // GET, POST; DELETE /{product_id}

  // Order endpoints
  static const String orders = "/orders";
  static const String ordersCreate = "/orders/create";
  static const String myOrders = "/orders/my";

  // Admin endpoints
  static const String adminDashboard = "/admin/dashboard";
  static const String adminOrders = "/admin/orders";
  static const String adminProducts = "/admin/products";
  static const String adminCustomers = "/admin/customers";
  static const String adminOrderStatus = "/admin/orders"; // append /{id}/status
}
