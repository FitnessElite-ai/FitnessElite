import 'dart:convert';

/// Executable agent action planned or executed by FitnessAgent.
class AgentAction {
  final String id;
  final String type; // e.g. "modify_workout", "update_goal", "adjust_volume"
  final String description;
  final String targetTool;
  final Map<String, dynamic> parameters;
  final bool requiresConfirmation;

  const AgentAction({
    required this.id,
    required this.type,
    required this.description,
    required this.targetTool,
    this.parameters = const {},
    this.requiresConfirmation = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'description': description,
      'targetTool': targetTool,
      'parameters': parameters,
      'requiresConfirmation': requiresConfirmation,
    };
  }

  factory AgentAction.fromMap(Map<String, dynamic> map) {
    return AgentAction(
      id: map['id'] as String? ?? '',
      type: map['type'] as String? ?? 'general',
      description: map['description'] as String? ?? '',
      targetTool: map['targetTool'] as String? ?? '',
      parameters: (map['parameters'] as Map<String, dynamic>?) ?? {},
      requiresConfirmation: map['requiresConfirmation'] as bool? ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory AgentAction.fromJson(String source) =>
      AgentAction.fromMap(json.decode(source) as Map<String, dynamic>);
}
