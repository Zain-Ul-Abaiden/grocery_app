import 'package:flutter/material.dart';
import 'package:grocery_app/features/products/presentation/widgets/product_card_compact.dart';
import 'package:grocery_app/shared/models/product_model.dart';

/// Horizontal, scrollable list of compact product cards.
class ProductRail extends StatelessWidget {
  final List<ProductModel> products;
  final double height;

  const ProductRail({super.key, required this.products, this.height = 250});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: products.length,
        itemBuilder: (context, index) => ProductCardCompact(product: products[index]),
      ),
    );
  }
}
