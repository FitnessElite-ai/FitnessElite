import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../providers/ai_coach_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/profile_summary_card.dart';
import '../widgets/quick_reply_chips.dart';
import '../widgets/typing_indicator.dart';

/// Premium Conversational AI Coach Screen for FitnessElite.ai.
class AICoachScreen extends ConsumerStatefulWidget {
  const AICoachScreen({super.key});

  @override
  ConsumerState<AICoachScreen> createState() => _AICoachScreenState();
}

class _AICoachScreenState extends ConsumerState<AICoachScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend(String text) {
    if (text.trim().isEmpty) return;
    _textController.clear();

    final notifier = ref.read(conversationNotifierProvider.notifier);
    notifier.answerQuestion(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontalPadding = ResponsiveUtils.getHorizontalPadding(context);
    final state = ref.watch(conversationNotifierProvider);

    // Auto-scroll when messages change or typing state updates
    ref.listen<ConversationState>(conversationNotifierProvider, (prev, next) {
      if (prev?.messages.length != next.messages.length ||
          prev?.isTyping != next.isTyping ||
          next.isCompleted) {
        _scrollToBottom();
      }
    });

    // Extract quick replies from last message if from AI and not typing/completed
    List<String>? activeQuickReplies;
    if (!state.isTyping && !state.isCompleted && state.messages.isNotEmpty) {
      final lastMsg = state.messages.last;
      if (lastMsg.quickReplies != null && lastMsg.quickReplies!.isNotEmpty) {
        activeQuickReplies = lastMsg.quickReplies;
      }
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/health-assessment'),
          tooltip: 'Back',
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: Colors.black,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              l10n.aiCoach,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Restart Conversation',
            onPressed: () {
              ref
                  .read(conversationNotifierProvider.notifier)
                  .resetConversation();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            children: [
              // Chat Messages List
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: state.messages.length +
                      (state.isTyping ? 1 : 0) +
                      (state.isCompleted ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < state.messages.length) {
                      return ChatBubble(message: state.messages[index]);
                    }

                    if (state.isTyping && index == state.messages.length) {
                      return const TypingIndicator();
                    }

                    if (state.isCompleted) {
                      return ProfileSummaryCard(
                        state: state,
                        onBuildPlanPressed: () {
                          context.go('/plan-preview');
                        },
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),

              // Active Quick Reply Chips
              if (activeQuickReplies != null)
                QuickReplyChips(
                  options: activeQuickReplies,
                  onSelected: _handleSend,
                ),

              // Text Input Bar
              if (!state.isCompleted)
                Padding(
                  padding: const EdgeInsets.only(
                    top: 8,
                    bottom: AppConstants.defaultPadding,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          enabled: !state.isTyping,
                          style: Theme.of(context).textTheme.bodyMedium,
                          onSubmitted: _handleSend,
                          decoration: InputDecoration(
                            hintText: 'Type your response...',
                            filled: true,
                            fillColor: isDark
                                ? AppColors.darkSurfaceVariant
                                : AppColors.lightSurfaceVariant,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(
                                color: isDark
                                    ? AppColors.darkGlassBorder
                                    : AppColors.lightGlassBorder,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: const BorderSide(
                                color: AppColors.electricBlue,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton.filled(
                        icon: const Icon(Icons.send_rounded, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.electricBlue,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.all(14),
                        ),
                        onPressed: state.isTyping
                            ? null
                            : () => _handleSend(_textController.text),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
