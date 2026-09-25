import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/animations/fade_in_animation.dart';
import '../../../../shared/animations/glass_entrance_animation.dart';
import '../../../../shared/animations/slide_in_animation.dart';
import '../../../../shared/widgets/fitness_elite_logo.dart';
import '../../providers/vision_assessment_provider.dart';
import '../widgets/insight_card.dart';

/// Screen displaying the generated Visual Fitness Insights.
class VisionResultsScreen extends ConsumerWidget {
  const VisionResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontalPadding = ResponsiveUtils.getHorizontalPadding(context);
    final state = ref.watch(visionAssessmentNotifierProvider);
    final assessment = state.completedAssessment;
    final insights = assessment?.insights ?? [];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const FitnessEliteLogo(
          iconSize: 26,
          fontSize: 18,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // AI Vision Preview Chip Badge
                      SlideInAnimation(
                        direction: SlideDirection.down,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.electricBlue.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.electricBlue),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.auto_awesome_rounded,
                                    size: 14, color: AppColors.electricBlue),
                                const SizedBox(width: 6),
                                Text(
                                  l10n.aiVisionPreview,
                                  style: const TextStyle(
                                    color: AppColors.electricBlue,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Header Title
                      SlideInAnimation(
                        direction: SlideDirection.up,
                        child: Text(
                          l10n.visualInsightsTitle,
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      FadeInAnimation(
                        delay: const Duration(milliseconds: 150),
                        child: Text(
                          l10n.visualEstimateDisclaimer,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Insight Cards List
                      ...insights.asMap().entries.map((entry) {
                        final index = entry.key;
                        final insight = entry.value;
                        final delay = 200 + (index * 100);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: InsightCard(
                            insight: insight,
                            delayMs: delay,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              // Bottom Action Button to Plan Preview
              Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
                child: GlassEntranceAnimation(
                  delay: const Duration(milliseconds: 600),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/plan-preview'),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                      label: Text(l10n.continueToPlanPreview),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
