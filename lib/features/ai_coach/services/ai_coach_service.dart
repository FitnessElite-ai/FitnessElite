import '../models/conversation_message.dart';

/// Abstract service interface for AI Fitness Coach responses.
/// Decoupled so MockAICoachService can later be replaced by OpenAI/Gemini/LLM APIs.
abstract class AICoachService {
  Future<String> generateResponse({
    required String userMessage,
    required List<ConversationMessage> conversation,
  });
}
