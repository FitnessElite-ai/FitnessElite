import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/animations/glass_entrance_animation.dart';
import '../../../../shared/widgets/fitness_elite_logo.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../fitness_engine/models/exercise.dart';
import '../../../fitness_engine/models/warmup_cooldown.dart';
import '../../providers/workout_session_provider.dart';
import 'workout_complete_screen.dart';

/// Full interactive Workout Execution Screen handling Warm-up, Exercises, Breathing Coaching, Rest Timers, and Cooldown.
class WorkoutExecutionScreen extends ConsumerWidget {
  const WorkoutExecutionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final horizontalPadding = ResponsiveUtils.getHorizontalPadding(context);
    final sessionState = ref.watch(workoutSessionNotifierProvider);
    final notifier = ref.read(workoutSessionNotifierProvider.notifier);

    final day = sessionState.workoutDay;

    if (day == null) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const FitnessEliteLogo(iconSize: 26, fontSize: 18),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No active workout session.'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Return to Home'),
              ),
            ],
          ),
        ),
      );
    }

    if (sessionState.stage == SessionStage.complete) {
      return const WorkoutCompleteScreen();
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.go('/home'),
          tooltip: 'Exit Workout',
        ),
        title: Column(
          children: [
            Text(
              day.title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            Text(
              '${(sessionState.totalDurationSeconds ~/ 60).toString().padLeft(2, '0')}:${(sessionState.totalDurationSeconds % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: AppColors.electricBlue,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              sessionState.isPaused
                  ? Icons.play_arrow_rounded
                  : Icons.pause_rounded,
              color: AppColors.electricBlue,
            ),
            onPressed: notifier.togglePause,
            tooltip: sessionState.isPaused ? 'Resume' : 'Pause',
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
                      // Stage Header
                      _StageHeader(stage: sessionState.stage),

                      const SizedBox(height: 16),

                      if (sessionState.stage == SessionStage.warmup) ...[
                        _WarmupStageView(focus: day.focus),
                      ] else if (sessionState.stage == SessionStage.rest) ...[
                        _RestTimerStageView(
                          remainingSeconds: sessionState.restSecondsRemaining,
                          nextExercise: sessionState.currentExercise,
                        ),
                      ] else if (sessionState.stage == SessionStage.cooldown) ...[
                        _CooldownStageView(focus: day.focus),
                      ] else ...[
                        _ExerciseStageView(
                          exercise: sessionState.currentExercise,
                          activeSetIndex: sessionState.currentSetIndex,
                          onReplacePressed: notifier.replaceExerciseWithAlternative,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Bottom Action Bar
              Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
                child: GlassEntranceAnimation(
                  child: _BottomActionBar(
                    stage: sessionState.stage,
                    sessionState: sessionState,
                    notifier: notifier,
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

class _StageHeader extends StatelessWidget {
  final SessionStage stage;

  const _StageHeader({required this.stage});

  @override
  Widget build(BuildContext context) {
    String label = 'WARM-UP PROTOCOL';
    if (stage == SessionStage.exercise) label = 'ACTIVE EXERCISE';
    if (stage == SessionStage.rest) label = 'REST & RECOVERY TIMER';
    if (stage == SessionStage.cooldown) label = 'COOL-DOWN & MOBILITY';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.electricBlue.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.electricBlue.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.fitness_center_rounded,
              size: 14, color: AppColors.electricBlue),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.electricBlue,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _WarmupStageView extends StatelessWidget {
  final String focus;

  const _WarmupStageView({required this.focus});

  @override
  Widget build(BuildContext context) {
    final items = WarmupCooldownLibrary.getWarmupForFocus(focus);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Targeted Warm-Up Protocol',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          'Prepare joints, elevate core body temperature, and prime nervous system for $focus.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '${item.durationSeconds}s',
                          style: const TextStyle(
                              color: AppColors.electricBlue,
                              fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(item.instructions,
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.air_rounded,
                            size: 14, color: AppColors.electricBlue),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.breathingGuidance,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: AppColors.electricBlue),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}

class _RestTimerStageView extends StatelessWidget {
  final int remainingSeconds;
  final Exercise? nextExercise;

  const _RestTimerStageView({
    required this.remainingSeconds,
    this.nextExercise,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),

        // Animated Rest Timer Circle
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.electricBlue.withValues(alpha: 0.3),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Center(
            child: Text(
              '${remainingSeconds}s',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),
        Text(
          'Catch your breath & hydrate',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),

        if (nextExercise != null) ...[
          const SizedBox(height: 20),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'UPCOMING EXERCISE',
                  style: TextStyle(
                    color: AppColors.electricBlue,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  nextExercise!.name,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                Text(
                  'Target: ${nextExercise!.sets} sets × ${nextExercise!.reps}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ExerciseStageView extends StatelessWidget {
  final Exercise? exercise;
  final int activeSetIndex;
  final VoidCallback onReplacePressed;

  const _ExerciseStageView({
    required this.exercise,
    required this.activeSetIndex,
    required this.onReplacePressed,
  });

  @override
  Widget build(BuildContext context) {
    if (exercise == null) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Exercise Title & Replace Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise!.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  Text(
                    '${exercise!.muscleGroup} • Target: ${exercise!.sets} sets × ${exercise!.reps}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.electricBlue,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: onReplacePressed,
              icon: const Icon(Icons.swap_horiz_rounded, size: 16),
              label: const Text('Replace'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Set Progress Tracker
        Row(
          children: List.generate(exercise!.sets, (index) {
            final setNum = index + 1;
            final isCurrent = setNum == activeSetIndex;
            final isDone = setNum < activeSetIndex;

            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isDone
                      ? AppColors.electricBlue
                      : isCurrent
                          ? AppColors.electricBlue.withValues(alpha: 0.25)
                          : isDark
                              ? AppColors.darkSurfaceVariant
                              : AppColors.lightSurfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                  border: isCurrent
                      ? Border.all(color: AppColors.electricBlue, width: 1.5)
                      : null,
                ),
                child: Center(
                  child: Text(
                    'SET $setNum',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: isDone ? Colors.black : AppColors.electricBlue,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 16),

        // Breathing Coaching Banner
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.air_rounded, color: AppColors.electricBlue, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'EXERCISE-SPECIFIC BREATHING COACHING',
                    style: TextStyle(
                      color: AppColors.electricBlue,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                exercise!.breathingPattern,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.arrow_downward_rounded,
                      size: 14, color: AppColors.electricBlue),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(exercise!.inhaleInstruction,
                        style: Theme.of(context).textTheme.bodySmall),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.arrow_upward_rounded,
                      size: 14, color: AppColors.electricBlue),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(exercise!.exhaleInstruction,
                        style: Theme.of(context).textTheme.bodySmall),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Execution & Form Cues
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SETUP & EXECUTION',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.electricBlue,
                        fontWeight: FontWeight.w800,
                      )),
              const SizedBox(height: 4),
              Text(exercise!.setupInstructions,
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 10),
              Text('FORM CUES',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.electricBlue,
                        fontWeight: FontWeight.w800,
                      )),
              ...exercise!.formCues.map((cue) => Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline_rounded,
                            size: 14, color: AppColors.electricBlue),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(cue,
                              style: Theme.of(context).textTheme.bodySmall),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Common Mistakes & Safety
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SAFETY & MISTAKES TO AVOID',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w800,
                      )),
              const SizedBox(height: 4),
              Text(exercise!.safetyNotes,
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 6),
              ...exercise!.commonMistakes.map((mistake) => Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            size: 14, color: AppColors.error),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(mistake,
                              style: Theme.of(context).textTheme.bodySmall),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }
}

class _CooldownStageView extends StatelessWidget {
  final String focus;

  const _CooldownStageView({required this.focus});

  @override
  Widget build(BuildContext context) {
    final items = WarmupCooldownLibrary.getCooldownForFocus(focus);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Post-Workout Cool-Down',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          'Lower heart rate, reduce parasympathetic recovery latency, and restore flexibility.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '${item.durationSeconds}s',
                          style: const TextStyle(
                              color: AppColors.electricBlue,
                              fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(item.instructions,
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.air_rounded,
                            size: 14, color: AppColors.electricBlue),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.breathingGuidance,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: AppColors.electricBlue),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  final SessionStage stage;
  final WorkoutSessionState sessionState;
  final WorkoutSessionNotifier notifier;

  const _BottomActionBar({
    required this.stage,
    required this.sessionState,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    if (stage == SessionStage.warmup) {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: notifier.completeWarmup,
          icon: const Icon(Icons.play_arrow_rounded, size: 20),
          label: const Text('Start Exercises'),
        ),
      );
    }

    if (stage == SessionStage.rest) {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: notifier.skipRest,
          icon: const Icon(Icons.skip_next_rounded, size: 20),
          label: const Text('Skip Rest & Continue'),
        ),
      );
    }

    if (stage == SessionStage.cooldown) {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: notifier.completeCooldown,
          icon: const Icon(Icons.check_circle_rounded, size: 20),
          label: const Text('Finish Workout'),
        ),
      );
    }

    // Exercise stage
    final ex = sessionState.currentExercise;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: notifier.completeSet,
        icon: const Icon(Icons.check_rounded, size: 20),
        label: Text('Complete Set ${sessionState.currentSetIndex} of ${ex?.sets ?? 3}'),
      ),
    );
  }
}
