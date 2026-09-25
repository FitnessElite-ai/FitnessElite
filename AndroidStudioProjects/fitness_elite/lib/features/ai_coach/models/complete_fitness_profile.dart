import 'dart:convert';
import '../../health_assessment/domain/fitness_profile.dart';
import 'fitness_preferences.dart';

/// Complete Fitness Profile aggregating Health Profile and AI Fitness Preferences.
class CompleteFitnessProfile {
  final FitnessProfile healthProfile;
  final FitnessPreferences fitnessPreferences;
  final DateTime completedAt;

  const CompleteFitnessProfile({
    required this.healthProfile,
    required this.fitnessPreferences,
    required this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'healthProfile': healthProfile.toMap(),
      'fitnessPreferences': fitnessPreferences.toMap(),
      'completedAt': completedAt.toIso8601String(),
    };
  }

  factory CompleteFitnessProfile.fromMap(Map<String, dynamic> map) {
    return CompleteFitnessProfile(
      healthProfile: FitnessProfile.fromMap(
          map['healthProfile'] as Map<String, dynamic>? ?? {}),
      fitnessPreferences: FitnessPreferences.fromMap(
          map['fitnessPreferences'] as Map<String, dynamic>? ?? {}),
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'] as String)
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory CompleteFitnessProfile.fromJson(String source) =>
      CompleteFitnessProfile.fromMap(
          json.decode(source) as Map<String, dynamic>);
}
