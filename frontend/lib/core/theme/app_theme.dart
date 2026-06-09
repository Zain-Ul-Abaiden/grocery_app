import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_app/core/constants/colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        background: AppColors.background,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,
      
      // Typography styling via Google Fonts
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        titleLarge: GoogleFonts.outfit(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
        titleMedium: GoogleFonts.outfit(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
        bodyLarge: GoogleFonts.outfit(
          color: AppColors.textPrimary,
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.outfit(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
      ),

      // Input Decoration (Text fields) styling
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        labelStyle: GoogleFonts.outfit(color: AppColors.textSecondary),
        hintStyle: GoogleFonts.outfit(color: AppColors.textLight),
      ),

      // Elevated Button styling
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Card styling
      cardTheme: CardThemeData(
        color: AppColors.cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),

    );
  }
}
