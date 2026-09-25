import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/persistence_providers.dart';
import '../../health_assessment/domain/fitness_profile.dart';
import '../../health_assessment/presentation/providers/health_assessment_provider.dart';
import '../models/complete_fitness_profile.dart';
import '../models/conversation_message.dart';
import '../models/fitness_preferences.dart';
import '../repositories/ai_coach_repository.dart';
import '../services/ai_coach_service.dart';
import '../services/mock_ai_coach_service.dart';

final aiCoachServiceProvider = Provider<AICoachService>((ref) {
  return MockAICoachService();
});

final aiCoachRepositoryProvider = Provider<AICoachRepository>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return LocalAICoachRepository(storage);
});

class ConversationState {
  final List<ConversationMessage> messages;
  final int currentQuestionIndex;
  final bool isTyping;
  final bool isCompleted;
  final String primaryGoal;
  final String dailyTrainingTime;
  final String preferredLocation;
  final String experienceLevel;
  final String consistencyBarrier;
  final String dietaryPreference;
  final String additionalNotes;
  final CompleteFitnessProfile? completeProfile;

  const ConversationState({
    this.messages = const [],
    this.currentQuestionIndex = 0,
    this.isTyping = false,
    this.isCompleted = false,
    this.primaryGoal = '',
    this.dailyTrainingTime = '',
    this.preferredLocation = '',
    this.experienceLevel = '',
    this.consistencyBarrier = '',
    this.dietaryPreference = '',
    this.additionalNotes = '',
    this.completeProfile,
  });

  ConversationState copyWith({
    List<ConversationMessage>? messages,
    int? currentQuestionIndex,
    bool? isTyping,
    bool? isCompleted,
    String? primaryGoal,
    String? dailyTrainingTime,
    String? preferredLocation,
    String? experienceLevel,
    String? consistencyBarrier,
    String? dietaryPreference,
    String? additionalNotes,
    CompleteFitnessProfile? completeProfile,
  }) {
    return ConversationState(
      messages: messages ?? this.messages,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      isTyping: isTyping ?? this.isTyping,
      isCompleted: isCompleted ?? this.isCompleted,
      primaryGoal: primaryGoal ?? this.primaryGoal,
      dailyTrainingTime: dailyTrainingTime ?? this.dailyTrainingTime,
      preferredLocation: preferredLocation ?? this.preferredLocation,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      consistencyBarrier: consistencyBarrier ?? this.consistencyBarrier,
      dietaryPreference: dietaryPreference ?? this.dietaryPreference,
      additionalNotes: additionalNotes ?? this.additionalNotes,
      completeProfile: completeProfile ?? this.completeProfile,
    );
  }
}

class ConversationNotifier extends Notifier<ConversationState> {
  late final AICoachService _aiService;
  late final AICoachRepository _repository;

  @override
  ConversationState build() {
    _aiService = ref.watch(aiCoachServiceProvider);
    _repository = ref.watch(aiCoachRepositoryProvider);

    final existingComplete = _repository.getCompleteFitnessProfile();
    if (existingComplete != null) {
      return ConversationState(
        isCompleted: true,
        primaryGoal: existingComplete.fitnessPreferences.primaryGoal,
        dailyTrainingTime: existingComplete.fitnessPreferences.dailyTrainingTime,
        preferredLocation: existingComplete.fitnessPreferences.preferredLocation,
        experienceLevel: existingComplete.fitnessPreferences.experienceLevel,
        consistencyBarrier: existingComplete.fitnessPreferences.consistencyBarrier,
        dietaryPreference: existingComplete.fitnessPreferences.dietaryPreference,
        additionalNotes: existingComplete.fitnessPreferences.additionalNotes,
        completeProfile: existingComplete,
      );
    }

    // Initialize conversation
    final initialMessages = [
      ConversationMessage(
        id: 'msg_welcome',
        text:
            "Hey! I'm your FitnessElite AI coach.\n\nI already know a little about you from your assessment. Let's understand your goals, lifestyle, and preferences so I can build something that actually fits your life.",
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
      ),
      ConversationMessage(
        id: 'q_0',
        text: "What is your main goal right now?",
        sender: MessageSender.ai,
        timestamp: DateTime.now().add(const Duration(milliseconds: 100)),
        quickReplies: const [
          'Lose fat',
          'Build muscle',
          'Get stronger',
          'Improve endurance',
          'Improve overall fitness',
        ],
      ),
    ];

    return ConversationState(messages: initialMessages);
  }

  Future<void> answerQuestion(String answerText) async {
    if (state.isTyping || state.isCompleted) return;

    final trimmedAnswer = answerText.trim();
    if (trimmedAnswer.isEmpty) return;

    final userMsg = ConversationMessage(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      text: trimmedAnswer,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    // Update messages & answer store
    final updatedMessages = List<ConversationMessage>.from(state.messages)..add(userMsg);

    String newGoal = state.primaryGoal;
    String newTime = state.dailyTrainingTime;
    String newLocation = state.preferredLocation;
    String newExperience = state.experienceLevel;
    String newBarrier = state.consistencyBarrier;
    String newDiet = state.dietaryPreference;
    String newNotes = state.additionalNotes;

    switch (state.currentQuestionIndex) {
      case 0:
        newGoal = trimmedAnswer;
        break;
      case 1:
        newTime = trimmedAnswer;
        break;
      case 2:
        newLocation = trimmedAnswer;
        break;
      case 3:
        newExperience = trimmedAnswer;
        break;
      case 4:
        newBarrier = trimmedAnswer;
        break;
      case 5:
        newDiet = trimmedAnswer;
        break;
      case 6:
        newNotes = trimmedAnswer;
        break;
    }

    state = state.copyWith(
      messages: updatedMessages,
      isTyping: true,
      primaryGoal: newGoal,
      dailyTrainingTime: newTime,
      preferredLocation: newLocation,
      experienceLevel: newExperience,
      consistencyBarrier: newBarrier,
      dietaryPreference: newDiet,
      additionalNotes: newNotes,
    );

    // AI Response Generation
    final aiResponseText = await _aiService.generateResponse(
      userMessage: trimmedAnswer,
      conversation: updatedMessages,
    );

    final aiFeedbackMsg = ConversationMessage(
      id: 'ai_fb_${DateTime.now().millisecondsSinceEpoch}',
      text: aiResponseText,
      sender: MessageSender.ai,
      timestamp: DateTime.now(),
    );

    final nextIndex = state.currentQuestionIndex + 1;
    final finalMessages = List<ConversationMessage>.from(updatedMessages)..add(aiFeedbackMsg);

    if (nextIndex <= 6) {
      final nextQuestion = _getQuestionForIndex(nextIndex);
      final qMsg = ConversationMessage(
        id: 'q_$nextIndex',
        text: nextQuestion.text,
        sender: MessageSender.ai,
        timestamp: DateTime.now().add(const Duration(milliseconds: 100)),
        quickReplies: nextQuestion.quickReplies,
      );
      finalMessages.add(qMsg);

      state = state.copyWith(
        messages: finalMessages,
        currentQuestionIndex: nextIndex,
        isTyping: false,
      );
    } else {
      // Completed! Save Complete Fitness Profile
      state = state.copyWith(
        messages: finalMessages,
        currentQuestionIndex: nextIndex,
        isTyping: false,
        isCompleted: true,
      );

      await _finalizeProfile();
    }
  }

  ({String text, List<String>? quickReplies}) _getQuestionForIndex(int index) {
    switch (index) {
      case 1:
        return (
          text: "How much time can you realistically dedicate to training each day?",
          quickReplies: ['15 minutes', '30 minutes', '45 minutes', '60+ minutes'],
        );
      case 2:
        return (
          text: "Where do you prefer to train?",
          quickReplies: ['Home', 'Gym', 'Outdoors', 'Combination'],
        );
      case 3:
        return (
          text: "How would you describe your fitness experience?",
          quickReplies: ['Beginner', 'Intermediate', 'Advanced'],
        );
      case 4:
        return (
          text: "What usually makes it difficult to stay consistent?",
          quickReplies: [
            'Lack of time',
            'Motivation',
            'Work/studies',
            'Travel',
            "I don't know what to do",
            "Nothing — I'm consistent"
          ],
        );
      case 5:
        return (
          text: "How would you describe your usual diet?",
          quickReplies: [
            'Vegetarian',
            'Non-vegetarian',
            'Vegan',
            'Eggetarian',
            'Flexible'
          ],
        );
      case 6:
        return (
          text: "Anything else you want your AI coach to know?",
          quickReplies: [
            'No additional notes',
            'I have a previous injury',
            'I prefer low-impact exercises'
          ],
        );
      default:
        return (text: "", quickReplies: null);
    }
  }

  Future<void> _finalizeProfile() async {
    final healthState = ref.read(healthAssessmentNotifierProvider);
    final healthProfile = healthState.savedProfile ??
        FitnessProfile(
          name: healthState.name.isNotEmpty
              ? healthState.name
              : 'Fitness Elite Athlete',
          age: healthState.age,
          sex: healthState.sex,
          heightCm: healthState.heightCm,
          weightKg: healthState.weightKg,
          unitSystem: healthState.unitSystem,
          bmi: healthState.calculatedBmi,
          bmiCategory: healthState.bmiCategoryName,
          activityLevel: healthState.activityLevel,
          primaryGoal: healthState.primaryGoal,
          workoutAvailability: healthState.workoutAvailability,
          workoutDays: healthState.workoutDays,
          equipment: healthState.equipment,
          sleepDuration: healthState.sleepDuration,
          dietaryPreference: healthState.dietaryPreference,
          preferredLanguage: 'en',
        );

    final preferences = FitnessPreferences(
      primaryGoal: state.primaryGoal,
      dailyTrainingTime: state.dailyTrainingTime,
      preferredLocation: state.preferredLocation,
      experienceLevel: state.experienceLevel,
      consistencyBarrier: state.consistencyBarrier,
      dietaryPreference: state.dietaryPreference,
      additionalNotes: state.additionalNotes,
    );

    final completeProfile = CompleteFitnessProfile(
      healthProfile: healthProfile,
      fitnessPreferences: preferences,
      completedAt: DateTime.now(),
    );

    await _repository.saveCompleteFitnessProfile(completeProfile);

    state = state.copyWith(completeProfile: completeProfile);
  }

  void resetConversation() {
    _repository.clearCompleteFitnessProfile();
    ref.invalidateSelf();
  }
}

final conversationNotifierProvider = NotifierProvider<
    ConversationNotifier, ConversationState>(
  ConversationNotifier.new,
);
