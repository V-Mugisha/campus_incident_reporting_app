import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App color tokens. No screen should hard-code a color value.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF6C4DF6);
  static const Color primaryLight = Color(0xFFEDE9FE);
  static const Color gradientStart = Color(0xFF8B6CFF);
  static const Color gradientEnd = Color(0xFF6C4DF6);
  static const Color background = Color(0xFFF8F8FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE6E6F0);
  static const Color textPrimary = Color(0xFF1F1B3A);
  static const Color textSecondary = Color(0xFF7A7A90);
  static const Color textHint = Color(0xFFA5A5B8);
  static const Color error = Color(0xFFE5484D);
  static const Color successBg = Color(0xFFDDF6E8);
  static const Color successText = Color(0xFF1F9D57);

  static const Color statusSubmittedBg = Color(0xFFFFF1D6);
  static const Color statusSubmittedText = Color(0xFFB7791F);
  static const Color statusProgressBg = Color(0xFFEDE9FE);
  static const Color statusProgressText = Color(0xFF6C4DF6);
  static const Color statusResolvedBg = Color(0xFFDDF6E8);
  static const Color statusResolvedText = Color(0xFF1F9D57);
  static const Color tileBlueBg = Color(0xFFE6F0FF);
  static const Color tileBlue = Color(0xFF3B82F6);
  static const Color tilePinkBg = Color(0xFFFDE8EC);
  static const Color tilePink = Color(0xFFE5484D);

  static const Color categorySelectedBg = Color(0xFF6C4DF6);
  static const Color categoryIdleBg = Color(0xFFF1F0F9);
  static const Color categoryAccent = Color(0xFF3B82F6);
  static const Color dashedBorder = Color(0xFFCFCBEA);
  static const Color photoZoneBg = Color(0xFFFAFAFF);
}

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        error: AppColors.error,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,
    );

    final textTheme = GoogleFonts.plusJakartaSansTextTheme(base.textTheme);

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 15),
        errorStyle: const TextStyle(color: AppColors.error, fontSize: 12),
        counterStyle: const TextStyle(color: AppColors.textHint, fontSize: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }
}
