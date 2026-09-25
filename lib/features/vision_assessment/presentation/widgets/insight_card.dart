import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/animations/glass_entrance_animation.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../models/vision_insight.dart';

class InsightCard extends StatelessWidget {
  final VisionInsight insight;
  final int delayMs;

  const InsightCard({
    super.key,
    required this.insight,
    this.delayMs = 200,
  });

  IconData _getCategoryIcon(String category) {
    switch (category.toUpperCase()) {
      case 'POSTURE':
        return Icons.accessibility_new_rounded;
      case 'BODY BALANCE':
        return Icons.scale_rounded;
      case 'TRAINING FOCUS':
        return Icons.fitness_center_rounded;
      case 'PROGRESS BASELINE':
        return Icons.trending_up_rounded;
      default:
        return Icons.auto_awesome_rounded;
    }
  }

  String _getConfidenceLabel(ConfidenceLevel level) {
    switch (level) {
      case ConfidenceLevel.low:
        return 'Visual estimate • Low confidence';
      case ConfidenceLevel.moderate:
        return 'General observation • Moderate confidence';
      case ConfidenceLevel.high:
        return 'Visual baseline • Moderate confidence';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassEntranceAnimation(
      delay: Duration(milliseconds: delayMs),
      child: GlassCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                  ),
                  child: Icon(
                    _getCategoryIcon(insight.category),
                    color: Colors.black,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insight.category,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.electricBlue,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                            ),
                      ),
                      Text(
                        insight.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Text(
              insight.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                    height: 1.4,
                  ),
            ),

            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 16,
                  color: AppColors.electricBlue,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    insight.recommendation,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.electricBlue,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getConfidenceLabel(insight.confidence),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                        fontSize: 10,
                      ),
                ),
                Text(
                  l10n.visualEstimateDisclaimer,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                        fontSize: 9,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
