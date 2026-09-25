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
import '../../providers/ai_coach_provider.dart';

/// Personalized Plan Preview Screen for FitnessElite.ai.
class PlanPreviewScreen extends ConsumerWidget {
  const PlanPreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontalPadding = ResponsiveUtils.getHorizontalPadding(context);
    final conversationState = ref.watch(conversationNotifierProvider);
    final completeProfile = conversationState.completeProfile;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const FitnessEliteLogo(
          iconSize: 26,
          fontSize: 18,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/ai-coach'),
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
                      // Header Title
                      SlideInAnimation(
                        direction: SlideDirection.up,
                        child: Text(
                          'Your personalized plan is next.',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Subtitle
                      FadeInAnimation(
                        delay: const Duration(milliseconds: 150),
                        child: Text(
                          'FitnessElite AI is ready to turn your profile into a plan built around your body, goals, and lifestyle.',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Section 1: WORKOUT PREVIEW
                      _PlanSectionCard(
                        delayMs: 250,
                        title: 'WORKOUT',
                        subtitle: 'Custom Volume & Training Split',
                        icon: Icons.fitness_center_rounded,
                        gradient: AppColors.primaryGradient,
                        details: [
                          'Goal: ${completeProfile?.fitnessPreferences.primaryGoal ?? conversationState.primaryGoal}',
                          'Time: ${completeProfile?.fitnessPreferences.dailyTrainingTime ?? conversationState.dailyTrainingTime}',
                          'Location: ${completeProfile?.fitnessPreferences.preferredLocation ?? conversationState.preferredLocation}',
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Section 2: NUTRITION PREVIEW
                      _PlanSectionCard(
                        delayMs: 350,
                        title: 'NUTRITION',
                        subtitle: 'Target Protein & Macro Distribution',
                        icon: Icons.restaurant_rounded,
                        gradient: AppColors.violetCyanGradient,
                        details: [
                          'Diet: ${completeProfile?.fitnessPreferences.dietaryPreference ?? conversationState.dietaryPreference}',
                          'Metabolic Baseline: Calculated from BMI (${completeProfile?.healthProfile.bmi ?? '22.5'})',
                          'Fuel Strategy: Precision Caloric Adjustment',
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Section 3: RECOVERY PREVIEW
                      _PlanSectionCard(
                        delayMs: 450,
                        title: 'RECOVERY',
                        subtitle: 'Sleep & Muscle Repair Optimization',
                        icon: Icons.bedtime_rounded,
                        gradient: AppColors.primaryGradient,
                        details: [
                          'Sleep Target: ${completeProfile?.healthProfile.sleepDuration ?? '7-8 hours'}',
                          'Consistency Guard: Adapted to ${completeProfile?.fitnessPreferences.consistencyBarrier ?? conversationState.consistencyBarrier}',
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Section 4: PROGRESS PREVIEW
                      _PlanSectionCard(
                        delayMs: 550,
                        title: 'PROGRESS',
                        subtitle: 'Biomechanical Digital Twin Trajectory',
                        icon: Icons.trending_up_rounded,
                        gradient: AppColors.violetCyanGradient,
                        details: [
                          'Biometric Profile: ${completeProfile?.healthProfile.name ?? 'Fitness Athlete'}',
                          'Tracking Engine: Adaptive Load Adjustment',
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Continue Action Button
              Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
                child: GlassEntranceAnimation(
                  delay: const Duration(milliseconds: 650),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => context.go('/home'),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(l10n.continueButton),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
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

class _PlanSectionCard extends StatelessWidget {
  final int delayMs;
  final String title;
  final String subtitle;
  final IconData icon;
  final LinearGradient gradient;
  final List<String> details;

  const _PlanSectionCard({
    required this.delayMs,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
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
                    borderRadius: BorderRadius.circular(12),
                    gradient: gradient,
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
                              letterSpacing: 1.2,
                              color: AppColors.electricBlue,
                            ),
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(),
            const SizedBox(height: 10),
            ...details.map((detail) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 16,
                      color: AppColors.electricBlue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        detail,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
