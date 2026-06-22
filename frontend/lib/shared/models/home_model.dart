import 'package:grocery_app/shared/models/product_model.dart';

class BannerModel {
  final int id;
  final String imageUrl;
  final bool isActive;

  BannerModel({
    required this.id,
    required this.imageUrl,
    required this.isActive,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] as int,
      imageUrl: json['image_url'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}

class CategorySection {
  final CategoryModel category;
  final List<ProductModel> products;

  CategorySection({required this.category, required this.products});

  factory CategorySection.fromJson(Map<String, dynamic> json) {
    return CategorySection(
      category: CategoryModel.fromJson(json['category'] as Map<String, dynamic>),
      products: (json['products'] as List<dynamic>)
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class HomeData {
  final List<BannerModel> banners;
  final List<CategoryModel> categories;
  final List<ProductModel> bestsellers;
  final List<ProductModel> featured;
  final List<ProductModel> deals;
  final List<CategorySection> categorySections;

  HomeData({
    required this.banners,
    required this.categories,
    required this.bestsellers,
    required this.featured,
    required this.deals,
    required this.categorySections,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) {
    List<ProductModel> products(String key) =>
        (json[key] as List<dynamic>? ?? [])
            .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
            .toList();

    return HomeData(
      banners: (json['banners'] as List<dynamic>? ?? [])
          .map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      categories: (json['categories'] as List<dynamic>? ?? [])
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      bestsellers: products('bestsellers'),
      featured: products('featured'),
      deals: products('deals'),
      categorySections: (json['category_sections'] as List<dynamic>? ?? [])
          .map((e) => CategorySection.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
