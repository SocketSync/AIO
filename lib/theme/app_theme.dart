import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// FinWise brand color palette tokens.
///
/// Defines the Royal Navy primary (`#00236F`), Growth Emerald secondary
/// (`#006C49`), Material 3 surface container ramp (`#FAF8FF`–`#E3E1E9`),
/// neutral text/outline/border tokens, and semantic alert/error colors.
class AppColors {
  // Brand primary & emerald growth accent tokens
  static const Color primary = Color(0xFF00236F);
  static const Color primaryContainer = Color(0xFF1E3A8A);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFF006C49);
  static const Color secondaryContainer = Color(0xFF6CF8BB);
  static const Color secondaryFixed = Color(0xFF6FFBBE);
  static const Color onSecondaryFixed = Color(0xFF002113);

  // Material 3 surface & container hierarchy
  static const Color surface = Color(0xFFFAF8FF);
  static const Color surfaceContainerLow = Color(0xFFF4F3FA);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerHigh = Color(0xFFE9E7EF);
  static const Color surfaceContainerHighest = Color(0xFFE3E1E9);

  // Semantic accents, outlines, and typography contrast tokens
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
  /// Default border radius shared across FinWise text inputs (AIO-66).
  static const double inputBorderRadius = 12.0;

  /// Centralized [InputDecorationTheme] for consistent form field styling (AIO-66).
  static InputDecorationTheme get inputDecorationTheme {
    final defaultBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(inputBorderRadius),
      borderSide: const BorderSide(color: AppColors.borderNeutral),
    );

    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceContainerLowest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 14,
      ),
      hintStyle: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 14,
      ),
      errorStyle: const TextStyle(
        color: AppColors.error,
        fontSize: 12,
      ),
      border: defaultBorder,
      enabledBorder: defaultBorder,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputBorderRadius),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputBorderRadius),
        borderSide: const BorderSide(color: AppColors.error, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputBorderRadius),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }

  /// Builds a reusable [InputDecoration] following FinWise input styling (AIO-66).
  static InputDecoration inputDecoration({
    String? labelText,
    String? hintText,
    String? helperText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      helperText: helperText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
    );
  }

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
      // Inter typography scale applied app-wide via GoogleFonts
      textTheme: GoogleFonts.interTextTheme(),
      inputDecorationTheme: inputDecorationTheme,
    );
  }
}

