import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Lightweight 3D depth container for FitnessElite.ai.
/// Provides visual elevation, layered card perspective, and subtle depth effects.
class DepthContainer extends StatelessWidget {
  final Widget child;
  final double depth;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final LinearGradient? gradient;
  final VoidCallback? onTap;

  const DepthContainer({
    super.key,
    required this.child,
    this.depth = 12.0,
    this.borderRadius = 24.0,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final baseColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkGlassBorder : AppColors.lightGlassBorder;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          // Depth shadow 1 (ambient glow)
          BoxShadow(
            color: isDark
                ? AppColors.electricBlue.withValues(alpha: 0.12)
                : AppColors.vividBlue.withValues(alpha: 0.08),
            blurRadius: depth * 2,
            spreadRadius: 1,
            offset: Offset(0, depth / 2),
          ),
          // Depth shadow 2 (directional dark elevation)
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.5)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: depth,
            offset: Offset(0, depth / 1.5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: gradient == null ? baseColor : null,
              gradient: gradient,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: borderColor, width: 1.2),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Interactive 3D Tilt Card that subtly rotates in 3D space on gesture/touch.
class Subtle3DTiltCard extends StatefulWidget {
  final Widget child;
  final double maxTiltAngle;
  final double borderRadius;
  final VoidCallback? onTap;

  const Subtle3DTiltCard({
    super.key,
    required this.child,
    this.maxTiltAngle = 0.08, // in radians (~4.5 deg)
    this.borderRadius = 24.0,
    this.onTap,
  });

  @override
  State<Subtle3DTiltCard> createState() => _Subtle3DTiltCardState();
}

class _Subtle3DTiltCardState extends State<Subtle3DTiltCard> {
  double _rotateX = 0;
  double _rotateY = 0;

  void _onPointerMove(PointerEvent event, Size size) {
    if (size.width == 0 || size.height == 0) return;
    final dx = (event.localPosition.dx - (size.width / 2)) / (size.width / 2);
    final dy = (event.localPosition.dy - (size.height / 2)) / (size.height / 2);

    setState(() {
      _rotateX = -dy * widget.maxTiltAngle;
      _rotateY = dx * widget.maxTiltAngle;
    });
  }

  void _onPointerReset() {
    setState(() {
      _rotateX = 0;
      _rotateY = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        return Listener(
          onPointerDown: (e) => _onPointerMove(e, size),
          onPointerMove: (e) => _onPointerMove(e, size),
          onPointerUp: (_) => _onPointerReset(),
          onPointerCancel: (_) => _onPointerReset(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // perspective
              ..rotateX(_rotateX)
              ..rotateY(_rotateY),
            alignment: FractionalOffset.center,
            child: GestureDetector(
              onTap: widget.onTap,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}
