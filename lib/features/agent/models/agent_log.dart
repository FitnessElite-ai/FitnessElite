import 'dart:convert';

/// Structured telemetry log for developer/agent observability without exposing biometrics.
class AgentLog {
  final String runId;
  final DateTime timestamp;
  final String trigger;
  final List<String> agentsInvoked;
  final List<String> toolsUsed;
  final String decisionSummary;
  final int durationMs;

  const AgentLog({
    required this.runId,
    required this.timestamp,
    required this.trigger,
    this.agentsInvoked = const [],
    this.toolsUsed = const [],
    required this.decisionSummary,
    required this.durationMs,
  });

  Map<String, dynamic> toMap() {
    return {
      'runId': runId,
      'timestamp': timestamp.toIso8601String(),
      'trigger': trigger,
      'agentsInvoked': agentsInvoked,
      'toolsUsed': toolsUsed,
      'decisionSummary': decisionSummary,
      'durationMs': durationMs,
    };
  }

  factory AgentLog.fromMap(Map<String, dynamic> map) {
    return AgentLog(
      runId: map['runId'] as String? ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'] as String)
          : DateTime.now(),
      trigger: map['trigger'] as String? ?? 'scheduled',
      agentsInvoked: (map['agentsInvoked'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      toolsUsed: (map['toolsUsed'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      decisionSummary: map['decisionSummary'] as String? ?? '',
      durationMs: (map['durationMs'] as num?)?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory AgentLog.fromJson(String source) =>
      AgentLog.fromMap(json.decode(source) as Map<String, dynamic>);
}
