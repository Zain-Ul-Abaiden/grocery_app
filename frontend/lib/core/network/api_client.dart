import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:grocery_app/core/constants/api_endpoints.dart';

// Provider to manage secure storage instances
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

// Primary network request client provider
final apiClientProvider = Provider<Dio>((ref) {
  final storage = ref.read(secureStorageProvider);
  
  // Dynamically select base URL based on platform running (Android Emulator loopback vs standard host)
  String activeBaseUrl = ApiEndpoints.baseUrl;
  if (!kIsWeb && Platform.isAndroid) {
    activeBaseUrl = ApiEndpoints.emulatorBaseUrl;
  }

  final dio = Dio(
    BaseOptions(
      baseUrl: activeBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      contentType: 'application/json',
    ),
  );

  // Add interceptor to automatically manage JWT authorization headers
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.read(key: "auth_token");
        if (token != null) {
          options.headers["Authorization"] = "Bearer $token";
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        debugPrint("❌ Network Error [${error.response?.statusCode}]: ${error.message}");
        return handler.next(error);
      },
    ),
  );

  return dio;
});
