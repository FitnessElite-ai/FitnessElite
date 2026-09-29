import 'dart:convert';

/// Representation of a structured Breathwork pattern.
class BreathingExercise {
  final String id;
  final String name;
  final String category; // e.g., "Calm", "Focus", "Pre-Workout", "Post-Workout", "Wind-Down"
  final String difficulty; // "Beginner", "Intermediate"
  final int durationSeconds;
  final int cycles;
  final int inhaleSeconds;
  final int holdAfterInhaleSeconds;
  final int exhaleSeconds;
  final int holdAfterExhaleSeconds;
  final String instructions;
  final String benefitsDescription;
  final String safetyNotes;
  final String recommendedContext;

  const BreathingExercise({
    required this.id,
    required this.name,
    required this.category,
    this.difficulty = 'Beginner',
    required this.durationSeconds,
    required this.cycles,
    required this.inhaleSeconds,
    this.holdAfterInhaleSeconds = 0,
    required this.exhaleSeconds,
    this.holdAfterExhaleSeconds = 0,
    required this.instructions,
    required this.benefitsDescription,
    required this.safetyNotes,
    required this.recommendedContext,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'difficulty': difficulty,
      'durationSeconds': durationSeconds,
      'cycles': cycles,
      'inhaleSeconds': inhaleSeconds,
      'holdAfterInhaleSeconds': holdAfterInhaleSeconds,
      'exhaleSeconds': exhaleSeconds,
      'holdAfterExhaleSeconds': holdAfterExhaleSeconds,
      'instructions': instructions,
      'benefitsDescription': benefitsDescription,
      'safetyNotes': safetyNotes,
      'recommendedContext': recommendedContext,
    };
  }

  factory BreathingExercise.fromMap(Map<String, dynamic> map) {
    return BreathingExercise(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? 'Breathing Exercise',
      category: map['category'] as String? ?? 'Calm',
      difficulty: map['difficulty'] as String? ?? 'Beginner',
      durationSeconds: (map['durationSeconds'] as num?)?.toInt() ?? 120,
      cycles: (map['cycles'] as num?)?.toInt() ?? 8,
      inhaleSeconds: (map['inhaleSeconds'] as num?)?.toInt() ?? 4,
      holdAfterInhaleSeconds: (map['holdAfterInhaleSeconds'] as num?)?.toInt() ?? 0,
      exhaleSeconds: (map['exhaleSeconds'] as num?)?.toInt() ?? 4,
      holdAfterExhaleSeconds: (map['holdAfterExhaleSeconds'] as num?)?.toInt() ?? 0,
      instructions: map['instructions'] as String? ?? '',
      benefitsDescription: map['benefitsDescription'] as String? ?? '',
      safetyNotes: map['safetyNotes'] as String? ?? '',
      recommendedContext: map['recommendedContext'] as String? ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory BreathingExercise.fromJson(String source) =>
      BreathingExercise.fromMap(json.decode(source) as Map<String, dynamic>);
}
