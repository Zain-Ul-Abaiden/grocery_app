import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_app/core/constants/colors.dart';
import 'package:grocery_app/features/cart/data/cart_provider.dart';
import 'package:grocery_app/shared/models/cart_model.dart';
import 'package:grocery_app/shared/models/product_model.dart';

/// Blinkit-style add control: an "ADD" button that becomes a − / qty / +
/// stepper once the product is in the cart. Wired to the shared cartProvider.
class CartQuantityControl extends ConsumerWidget {
  final ProductModel product;
  final double height;

  const CartQuantityControl({
    super.key,
    required this.product,
    this.height = 34,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final notifier = ref.read(cartProvider.notifier);

    CartItemModel? item;
    for (final i in cartState.summary?.items ?? const <CartItemModel>[]) {
      if (i.product.id == product.id) {
        item = i;
        break;
      }
    }

    if (product.isOutOfStock) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            "Out of Stock",
            style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textLight, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    if (item == null) {
      return SizedBox(
        height: height,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: EdgeInsets.zero,
          ),
          onPressed: () async {
            final ok = await notifier.addToCart(product.id, 1);
            if (!ok && context.mounted) {
              final msg = ref.read(cartProvider).errorMessage ?? "Could not add item.";
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(msg, style: GoogleFonts.outfit()),
                duration: const Duration(seconds: 1),
                backgroundColor: AppColors.discountBadge,
              ));
            }
          },
          child: Text("ADD", style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold)),
        ),
      );
    }

    final current = item;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StepButton(
            icon: Icons.remove_rounded,
            onTap: () {
              if (current.quantity <= 1) {
                notifier.removeFromCart(product.id);
              } else {
                notifier.updateQuantity(current.id, current.quantity - 1);
              }
            },
          ),
          Text(
            "${current.quantity}",
            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          _StepButton(
            icon: Icons.add_rounded,
            onTap: () => notifier.updateQuantity(current.id, current.quantity + 1),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _StepButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}
