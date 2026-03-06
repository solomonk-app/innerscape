import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color background = Color(0xFF1A1512);
  static const Color surface = Color(0xFF2C2621);
  static const Color surfaceLight = Color(0xFF3A332D);
  static const Color accent = Color(0xFFE8945A);
  static const Color accentDark = Color(0xFFE07B3C);
  static const Color warmGold = Color(0xFFD4A574);
  static const Color textPrimary = Color(0xFFE8D5C4);
  static const Color textSecondary = Color(0xFFC4B8A5);
  static const Color textMuted = Color(0xFF8B7E74);
  static const Color textDim = Color(0xFF5A524A);
  static const Color borderLight = Color(0x268B7E74);
  static const Color accentTranslucent = Color(0x26E8945A);
  static const Color accentBorder = Color(0x4DE8945A);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        secondary: AppColors.warmGold,
        surface: AppColors.surface,
      ),
      textTheme: GoogleFonts.loraTextTheme(
        const TextTheme(
          headlineLarge: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
          headlineMedium: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w300,
          ),
          titleMedium: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
          bodyLarge: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            height: 1.7,
          ),
          bodyMedium: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
          bodySmall: TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
          ),
          labelSmall: TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            letterSpacing: 2,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textMuted,
      ),
    );
  }
}
