import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_app/core/constants/colors.dart';
import 'package:grocery_app/shared/models/product_model.dart';

/// Horizontal rail of rounded category tiles. Tapping a tile opens that
/// category's product list.
class CategoryRail extends StatelessWidget {
  final List<CategoryModel> categories;

  const CategoryRail({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 104,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return GestureDetector(
            onTap: () => context.push('/category/${cat.id}?name=${Uri.encodeComponent(cat.name)}'),
            child: Container(
              width: 76,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.35),
                      shape: BoxShape.circle,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: cat.imageUrl != null
                        ? Image.network(
                            cat.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, url, err) =>
                                const Icon(Icons.category_rounded, color: AppColors.primary),
                          )
                        : const Icon(Icons.category_rounded, color: AppColors.primary),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Text(
                      cat.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textPrimary, height: 1.1),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
