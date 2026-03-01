import 'package:festum/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get lightTheme {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.appBar,
      brightness: Brightness.light,
      primary: AppColors.appBar,
      secondary: AppColors.secondaryButton,
      error: AppColors.alert,
      surface: AppColors.card,
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: colorScheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.appBar,
        foregroundColor: AppColors.appBarText,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.card,
        elevation: 2,
        margin: EdgeInsets.all(16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryButton,
          foregroundColor: AppColors.primaryText,
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.activeIcon),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.primaryText),
        bodyMedium: TextStyle(color: AppColors.primaryText),
      ),
    );
  }
}
