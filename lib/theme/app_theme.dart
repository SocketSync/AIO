import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF00236F);
  static const Color primaryContainer = Color(0xFF1E3A8A);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFF006C49);
  static const Color secondaryContainer = Color(0xFF6CF8BB);
  static const Color secondaryFixed = Color(0xFF6FFBBE);
  static const Color onSecondaryFixed = Color(0xFF002113);
  static const Color surface = Color(0xFFFAF8FF);
  static const Color surfaceContainerLow = Color(0xFFF4F3FA);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerHigh = Color(0xFFE9E7EF);
  static const Color surfaceContainerHighest = Color(0xFFE3E1E9);
  static const Color growthMintSubtle = Color(0xFFD1FAE5);
  static const Color primaryFixedDim = Color(0xFFB6C4FF);
  static const Color outline = Color(0xFF757682);
  static const Color outlineVariant = Color(0xFFC5C5D3);
  static const Color alertCoral = Color(0xFFEF4444);
  static const Color alertCoralSubtle = Color(0xFFFEE2E2);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color onSurface = Color(0xFF1A1B21);
  static const Color onSurfaceVariant = Color(0xFF444651);
  static const Color borderNeutral = Color(0xFFE2E8F0);
  static const Color error = Color(0xFFBA1A1A);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.surface,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
      ),
      textTheme: GoogleFonts.interTextTheme(),
    );
  }
}

