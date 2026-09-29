import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Simple, Minimal, and Professional FitnessElite.ai Logo Component.
/// Combines a sleek squircle AI emblem with two-tone "FitnessElite.ai" wordmark.
class FitnessEliteLogo extends StatelessWidget {
  final double iconSize;
  final double fontSize;
  final bool showText;
  final bool showTagline;
  final String? taglineText;
  final Color? primaryTextColor;

  const FitnessEliteLogo({
    super.key,
    this.iconSize = 44.0,
    this.fontSize = 24.0,
    this.showText = true,
    this.showTagline = false,
    this.taglineText = 'AUTONOMOUS FITNESS OS',
    this.primaryTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultTextColor = primaryTextColor ??
        (isDark ? AppColors.darkTextPrimary : const Color(0xFF0F172A));

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Sleek Minimalist Squircle Emblem
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(iconSize * 0.28),
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF101522), const Color(0xFF1A2234)]
                      : [const Color(0xFF0F172A), const Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: AppColors.electricBlue.withValues(alpha: 0.4),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.electricBlue.withValues(alpha: 0.18),
                    blurRadius: 12,
                    spreadRadius: -2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: SizedBox(
                  width: iconSize * 0.52,
                  height: iconSize * 0.52,
                  child: CustomPaint(
                    painter: _FitnessEliteMinimalLogoPainter(),
                  ),
                ),
              ),
            ),

            if (showText) ...[
              SizedBox(width: iconSize * 0.22),

              // "FitnessElite.ai" Clean Wordmark
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Fitness',
                      style: TextStyle(
                        fontFamily: '.SF Pro Text',
                        fontSize: fontSize,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: defaultTextColor,
                      ),
                    ),
                    TextSpan(
                      text: 'Elite',
                      style: TextStyle(
                        fontFamily: '.SF Pro Text',
                        fontSize: fontSize,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: AppColors.electricBlue,
                      ),
                    ),
                    TextSpan(
                      text: '.ai',
                      style: TextStyle(
                        fontFamily: '.SF Pro Text',
                        fontSize: fontSize,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: AppColors.cyanAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),

        if (showTagline && taglineText != null) ...[
          const SizedBox(height: 6),
          Text(
            taglineText!,
            style: TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: fontSize * 0.28,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

/// Custom Painter drawing a sleek geometric athletic 'F' + AI Sparkle Dot
class _FitnessEliteMinimalLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00F0FF), Color(0xFF007AFF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.18
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    // Sleek Athletic 'F'
    final fPath = Path();
    // Vertical stem
    fPath.moveTo(w * 0.22, h * 0.90);
    fPath.lineTo(w * 0.22, h * 0.12);
    // Top bar
    fPath.lineTo(w * 0.88, h * 0.12);
    // Middle bar
    fPath.moveTo(w * 0.22, h * 0.50);
    fPath.lineTo(w * 0.72, h * 0.50);

    canvas.drawPath(fPath, paint);

    // AI Sparkle Dot (Top Right Accent)
    final sparkPaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawCircle(Offset(w * 0.88, h * 0.82), w * 0.12, sparkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
