import 'dart:convert';
import 'agent_action.dart';

/// User-explainable agent decision output.
class AgentDecision {
  final String id;
  final String title;
  final String decision;
  final String reason;
  final String evidence;
  final List<AgentAction> actions;
  final bool requiresApproval;
  final bool isApproved;
  final DateTime createdAt;

  const AgentDecision({
    required this.id,
    required this.title,
    required this.decision,
    required this.reason,
    required this.evidence,
    this.actions = const [],
    this.requiresApproval = false,
    this.isApproved = true,
    required this.createdAt,
  });

  AgentDecision copyWith({
    String? id,
    String? title,
    String? decision,
    String? reason,
    String? evidence,
    List<AgentAction>? actions,
    bool? requiresApproval,
    bool? isApproved,
    DateTime? createdAt,
  }) {
    return AgentDecision(
      id: id ?? this.id,
      title: title ?? this.title,
      decision: decision ?? this.decision,
      reason: reason ?? this.reason,
      evidence: evidence ?? this.evidence,
      actions: actions ?? this.actions,
      requiresApproval: requiresApproval ?? this.requiresApproval,
      isApproved: isApproved ?? this.isApproved,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'decision': decision,
      'reason': reason,
      'evidence': evidence,
      'actions': actions.map((e) => e.toMap()).toList(),
      'requiresApproval': requiresApproval,
      'isApproved': isApproved,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AgentDecision.fromMap(Map<String, dynamic> map) {
    return AgentDecision(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? 'Agent Decision',
      decision: map['decision'] as String? ?? '',
      reason: map['reason'] as String? ?? '',
      evidence: map['evidence'] as String? ?? '',
      actions: (map['actions'] as List<dynamic>?)
              ?.map((e) => AgentAction.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      requiresApproval: map['requiresApproval'] as bool? ?? false,
      isApproved: map['isApproved'] as bool? ?? true,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory AgentDecision.fromJson(String source) =>
      AgentDecision.fromMap(json.decode(source) as Map<String, dynamic>);
}
