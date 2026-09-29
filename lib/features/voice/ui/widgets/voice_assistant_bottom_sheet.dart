import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../models/voice_state.dart';
import '../../providers/voice_provider.dart';

/// Lightweight Voice Assistant Bottom Sheet ("Ask FitnessElite.ai")
class VoiceAssistantBottomSheet extends ConsumerStatefulWidget {
  const VoiceAssistantBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const VoiceAssistantBottomSheet(),
    );
  }

  @override
  ConsumerState<VoiceAssistantBottomSheet> createState() => _VoiceAssistantBottomSheetState();
}

class _VoiceAssistantBottomSheetState extends ConsumerState<VoiceAssistantBottomSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitQuery(String text) {
    if (text.trim().isEmpty) return;
    ref.read(voiceNotifierProvider.notifier).handleVoiceInput(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final voiceState = ref.watch(voiceNotifierProvider);

    final suggestions = const [
      'I only have 20 minutes today.',
      'I\'m feeling tired for legs.',
      'How should I breathe during squats?',
      'Give me a 10-minute yoga session.',
    ];

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.primaryGradient,
                      ),
                      child: const Icon(Icons.mic_rounded, color: Colors.black, size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Ask FitnessElite.ai',
                      style: TextStyle(
                        color: AppColors.electricBlue,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (voiceState.status == VoiceStatus.understanding) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(color: AppColors.electricBlue),
                ),
              ),
            ] else if (voiceState.responseText.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.electricBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  voiceState.responseText,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Input Row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: Theme.of(context).textTheme.bodyMedium,
                    onSubmitted: _submitQuery,
                    decoration: InputDecoration(
                      hintText: 'Say or type your query...',
                      filled: true,
                      fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.send_rounded, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.electricBlue,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () => _submitQuery(_controller.text),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Suggestions Chips
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: suggestions.map((s) {
                return ActionChip(
                  label: Text(s, style: const TextStyle(fontSize: 11)),
                  onPressed: () => _submitQuery(s),
                  backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                  side: BorderSide(color: AppColors.electricBlue.withValues(alpha: 0.4)),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
