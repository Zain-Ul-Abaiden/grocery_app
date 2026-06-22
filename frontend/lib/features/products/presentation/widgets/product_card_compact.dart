import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_app/core/constants/colors.dart';
import 'package:grocery_app/features/products/presentation/widgets/cart_quantity_control.dart';
import 'package:grocery_app/shared/models/product_model.dart';

/// Compact, fixed-width product card used inside horizontal rails on the home
/// screen (Blinkit/Zepto style).
class ProductCardCompact extends StatelessWidget {
  final ProductModel product;
  final double width;

  const ProductCardCompact({super.key, required this.product, this.width = 150});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/product/${product.id}'),
      child: Container(
        width: width,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image + discount badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                  child: AspectRatio(
                    aspectRatio: 1.1,
                    child: Image.network(
                      product.imageUrl ?? "https://via.placeholder.com/150",
                      fit: BoxFit.cover,
                      errorBuilder: (context, url, err) => Container(
                        color: AppColors.greyLight,
                        child: const Icon(Icons.image, color: AppColors.textLight),
                      ),
                    ),
                  ),
                ),
                if (product.hasDiscount)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.discountBadge,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "${product.discountPercentage}% OFF",
                        style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 9),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.unit,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          "Rs. ${product.activePrice.round()}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 14),
                        ),
                      ),
                      if (product.hasDiscount) ...[
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            "Rs. ${product.price.round()}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(decoration: TextDecoration.lineThrough, color: AppColors.textLight, fontSize: 11),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  CartQuantityControl(product: product),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
