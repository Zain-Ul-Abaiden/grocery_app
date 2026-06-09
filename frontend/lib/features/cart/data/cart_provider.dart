import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_app/core/constants/api_endpoints.dart';
import 'package:grocery_app/core/network/api_client.dart';
import 'package:grocery_app/shared/models/cart_model.dart';
import 'package:grocery_app/features/auth/data/auth_provider.dart';

class CartState {
  final CartSummaryModel? summary;
  final bool isLoading;
  final String? errorMessage;

  CartState({
    this.summary,
    this.isLoading = false,
    this.errorMessage,
  });

  CartState copyWith({
    CartSummaryModel? summary,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CartState(
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class CartNotifier extends StateNotifier<CartState> {
  final Dio _dio;
  final Ref _ref;

  CartNotifier(this._dio, this._ref) : super(CartState()) {
    // Automatically load cart when user logs in successfully
    _ref.listen(authProvider, (previous, next) {
      if (next.isAuthenticated) {
        fetchCart();
      } else {
        state = CartState(); // Reset cart on logout
      }
    });
  }

  Future<void> fetchCart() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _dio.get(ApiEndpoints.cart);
      final summary = CartSummaryModel.fromJson(response.data as Map<String, dynamic>);
      state = CartState(summary: summary, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: "Failed to load shopping cart.");
    }
  }

  Future<bool> addToCart(String productId, int quantity) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.cartAdd,
        data: {
          "product_id": productId,
          "quantity": quantity,
        },
      );
      if (response.statusCode == 200) {
        await fetchCart(); // Refresh cart summary
        return true;
      }
      return false;
    } on DioException catch (e) {
      final message = e.response?.data["detail"] ?? "Insufficient stock.";
      state = state.copyWith(errorMessage: message.toString());
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> updateQuantity(int cartId, int quantity) async {
    try {
      final response = await _dio.put(
        "${ApiEndpoints.cart}/$cartId",
        data: {
          "quantity": quantity,
        },
      );
      if (response.statusCode == 200) {
        await fetchCart();
      }
    } on DioException catch (e) {
      final message = e.response?.data["detail"] ?? "Stock limit reached.";
      state = state.copyWith(errorMessage: message.toString());
    }
  }

  Future<void> removeFromCart(String productId) async {
    try {
      final response = await _dio.delete("${ApiEndpoints.cartRemove}/$productId");
      if (response.statusCode == 204) {
        await fetchCart();
      }
    } catch (e) {
      state = state.copyWith(errorMessage: "Failed to remove item.");
    }
  }

  Future<void> clearCart() async {
    try {
      final response = await _dio.delete(ApiEndpoints.cartClear);
      if (response.statusCode == 204) {
        state = CartState(summary: CartSummaryModel(items: [], totalPrice: 0.0));
      }
    } catch (e) {
      state = state.copyWith(errorMessage: "Failed to clear cart.");
    }
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  final dio = ref.watch(apiClientProvider);
  return CartNotifier(dio, ref);
});
