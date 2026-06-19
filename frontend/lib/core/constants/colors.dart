import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors - green (Shadab Super Store)
  static const Color primary = Color(0xFF2F6B1A); // Deep green: buttons, fills, accent text/icons on white
  static const Color primaryDark = Color(0xFF143F17); // Darkest green: gradient dark-end, deep text, dark sections
  static const Color primaryMid = Color(0xFF8ABF2C); // Mid green: optional decorative accents
  static const Color primaryLight = Color(0xFFCDEE77); // Light lime tint for light section surfaces (paired with dark text)
  static const Color accent = Color(0xFFB4EB39); // Bright lime accent for highlights/badges
  static const Color onPrimary = Color(0xFFFFFFFF); // White text/icons on green fills
  static const Color success = Color(0xFF22C55E); // Green for success states

  // Background and Surface Colors
  static const Color background = Color(0xFFFFFFFF); // White background for lists
  static const Color surface = Colors.white;
  static const Color cardBg = Colors.white;

  // Text Colors
  static const Color textPrimary = Color(0xFF1E1E1E); // Very dark gray/black
  static const Color textSecondary = Color(0xFF6B7280); // Gray
  static const Color textLight = Color(0xFF9CA3AF); // Light Gray

  // Status and Accent Colors
  static const Color discountBadge = Color(0xFFFF3B30); // Red
  static const Color discountBg = Color(0xFFFFEAEA);
  static const Color warning = Color(0xFFFF9F43);
  static const Color info = Color(0xFF2EA8FF);
  
  // Grey and Borders
  static const Color borderLight = Color(0xFFF3F4F6); // Very light grey border
  static const Color greyLight = Color(0xFFF9FAFB); // Very light grey bg
}
