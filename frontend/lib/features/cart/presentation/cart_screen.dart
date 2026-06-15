import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_app/core/constants/colors.dart';
import 'package:grocery_app/features/cart/data/cart_provider.dart';
import 'package:grocery_app/features/main/presentation/main_scaffold.dart';

// Minimum order value required to checkout. Delivery is free for now.
const double kMinOrder = 1000;

class CartTab extends ConsumerWidget {
  const CartTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final summary = cartState.summary;
    final total = summary?.totalPrice ?? 0;
    final hasItems = summary != null && summary.items.isNotEmpty;
    final meetsMin = total >= kMinOrder;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text("Cart", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 22)),
        actions: [
          if (hasItems)
            TextButton(
              onPressed: () => ref.read(cartProvider.notifier).clearCart(),
              child: Text("Clear", style: GoogleFonts.outfit(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: cartState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : !hasItems
              ? _emptyCart(context, ref)
              : Column(
                  children: [
                    // Minimum order banner
                    if (!meetsMin)
                      Container(
                        width: double.infinity,
                        color: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        child: Text(
                          "Minimum order is Rs ${kMinOrder.round()}. Add more items to continue.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: summary.items.length,
                        itemBuilder: (context, index) {
                          final item = summary.items[index];
                          final product = item.product;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: AppColors.greyLight,
                                      image: (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                                          ? DecorationImage(image: NetworkImage(product.imageUrl!), fit: BoxFit.cover)
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
                                        Text("Unit: ${product.unit}", style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary)),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text("Rs. ${product.activePrice.round()}", style: GoogleFonts.outfit(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.bold)),
                                            if (product.hasDiscount) ...[
                                              const SizedBox(width: 6),
                                              Text("Rs. ${product.price.round()}", style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textLight, decoration: TextDecoration.lineThrough)),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
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
                                            child: Text("${item.quantity}", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                                          ),
                                          IconButton(
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary, size: 22),
                                            onPressed: () => ref.read(cartProvider.notifier).updateQuantity(item.id, item.quantity + 1),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Bottom summary + checkout
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -4))],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Delivery", style: GoogleFonts.outfit(color: AppColors.textSecondary)),
                              Text("FREE", style: GoogleFonts.outfit(color: AppColors.success, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: meetsMin ? () => context.push('/checkout') : null,
                            child: Text(
                              meetsMin ? "Checkout  •  Rs. ${total.round()}" : "Add Rs. ${(kMinOrder - total).round()} more to checkout",
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _emptyCart(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_cart_outlined, size: 80, color: AppColors.textLight),
            const SizedBox(height: 16),
            Text("Your cart is empty!", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text("Browse products and add items to get started.", textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () => ref.read(selectedTabProvider.notifier).state = 0,
                child: const Text("Start Shopping"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
