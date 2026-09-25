import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/animations/fade_in_animation.dart';
import '../../../../shared/animations/glass_entrance_animation.dart';
import '../../../../shared/widgets/fitness_elite_logo.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../providers/workout_session_provider.dart';

/// Post-workout Completion Screen displaying session metrics and collecting user effort feedback.
class WorkoutCompleteScreen extends ConsumerWidget {
  const WorkoutCompleteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontalPadding = ResponsiveUtils.getHorizontalPadding(context);
    final sessionState = ref.watch(workoutSessionNotifierProvider);
    final notifier = ref.read(workoutSessionNotifierProvider.notifier);
    final historyRepo = ref.watch(workoutHistoryRepositoryProvider);

    final durationMin = (sessionState.totalDurationSeconds / 60).ceil().clamp(1, 120);
    final streak = historyRepo.getCurrentStreak() + 1;

    final feedbackOptions = ['Easy', 'Good', 'Challenging', 'Very challenging'];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
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
                    children: [
                      // Celebration Trophy Badge
                      GlassEntranceAnimation(
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.primaryGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.electricBlue.withValues(alpha: 0.4),
                                blurRadius: 28,
                                spreadRadius: 6,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.emoji_events_rounded,
                            color: Colors.black,
                            size: 52,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      FadeInAnimation(
                        child: Text(
                          'Workout Complete!',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        'Great job crushing your session. Session metrics recorded.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 24),

                      // Metrics Banner
                      GlassEntranceAnimation(
                        child: GlassCard(
                          padding: const EdgeInsets.all(18),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _StatItem(
                                icon: Icons.timer_rounded,
                                label: 'DURATION',
                                value: '$durationMin min',
                              ),
                              _StatItem(
                                icon: Icons.fitness_center_rounded,
                                label: 'EXERCISES',
                                value: '${sessionState.workoutDay?.exercises.length ?? 0}',
                              ),
                              _StatItem(
                                icon: Icons.check_circle_rounded,
                                label: 'SETS',
                                value: '${sessionState.completedSetsTotal}',
                              ),
                              _StatItem(
                                icon: Icons.local_fire_department_rounded,
                                label: 'STREAK',
                                value: '$streak days',
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Feedback Rating Question
                      GlassEntranceAnimation(
                        child: GlassCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'How did this workout feel?',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w800),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 14),

                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                alignment: WrapAlignment.center,
                                children: feedbackOptions.map((option) {
                                  final isSelected =
                                      sessionState.selectedFeedback == option;
                                  return ChoiceChip(
                                    label: Text(option),
                                    selected: isSelected,
                                    selectedColor: AppColors.electricBlue,
                                    labelStyle: TextStyle(
                                      color: isSelected
                                          ? Colors.black
                                          : (isDark
                                              ? AppColors.darkTextPrimary
                                              : AppColors.lightTextPrimary),
                                      fontWeight: FontWeight.w700,
                                    ),
                                    onSelected: (selected) {
                                      if (selected) {
                                        notifier.saveWorkoutFeedback(option);
                                      }
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Return Home CTA
              Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
                child: GlassEntranceAnimation(
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/home'),
                      icon: const Icon(Icons.home_rounded, size: 20),
                      label: const Text('Return to Home Dashboard'),
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

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
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
            letterSpacing: 0.8,
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
