import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  // ===========================
  // LIGHT THEME
  // ===========================

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.primaryLight,
        surface: AppColors.surface,
        error: AppColors.error,
      ),

      scaffoldBackgroundColor: AppColors.background,

      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
      ),

      cardColor: AppColors.card,

      dividerColor: AppColors.border,
      textTheme: const TextTheme(
  bodyLarge: TextStyle(
    color: AppColors.textPrimary,
  ),
  bodyMedium: TextStyle(
    color: AppColors.textPrimary,
  ),
  bodySmall: TextStyle(
    color: AppColors.textSecondary,
  ),
  titleLarge: TextStyle(
    color: AppColors.textPrimary,
    fontWeight: FontWeight.bold,
  ),
  titleMedium: TextStyle(
    color: AppColors.textPrimary,
  ),
  titleSmall: TextStyle(
    color: AppColors.textPrimary,
  ),
),

      floatingActionButtonTheme:
          const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),

      bottomNavigationBarTheme:
          const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedIconTheme: IconThemeData(size: 26),
        unselectedIconTheme: IconThemeData(size: 24),
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        hintStyle: const TextStyle(
  color: AppColors.textSecondary,
),

labelStyle: const TextStyle(
  color: AppColors.textPrimary,
),

floatingLabelStyle: const TextStyle(
  color: AppColors.primary,
),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
      ),
    );
  }

  // ===========================
  // DARK THEME
  // ===========================

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.primaryLight,
        surface: AppColors.darkSurface,
        error: AppColors.error,
      ),

      scaffoldBackgroundColor:
          AppColors.darkBackground,

      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextPrimary,
      ),

      cardColor: AppColors.darkCard,

      dividerColor: AppColors.darkBorder,
      textTheme: const TextTheme(
  bodyLarge: TextStyle(
    color: AppColors.darkTextPrimary,
  ),
  bodyMedium: TextStyle(
    color: AppColors.darkTextPrimary,
  ),
  bodySmall: TextStyle(
    color: AppColors.darkTextSecondary,
  ),
  titleLarge: TextStyle(
    color: AppColors.darkTextPrimary,
    fontWeight: FontWeight.bold,
  ),
  titleMedium: TextStyle(
    color: AppColors.darkTextPrimary,
  ),
  titleSmall: TextStyle(
    color: AppColors.darkTextPrimary,
  ),
),

      floatingActionButtonTheme:
          const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),

      bottomNavigationBarTheme:
          const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor:
            AppColors.darkTextSecondary,
        selectedIconTheme:
            IconThemeData(size: 26),
        unselectedIconTheme:
            IconThemeData(size: 24),
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        hintStyle: const TextStyle(
  color: AppColors.darkTextSecondary,
),

labelStyle: const TextStyle(
  color: AppColors.darkTextPrimary,
),

floatingLabelStyle: const TextStyle(
  color: AppColors.primary,
),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.darkBorder,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.darkBorder,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
      ),
    );
  }
}