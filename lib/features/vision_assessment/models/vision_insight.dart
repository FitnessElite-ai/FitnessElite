import 'dart:convert';

enum ConfidenceLevel { low, moderate, high }

/// Model representing a visual fitness insight generated from photo analysis.
class VisionInsight {
  final String category;
  final String title;
  final String description;
  final ConfidenceLevel confidence;
  final String recommendation;

  const VisionInsight({
    required this.category,
    required this.title,
    required this.description,
    required this.confidence,
    required this.recommendation,
  });

  String get confidenceLabel {
    switch (confidence) {
      case ConfidenceLevel.low:
        return 'Low confidence';
      case ConfidenceLevel.moderate:
        return 'Moderate confidence';
      case ConfidenceLevel.high:
        return 'High confidence';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'title': title,
      'description': description,
      'confidence': confidence.name,
      'confidenceLabel': confidenceLabel,
      'recommendation': recommendation,
    };
  }

  factory VisionInsight.fromMap(Map<String, dynamic> map) {
    return VisionInsight(
      category: map['category'] as String? ?? 'General',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      confidence: ConfidenceLevel.values.firstWhere(
        (e) => e.name == map['confidence'],
        orElse: () => ConfidenceLevel.moderate,
      ),
      recommendation: map['recommendation'] as String? ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory VisionInsight.fromJson(String source) =>
      VisionInsight.fromMap(json.decode(source) as Map<String, dynamic>);
}
