import '../models/conversation_message.dart';
import 'ai_coach_service.dart';
import 'conversational_ai_provider.dart';

/// Production-ready AI Coach Service delegating to pluggable ConversationalAIProvider architecture.
class MockAICoachService implements AICoachService {
  final ConversationalAIProvider _provider;

  MockAICoachService({ConversationalAIProvider? provider})
      : _provider = provider ?? DeterministicFallbackProvider();

  @override
  Future<String> generateResponse({
    required String userMessage,
    required List<ConversationMessage> conversation,
  }) async {
    return _provider.generateResponse(
      userMessage: userMessage,
      conversation: conversation,
    );
  }
}
