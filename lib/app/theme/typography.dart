import 'package:flutter/material.dart';
import 'package:place_stack/app/theme/colors.dart';

abstract final class AppTypography {
  /// Set to a font family declared in pubspec once real fonts are added.
  static const String? fontFamily = null;

  static const TextStyle score = TextStyle(
    fontFamily: fontFamily,
    fontSize: 64,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.0,
  );
  static const TextStyle logo = TextStyle(
    fontFamily: fontFamily,
    fontSize: 54,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    height: 0.95,
    letterSpacing: 1,
  );
  static const TextStyle title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
  static const TextStyle heading = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.5,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
}
