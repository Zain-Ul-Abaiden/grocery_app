import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_app/core/constants/colors.dart';
import 'package:grocery_app/features/auth/data/auth_provider.dart';
import 'package:grocery_app/features/products/data/product_provider.dart';
import 'package:grocery_app/features/cart/data/cart_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final productsState = ref.watch(productsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final cartState = ref.watch(cartProvider);

    final currentUser = authState.user;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Taza Store",
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                fontSize: 24,
              ),
            ),
            Text(
              currentUser != null ? "Khush Aamdeed, ${currentUser.name}!" : "Har Cheez Fresh!",
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          // If User is Admin, show Admin Console button
          if (currentUser?.isAdmin == true)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                onPressed: () => context.push('/admin'),
                icon: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.primary, size: 28),
                tooltip: "Admin Panel",
              ),
            ),
          IconButton(
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            icon: const Icon(Icons.logout_rounded, color: AppColors.textSecondary),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Search Bar Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              onChanged: (val) {
                ref.read(productsProvider.notifier).searchProducts(val);
              },
              decoration: InputDecoration(
                hintText: "Sabzi, ghee, chips dhundhein...",
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                suffixIcon: productsState.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary),
                        onPressed: () {
                          ref.read(productsProvider.notifier).searchProducts('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(categoriesProvider);
                await ref.read(productsProvider.notifier).fetchProducts();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2. Banner Slider Section (Premium Design)
                    Container(
                      margin: const EdgeInsets.all(16),
                      height: 140,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -20,
                            bottom: -20,
                            child: Icon(
                              Icons.spa_rounded,
                              size: 160,
                              color: Colors.white.withOpacity(0.12),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "100% Organic & Pure",
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Fresh Sabzi & Groceries",
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Bazar se sasti rate par direct aapke ghar!",
                                  style: GoogleFonts.outfit(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 3. Category Horizontal Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Categories",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 12),
                    categoriesAsync.when(
                      loading: () => const SizedBox(
                        height: 50,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (err, stack) => const SizedBox.shrink(),
                      data: (list) {
                        return SizedBox(
                          height: 55,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: list.length,
                            itemBuilder: (context, index) {
                              final cat = list[index];
                              final isSelected = productsState.selectedCategoryId == cat.id;

                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: ChoiceChip(
                                  label: Text(
                                    cat.name,
                                    style: GoogleFonts.outfit(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? Colors.white : AppColors.textPrimary,
                                    ),
                                  ),
                                  selected: isSelected,
                                  onSelected: (val) {
                                    ref.read(productsProvider.notifier).selectCategory(cat.id);
                                  },
                                  selectedColor: AppColors.primary,
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: isSelected ? AppColors.primary : AppColors.borderLight,
                                    ),
                                  ),
                                  showCheckmark: false,
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),

                    // 4. Products Grid Section
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Products List",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (productsState.isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (productsState.products.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Column(
                            children: [
                              const Icon(Icons.search_off_rounded, size: 60, color: AppColors.textLight),
                              const SizedBox(height: 12),
                              Text(
                                "Koi items nahi mile!",
                                style: GoogleFonts.outfit(
                                  color: AppColors.textSecondary,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.72,
                        ),
                        itemCount: productsState.products.length,
                        itemBuilder: (context, index) {
                          final product = productsState.products[index];

                          return GestureDetector(
                            onTap: () => context.push('/product/${product.id}'),
                            child: Card(
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Product Image & Discount Badge
                                  Expanded(
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.network(
                                          product.imageUrl ?? "https://via.placeholder.com/150",
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, url, err) => Container(
                                            color: AppColors.greyLight,
                                            child: const Icon(Icons.image, color: AppColors.textLight),
                                          ),
                                        ),
                                        if (product.hasDiscount)
                                          Positioned(
                                            top: 8,
                                            left: 8,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: AppColors.discountBadge,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                "${product.discountPercentage}% OFF",
                                                style: GoogleFonts.outfit(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),

                                  // Product Info & Price
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.outfit(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          "Unit: ${product.unit}",
                                          style: GoogleFonts.outfit(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Text(
                                              "Rs. ${product.activePrice.round()}",
                                              style: GoogleFonts.outfit(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primary,
                                                fontSize: 14,
                                              ),
                                            ),
                                            if (product.hasDiscount) ...[
                                              const SizedBox(width: 6),
                                              Text(
                                                "Rs. ${product.price.round()}",
                                                style: GoogleFonts.outfit(
                                                  decoration: TextDecoration.lineThrough,
                                                  color: AppColors.textLight,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 8),

                                        // Add to Cart Button
                                        SizedBox(
                                          height: 36,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.primary,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              padding: EdgeInsets.zero,
                                            ),
                                            onPressed: product.isOutOfStock
                                                ? null
                                                : () async {
                                                    final ok = await ref
                                                        .read(cartProvider.notifier)
                                                        .addToCart(product.id, 1);
                                                    if (ok && context.mounted) {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            "${product.name} bag mein shamil ho gaya!",
                                                            style: GoogleFonts.outfit(),
                                                          ),
                                                          duration: const Duration(seconds: 1),
                                                          backgroundColor: AppColors.primary,
                                                        ),
                                                      );
                                                    }
                                                  },
                                            child: product.isOutOfStock
                                                ? Text("Stock Khatam", style: GoogleFonts.outfit(fontSize: 11))
                                                : Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      const Icon(Icons.add_shopping_cart_rounded, size: 14),
                                                      const SizedBox(width: 4),
                                                      Text("Shamil Karein", style: GoogleFonts.outfit(fontSize: 11)),
                                                    ],
                                                  ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 100), // Spacing for floating bottom bar
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // 5. Floating Cart Summary Bar (Premium UX)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: cartState.summary != null && cartState.summary!.items.isNotEmpty
          ? GestureDetector(
              onTap: () => context.push('/cart'),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.textPrimary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                        const SizedBox(width: 12),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${cartState.summary!.items.length} Items",
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              "Taza basket bhari hui hai!",
                              style: GoogleFonts.outfit(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "Rs. ${cartState.summary!.totalPrice.round()}",
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                      ],
                    )
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
