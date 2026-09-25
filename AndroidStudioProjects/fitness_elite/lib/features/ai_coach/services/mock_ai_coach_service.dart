import '../models/conversation_message.dart';
import 'ai_coach_service.dart';

/// Production-ready Mock AI Coach Service.
/// Simulates intelligent, contextual LLM responses without external API calls or secret keys.
class MockAICoachService implements AICoachService {
  @override
  Future<String> generateResponse({
    required String userMessage,
    required List<ConversationMessage> conversation,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final cleanMsg = userMessage.trim().toLowerCase();

    if (cleanMsg.contains('15 min') ||
        cleanMsg.contains('30 min') ||
        cleanMsg.contains('45 min') ||
        cleanMsg.contains('60+ min')) {
      return "Perfect. We can build an efficient $userMessage routine around consistency rather than long sessions.";
    }

    if (cleanMsg.contains('travel') ||
        cleanMsg.contains('work') ||
        cleanMsg.contains('lack of time') ||
        cleanMsg.contains('motivation')) {
      return "Got it. I'll keep your future plan flexible so travel and busy days don't completely disrupt your routine.";
    }

    if (cleanMsg.contains('beginner')) {
      return "That's a great place to start. We'll focus on building consistency and mastering the basics before increasing intensity.";
    }

    if (cleanMsg.contains('intermediate') || cleanMsg.contains('advanced')) {
      return "Excellent. We can optimize your volume, intensity, and progressive overload strategy right away.";
    }

    if (cleanMsg.contains('home') ||
        cleanMsg.contains('gym') ||
        cleanMsg.contains('outdoors')) {
      return "Awesome! Training at $userMessage gives us great flexibility for your equipment and routine.";
    }

    if (cleanMsg.contains('lose fat') || cleanMsg.contains('build muscle')) {
      return "Understood. Target $userMessage aligns directly with your metabolic profile and strength programming.";
    }

    if (cleanMsg.contains('vegetarian') ||
        cleanMsg.contains('vegan') ||
        cleanMsg.contains('keto') ||
        cleanMsg.contains('eggetarian') ||
        cleanMsg.contains('non-vegetarian')) {
      return "Noted. We will align your protein and macro targets to match your $userMessage dietary preference.";
    }

    return "Thank you for sharing that context. I've integrated this directly into your FitnessElite AI profile!";
  }
}
