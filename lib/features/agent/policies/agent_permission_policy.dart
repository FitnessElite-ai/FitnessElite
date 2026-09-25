enum ActionPermissionLevel { read, lowRiskWrite, userConfirmationRequired, neverAllowed }

/// Centralized permission policy governing autonomous agent tool execution.
class AgentPermissionPolicy {
  static ActionPermissionLevel evaluateActionPermission(String actionType, String toolName) {
    final cleanAction = actionType.toLowerCase();
    final cleanTool = toolName.toLowerCase();

    // NEVER ALLOWED
    if (cleanAction.contains('medical') ||
        cleanAction.contains('diagnose') ||
        cleanAction.contains('medication') ||
        cleanAction.contains('starve') ||
        cleanAction.contains('silent_share')) {
      return ActionPermissionLevel.neverAllowed;
    }

    // USER CONFIRMATION REQUIRED
    if (cleanAction.contains('subscription') ||
        cleanAction.contains('paywall') ||
        cleanAction.contains('upload_vision') ||
        cleanAction.contains('external_ai') ||
        cleanAction.contains('major_plan_reset') ||
        cleanTool.contains('regenerate')) {
      return ActionPermissionLevel.userConfirmationRequired;
    }

    // LOW RISK WRITE
    if (cleanAction.contains('log_workout') ||
        cleanAction.contains('log_feedback') ||
        cleanAction.contains('modify_workout') ||
        cleanAction.contains('update_preference') ||
        cleanAction.contains('store_memory')) {
      return ActionPermissionLevel.lowRiskWrite;
    }

    // READ
    return ActionPermissionLevel.read;
  }

  static bool isPermittedWithoutApproval(String actionType, String toolName) {
    final level = evaluateActionPermission(actionType, toolName);
    return level == ActionPermissionLevel.read || level == ActionPermissionLevel.lowRiskWrite;
  }
}
