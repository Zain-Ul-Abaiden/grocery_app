import 'package:grocery_app/shared/models/product_model.dart';

class CartItemModel {
  final int id;
  final ProductModel product;
  final int quantity;
  final double subtotal;

  CartItemModel({
    required this.id,
    required this.product,
    required this.quantity,
    required this.subtotal,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as int,
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      subtotal: double.parse(json['subtotal'].toString()),
    );
  }
}

class CartSummaryModel {
  final List<CartItemModel> items;
  final double totalPrice;

  CartSummaryModel({
    required this.items,
    required this.totalPrice,
  });

  factory CartSummaryModel.fromJson(Map<String, dynamic> json) {
    return CartSummaryModel(
      items: (json['items'] as List<dynamic>)
          .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalPrice: double.parse(json['total_price'].toString()),
    );
  }
}
