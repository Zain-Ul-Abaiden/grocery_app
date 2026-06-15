import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_app/core/constants/api_endpoints.dart';
import 'package:grocery_app/core/network/api_client.dart';
import 'package:grocery_app/shared/models/order_model.dart';
import 'package:grocery_app/features/cart/data/cart_provider.dart';

class OrderNotifier extends StateNotifier<AsyncValue<List<OrderModel>>> {
  final Dio _dio;
  final Ref _ref;

  OrderNotifier(this._dio, this._ref) : super(const AsyncValue.loading());

  Future<void> fetchMyOrders() async {
    state = const AsyncValue.loading();
    try {
      final response = await _dio.get(ApiEndpoints.myOrders);
      final list = response.data as List<dynamic>;
      final orders = list.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
      state = AsyncValue.data(orders);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<OrderModel?> createOrder(String address, String phone) async {
    try {
      final cartItems = _ref.read(cartProvider).summary?.items ?? [];
      final payloadItems = cartItems.map((e) => {
        "product_id": e.product.id,
        "quantity": e.quantity,
      }).toList();

      final response = await _dio.post(
        ApiEndpoints.ordersCreate,
        data: {
          "delivery_address": address,
          "contact_phone": phone,
          "items": payloadItems,
        },
      );
      if (response.statusCode == 201) {
        final order = OrderModel.fromJson(response.data as Map<String, dynamic>);

        // Refresh cart states (backend clears the cart on order creation)
        _ref.read(cartProvider.notifier).fetchCart();
        // Refresh order history
        fetchMyOrders();
        // Refresh the active-order providers (home bar + notification tab)
        _ref.invalidate(activeOrderProvider);
        _ref.invalidate(activeOrdersProvider);

        return order;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

final orderNotifierProvider = StateNotifierProvider<OrderNotifier, AsyncValue<List<OrderModel>>>((ref) {
  final dio = ref.watch(apiClientProvider);
  return OrderNotifier(dio, ref);
});

// IDs of order-notifications the user has already viewed. Used to compute the
// unread badge count on the Notification tab.
final readNotificationsProvider = StateProvider<Set<String>>((ref) => {});

// All active (not delivered/cancelled) orders — powers the Notification tab.
final activeOrdersProvider = FutureProvider.autoDispose<List<OrderModel>>((ref) async {
  final dio = ref.watch(apiClientProvider);
  try {
    final response = await dio.get(ApiEndpoints.myOrders);
    final list = response.data as List<dynamic>;
    final orders = list.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
    return orders.where((o) {
      final s = o.status.toLowerCase();
      return s != 'delivered' && s != 'cancelled';
    }).toList();
  } catch (_) {
    return [];
  }
});

// Latest active (not delivered/cancelled) order — powers the home tracking bar.
final activeOrderProvider = FutureProvider.autoDispose<OrderModel?>((ref) async {
  final dio = ref.watch(apiClientProvider);
  try {
    final response = await dio.get(ApiEndpoints.myOrders);
    final list = response.data as List<dynamic>;
    final orders = list.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
    for (final o in orders) {
      final s = o.status.toLowerCase();
      if (s != 'delivered' && s != 'cancelled') return o;
    }
    return null;
  } catch (_) {
    return null;
  }
});

// Single order details family provider
final orderDetailsProvider = FutureProvider.family<OrderModel, String>((ref, orderId) async {
  final dio = ref.watch(apiClientProvider);
  final response = await dio.get("${ApiEndpoints.orders}/$orderId");
  return OrderModel.fromJson(response.data as Map<String, dynamic>);
});

// --- Admin Section Providers ---

// Admin dashboard summary provider
final adminDashboardStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final dio = ref.watch(apiClientProvider);
  final response = await dio.get(ApiEndpoints.adminDashboard);
  return response.data["stats"] as Map<String, dynamic>;
});

// Admin orders fetcher
final adminOrdersProvider = FutureProvider<List<OrderModel>>((ref) async {
  final dio = ref.watch(apiClientProvider);
  final response = await dio.get(ApiEndpoints.adminOrders);
  final list = response.data as List<dynamic>;
  return list.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
});

// Admin order status update provider
final adminStatusUpdateProvider = Provider((ref) {
  final dio = ref.watch(apiClientProvider);
  
  return (String orderId, String status) async {
    final response = await dio.put(
      "${ApiEndpoints.adminOrders}/$orderId/status",
      data: {
        "status": status,
      },
    );
    if (response.statusCode == 200) {
      ref.invalidate(adminOrdersProvider);
      ref.invalidate(adminDashboardStatsProvider);
      return true;
    }
    return false;
  };
});
