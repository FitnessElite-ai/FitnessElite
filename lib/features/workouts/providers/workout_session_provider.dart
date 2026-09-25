import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/persistence_providers.dart';
import '../../fitness_engine/models/exercise.dart';
import '../../fitness_engine/models/workout_day.dart';
import '../../fitness_engine/services/exercise_library.dart';
import '../models/workout_history_log.dart';
import '../repositories/workout_history_repository.dart';

enum SessionStage { warmup, exercise, rest, cooldown, complete }

final workoutHistoryRepositoryProvider = Provider<WorkoutHistoryRepository>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return LocalWorkoutHistoryRepository(storage);
});

class WorkoutSessionState {
  final WorkoutDay? workoutDay;
  final SessionStage stage;
  final int activeExerciseIndex;
  final int currentSetIndex;
  final int completedSetsTotal;
  final int restSecondsRemaining;
  final bool isPaused;
  final int totalDurationSeconds;
  final String? selectedFeedback;

  const WorkoutSessionState({
    this.workoutDay,
    this.stage = SessionStage.warmup,
    this.activeExerciseIndex = 0,
    this.currentSetIndex = 1,
    this.completedSetsTotal = 0,
    this.restSecondsRemaining = 0,
    this.isPaused = false,
    this.totalDurationSeconds = 0,
    this.selectedFeedback,
  });

  Exercise? get currentExercise {
    if (workoutDay == null ||
        workoutDay!.exercises.isEmpty ||
        activeExerciseIndex >= workoutDay!.exercises.length) {
      return null;
    }
    return workoutDay!.exercises[activeExerciseIndex];
  }

  WorkoutSessionState copyWith({
    WorkoutDay? workoutDay,
    SessionStage? stage,
    int? activeExerciseIndex,
    int? currentSetIndex,
    int? completedSetsTotal,
    int? restSecondsRemaining,
    bool? isPaused,
    int? totalDurationSeconds,
    String? selectedFeedback,
  }) {
    return WorkoutSessionState(
      workoutDay: workoutDay ?? this.workoutDay,
      stage: stage ?? this.stage,
      activeExerciseIndex: activeExerciseIndex ?? this.activeExerciseIndex,
      currentSetIndex: currentSetIndex ?? this.currentSetIndex,
      completedSetsTotal: completedSetsTotal ?? this.completedSetsTotal,
      restSecondsRemaining:
          restSecondsRemaining ?? this.restSecondsRemaining,
      isPaused: isPaused ?? this.isPaused,
      totalDurationSeconds:
          totalDurationSeconds ?? this.totalDurationSeconds,
      selectedFeedback: selectedFeedback ?? this.selectedFeedback,
    );
  }
}

class WorkoutSessionNotifier extends Notifier<WorkoutSessionState> {
  late final WorkoutHistoryRepository _historyRepo;
  Timer? _tickerTimer;
  Timer? _restTimer;

  @override
  WorkoutSessionState build() {
    _historyRepo = ref.watch(workoutHistoryRepositoryProvider);

    ref.onDispose(() {
      _tickerTimer?.cancel();
      _restTimer?.cancel();
    });

    return const WorkoutSessionState();
  }

  void startWorkout(WorkoutDay day) {
    _tickerTimer?.cancel();
    _restTimer?.cancel();

    state = WorkoutSessionState(
      workoutDay: day,
      stage: SessionStage.warmup,
      activeExerciseIndex: 0,
      currentSetIndex: 1,
      completedSetsTotal: 0,
      totalDurationSeconds: 0,
      isPaused: false,
    );

    _startDurationTicker();
  }

  void _startDurationTicker() {
    _tickerTimer?.cancel();
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!state.isPaused && state.stage != SessionStage.complete) {
        state = state.copyWith(
          totalDurationSeconds: state.totalDurationSeconds + 1,
        );
      }
    });
  }

  void completeWarmup() {
    state = state.copyWith(
      stage: SessionStage.exercise,
      activeExerciseIndex: 0,
      currentSetIndex: 1,
    );
  }

  void completeSet() {
    final ex = state.currentExercise;
    if (ex == null) return;

    final newCompletedSets = state.completedSetsTotal + 1;

    if (state.currentSetIndex < ex.sets) {
      // Start rest timer before next set
      _startRestTimer(ex.restSeconds);
      state = state.copyWith(
        stage: SessionStage.rest,
        completedSetsTotal: newCompletedSets,
        currentSetIndex: state.currentSetIndex + 1,
      );
    } else {
      // Completed all sets for this exercise
      if (state.activeExerciseIndex < (state.workoutDay?.exercises.length ?? 1) - 1) {
        _startRestTimer(ex.restSeconds);
        state = state.copyWith(
          stage: SessionStage.rest,
          completedSetsTotal: newCompletedSets,
          activeExerciseIndex: state.activeExerciseIndex + 1,
          currentSetIndex: 1,
        );
      } else {
        // Move to cooldown
        _restTimer?.cancel();
        state = state.copyWith(
          stage: SessionStage.cooldown,
          completedSetsTotal: newCompletedSets,
        );
      }
    }
  }

  void _startRestTimer(int seconds) {
    _restTimer?.cancel();
    state = state.copyWith(restSecondsRemaining: seconds);

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.isPaused) return;

      if (state.restSecondsRemaining > 1) {
        state = state.copyWith(
          restSecondsRemaining: state.restSecondsRemaining - 1,
        );
      } else {
        timer.cancel();
        state = state.copyWith(
          stage: SessionStage.exercise,
          restSecondsRemaining: 0,
        );
      }
    });
  }

  void skipRest() {
    _restTimer?.cancel();
    state = state.copyWith(
      stage: SessionStage.exercise,
      restSecondsRemaining: 0,
    );
  }

  void replaceExerciseWithAlternative() {
    final current = state.currentExercise;
    if (current == null || state.workoutDay == null) return;

    final alt = ExerciseLibrary.getAlternative(current);
    if (alt != null) {
      final updatedExercises = List<Exercise>.from(state.workoutDay!.exercises);
      updatedExercises[state.activeExerciseIndex] = alt;

      final updatedDay = WorkoutDay(
        day: state.workoutDay!.day,
        title: state.workoutDay!.title,
        focus: state.workoutDay!.focus,
        type: state.workoutDay!.type,
        durationMinutes: state.workoutDay!.durationMinutes,
        exercises: updatedExercises,
        isCompleted: state.workoutDay!.isCompleted,
      );

      state = state.copyWith(
        workoutDay: updatedDay,
        currentSetIndex: 1,
      );
    }
  }

  void completeCooldown() {
    _restTimer?.cancel();
    _tickerTimer?.cancel();

    state = state.copyWith(stage: SessionStage.complete);
  }

  Future<void> saveWorkoutFeedback(String rating) async {
    state = state.copyWith(selectedFeedback: rating);

    final durationMin = (state.totalDurationSeconds / 60).ceil().clamp(1, 120);
    final log = WorkoutHistoryLog(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}',
      completedAt: DateTime.now(),
      dayTitle: state.workoutDay?.title ?? 'Completed Session',
      focus: state.workoutDay?.focus ?? 'Full Body',
      durationMinutes: durationMin,
      exercisesCompleted: state.workoutDay?.exercises.length ?? 0,
      setsCompleted: state.completedSetsTotal,
      feedbackRating: rating,
    );

    await _historyRepo.saveWorkoutLog(log);
  }

  void togglePause() {
    state = state.copyWith(isPaused: !state.isPaused);
  }
}

final workoutSessionNotifierProvider = NotifierProvider<
    WorkoutSessionNotifier, WorkoutSessionState>(
  WorkoutSessionNotifier.new,
);
