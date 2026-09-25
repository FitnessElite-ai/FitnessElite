import 'dart:convert';

/// Persisted historical workout log item recording user performance and feedback.
class WorkoutHistoryLog {
  final String id;
  final DateTime completedAt;
  final String dayTitle;
  final String focus;
  final int durationMinutes;
  final int exercisesCompleted;
  final int setsCompleted;
  final String feedbackRating; // "Easy", "Good", "Challenging", "Very challenging"

  const WorkoutHistoryLog({
    required this.id,
    required this.completedAt,
    required this.dayTitle,
    required this.focus,
    required this.durationMinutes,
    required this.exercisesCompleted,
    required this.setsCompleted,
    required this.feedbackRating,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'completedAt': completedAt.toIso8601String(),
      'dayTitle': dayTitle,
      'focus': focus,
      'durationMinutes': durationMinutes,
      'exercisesCompleted': exercisesCompleted,
      'setsCompleted': setsCompleted,
      'feedbackRating': feedbackRating,
    };
  }

  factory WorkoutHistoryLog.fromMap(Map<String, dynamic> map) {
    return WorkoutHistoryLog(
      id: map['id'] as String? ?? '',
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'] as String)
          : DateTime.now(),
      dayTitle: map['dayTitle'] as String? ?? 'Workout',
      focus: map['focus'] as String? ?? 'General',
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 0,
      exercisesCompleted: (map['exercisesCompleted'] as num?)?.toInt() ?? 0,
      setsCompleted: (map['setsCompleted'] as num?)?.toInt() ?? 0,
      feedbackRating: map['feedbackRating'] as String? ?? 'Good',
    );
  }

  String toJson() => json.encode(toMap());

  factory WorkoutHistoryLog.fromJson(String source) =>
      WorkoutHistoryLog.fromMap(json.decode(source) as Map<String, dynamic>);
}
