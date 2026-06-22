import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_app/core/constants/api_endpoints.dart';
import 'package:grocery_app/core/network/api_client.dart';
import 'package:grocery_app/shared/models/product_model.dart';
import 'package:grocery_app/shared/models/home_model.dart';

// Provider to fetch categories
final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final dio = ref.watch(apiClientProvider);
  final response = await dio.get(ApiEndpoints.categories);
  final list = response.data as List<dynamic>;
  return list.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
});

// Composed home feed (banners, categories, bestsellers, featured, deals, sections)
final homeProvider = FutureProvider<HomeData>((ref) async {
  final dio = ref.watch(apiClientProvider);
  final response = await dio.get(ApiEndpoints.home);
  return HomeData.fromJson(response.data as Map<String, dynamic>);
});

// Dedicated search results for the search screen. Kept separate from
// `productsProvider` so search does not clobber the Categories tab state.
final searchProvider = FutureProvider.family<List<ProductModel>, String>((ref, query) async {
  final trimmed = query.trim();
  if (trimmed.isEmpty) return <ProductModel>[];
  final dio = ref.watch(apiClientProvider);
  final response = await dio.get(
    ApiEndpoints.products,
    queryParameters: {'search': trimmed},
  );
  final list = response.data as List<dynamic>;
  return list.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
});

class ProductsState {
  final List<ProductModel> products;
  final bool isLoading;
  final String? errorMessage;
  final int? selectedCategoryId;
  final String searchQuery;

  ProductsState({
    this.products = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedCategoryId,
    this.searchQuery = '',
  });

  ProductsState copyWith({
    List<ProductModel>? products,
    bool? isLoading,
    String? errorMessage,
    int? selectedCategoryId,
    bool clearCategory = false,
    String? searchQuery,
  }) {
    return ProductsState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedCategoryId: clearCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ProductsNotifier extends StateNotifier<ProductsState> {
  final Dio _dio;

  ProductsNotifier(this._dio) : super(ProductsState()) {
    fetchProducts();
  }

  Future<void> fetchProducts({
    int? categoryId,
    String? search,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      selectedCategoryId: categoryId,
      clearCategory: categoryId == null && categoryId != state.selectedCategoryId,
      searchQuery: search,
    );

    try {
      final Map<String, dynamic> queryParams = {};
      if (state.selectedCategoryId != null) {
        queryParams['category_id'] = state.selectedCategoryId;
      }
      if (state.searchQuery.trim().isNotEmpty) {
        queryParams['search'] = state.searchQuery.trim();
      }

      final response = await _dio.get(
        ApiEndpoints.products,
        queryParameters: queryParams,
      );

      final list = response.data as List<dynamic>;
      final products = list.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
      state = state.copyWith(products: products, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: "Failed to load products.");
    }
  }

  void selectCategory(int? categoryId) {
    if (state.selectedCategoryId == categoryId) {
      // Toggle off
      fetchProducts(categoryId: null, search: state.searchQuery);
    } else {
      fetchProducts(categoryId: categoryId, search: state.searchQuery);
    }
  }

  void searchProducts(String search) {
    fetchProducts(categoryId: state.selectedCategoryId, search: search);
  }
}

final productsProvider = StateNotifierProvider<ProductsNotifier, ProductsState>((ref) {
  final dio = ref.watch(apiClientProvider);
  return ProductsNotifier(dio);
});

// Single product fetcher
final singleProductProvider = FutureProvider.family<ProductModel, String>((ref, productId) async {
  final dio = ref.watch(apiClientProvider);
  final response = await dio.get("${ApiEndpoints.products}/$productId");
  return ProductModel.fromJson(response.data as Map<String, dynamic>);
});

// Loader for a single category's products (with optional search). Returns a
// callable so the category screen can re-fetch on search without touching the
// global products state used by Home.
final categoryProductsLoader = Provider((ref) {
  final dio = ref.watch(apiClientProvider);
  return (int categoryId, String search) async {
    final params = <String, dynamic>{'category_id': categoryId};
    if (search.trim().isNotEmpty) params['search'] = search.trim();
    final response = await dio.get(ApiEndpoints.products, queryParameters: params);
    final list = response.data as List<dynamic>;
    return list.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
  };
});
