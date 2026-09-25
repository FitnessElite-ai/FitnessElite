import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/responsive_utils.dart';
import '../../shared/animations/fade_in_animation.dart';
import '../../shared/animations/glass_entrance_animation.dart';
import '../../shared/animations/slide_in_animation.dart';
import '../../shared/widgets/fitness_elite_logo.dart';
import '../../shared/widgets/glass_card.dart';
import '../auth/presentation/providers/auth_provider.dart';
import '../health_assessment/presentation/providers/health_assessment_provider.dart';

/// Placeholder screen for Home Dashboard.
/// Displays user's calculated BMI and biometric summary.
class HomePlaceholderScreen extends ConsumerWidget {
  const HomePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontalPadding = ResponsiveUtils.getHorizontalPadding(context);
    final assessmentState = ref.watch(healthAssessmentNotifierProvider);
    final profile = assessmentState.savedProfile;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const FitnessEliteLogo(
          iconSize: 26,
          fontSize: 18,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: l10n.signOut,
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/auth');
              }
            },
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
                      // Header
                      SlideInAnimation(
                        direction: SlideDirection.up,
                        child: Text(
                          l10n.homeDashboardTitle,
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      FadeInAnimation(
                        delay: const Duration(milliseconds: 150),
                        child: Text(
                          l10n.homeDashboardSubtitle,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Profile Metric Summary Card
                      if (profile != null)
                        GlassEntranceAnimation(
                          delay: const Duration(milliseconds: 250),
                          child: GlassCard(
                            enableGlow: true,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: AppColors.primaryGradient,
                                      ),
                                      child: const Icon(
                                        Icons.person_rounded,
                                        color: Colors.black,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            profile.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w800,
                                                ),
                                          ),
                                          Text(
                                            '${profile.age} yrs • ${profile.sex}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),
                                const Divider(),
                                const SizedBox(height: 16),

                                // Metric Badges
                                Row(
                                  children: [
                                    Expanded(
                                      child: _MetricTile(
                                        title: l10n.bmiValue,
                                        value: '${profile.bmi}',
                                        subtitle: profile.bmiCategory,
                                        highlight: true,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _MetricTile(
                                        title: l10n.heightCm.split(' ').first,
                                        value: '${profile.heightCm} cm',
                                        subtitle: '${profile.weightKg} kg',
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                _DetailRow(
                                  icon: Icons.fitness_center_rounded,
                                  label: l10n.step3Title.split('?').first,
                                  value: profile.primaryGoal,
                                ),
                                const SizedBox(height: 10),
                                _DetailRow(
                                  icon: Icons.directions_run_rounded,
                                  label: l10n.step2Title.split('?').first,
                                  value: profile.activityLevel,
                                ),
                                const SizedBox(height: 10),
                                _DetailRow(
                                  icon: Icons.schedule_rounded,
                                  label: l10n.workoutDaysPerWeek,
                                  value: profile.workoutDays,
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Next Phase Info Card
                      GlassEntranceAnimation(
                        delay: const Duration(milliseconds: 350),
                        child: GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI Digital Twin & Vision Engine',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Next phases will generate personalized AI workouts, nutrition fuel plans, and vision body posture tracking based on your biometric profile.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary,
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

              // Bottom Button to Retake Assessment
              Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
                child: GlassEntranceAnimation(
                  delay: const Duration(milliseconds: 450),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ref
                            .read(healthAssessmentNotifierProvider.notifier)
                            .setStep(0);
                        context.go('/health-assessment');
                      },
                      icon: const Icon(Icons.edit_rounded, size: 20),
                      label: Text(l10n.healthAssessment),
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

class _MetricTile extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final bool highlight;

  const _MetricTile({
    required this.title,
    required this.value,
    required this.subtitle,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.electricBlue.withValues(alpha: 0.15)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight ? AppColors.electricBlue : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: highlight ? AppColors.electricBlue : null,
                ),
          ),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: highlight ? AppColors.electricBlue : null,
                ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.electricBlue),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}
