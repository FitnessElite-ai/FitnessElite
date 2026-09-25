import 'dart:convert';

/// Model representing a fitness observation signal collected by the agent.
class AgentObservation {
  final String id;
  final String type; // e.g. "workout_completion", "fatigue_feedback", "sleep_data", "missed_session"
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const AgentObservation({
    required this.id,
    required this.type,
    required this.description,
    required this.timestamp,
    this.metadata = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory AgentObservation.fromMap(Map<String, dynamic> map) {
    return AgentObservation(
      id: map['id'] as String? ?? '',
      type: map['type'] as String? ?? 'general',
      description: map['description'] as String? ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'] as String)
          : DateTime.now(),
      metadata: (map['metadata'] as Map<String, dynamic>?) ?? {},
    );
  }

  String toJson() => json.encode(toMap());

  factory AgentObservation.fromJson(String source) =>
      AgentObservation.fromMap(json.decode(source) as Map<String, dynamic>);
}
