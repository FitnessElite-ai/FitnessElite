import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/animations/fade_in_animation.dart';
import '../../../../shared/animations/glass_entrance_animation.dart';
import '../../../../shared/widgets/fitness_elite_logo.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../ai_coach/providers/ai_coach_provider.dart';
import '../../../workouts/providers/workout_session_provider.dart';

/// Progress Dashboard tracking real user performance, streaks, workouts, and target metrics.
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontalPadding = ResponsiveUtils.getHorizontalPadding(context);
    final historyRepo = ref.watch(workoutHistoryRepositoryProvider);
    final aiState = ref.watch(conversationNotifierProvider);

    final history = historyRepo.getWorkoutHistory();
    final streak = historyRepo.getCurrentStreak();
    final totalMin = historyRepo.getTotalWorkoutMinutes();
    final totalWorkouts = historyRepo.getTotalWorkoutsCompleted();

    final weight = aiState.completeProfile?.healthProfile.weightKg ?? 70.0;

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
                        child: Text(
                          'Performance Insights',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Key Performance Metrics Grid
                      GlassEntranceAnimation(
                        child: GlassCard(
                          padding: const EdgeInsets.all(18),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _MetricTile(
                                icon: Icons.local_fire_department_rounded,
                                label: 'STREAK',
                                value: '$streak Days',
                              ),
                              _MetricTile(
                                icon: Icons.fitness_center_rounded,
                                label: 'WORKOUTS',
                                value: '$totalWorkouts',
                              ),
                              _MetricTile(
                                icon: Icons.timer_rounded,
                                label: 'MINUTES',
                                value: '$totalMin min',
                              ),
                              _MetricTile(
                                icon: Icons.monitor_weight_rounded,
                                label: 'WEIGHT',
                                value: '${weight.toStringAsFixed(1)} kg',
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        'Weekly Activity & History',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),

                      const SizedBox(height: 10),

                      if (history.isEmpty) ...[
                        GlassCard(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: const [
                              Icon(Icons.history_rounded,
                                  size: 40, color: AppColors.electricBlue),
                              SizedBox(height: 10),
                              Text(
                                'No completed workouts recorded yet.',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Start your first workout from the Home Dashboard to track activity.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        ...history.reversed.take(10).map((log) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: GlassCard(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        log.dayTitle,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                                fontWeight: FontWeight.w800),
                                      ),
                                      Text(
                                        '${log.focus} • ${log.durationMinutes} min • Rating: ${log.feedbackRating}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: isDark
                                                  ? AppColors.darkTextSecondary
                                                  : AppColors.lightTextSecondary,
                                              fontSize: 11,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: AppColors.electricBlue,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
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

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.electricBlue),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: AppColors.electricBlue,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
      ],
    );
  }
}
