import 'package:flutter/foundation.dart';
import '../models/conversation_message.dart';

/// Provider interface for pluggable LLM backends (OpenAI, Gemini, AWS Bedrock, Custom, or Deterministic local).
abstract class ConversationalAIProvider {
  String get providerName;

  Future<String> generateResponse({
    required String userMessage,
    required List<ConversationMessage> conversation,
    Map<String, dynamic>? context,
  });
}

/// Structured intent extracted from conversational user query without requiring an active LLM.
class StructuredUserIntent {
  final String rawQuery;
  final String intentType; // e.g., "time_constraint", "fatigue", "exercise_dislike", "exercise_replacement", "missed_workout", "schedule_change", "travel", "level"
  final Map<String, dynamic> extractedParameters;

  const StructuredUserIntent({
    required this.rawQuery,
    required this.intentType,
    required this.extractedParameters,
  });

  static StructuredUserIntent parse(String text) {
    final lower = text.toLowerCase().trim();

    if (lower.contains('min') || lower.contains('limited time') || lower.contains('short on time') || lower.contains('only have')) {
      int minutes = 30;
      final match = RegExp(r'(\d+)').firstMatch(lower);
      if (match != null) {
        minutes = int.tryParse(match.group(1) ?? '30') ?? 30;
      }
      return StructuredUserIntent(
        rawQuery: text,
        intentType: 'time_constraint',
        extractedParameters: {'durationMinutes': minutes},
      );
    }

    if (lower.contains('travel') || lower.contains('busy') || lower.contains('on the road')) {
      return StructuredUserIntent(
        rawQuery: text,
        intentType: 'travel',
        extractedParameters: {},
      );
    }

    if (lower.contains('beginner') || lower.contains('intermediate') || lower.contains('advanced')) {
      String level = 'beginner';
      if (lower.contains('intermediate')) level = 'intermediate';
      if (lower.contains('advanced')) level = 'advanced';
      return StructuredUserIntent(
        rawQuery: text,
        intentType: 'level',
        extractedParameters: {'level': level},
      );
    }

    if (lower.contains('too tired') || lower.contains('fatigued') || lower.contains('exhausted') || lower.contains('low energy')) {
      String targetGroup = 'general';
      if (lower.contains('legs') || lower.contains('leg day')) targetGroup = 'legs';
      if (lower.contains('arms') || lower.contains('upper')) targetGroup = 'upper';
      return StructuredUserIntent(
        rawQuery: text,
        intentType: 'fatigue',
        extractedParameters: {'targetGroup': targetGroup},
      );
    }

    if (lower.contains('hate') || lower.contains('don\'t like') || lower.contains('dislike')) {
      String exercise = 'running';
      if (lower.contains('running') || lower.contains('jogging')) exercise = 'running';
      if (lower.contains('burpees')) exercise = 'burpees';
      return StructuredUserIntent(
        rawQuery: text,
        intentType: 'exercise_dislike',
        extractedParameters: {'exerciseToAvoid': exercise},
      );
    }

    if (lower.contains('replace') || lower.contains('substitute') || lower.contains('alternative')) {
      String exercise = 'push-ups';
      if (lower.contains('push-up') || lower.contains('pushup')) exercise = 'push-ups';
      return StructuredUserIntent(
        rawQuery: text,
        intentType: 'exercise_replacement',
        extractedParameters: {'exerciseToReplace': exercise},
      );
    }

    if (lower.contains('missed') || lower.contains('skipped')) {
      return StructuredUserIntent(
        rawQuery: text,
        intentType: 'missed_workout',
        extractedParameters: {'timeframe': 'yesterday'},
      );
    }

    if (lower.contains('tomorrow morning') || lower.contains('train tomorrow') || lower.contains('reschedule')) {
      return StructuredUserIntent(
        rawQuery: text,
        intentType: 'schedule_change',
        extractedParameters: {'preferredTime': 'morning'},
      );
    }

    return StructuredUserIntent(
      rawQuery: text,
      intentType: 'general_question',
      extractedParameters: {},
    );
  }
}

/// Fallback deterministic AI provider working offline without external API keys.
class DeterministicFallbackProvider implements ConversationalAIProvider {
  @override
  String get providerName => 'Deterministic Rule Engine';

  @override
  Future<String> generateResponse({
    required String userMessage,
    required List<ConversationMessage> conversation,
    Map<String, dynamic>? context,
  }) async {
    final cleanMsg = userMessage.trim().toLowerCase();
    final intent = StructuredUserIntent.parse(userMessage);

    if (cleanMsg.contains('travel') || cleanMsg.contains('busy')) {
      return "Got it. I'll keep your future plan flexible so travel and busy days don't completely disrupt your routine.";
    }

    if (cleanMsg.contains('beginner')) {
      return "That's a great place to start. We'll focus on building consistency and mastering the basics before increasing intensity.";
    }

    switch (intent.intentType) {
      case 'time_constraint':
        final min = intent.extractedParameters['durationMinutes'] ?? 30;
        return "I've adapted today's session to a high-efficiency $min minutes workout focus so you get maximum stimulus in your available time window.";

      case 'travel':
        return "Got it. I'll keep your future plan flexible so travel and busy days don't completely disrupt your routine.";

      case 'level':
        final level = intent.extractedParameters['level'] ?? 'beginner';
        if (level == 'beginner') {
          return "That's a great place to start. We'll focus on building consistency and mastering the basics before increasing intensity.";
        }
        return "Excellent. We can optimize your volume, intensity, and progressive overload strategy right away.";

      case 'fatigue':
        final target = intent.extractedParameters['targetGroup'] ?? 'general';
        return "Understood. I've adjusted your plan to prioritize an active recovery and low-impact session for $target today.";

      case 'exercise_dislike':
        final ex = intent.extractedParameters['exerciseToAvoid'] ?? 'this exercise';
        return "Noted. I've updated your fitness memory to minimize $ex and substituted low-impact alternatives into your schedule.";

      case 'exercise_replacement':
        final ex = intent.extractedParameters['exerciseToReplace'] ?? 'push-ups';
        return "You can replace $ex with incline dumbbell presses or chest dip progressions to target the same muscle groups effectively.";

      case 'missed_workout':
        return "No worries! Missing one day doesn't ruin progress. Your schedule has automatically re-balanced to preserve your weekly consistency without overtraining.";

      case 'schedule_change':
        return "Scheduled! Your morning workout notification and warm-up routine are queued for tomorrow morning.";

      default:
        return "Your Fitness Agent has logged your feedback. I'm continually adapting your training plan based on your energy, schedule, and recovery.";
    }
  }
}

/// Pluggable OpenAI Provider stub (API Key configured via environment/secure storage).
class OpenAIProvider implements ConversationalAIProvider {
  final String? apiKey;
  OpenAIProvider({this.apiKey});

  @override
  String get providerName => 'OpenAI GPT-4o';

  @override
  Future<String> generateResponse({
    required String userMessage,
    required List<ConversationMessage> conversation,
    Map<String, dynamic>? context,
  }) async {
    if (apiKey == null || apiKey!.isEmpty) {
      debugPrint('[OpenAIProvider] No API key set. Delegating to Deterministic Fallback.');
      return DeterministicFallbackProvider().generateResponse(
        userMessage: userMessage,
        conversation: conversation,
        context: context,
      );
    }
    return "OpenAI response for '$userMessage'";
  }
}

/// Pluggable Gemini Provider stub.
class GeminiProvider implements ConversationalAIProvider {
  final String? apiKey;
  GeminiProvider({this.apiKey});

  @override
  String get providerName => 'Google Gemini 1.5 Pro';

  @override
  Future<String> generateResponse({
    required String userMessage,
    required List<ConversationMessage> conversation,
    Map<String, dynamic>? context,
  }) async {
    if (apiKey == null || apiKey!.isEmpty) {
      return DeterministicFallbackProvider().generateResponse(
        userMessage: userMessage,
        conversation: conversation,
        context: context,
      );
    }
    return "Gemini response for '$userMessage'";
  }
}

/// Pluggable AWS Bedrock Provider stub.
class BedrockProvider implements ConversationalAIProvider {
  @override
  String get providerName => 'AWS Bedrock Claude 3.5';

  @override
  Future<String> generateResponse({
    required String userMessage,
    required List<ConversationMessage> conversation,
    Map<String, dynamic>? context,
  }) async {
    return DeterministicFallbackProvider().generateResponse(
      userMessage: userMessage,
      conversation: conversation,
      context: context,
    );
  }
}

/// Custom Model Provider stub.
class CustomModelProvider implements ConversationalAIProvider {
  @override
  String get providerName => 'Custom On-Device / Cloud LLM';

  @override
  Future<String> generateResponse({
    required String userMessage,
    required List<ConversationMessage> conversation,
    Map<String, dynamic>? context,
  }) async {
    return DeterministicFallbackProvider().generateResponse(
      userMessage: userMessage,
      conversation: conversation,
      context: context,
    );
  }
}
