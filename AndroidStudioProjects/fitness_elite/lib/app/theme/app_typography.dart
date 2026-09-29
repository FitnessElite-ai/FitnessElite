import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized typography hierarchy for FitnessElite.ai.
/// Provides large display fonts, bold headers, clean body, and compact labels.
class AppTypography {
  AppTypography._();

  static const String _fontFamily = '.SF Pro Text'; // Default fallback to system premium font

  static TextTheme createTextTheme({required bool isDark}) {
    final primaryColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return TextTheme(
      // Display typography - Large & bold for key stats & titles
      displayLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 40,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.2,
        height: 1.15,
        color: primaryColor,
      ),
      displayMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        height: 1.2,
        color: primaryColor,
      ),
      displaySmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.25,
        color: primaryColor,
      ),

      // Headlines - Bold section headers
      headlineLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        height: 1.3,
        color: primaryColor,
      ),
      headlineMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.3,
        color: primaryColor,
      ),
      headlineSmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.35,
        color: primaryColor,
      ),

      // Titles - Card & subsection headers
      titleLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        height: 1.35,
        color: primaryColor,
      ),
      titleMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.4,
        color: primaryColor,
      ),
      titleSmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.4,
        color: secondaryColor,
      ),

      // Body - Readable content
      bodyLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        height: 1.5,
        color: primaryColor,
      ),
      bodyMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        height: 1.45,
        color: primaryColor,
      ),
      bodySmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
        height: 1.4,
        color: secondaryColor,
      ),

      // Labels - Buttons, chips, compact tags
      labelLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.25,
        color: primaryColor,
      ),
      labelMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        height: 1.25,
        color: secondaryColor,
      ),
      labelSmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        height: 1.2,
        color: secondaryColor,
      ),
    );
  }
}
