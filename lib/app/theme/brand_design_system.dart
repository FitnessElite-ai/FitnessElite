import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Centralized Brand Identity & Design Tokens for FitnessElite.ai
class BrandAssets {
  BrandAssets._();

  static const String appName = 'FitnessElite.ai';
  static const String brandTitle = 'FitnessElite';
  static const String brandDomain = '.ai';
  static const String logoPath = 'assets/images/logo.png';
}

class BrandColors {
  BrandColors._();

  static const Color primaryNavy = Color(0xFF08090C);
  static const Color electricBlue = AppColors.electricBlue;
  static const Color cyanAccent = AppColors.cyanAccent;
  static const Color vividBlue = AppColors.vividBlue;
  static const Color deepViolet = AppColors.deepViolet;

  static const Color darkSurface = AppColors.darkSurface;
  static const Color darkCard = AppColors.darkCard;

  static const Color lightBackground = AppColors.lightBackground;
  static const Color lightSurface = AppColors.lightSurface;

  static const LinearGradient heroGradient = AppColors.primaryGradient;
}

class BrandTypography {
  BrandTypography._();

  static TextStyle displayLarge(bool isDark) => AppTypography.createTextTheme(isDark: isDark).displayLarge!;
  static TextStyle displaySmall(bool isDark) => AppTypography.createTextTheme(isDark: isDark).displaySmall!;
  static TextStyle titleMedium(bool isDark) => AppTypography.createTextTheme(isDark: isDark).titleMedium!;
  static TextStyle bodyMedium(bool isDark) => AppTypography.createTextTheme(isDark: isDark).bodyMedium!;
  static TextStyle bodySmall(bool isDark) => AppTypography.createTextTheme(isDark: isDark).bodySmall!;
}

class BrandSpacing {
  BrandSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class BrandRadii {
  BrandRadii._();

  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double circle = 999.0;

  static BorderRadius get cardRadius => BorderRadius.circular(xl);
  static BorderRadius get buttonRadius => BorderRadius.circular(lg);
  static BorderRadius get chipRadius => BorderRadius.circular(md);
}

class BrandShadows {
  BrandShadows._();

  static List<BoxShadow> subtleGlow(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.25),
          blurRadius: 16,
          spreadRadius: -2,
          offset: const Offset(0, 4),
        ),
      ];
}

class BrandAnimations {
  BrandAnimations._();

  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);

  static const Curve defaultCurve = Curves.easeOutCubic;
}
