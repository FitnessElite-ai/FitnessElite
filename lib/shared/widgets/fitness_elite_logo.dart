import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Official FitnessElite.ai Logo & Wordmark Component.
/// Features the signature wing 'F' logo mark, two-tone "FitnessElite.ai" wordmark,
/// and "YOUR BODY. SIMULATED. OPTIMIZED." tagline.
class FitnessEliteLogo extends StatelessWidget {
  final double iconSize;
  final double fontSize;
  final bool showText;
  final bool showTagline;
  final String? taglineText;
  final Color? primaryTextColor;

  const FitnessEliteLogo({
    super.key,
    this.iconSize = 52.0,
    this.fontSize = 32.0,
    this.showText = true,
    this.showTagline = false,
    this.taglineText = 'YOUR BODY. SIMULATED. OPTIMIZED.',
    this.primaryTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultTextColor = primaryTextColor ??
        (isDark ? AppColors.darkTextPrimary : const Color(0xFF0B132B));

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Custom Painter Stylized Wing 'F' Logo Mark
            SizedBox(
              width: iconSize * 1.2,
              height: iconSize,
              child: CustomPaint(
                painter: _FitnessEliteWingLogoPainter(),
              ),
            ),

            if (showText) ...[
              SizedBox(width: iconSize * 0.2),

              // "FitnessElite.ai" Two-Tone Wordmark
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Fitness',
                      style: TextStyle(
                        fontFamily: '.SF Pro Text',
                        fontSize: fontSize,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.0,
                        color: defaultTextColor,
                      ),
                    ),
                    TextSpan(
                      text: 'Elite',
                      style: TextStyle(
                        fontFamily: '.SF Pro Text',
                        fontSize: fontSize,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.0,
                        color: const Color(0xFF0066FF),
                      ),
                    ),
                    TextSpan(
                      text: '.ai',
                      style: TextStyle(
                        fontFamily: '.SF Pro Text',
                        fontSize: fontSize,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: AppColors.electricBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),

        if (showTagline && taglineText != null) ...[
          const SizedBox(height: 8),
          Text(
            taglineText!,
            style: TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: fontSize * 0.32,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.4,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : const Color(0xFF1E293B),
            ),
          ),
        ],
      ],
    );
  }
}

/// Custom Painter drawing the official wing 'F' logo icon for FitnessElite.ai
class _FitnessEliteWingLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Top Wing Gradient (Cyan to Royal Blue)
    final topGradient = const LinearGradient(
      colors: [Color(0xFF00F0FF), Color(0xFF007AFF), Color(0xFF0040DD)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Offset.zero & size);

    // Mid/Lower Wing Gradient (Deep Vivid Blue to Cyan)
    final midGradient = const LinearGradient(
      colors: [Color(0xFF0038FF), Color(0xFF0088FF), Color(0xFF00F0FF)],
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
    ).createShader(Offset.zero & size);

    final topPaint = Paint()
      ..shader = topGradient
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final midPaint = Paint()
      ..shader = midGradient
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // 1. Top Wing Swoosh
    final topWing = Path();
    topWing.moveTo(width * 0.22, height * 0.02);
    topWing.cubicTo(
      width * 0.55, height * -0.05,
      width * 0.90, height * 0.08,
      width * 1.00, height * 0.28,
    );
    topWing.cubicTo(
      width * 0.82, height * 0.42,
      width * 0.45, height * 0.42,
      width * 0.18, height * 0.38,
    );
    topWing.cubicTo(
      width * 0.05, height * 0.22,
      width * 0.10, height * 0.10,
      width * 0.22, height * 0.02,
    );
    topWing.close();

    // 2. Middle Wing Bar
    final midWing = Path();
    midWing.moveTo(width * 0.20, height * 0.44);
    midWing.cubicTo(
      width * 0.50, height * 0.38,
      width * 0.72, height * 0.42,
      width * 0.82, height * 0.54,
    );
    midWing.cubicTo(
      width * 0.65, height * 0.68,
      width * 0.38, height * 0.66,
      width * 0.12, height * 0.68,
    );
    midWing.cubicTo(
      width * 0.06, height * 0.58,
      width * 0.10, height * 0.48,
      width * 0.20, height * 0.44,
    );
    midWing.close();

    // 3. Left Vertical Stem Curve
    final stemCurve = Path();
    stemCurve.moveTo(width * 0.28, height * 0.68);
    stemCurve.cubicTo(
      width * 0.20, height * 0.78,
      width * 0.08, height * 0.88,
      width * 0.00, height * 0.98,
    );
    stemCurve.cubicTo(
      width * 0.12, height * 0.92,
      width * 0.25, height * 0.78,
      width * 0.38, height * 0.72,
    );
    stemCurve.close();

    canvas.drawPath(topWing, topPaint);
    canvas.drawPath(midWing, midPaint);
    canvas.drawPath(stemCurve, midPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
