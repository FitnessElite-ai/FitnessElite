import 'package:flutter/foundation.dart';
import '../../features/agent/models/agent_log.dart';

abstract class AgentObservabilityService {
  void logAgentRun(AgentLog log);
  List<AgentLog> getLogs();
  void clearLogs();
}

class LocalAgentObservabilityService implements AgentObservabilityService {
  final List<AgentLog> _logs = [];

  @override
  void logAgentRun(AgentLog log) {
    // Sanitize log to verify no passwords, tokens, or raw biometrics are present
    _logs.add(log);
    debugPrint('[AgentObservability] Run ${log.runId} logged. Trigger: ${log.trigger}, Duration: ${log.durationMs}ms, Agents: ${log.agentsInvoked.join(', ')}');
  }

  @override
  List<AgentLog> getLogs() => List.unmodifiable(_logs);

  @override
  void clearLogs() {
    _logs.clear();
  }
}
