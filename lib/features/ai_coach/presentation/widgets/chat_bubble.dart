import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/animations/glass_entrance_animation.dart';
import '../../models/conversation_message.dart';

class ChatBubble extends StatelessWidget {
  final ConversationMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isAi = message.sender == MessageSender.ai;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassEntranceAnimation(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment:
              isAi ? MainAxisAlignment.start : MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isAi) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                ),
                child: const Icon(
                  Icons.smart_toy_rounded,
                  color: Colors.black,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
            ],

            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: isAi
                      ? null
                      : const LinearGradient(
                          colors: [
                            AppColors.electricBlue,
                            AppColors.vividBlue,
                          ],
                        ),
                  color: isAi
                      ? (isDark
                          ? AppColors.darkSurfaceVariant
                          : AppColors.lightSurfaceVariant)
                      : null,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isAi ? 4 : 18),
                    bottomRight: Radius.circular(isAi ? 18 : 4),
                  ),
                  border: isAi
                      ? Border.all(
                          color: isDark
                              ? AppColors.darkGlassBorder
                              : AppColors.lightGlassBorder,
                        )
                      : null,
                ),
                child: Text(
                  message.text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isAi
                            ? (isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary)
                            : Colors.black,
                        fontWeight: isAi ? FontWeight.w400 : FontWeight.w600,
                        height: 1.4,
                      ),
                ),
              ),
            ),

            if (!isAi) const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}
