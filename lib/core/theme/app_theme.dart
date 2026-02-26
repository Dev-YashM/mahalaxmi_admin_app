import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,

      primary: AppColors.primary,
      onPrimary: Colors.white,

      secondary: AppColors.secondary,
      onSecondary: Colors.white,

      error: Colors.red,
      onError: Colors.white,

      background: AppColors.background,
      onBackground: Colors.black,

      surface: AppColors.surface,
      onSurface: Colors.black,
    ),

    scaffoldBackgroundColor: AppColors.background,
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,

      primary: AppColors.primary,
      onPrimary: Colors.white,

      secondary: AppColors.secondary,
      onSecondary: Colors.white,

      tertiary: AppColors.accent,
      onTertiary: Colors.white,

      error: Colors.red,
      onError: Colors.white,

      background: AppColors.background,
      onBackground: Colors.black,

      surface: AppColors.surface,
      onSurface: Colors.black,
    ),

    scaffoldBackgroundColor: Colors.black,
  );
}