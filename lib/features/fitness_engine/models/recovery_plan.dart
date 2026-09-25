import 'dart:convert';

/// Personalized Recovery Plan model covering sleep, mobility, and rest protocols.
class RecoveryPlan {
  final String sleepTargetHours;
  final int restDaysPerWeek;
  final String hydrationGuidance;
  final String mobilityRecommendation;
  final String recoveryNotes;

  const RecoveryPlan({
    required this.sleepTargetHours,
    required this.restDaysPerWeek,
    required this.hydrationGuidance,
    required this.mobilityRecommendation,
    required this.recoveryNotes,
  });

  Map<String, dynamic> toMap() {
    return {
      'sleepTargetHours': sleepTargetHours,
      'restDaysPerWeek': restDaysPerWeek,
      'hydrationGuidance': hydrationGuidance,
      'mobilityRecommendation': mobilityRecommendation,
      'recoveryNotes': recoveryNotes,
    };
  }

  factory RecoveryPlan.fromMap(Map<String, dynamic> map) {
    return RecoveryPlan(
      sleepTargetHours: map['sleepTargetHours'] as String? ?? '7-8 hours',
      restDaysPerWeek: (map['restDaysPerWeek'] as num?)?.toInt() ?? 2,
      hydrationGuidance:
          map['hydrationGuidance'] as String? ?? '2.5 - 3.0 Liters daily',
      mobilityRecommendation: map['mobilityRecommendation'] as String? ??
          'Daily 10-min dynamic stretching',
      recoveryNotes: map['recoveryNotes'] as String? ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory RecoveryPlan.fromJson(String source) =>
      RecoveryPlan.fromMap(json.decode(source) as Map<String, dynamic>);
}
