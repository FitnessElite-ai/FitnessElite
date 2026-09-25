import 'dart:convert';

/// Structured memory item retained by FitnessMemoryService.
class AgentMemory {
  final String id;
  final String category; // e.g. "USER_PROFILE", "PREFERENCES", "EXERCISE_PREFERENCE", "ADHERENCE_PATTERN", "RECOVERY_PATTERN"
  final String value;
  final double confidence; // 0.0 - 1.0
  final String source; // "user", "observation", "reflection"
  final DateTime createdAt;

  const AgentMemory({
    required this.id,
    required this.category,
    required this.value,
    this.confidence = 0.9,
    this.source = 'observation',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'value': value,
      'confidence': confidence,
      'source': source,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AgentMemory.fromMap(Map<String, dynamic> map) {
    return AgentMemory(
      id: map['id'] as String? ?? '',
      category: map['category'] as String? ?? 'PREFERENCES',
      value: map['value'] as String? ?? '',
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.9,
      source: map['source'] as String? ?? 'observation',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory AgentMemory.fromJson(String source) =>
      AgentMemory.fromMap(json.decode(source) as Map<String, dynamic>);
}
