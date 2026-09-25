import 'dart:convert';
import '../../health_assessment/domain/fitness_profile.dart';
import '../../vision_assessment/models/vision_assessment.dart';
import 'fitness_preferences.dart';

/// Complete Fitness Profile aggregating Health Profile, AI Fitness Preferences, and optional Vision AI Assessment.
class CompleteFitnessProfile {
  final FitnessProfile healthProfile;
  final FitnessPreferences fitnessPreferences;
  final VisionAssessment? visionAssessment;
  final DateTime completedAt;

  const CompleteFitnessProfile({
    required this.healthProfile,
    required this.fitnessPreferences,
    this.visionAssessment,
    required this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'healthProfile': healthProfile.toMap(),
      'fitnessPreferences': fitnessPreferences.toMap(),
      'visionAssessment': visionAssessment?.toMap(),
      'completedAt': completedAt.toIso8601String(),
    };
  }

  factory CompleteFitnessProfile.fromMap(Map<String, dynamic> map) {
    return CompleteFitnessProfile(
      healthProfile: FitnessProfile.fromMap(
          map['healthProfile'] as Map<String, dynamic>? ?? {}),
      fitnessPreferences: FitnessPreferences.fromMap(
          map['fitnessPreferences'] as Map<String, dynamic>? ?? {}),
      visionAssessment: map['visionAssessment'] != null
          ? VisionAssessment.fromMap(
              map['visionAssessment'] as Map<String, dynamic>)
          : null,
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
