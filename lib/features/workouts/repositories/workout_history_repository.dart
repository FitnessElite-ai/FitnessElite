import 'dart:convert';
import '../../../core/services/local_storage_service.dart';
import '../models/workout_history_log.dart';

abstract class WorkoutHistoryRepository {
  List<WorkoutHistoryLog> getWorkoutHistory();
  Future<bool> saveWorkoutLog(WorkoutHistoryLog log);
  int getCurrentStreak();
  int getTotalWorkoutMinutes();
  int getTotalWorkoutsCompleted();
  Future<bool> clearHistory();
}

class LocalWorkoutHistoryRepository implements WorkoutHistoryRepository {
  static const String _keyWorkoutHistory = 'fe_workout_history_list';

  final LocalStorageService _storage;

  LocalWorkoutHistoryRepository(this._storage);

  @override
  List<WorkoutHistoryLog> getWorkoutHistory() {
    final data = _storage.getString(_keyWorkoutHistory);
    if (data != null && data.isNotEmpty) {
      try {
        final List<dynamic> jsonList = json.decode(data) as List<dynamic>;
        return jsonList
            .map((e) => WorkoutHistoryLog.fromMap(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }
    return [];
  }

  @override
  Future<bool> saveWorkoutLog(WorkoutHistoryLog log) async {
    final history = getWorkoutHistory();
    history.add(log);
    final jsonStr = json.encode(history.map((e) => e.toMap()).toList());
    return await _storage.setString(_keyWorkoutHistory, jsonStr);
  }

  @override
  int getCurrentStreak() {
    final history = getWorkoutHistory();
    if (history.isEmpty) return 0;

    // Calculate distinct days worked out consecutively or within last week
    final dates = history
        .map((l) => DateTime(l.completedAt.year, l.completedAt.month, l.completedAt.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    if (dates.isEmpty) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (!dates.contains(today) && !dates.contains(yesterday)) {
      return 0;
    }

    int streak = 0;
    DateTime checkDate = dates.contains(today) ? today : yesterday;

    while (dates.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  @override
  int getTotalWorkoutMinutes() {
    final history = getWorkoutHistory();
    return history.fold(0, (sum, log) => sum + log.durationMinutes);
  }

  @override
  int getTotalWorkoutsCompleted() {
    return getWorkoutHistory().length;
  }

  @override
  Future<bool> clearHistory() async {
    return await _storage.remove(_keyWorkoutHistory);
  }
}
