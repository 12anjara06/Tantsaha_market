import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF1B4332);
  static const Color primaryLight = Color(0xFF40916C);
  static const Color primaryLighter = Color(0xFF74C69D);
  static const Color accent = Color(0xFFFFD166);
  static const Color accentDark = Color(0xFFE8B84B);
  static const Color danger = Color(0xFFEF476F);
  static const Color dangerLight = Color(0xFFFF8FA3);
  static const Color success = Color(0xFF06D6A0);
  static const Color warning = Color(0xFFFF9F1C);
  static const Color background = Color(0xFF0D1B2A);
  static const Color surface = Color(0xFF1A2E3B);
  static const Color surfaceLight = Color(0xFF243B4A);
  static const Color cardBg = Color(0xFF1E3448);
  static const Color textPrimary = Color(0xFFF0F4F8);
  static const Color textSecondary = Color(0xFF8FA8BB);
  static const Color divider = Color(0xFF2D4A5A);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1B4332), Color(0xFF40916C)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD166), Color(0xFFE8B84B)],
  );

  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0D1B2A), Color(0xFF1A2E3B)],
  );

  static const LinearGradient dangerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEF476F), Color(0xFFD63A5F)],
  );
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.danger,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: GoogleFonts.outfit(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dividerColor: AppColors.divider,
    );
  }
}
