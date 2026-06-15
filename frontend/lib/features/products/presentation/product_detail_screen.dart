import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_app/core/constants/colors.dart';
import 'package:grocery_app/features/products/data/product_provider.dart';
import 'package:grocery_app/features/cart/data/cart_provider.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _quantity = 1;

  void _increment(int stock) {
    if (_quantity < stock) {
      setState(() => _quantity++);
    }
  }

  void _decrement() {
    if (_quantity > 1) {
      setState(() => _quantity--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(singleProductProvider(widget.productId));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: productAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => const Center(child: Text("Product details failed to load.")),
        data: (product) {
          return Column(
            children: [
              // Product Image Header with Background Styling
              Expanded(
                flex: 4,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color: AppColors.greyLight,
                      child: Image.network(
                        product.imageUrl ?? "",
                        fit: BoxFit.cover,
                        errorBuilder: (context, url, err) => const Center(
                          child: Icon(Icons.shopping_basket_rounded, size: 100, color: AppColors.textLight),
                        ),
                      ),
                    ),
                    if (product.hasDiscount)
                      Positioned(
                        bottom: 20,
                        left: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.discountBadge,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "${product.discountPercentage}% KHAAS BACHAT",
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Product Info & Controls Container
              Expanded(
                flex: 5,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Name & Package Size
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.greyLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "Packing Unit: ${product.unit}",
                                    style: GoogleFonts.outfit(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Pricing section
                      Row(
                        children: [
                          Text(
                            "Rs. ${product.activePrice.round()}",
                            style: GoogleFonts.outfit(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          if (product.hasDiscount) ...[
                            const SizedBox(width: 12),
                            Text(
                              "Rs. ${product.price.round()}",
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                decoration: TextDecoration.lineThrough,
                                color: AppColors.textLight,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Description
                      Text(
                        "Product Description",
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        product.description ?? "Fresh, quality grocery product selected directly for the best value.",
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),

                      const Spacer(),

                      // Packets Quantity Selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Select Packets/Quantity",
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: _decrement,
                                icon: const Icon(Icons.remove_circle_outline_rounded, color: AppColors.primary, size: 28),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                child: Text(
                                  "$_quantity",
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => _increment(product.stock),
                                icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 28),
                              ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Purchase Button
                      ElevatedButton(
                        onPressed: product.isOutOfStock
                            ? null
                            : () async {
                                final ok = await ref
                                    .read(cartProvider.notifier)
                                    .addToCart(product.id, _quantity);
                                if (ok && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "$_quantity x ${product.name} added to cart!",
                                        style: GoogleFonts.outfit(),
                                      ),
                                      backgroundColor: AppColors.primary,
                                    ),
                                  );
                                  context.pop();
                                }
                              },
                        child: product.isOutOfStock
                            ? const Text("Out of Stock")
                            : Text("Add to Cart (Rs. ${(product.activePrice * _quantity).round()})"),
                      ),
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
