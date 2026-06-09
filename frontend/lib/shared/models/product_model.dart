class CategoryModel {
  final int id;
  final String name;
  final String? imageUrl;

  CategoryModel({
    required this.id,
    required this.name,
    this.imageUrl,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      imageUrl: json['image_url'] as String?,
    );
  }
}

class ProductModel {
  final String id;
  final int categoryId;
  final String name;
  final String? description;
  final double price;
  final double? discountPrice;
  final String unit; // e.g. "250 gram", "500 gm", "1 kg", "1 packet"
  final int stock;
  final String? imageUrl;
  final bool isAvailable;

  ProductModel({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description,
    required this.price,
    this.discountPrice,
    required this.unit,
    required this.stock,
    this.imageUrl,
    required this.isAvailable,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      categoryId: json['category_id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: double.parse(json['price'].toString()),
      discountPrice: json['discount_price'] != null ? double.parse(json['discount_price'].toString()) : null,
      unit: json['unit'] as String,
      stock: json['stock'] as int,
      imageUrl: json['image_url'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
    );
  }

  // Active pricing helper
  double get activePrice => discountPrice ?? price;

  // Active discount percentage helper
  int get discountPercentage {
    if (discountPrice == null || price == 0) return 0;
    return (((price - discountPrice!) / price) * 100).round();
  }

  bool get hasDiscount => discountPrice != null;
  bool get isOutOfStock => stock <= 0;
}
