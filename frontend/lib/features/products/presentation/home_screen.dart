import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_app/core/constants/colors.dart';
import 'package:grocery_app/features/auth/data/auth_provider.dart';
import 'package:grocery_app/features/products/data/product_provider.dart';
import 'package:grocery_app/features/cart/data/cart_provider.dart';
import 'package:grocery_app/features/main/presentation/main_scaffold.dart';
import 'package:grocery_app/features/products/presentation/widgets/banner_carousel.dart';
import 'package:grocery_app/features/products/presentation/widgets/category_rail.dart';
import 'package:grocery_app/features/products/presentation/widgets/product_rail.dart';
import 'package:grocery_app/features/products/presentation/widgets/section_header.dart';
import 'package:grocery_app/features/products/presentation/widgets/cart_quantity_control.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final homeAsync = ref.watch(homeProvider);
    final cartState = ref.watch(cartProvider);
    final currentUser = authState.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Shadab Super Store",
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 20),
            ),
            Text(
              currentUser != null ? "Welcome, ${currentUser.name}!" : "Everything fresh!",
              style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          if (currentUser?.isAdmin == true)
            IconButton(
              onPressed: () => context.push('/admin'),
              icon: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.primary, size: 28),
              tooltip: "Admin Panel",
            ),
        ],
      ),
      body: Column(
        children: [
          // Tappable search bar -> dedicated search screen
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: GestureDetector(
              onTap: () => context.push('/search'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                    const SizedBox(width: 10),
                    Text(
                      "Search for groceries...",
                      style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: homeAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => _ErrorView(onRetry: () => ref.invalidate(homeProvider)),
              data: (home) => RefreshIndicator(
                onRefresh: () => ref.refresh(homeProvider.future),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: [
                    const SizedBox(height: 8),
                    // Banners (or fallback promo banner when none configured)
                    if (home.banners.isNotEmpty)
                      BannerCarousel(banners: home.banners)
                    else
                      const _PromoBannerFallback(),
                    const SizedBox(height: 20),

                    // Category rail
                    if (home.categories.isNotEmpty) ...[
                      const SectionHeader(title: "Shop by Category"),
                      const SizedBox(height: 8),
                      CategoryRail(categories: home.categories),
                      const SizedBox(height: 20),
                    ],

                    // Deals
                    if (home.deals.isNotEmpty) ...[
                      const SectionHeader(title: "Big Savings 🔥"),
                      const SizedBox(height: 8),
                      ProductRail(products: home.deals),
                      const SizedBox(height: 20),
                    ],

                    // Top selling
                    if (home.bestsellers.isNotEmpty) ...[
                      const SectionHeader(title: "Top Selling"),
                      const SizedBox(height: 8),
                      ProductRail(products: home.bestsellers),
                      const SizedBox(height: 20),
                    ],

                    // Featured (admin-curated)
                    if (home.featured.isNotEmpty) ...[
                      const SectionHeader(title: "Featured"),
                      const SizedBox(height: 8),
                      ProductRail(products: home.featured),
                      const SizedBox(height: 20),
                    ],

                    // Per-category carousels
                    ...home.categorySections.map((section) => Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SectionHeader(
                                title: section.category.name,
                                onSeeAll: () => context.push(
                                  '/category/${section.category.id}?name=${Uri.encodeComponent(section.category.name)}',
                                ),
                              ),
                              const SizedBox(height: 8),
                              ProductRail(products: section.products),
                            ],
                          ),
                        )),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: cartState.summary != null && cartState.summary!.items.isNotEmpty
          ? GestureDetector(
              onTap: () => ref.read(selectedTabProvider.notifier).state = 2,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                        const SizedBox(width: 12),
                        Text("${cartState.summary!.items.length} Items", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    Row(
                      children: [
                        Text("Rs. ${cartState.summary!.totalPrice.round()}", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                      ],
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}

/// Fallback gradient promo banner shown when no banners are configured in admin.
class _PromoBannerFallback extends StatelessWidget {
  const _PromoBannerFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 150,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(Icons.shopping_basket_rounded, size: 160, color: AppColors.onPrimary.withOpacity(0.10)),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.onPrimary.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                  child: Text("FRESH & AFFORDABLE", style: GoogleFonts.outfit(color: AppColors.onPrimary, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                Text("Click. Cart. Chill.", style: GoogleFonts.outfit(color: AppColors.onPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
                Text("Great prices, delivered to your door!", style: GoogleFonts.outfit(color: AppColors.onPrimary.withOpacity(0.8), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 60, color: AppColors.textLight),
          const SizedBox(height: 12),
          Text("Couldn't load the store.", style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 16)),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: onRetry,
            child: Text("Retry", style: GoogleFonts.outfit(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

/// Reusable 2-column product grid used by Category and Search screens.
class ProductGrid extends ConsumerWidget {
  final List products;
  const ProductGrid({super.key, required this.products});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return GestureDetector(
          onTap: () => context.push('/product/${product.id}'),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        product.imageUrl ?? "https://via.placeholder.com/150",
                        fit: BoxFit.cover,
                        errorBuilder: (context, url, err) => Container(color: AppColors.greyLight, child: const Icon(Icons.image, color: AppColors.textLight)),
                      ),
                      if (product.hasDiscount)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.discountBadge, borderRadius: BorderRadius.circular(8)),
                            child: Text("${product.discountPercentage}% OFF", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
                      Text("Unit: ${product.unit}", style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text("Rs. ${product.activePrice.round()}", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 14)),
                          if (product.hasDiscount) ...[
                            const SizedBox(width: 6),
                            Text("Rs. ${product.price.round()}", style: GoogleFonts.outfit(decoration: TextDecoration.lineThrough, color: AppColors.textLight, fontSize: 11)),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      CartQuantityControl(product: product, height: 36),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
