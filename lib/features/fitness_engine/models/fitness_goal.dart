import 'dart:convert';

/// Measurable fitness goal metric for tracking progress.
class FitnessGoal {
  final String metric;
  final String baseline;
  final String target;
  final String unit;
  final String timeframe;

  const FitnessGoal({
    required this.metric,
    required this.baseline,
    required this.target,
    required this.unit,
    required this.timeframe,
  });

  Map<String, dynamic> toMap() {
    return {
      'metric': metric,
      'baseline': baseline,
      'target': target,
      'unit': unit,
      'timeframe': timeframe,
    };
  }

  factory FitnessGoal.fromMap(Map<String, dynamic> map) {
    return FitnessGoal(
      metric: map['metric'] as String? ?? 'Consistency',
      baseline: map['baseline'] as String? ?? '0',
      target: map['target'] as String? ?? '100',
      unit: map['unit'] as String? ?? '%',
      timeframe: map['timeframe'] as String? ?? '4 weeks',
    );
  }

  String toJson() => json.encode(toMap());

  factory FitnessGoal.fromJson(String source) =>
      FitnessGoal.fromMap(json.decode(source) as Map<String, dynamic>);
}
