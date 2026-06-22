class ApiEndpoints {
  // ── Host configuration ────────────────────────────────────────────────
  // Set this to the PC's current local Wi-Fi IP so a physical phone on the
  // same network can reach the backend. Find it with `ipconfig` (IPv4 Address).
  static const String _host = "192.168.1.33";

  // Base URL used by web / desktop running on the SAME machine as the backend.
  // localhost is the most reliable here (loopback — no firewall/network needed).
  static const String baseUrl = "http://localhost:8000/api/v1";

  // Used by physical Android phones. Tethered over USB with
  // `adb reverse tcp:8000 tcp:8000`, localhost on the phone tunnels to the PC's
  // backend (no firewall/Wi-Fi needed). For a standalone Wi-Fi APK instead, set
  // this to "http://$_host:8000/api/v1" and add the firewall rule for TCP 8000.
  static const String emulatorBaseUrl = "http://localhost:8000/api/v1";

  // Auth endpoints
  static const String login = "/auth/login";
  static const String signup = "/auth/signup";
  static const String me = "/auth/me";
  static const String updatePassword = "/auth/update-password";
  static const String forgotPassword = "/auth/forgot-password";
  static const String updateProfile = "/auth/update-profile";
  static const String deleteAccount = "/auth/me";

  // Catalog endpoints
  static const String categories = "/categories";
  static const String products = "/products";
  static const String banners = "/banners";
  static const String home = "/home";

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
