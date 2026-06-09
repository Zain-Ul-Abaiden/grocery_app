import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:grocery_app/features/auth/presentation/login_screen.dart';
import 'package:grocery_app/features/products/presentation/home_screen.dart';
import 'package:grocery_app/features/products/presentation/product_detail_screen.dart';
import 'package:grocery_app/features/cart/presentation/cart_screen.dart';
import 'package:grocery_app/features/orders/presentation/checkout_screen.dart';
import 'package:grocery_app/features/orders/presentation/order_status_screen.dart';
import 'package:grocery_app/features/admin/presentation/admin_dashboard_screen.dart';
import 'package:grocery_app/core/network/api_client.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) {
          final productId = state.pathParameters['id']!;
          return ProductDetailScreen(productId: productId);
        },
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/order-status/:id',
        builder: (context, state) {
          final orderId = state.pathParameters['id']!;
          return OrderStatusScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
    ],
  );
});
