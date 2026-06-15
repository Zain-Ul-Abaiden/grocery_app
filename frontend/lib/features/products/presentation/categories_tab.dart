import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_app/core/constants/colors.dart';
import 'package:grocery_app/features/products/data/product_provider.dart';
import 'package:grocery_app/features/products/presentation/home_screen.dart';
import 'package:grocery_app/shared/models/product_model.dart';

class CategoriesTab extends ConsumerStatefulWidget {
  const CategoriesTab({super.key});

  @override
  ConsumerState<CategoriesTab> createState() => _CategoriesTabState();
}

class _CategoriesTabState extends ConsumerState<CategoriesTab> {
  String _query = "";

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text("Categories", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 22)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
              decoration: const InputDecoration(
                hintText: "Search Category...",
                prefixIcon: Icon(Icons.search_rounded, color: AppColors.textSecondary),
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          Expanded(
            child: categoriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text("Failed to load categories", style: GoogleFonts.outfit())),
              data: (categories) {
                final filtered = _query.isEmpty
                    ? categories
                    : categories.where((c) => c.name.toLowerCase().contains(_query)).toList();
                if (filtered.isEmpty) {
                  return Center(child: Text("No categories found", style: GoogleFonts.outfit(color: AppColors.textSecondary)));
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final cat = filtered[index];
                    return GestureDetector(
                      onTap: () => context.push('/category/${cat.id}?name=${Uri.encodeComponent(cat.name)}'),
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.greyLight,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.borderLight),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: (cat.imageUrl != null && cat.imageUrl!.isNotEmpty)
                                  ? Image.network(cat.imageUrl!, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.category_rounded, color: AppColors.textLight, size: 32))
                                  : const Icon(Icons.category_rounded, color: AppColors.textLight, size: 32),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            cat.name,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Products listing for a single category, with its own product search + back.
class CategoryProductsScreen extends ConsumerStatefulWidget {
  final int categoryId;
  final String categoryName;
  const CategoryProductsScreen({super.key, required this.categoryId, required this.categoryName});

  @override
  ConsumerState<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends ConsumerState<CategoryProductsScreen> {
  List<ProductModel> _products = [];
  bool _loading = true;
  String _search = "";

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final products = await ref.read(categoryProductsLoader)(widget.categoryId, _search);
      if (mounted) setState(() { _products = products; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _products = []; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary), onPressed: () => context.pop()),
        title: Text(widget.categoryName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 18)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              onChanged: (v) { _search = v; _load(); },
              decoration: const InputDecoration(
                hintText: "Search in this category...",
                prefixIcon: Icon(Icons.search_rounded, color: AppColors.textSecondary),
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _products.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off_rounded, size: 60, color: AppColors.textLight),
                            const SizedBox(height: 12),
                            Text("No products found", style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 16)),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 24),
                          child: ProductGrid(products: _products),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
