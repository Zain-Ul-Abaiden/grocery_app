import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:grocery_app/features/auth/presentation/login_screen.dart';
import 'package:grocery_app/features/auth/presentation/signup_screen.dart';
import 'package:grocery_app/features/main/presentation/main_scaffold.dart';
import 'package:grocery_app/features/products/presentation/product_detail_screen.dart';
import 'package:grocery_app/features/products/presentation/categories_tab.dart';
import 'package:grocery_app/features/orders/presentation/checkout_screen.dart';
import 'package:grocery_app/features/orders/presentation/order_status_screen.dart';
import 'package:grocery_app/features/orders/presentation/my_orders_screen.dart';
import 'package:grocery_app/features/profile/presentation/profile_screen.dart';
import 'package:grocery_app/features/admin/presentation/admin_dashboard_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),

      // Main app shell with bottom navigation tabs.
      GoRoute(path: '/', builder: (context, state) => const MainScaffold()),

      // Pushed (full-screen) routes
      GoRoute(
        path: '/product/:id',
        builder: (context, state) => ProductDetailScreen(productId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/category/:id',
        builder: (context, state) => CategoryProductsScreen(
          categoryId: int.parse(state.pathParameters['id']!),
          categoryName: state.uri.queryParameters['name'] ?? 'Category',
        ),
      ),
      GoRoute(path: '/checkout', builder: (context, state) => const CheckoutScreen()),
      GoRoute(
        path: '/order-status/:id',
        builder: (context, state) => OrderStatusScreen(orderId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/my-orders', builder: (context, state) => const MyOrdersScreen()),
      GoRoute(path: '/profile-details', builder: (context, state) => const ProfileDetailsScreen()),
      GoRoute(path: '/addresses', builder: (context, state) => const AddressesScreen()),
      GoRoute(path: '/terms', builder: (context, state) => const TermsScreen()),
      GoRoute(path: '/privacy', builder: (context, state) => const PrivacyScreen()),
      GoRoute(path: '/admin', builder: (context, state) => const AdminDashboardScreen()),
    ],
  );
});
