import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.babyPink,
    scaffoldBackgroundColor: AppColors.cream,
    cardColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.softPink,
    ),
    colorScheme: ColorScheme.light(
      primary: AppColors.babyPink,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.babyPink,
    scaffoldBackgroundColor: AppColors.darkBackground,
    cardColor: AppColors.darkCard,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkSurface,
    ),
    colorScheme: ColorScheme.dark(
      primary: AppColors.babyPink,
    ),
  );
}