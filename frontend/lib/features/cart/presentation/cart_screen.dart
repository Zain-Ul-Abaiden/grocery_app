import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_app/core/constants/colors.dart';
import 'package:grocery_app/features/cart/data/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Apka Bag (Shopping Cart)",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (cartState.summary != null && cartState.summary!.items.isNotEmpty)
            TextButton(
              onPressed: () => ref.read(cartProvider.notifier).clearCart(),
              child: Text(
                "Khali Karein",
                style: GoogleFonts.outfit(color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
            )
        ],
      ),
      body: cartState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : (cartState.summary == null || cartState.summary!.items.isEmpty)
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shopping_cart_outlined, size: 80, color: AppColors.textLight),
                        const SizedBox(height: 16),
                        Text(
                          "Apka cart khali hai!",
                          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Taza aur sasti products shamil karne ke liye home page par jayein.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: 200,
                          child: ElevatedButton(
                            onPressed: () => context.go('/'),
                            child: const Text("Khareedari Shuru Karein"),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Cart Items List
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: cartState.summary!.items.length,
                        itemBuilder: (context, index) {
                          final item = cartState.summary!.items[index];
                          final product = item.product;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  // Image
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: NetworkImage(product.imageUrl ?? ""),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          style: GoogleFonts.outfit(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          "Unit Size: ${product.unit}",
                                          style: GoogleFonts.outfit(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Rs. ${product.activePrice.round()} per packet",
                                          style: GoogleFonts.outfit(
                                            fontSize: 12,
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Adjustments (Quantity & Delete)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                                        onPressed: () => ref.read(cartProvider.notifier).removeFromCart(product.id),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          IconButton(
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary, size: 22),
                                            onPressed: () {
                                              if (item.quantity > 1) {
                                                ref.read(cartProvider.notifier).updateQuantity(item.id, item.quantity - 1);
                                              }
                                            },
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                            child: Text(
                                              "${item.quantity}",
                                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          IconButton(
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary, size: 22),
                                            onPressed: () {
                                              ref.read(cartProvider.notifier).updateQuantity(item.id, item.quantity + 1);
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Price Breakdown Drawer
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -4))
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Items Total", style: GoogleFonts.outfit(color: AppColors.textSecondary)),
                              Text("Rs. ${cartState.summary!.totalPrice.round()}", style: GoogleFonts.outfit(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Delivery Charges", style: GoogleFonts.outfit(color: AppColors.textSecondary)),
                              Text("FREE (Muft)", style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const Divider(height: 24, color: AppColors.borderLight),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Grand Total",
                                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                              Text(
                                "Rs. ${cartState.summary!.totalPrice.round()}",
                                style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => context.push('/checkout'),
                            child: const Text("Order Place Karein (Checkout)"),
                          )
                        ],
                      ),
                    )
                  ],
                ),
    );
  }
}
