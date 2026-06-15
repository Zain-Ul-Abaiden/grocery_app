import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_app/core/constants/api_endpoints.dart';
import 'package:grocery_app/core/network/api_client.dart';
import 'package:grocery_app/shared/models/user_model.dart';

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? errorMessage;
  final bool isAuthenticated;

  AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? errorMessage,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Dio _dio;
  final Ref _ref;

  AuthNotifier(this._dio, this._ref) : super(AuthState()) {
    checkSession();
  }

  Future<void> checkSession() async {
    final storage = _ref.read(secureStorageProvider);
    final token = await storage.read(key: "auth_token");
    if (token == null) {
      state = state.copyWith(isAuthenticated: false);
      return;
    }

    try {
      final response = await _dio.get(ApiEndpoints.me);
      if (response.statusCode == 200) {
        final user = UserModel.fromJson(response.data as Map<String, dynamic>);
        state = AuthState(user: user, isAuthenticated: true);
      } else {
        await storage.delete(key: "auth_token");
        state = AuthState(isAuthenticated: false);
      }
    } catch (e) {
      // Offline fallback or failed verification
      state = state.copyWith(isAuthenticated: false);
    }
  }

  Future<bool> login(String phone, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {
          "phone": phone,
          "password": password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final token = data["access_token"] as String;
        final user = UserModel.fromJson(data["user"] as Map<String, dynamic>);

        final storage = _ref.read(secureStorageProvider);
        await storage.write(key: "auth_token", value: token);

        state = AuthState(user: user, isAuthenticated: true);
        return true;
      }
      return false;
    } on DioException catch (e) {
      final message = e.response?.data["detail"] ?? "Server Error. Try again.";
      state = state.copyWith(isLoading: false, errorMessage: message.toString());
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: "An unexpected error occurred.");
      return false;
    }
  }

  Future<bool> signup(String phone, String name, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _dio.post(
        ApiEndpoints.signup,
        data: {
          "phone": phone,
          "name": name,
          "password": password,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        final token = data["access_token"] as String;
        final user = UserModel.fromJson(data["user"] as Map<String, dynamic>);

        final storage = _ref.read(secureStorageProvider);
        await storage.write(key: "auth_token", value: token);

        state = AuthState(user: user, isAuthenticated: true);
        return true;
      }
      return false;
    } on DioException catch (e) {
      final message = e.response?.data["detail"] ?? "Server Error. Try again.";
      state = state.copyWith(isLoading: false, errorMessage: message.toString());
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: "An unexpected error occurred.");
      return false;
    }
  }

  /// Update the logged-in user's password directly.
  Future<bool> updatePassword(String newPassword) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.updatePassword,
        data: {"new_password": newPassword},
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      state = state.copyWith(
        errorMessage: e.response?.data["detail"]?.toString() ?? "Failed to update password.",
      );
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Reset password by phone number (no OTP — simple flow).
  Future<bool> forgotPassword(String phone, String newPassword) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.forgotPassword,
        data: {"phone": phone, "new_password": newPassword},
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      state = state.copyWith(
        errorMessage: e.response?.data["detail"]?.toString() ?? "Failed to reset password.",
      );
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Update the logged-in user's name and/or saved address.
  Future<bool> updateProfile({String? name, String? address}) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.updateProfile,
        data: {
          if (name != null) "name": name,
          if (address != null) "address": address,
        },
      );
      if (response.statusCode == 200) {
        final user = UserModel.fromJson(response.data as Map<String, dynamic>);
        state = state.copyWith(user: user);
        return true;
      }
      return false;
    } on DioException catch (e) {
      state = state.copyWith(
        errorMessage: e.response?.data["detail"]?.toString() ?? "Failed to update profile.",
      );
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Permanently delete the account and log out.
  Future<bool> deleteAccount() async {
    try {
      final response = await _dio.delete(ApiEndpoints.deleteAccount);
      if (response.statusCode == 204) {
        final storage = _ref.read(secureStorageProvider);
        await storage.delete(key: "auth_token");
        state = AuthState(isAuthenticated: false);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    final storage = _ref.read(secureStorageProvider);
    await storage.delete(key: "auth_token");
    state = AuthState(isAuthenticated: false);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final dio = ref.watch(apiClientProvider);
  return AuthNotifier(dio, ref);
});
