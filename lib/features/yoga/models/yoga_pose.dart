import 'dart:convert';

/// Representation of a Yoga and Mobility Pose for adaptive recovery routines.
class YogaPose {
  final String id;
  final String name;
  final String category; // e.g., "Mobility", "Flexibility", "Restorative", "Balance"
  final String difficulty; // "Beginner", "Intermediate"
  final int durationSeconds;
  final String setup;
  final List<String> steps;
  final String breathing;
  final String benefits;
  final String modifications;
  final String safetyNotes;

  const YogaPose({
    required this.id,
    required this.name,
    required this.category,
    this.difficulty = 'Beginner',
    this.durationSeconds = 60,
    required this.setup,
    required this.steps,
    required this.breathing,
    required this.benefits,
    required this.modifications,
    required this.safetyNotes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'difficulty': difficulty,
      'durationSeconds': durationSeconds,
      'setup': setup,
      'steps': steps,
      'breathing': breathing,
      'benefits': benefits,
      'modifications': modifications,
      'safetyNotes': safetyNotes,
    };
  }

  factory YogaPose.fromMap(Map<String, dynamic> map) {
    return YogaPose(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? 'Yoga Pose',
      category: map['category'] as String? ?? 'Mobility',
      difficulty: map['difficulty'] as String? ?? 'Beginner',
      durationSeconds: (map['durationSeconds'] as num?)?.toInt() ?? 60,
      setup: map['setup'] as String? ?? '',
      steps: (map['steps'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      breathing: map['breathing'] as String? ?? '',
      benefits: map['benefits'] as String? ?? '',
      modifications: map['modifications'] as String? ?? '',
      safetyNotes: map['safetyNotes'] as String? ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory YogaPose.fromJson(String source) =>
      YogaPose.fromMap(json.decode(source) as Map<String, dynamic>);
}
