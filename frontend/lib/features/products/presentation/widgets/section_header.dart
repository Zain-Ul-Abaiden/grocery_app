import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_app/core/constants/colors.dart';

/// Row with a section title on the left and an optional "See all →" action.
class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const SectionHeader({super.key, required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("See all", style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13)),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
