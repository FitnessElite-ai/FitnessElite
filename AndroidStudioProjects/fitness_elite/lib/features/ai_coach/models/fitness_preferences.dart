import 'dart:convert';

/// Model representing user preferences collected during AI Coach conversation.
class FitnessPreferences {
  final String primaryGoal;
  final String dailyTrainingTime;
  final String preferredLocation;
  final String experienceLevel;
  final String consistencyBarrier;
  final String dietaryPreference;
  final String additionalNotes;

  const FitnessPreferences({
    required this.primaryGoal,
    required this.dailyTrainingTime,
    required this.preferredLocation,
    required this.experienceLevel,
    required this.consistencyBarrier,
    required this.dietaryPreference,
    required this.additionalNotes,
  });

  Map<String, dynamic> toMap() {
    return {
      'primaryGoal': primaryGoal,
      'dailyTrainingTime': dailyTrainingTime,
      'preferredLocation': preferredLocation,
      'experienceLevel': experienceLevel,
      'consistencyBarrier': consistencyBarrier,
      'dietaryPreference': dietaryPreference,
      'additionalNotes': additionalNotes,
    };
  }

  factory FitnessPreferences.fromMap(Map<String, dynamic> map) {
    return FitnessPreferences(
      primaryGoal: map['primaryGoal'] as String? ?? '',
      dailyTrainingTime: map['dailyTrainingTime'] as String? ?? '',
      preferredLocation: map['preferredLocation'] as String? ?? '',
      experienceLevel: map['experienceLevel'] as String? ?? '',
      consistencyBarrier: map['consistencyBarrier'] as String? ?? '',
      dietaryPreference: map['dietaryPreference'] as String? ?? '',
      additionalNotes: map['additionalNotes'] as String? ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory FitnessPreferences.fromJson(String source) =>
      FitnessPreferences.fromMap(
          json.decode(source) as Map<String, dynamic>);
}
