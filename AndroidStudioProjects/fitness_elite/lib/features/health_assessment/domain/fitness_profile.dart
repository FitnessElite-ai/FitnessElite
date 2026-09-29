import 'dart:convert';

enum UnitSystem { metric, imperial }

/// Strongly typed domain model representing user's Fitness & Health Profile.
class FitnessProfile {
  final String name;
  final int age;
  final String sex;
  final double heightCm;
  final double weightKg;
  final UnitSystem unitSystem;
  final double bmi;
  final String bmiCategory;
  final String activityLevel;
  final String primaryGoal;
  final String workoutAvailability;
  final String workoutDays;
  final String equipment;
  final String sleepDuration;
  final String dietaryPreference;
  final String preferredLanguage;

  const FitnessProfile({
    required this.name,
    required this.age,
    required this.sex,
    required this.heightCm,
    required this.weightKg,
    required this.unitSystem,
    required this.bmi,
    required this.bmiCategory,
    required this.activityLevel,
    required this.primaryGoal,
    required this.workoutAvailability,
    required this.workoutDays,
    required this.equipment,
    required this.sleepDuration,
    required this.dietaryPreference,
    required this.preferredLanguage,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'sex': sex,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'unitSystem': unitSystem.name,
      'bmi': bmi,
      'bmiCategory': bmiCategory,
      'activityLevel': activityLevel,
      'primaryGoal': primaryGoal,
      'workoutAvailability': workoutAvailability,
      'workoutDays': workoutDays,
      'equipment': equipment,
      'sleepDuration': sleepDuration,
      'dietaryPreference': dietaryPreference,
      'preferredLanguage': preferredLanguage,
    };
  }

  factory FitnessProfile.fromMap(Map<String, dynamic> map) {
    return FitnessProfile(
      name: map['name'] as String? ?? '',
      age: (map['age'] as num?)?.toInt() ?? 25,
      sex: map['sex'] as String? ?? 'Unspecified',
      heightCm: (map['heightCm'] as num?)?.toDouble() ?? 170.0,
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 70.0,
      unitSystem: map['unitSystem'] == 'imperial'
          ? UnitSystem.imperial
          : UnitSystem.metric,
      bmi: (map['bmi'] as num?)?.toDouble() ?? 22.0,
      bmiCategory: map['bmiCategory'] as String? ?? 'Normal weight',
      activityLevel: map['activityLevel'] as String? ?? 'Moderately Active',
      primaryGoal: map['primaryGoal'] as String? ?? 'Improve overall health',
      workoutAvailability: map['workoutAvailability'] as String? ?? '30-45 min',
      workoutDays: map['workoutDays'] as String? ?? '3-4 days',
      equipment: map['equipment'] as String? ?? 'Bodyweight only',
      sleepDuration: map['sleepDuration'] as String? ?? '7-8 hours',
      dietaryPreference: map['dietaryPreference'] as String? ?? 'Anything',
      preferredLanguage: map['preferredLanguage'] as String? ?? 'en',
    );
  }

  String toJson() => json.encode(toMap());

  factory FitnessProfile.fromJson(String source) =>
      FitnessProfile.fromMap(json.decode(source) as Map<String, dynamic>);
}
