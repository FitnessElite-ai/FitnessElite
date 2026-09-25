import 'package:flutter/foundation.dart';

/// Abstract AnalyticsService tracking non-sensitive product telemetry events.
abstract class AnalyticsService {
  void logEvent(String eventName, [Map<String, dynamic>? parameters]);
}

class LocalAnalyticsService implements AnalyticsService {
  @override
  void logEvent(String eventName, [Map<String, dynamic>? parameters]) {
    // Non-sensitive telemetry logging
    final paramsStr = parameters != null ? ' params: $parameters' : '';
    debugPrint('[Analytics] Event: $eventName$paramsStr');
  }
}

class AppAnalyticsEvents {
  static const String onboardingCompleted = 'onboarding_completed';
  static const String accountCreated = 'account_created';
  static const String healthAssessmentCompleted = 'health_assessment_completed';
  static const String planGenerated = 'plan_generated';
  static const String workoutStarted = 'workout_started';
  static const String workoutCompleted = 'workout_completed';
  static const String nutritionViewed = 'nutrition_viewed';
  static const String aiCoachOpened = 'ai_coach_opened';
  static const String paywallViewed = 'paywall_viewed';
  static const String purchaseStarted = 'purchase_started';
  static const String purchaseCompleted = 'purchase_completed';
  static const String restorePurchase = 'restore_purchase';
}
