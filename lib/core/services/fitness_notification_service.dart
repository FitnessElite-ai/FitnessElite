import 'package:flutter/foundation.dart';

abstract class FitnessNotificationService {
  Future<void> initialize();
  Future<void> sendAgentNotification({
    required String title,
    required String message,
    bool containsSensitiveHealthData = false,
  });
  Future<void> scheduleWorkoutReminder({
    required String title,
    required String body,
    required DateTime scheduledTime,
  });
}

class LocalFitnessNotificationService implements FitnessNotificationService {
  bool _hasPermission = true;

  @override
  Future<void> initialize() async {
    debugPrint('[FitnessNotificationService] Initialized local notification service abstraction.');
  }

  @override
  Future<void> sendAgentNotification({
    required String title,
    required String message,
    bool containsSensitiveHealthData = false,
  }) async {
    if (!_hasPermission) {
      debugPrint('[FitnessNotificationService] Notification suppressed: no permission granted.');
      return;
    }

    String previewMessage = message;
    if (containsSensitiveHealthData) {
      previewMessage = "Your Fitness Agent updated your plan.";
    }

    debugPrint('[FitnessNotificationService] AGENT NOTIFICATION: [$title] $previewMessage');
  }

  @override
  Future<void> scheduleWorkoutReminder({
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    debugPrint('[FitnessNotificationService] Scheduled workout reminder: "$title" at $scheduledTime');
  }

  void setPermissionState(bool granted) {
    _hasPermission = granted;
  }
}
