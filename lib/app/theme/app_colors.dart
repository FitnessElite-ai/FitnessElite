import 'package:flutter/material.dart';

/// Centralized color system for FitnessElite.ai.
/// Provides dark and light surface colors, electric blue/cyan primary accent,
/// subtle violet secondary accent, premium glassmorphic overlays, and gradients.
class AppColors {
  AppColors._();

  // Primary Accent Colors
  static const Color electricBlue = Color(0xFF00F0FF);
  static const Color cyanAccent = Color(0xFF00E5FF);
  static const Color vividBlue = Color(0xFF007AFF);
  static const Color deepViolet = Color(0xFF8A2BE2);
  static const Color electricViolet = Color(0xFF9D4EDD);

  // Dark Theme Surface Palette
  static const Color darkBackground = Color(0xFF08090C);
  static const Color darkSurface = Color(0xFF10131B);
  static const Color darkSurfaceVariant = Color(0xFF181C28);
  static const Color darkCard = Color(0xFF1A1E2B);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0x99F8FAFC);
  static const Color darkTextMuted = Color(0x66F8FAFC);

  // Light Theme Surface Palette
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFEDF2F7);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0x990F172A);
  static const Color lightTextMuted = Color(0x660F172A);

  // Status & Feedback
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFB300);
  static const Color error = Color(0xFFFF5252);
  static const Color info = Color(0xFF00B0FF);

  // Glassmorphic & Overlay Colors (Dark Mode)
  static const Color darkGlassSurface = Color(0x1AFFFFFF); // 10% White
  static const Color darkGlassBorder = Color(0x26FFFFFF);  // 15% White
  static const Color darkGlassGlow = Color(0x3300F0FF);    // 20% Cyan

  // Glassmorphic & Overlay Colors (Light Mode)
  static const Color lightGlassSurface = Color(0xCCFFFFFF); // 80% White
  static const Color lightGlassBorder = Color(0x1F000000);  // 12% Black
  static const Color lightGlassGlow = Color(0x20007AFF);    // 12% Blue

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [electricBlue, vividBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient violetCyanGradient = LinearGradient(
    colors: [deepViolet, electricBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkBackgroundGradient = LinearGradient(
    colors: [darkBackground, darkSurface, Color(0xFF0D1017)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient lightBackgroundGradient = LinearGradient(
    colors: [lightBackground, lightSurfaceVariant, Color(0xFFE2E8F0)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient glassBorderGradientDark = LinearGradient(
    colors: [Color(0x40FFFFFF), Color(0x10FFFFFF), Color(0x3000F0FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassBorderGradientLight = LinearGradient(
    colors: [Color(0x30007AFF), Color(0x10000000), Color(0x20007AFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
