import 'dart:convert';

class AgentToolResult {
  final bool success;
  final String output;
  final Map<String, dynamic> data;
  final String? errorMessage;

  const AgentToolResult({
    required this.success,
    required this.output,
    this.data = const {},
    this.errorMessage,
  });

  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'output': output,
      'data': data,
      'errorMessage': errorMessage,
    };
  }

  String toJson() => json.encode(toMap());
}

/// Abstract AgentTool base class providing strict validation, execution, and safety parameters.
abstract class AgentTool {
  String get name;
  String get description;
  bool get isReadOnly;

  Future<AgentToolResult> execute(Map<String, dynamic> parameters);
}
