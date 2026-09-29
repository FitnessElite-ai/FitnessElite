import 'dart:ui';
import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Reusable Glassmorphic Card widget for FitnessElite.ai.
/// Provides a frosted glass look with translucent surface, subtle gradient border,
/// theme awareness (dark/light mode), soft ambient glow/shadow, and performant blur.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blurSigma;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool enableGlow;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.borderRadius = 24.0,
    this.blurSigma = 10.0,
    this.backgroundColor,
    this.borderColor,
    this.enableGlow = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultBgColor = isDark
        ? AppColors.darkGlassSurface
        : AppColors.lightGlassSurface;

    final defaultBorderColor = isDark
        ? AppColors.darkGlassBorder
        : AppColors.lightGlassBorder;

    final defaultGlowColor = isDark
        ? AppColors.darkGlassGlow
        : AppColors.lightGlassGlow;

    final cardContent = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor ?? defaultBgColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ?? defaultBorderColor,
              width: 1.2,
            ),
          ),
          child: child,
        ),
      ),
    );

    final container = Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: enableGlow
            ? [
                BoxShadow(
                  color: defaultGlowColor,
                  blurRadius: 24,
                  spreadRadius: -4,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: cardContent,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: container,
        ),
      );
    }

    return container;
  }
}
