import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.purple,
      secondary: AppColors.cyan,
      surface: AppColors.surface,
      error: AppColors.red,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(
      const TextTheme(
        displayLarge: TextStyle(fontWeight: FontWeight.w800, color: AppColors.white),
        displayMedium: TextStyle(fontWeight: FontWeight.w800, color: AppColors.white),
        headlineLarge: TextStyle(fontWeight: FontWeight.w800, color: AppColors.white),
        headlineMedium: TextStyle(fontWeight: FontWeight.w700, color: AppColors.white),
        titleLarge: TextStyle(fontWeight: FontWeight.w700, color: AppColors.white),
        titleMedium: TextStyle(fontWeight: FontWeight.w600, color: AppColors.white),
        bodyLarge: TextStyle(fontWeight: FontWeight.w400, color: AppColors.white),
        bodyMedium: TextStyle(fontWeight: FontWeight.w400, color: AppColors.textSecondary),
        bodySmall: TextStyle(fontWeight: FontWeight.w500, color: AppColors.textMuted),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.purple,
        foregroundColor: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700),
      ),
    ),
  );
}
