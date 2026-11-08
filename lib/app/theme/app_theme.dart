import 'package:flutter/material.dart';
import 'package:place_stack/app/theme/colors.dart';
import 'package:place_stack/app/theme/typography.dart';

abstract final class AppTheme {
  static ThemeData get dark {
    final scheme = ColorScheme.dark(
      primary: AppColors.neonBlue,
      secondary: AppColors.purple,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.red,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.backgroundTop,
      fontFamily: AppTypography.fontFamily,
      textTheme: ThemeData.dark().textTheme.apply(
            bodyColor: AppColors.textPrimary,
            displayColor: AppColors.textPrimary,
          ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.green
              : AppColors.surfaceLight,
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.green,
        inactiveTrackColor: AppColors.surfaceLight,
        thumbColor: Colors.white,
        overlayColor: Color(0x331FD66B),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceLight,
      ),
    );
  }
}
