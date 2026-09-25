import 'dart:convert';
import 'workout_day.dart';

/// Aggregated Workout Plan model.
class WorkoutPlan {
  final String title;
  final String description;
  final int weeklyFrequency;
  final List<WorkoutDay> days;

  const WorkoutPlan({
    required this.title,
    required this.description,
    required this.weeklyFrequency,
    this.days = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'weeklyFrequency': weeklyFrequency,
      'days': days.map((e) => e.toMap()).toList(),
    };
  }

  factory WorkoutPlan.fromMap(Map<String, dynamic> map) {
    return WorkoutPlan(
      title: map['title'] as String? ?? 'Personalized Workout Plan',
      description: map['description'] as String? ?? '',
      weeklyFrequency: (map['weeklyFrequency'] as num?)?.toInt() ?? 3,
      days: (map['days'] as List<dynamic>?)
              ?.map((e) => WorkoutDay.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  String toJson() => json.encode(toMap());

  factory WorkoutPlan.fromJson(String source) =>
      WorkoutPlan.fromMap(json.decode(source) as Map<String, dynamic>);
}
