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
import '../../../../shared/widgets/glass_card.dart';
import '../../providers/vision_assessment_provider.dart';

/// Introduction Screen for Vision Fitness Assessment.
/// Explains visual baseline features, medical disclaimer, and offers "Start Assessment" or "Skip for now".
class VisionIntroScreen extends ConsumerWidget {
  const VisionIntroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontalPadding = ResponsiveUtils.getHorizontalPadding(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const FitnessEliteLogo(
          iconSize: 26,
          fontSize: 18,
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref
                  .read(visionAssessmentNotifierProvider.notifier)
                  .skipAssessment();
              context.go('/plan-preview');
            },
            child: Text(
              l10n.skipForNow,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
            ),
          ),
          const SizedBox(width: 8),
        ],
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
                      // Header Title
                      SlideInAnimation(
                        direction: SlideDirection.up,
                        child: Text(
                          l10n.visionIntroTitle,
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      FadeInAnimation(
                        delay: const Duration(milliseconds: 150),
                        child: Text(
                          l10n.visionIntroSubtitle,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 3 Benefit Cards
                      _BenefitCard(
                        delayMs: 250,
                        title: l10n.visualBaselineTitle,
                        subtitle: l10n.visualBaselineDesc,
                        icon: Icons.accessibility_new_rounded,
                      ),
                      const SizedBox(height: 12),

                      _BenefitCard(
                        delayMs: 350,
                        title: l10n.bodyBalanceTitle,
                        subtitle: l10n.bodyBalanceDesc,
                        icon: Icons.scale_rounded,
                      ),
                      const SizedBox(height: 12),

                      _BenefitCard(
                        delayMs: 450,
                        title: l10n.personalizationTitle,
                        subtitle: l10n.personalizationDesc,
                        icon: Icons.tune_rounded,
                      ),

                      const SizedBox(height: 24),

                      // Important Disclaimer
                      GlassEntranceAnimation(
                        delay: const Duration(milliseconds: 550),
                        child: GlassCard(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.info_outline_rounded,
                                color: AppColors.electricBlue,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  l10n.visionDisclaimer,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.lightTextSecondary,
                                        height: 1.4,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Action Buttons
              Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
                child: GlassEntranceAnimation(
                  delay: const Duration(milliseconds: 650),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () => context.go('/vision-capture'),
                          icon: const Icon(Icons.camera_alt_rounded, size: 20),
                          label: Text(l10n.startAssessment),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () {
                            ref
                                .read(visionAssessmentNotifierProvider.notifier)
                                .skipAssessment();
                            context.go('/plan-preview');
                          },
                          child: Text(l10n.skipForNow),
                        ),
                      ),
                    ],
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

class _BenefitCard extends StatelessWidget {
  final int delayMs;
  final String title;
  final String subtitle;
  final IconData icon;

  const _BenefitCard({
    required this.delayMs,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GlassEntranceAnimation(
      delay: Duration(milliseconds: delayMs),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
              ),
              child: Icon(
                icon,
                color: Colors.black,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.electricBlue,
                          letterSpacing: 1.1,
                        ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
