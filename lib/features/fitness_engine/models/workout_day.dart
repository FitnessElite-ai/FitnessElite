import 'dart:convert';
import 'exercise.dart';

/// Model representing a single day in a weekly training schedule.
class WorkoutDay {
  final String day;
  final String title;
  final String focus;
  final String type; // "workout", "recovery", "rest"
  final int durationMinutes;
  final List<Exercise> exercises;
  final bool isCompleted;

  const WorkoutDay({
    required this.day,
    required this.title,
    required this.focus,
    this.type = 'workout',
    required this.durationMinutes,
    this.exercises = const [],
    this.isCompleted = false,
  });

  bool get isRest => type == 'rest' || exercises.isEmpty;
  bool get isWorkout => type == 'workout' && exercises.isNotEmpty;
  bool get isRecovery => type == 'recovery';

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'title': title,
      'focus': focus,
      'type': type,
      'durationMinutes': durationMinutes,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'isCompleted': isCompleted,
    };
  }

  factory WorkoutDay.fromMap(Map<String, dynamic> map) {
    return WorkoutDay(
      day: map['day'] as String? ?? 'Monday',
      title: map['title'] as String? ?? 'Training Session',
      focus: map['focus'] as String? ?? 'General Fitness',
      type: map['type'] as String? ?? 'workout',
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 30,
      exercises: (map['exercises'] as List<dynamic>?)
              ?.map((e) => Exercise.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      isCompleted: map['isCompleted'] as bool? ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory WorkoutDay.fromJson(String source) =>
      WorkoutDay.fromMap(json.decode(source) as Map<String, dynamic>);
}
