import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  static const String brandFontFamily = 'Inter';

  static TextTheme textTheme = const TextTheme(
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: AppColors.charcoal,
      fontFamily: brandFontFamily,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: AppColors.charcoal,
      fontFamily: brandFontFamily,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.charcoal,
      fontFamily: brandFontFamily,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.charcoal,
      fontFamily: brandFontFamily,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.charcoal,
      fontFamily: brandFontFamily,
    ),
  );
}
