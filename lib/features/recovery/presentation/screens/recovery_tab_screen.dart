import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/animations/fade_in_animation.dart';
import '../../../../shared/animations/glass_entrance_animation.dart';
import '../../../../shared/widgets/fitness_elite_logo.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../breathwork/services/breathing_library.dart';
import '../../../breathwork/ui/screens/breathing_session_screen.dart';
import '../../../fitness_engine/providers/fitness_engine_provider.dart';
import '../../../yoga/services/yoga_library.dart';
import '../../../yoga/ui/screens/yoga_session_screen.dart';

/// Recover Tab Screen providing AI Recovery Insights, Sleep/Fatigue metrics, Yoga Mobility, and Breathwork sessions.
class RecoveryTabScreen extends ConsumerWidget {
  const RecoveryTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontalPadding = ResponsiveUtils.getHorizontalPadding(context);
    final engineState = ref.watch(fitnessEngineNotifierProvider);
    final recoveryPlan = engineState.currentPlan?.recoveryPlan;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const FitnessEliteLogo(iconSize: 26, fontSize: 18),
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
                      FadeInAnimation(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'RECOVER',
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Active recovery, mobility, and AI-guided breathwork for optimal repair.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Recovery Index Hero Card
                      GlassEntranceAnimation(
                        child: GlassCard(
                          padding: const EdgeInsets.all(20),
                          enableGlow: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'RECOVERY INDEX',
                                    style: TextStyle(
                                      color: AppColors.electricBlue,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.greenAccent.withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      '84% Optimal',
                                      style: TextStyle(
                                        color: Colors.greenAccent,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Ready for Normal Training',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Sleep and muscle fatigue signals indicate optimal energy capacity today.',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary,
                                    ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _RecoveryMetric('SLEEP TARGET', recoveryPlan?.sleepTargetHours ?? '7-8 hrs'),
                                  _RecoveryMetric('HYDRATION', recoveryPlan?.hydrationGuidance ?? '2.5 L'),
                                  _RecoveryMetric('REST DAYS', '${recoveryPlan?.restDaysPerWeek ?? 2} days/wk'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Breathwork Section
                      Text(
                        'BREATHWORK & CALM',
                        style: const TextStyle(
                          color: AppColors.electricBlue,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 10),

                      GlassEntranceAnimation(
                        delay: const Duration(milliseconds: 100),
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
                                      color: AppColors.electricBlue.withValues(alpha: 0.15),
                                    ),
                                    child: const Icon(Icons.air_rounded,
                                        color: AppColors.electricBlue, size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Post-Workout Recovery Breathing',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(fontWeight: FontWeight.w800),
                                        ),
                                        Text(
                                          '4s Inhale • 2s Hold • 6s Exhale',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    final exercise = BreathingLibrary.catalog[6]; // Post-workout recovery
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => BreathingSessionScreen(exercise: exercise),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.play_arrow_rounded, size: 20),
                                  label: const Text('Start Breathwork Session'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Yoga & Active Mobility Banner
                      Text(
                        'ACTIVE MOBILITY & YOGA',
                        style: const TextStyle(
                          color: AppColors.electricBlue,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 10),

                      GlassEntranceAnimation(
                        delay: const Duration(milliseconds: 150),
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
                                    child: const Icon(Icons.self_improvement_rounded,
                                        color: Colors.black, size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '10-Min Recovery Yoga Flow',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(fontWeight: FontWeight.w800),
                                        ),
                                        Text(
                                          'Child\'s Pose, Cat-Cow, Downward Dog, Cobra',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    final session = YogaLibrary.generateRecoverySession(durationMin: 10);
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => YogaSessionScreen(session: session),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.play_arrow_rounded, size: 20),
                                  label: const Text('Start Mobility Session'),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _RecoveryMetric extends StatelessWidget {
  final String label;
  final String value;
  const _RecoveryMetric(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.electricBlue,
            fontSize: 9,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}
