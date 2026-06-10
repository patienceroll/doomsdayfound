import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.light.primary,
        brightness: Brightness.light,
      ),
      extensions: const [AppColors.light],
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.dark.primary,
        brightness: Brightness.dark,
      ),
      extensions: const [AppColors.dark],
    );
  }
}
