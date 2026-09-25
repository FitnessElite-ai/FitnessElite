import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class QuickReplyChips extends StatelessWidget {
  final List<String> options;
  final ValueChanged<String> onSelected;

  const QuickReplyChips({
    super.key,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: options.map((opt) {
          return ActionChip(
            label: Text(opt),
            onPressed: () => onSelected(opt),
            backgroundColor: isDark
                ? AppColors.darkSurfaceVariant
                : AppColors.lightSurfaceVariant,
            side: BorderSide(
              color: isDark
                  ? AppColors.electricBlue.withValues(alpha: 0.5)
                  : AppColors.vividBlue.withValues(alpha: 0.5),
            ),
            labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppColors.electricBlue
                      : AppColors.vividBlue,
                  fontWeight: FontWeight.w700,
                ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          );
        }).toList(),
      ),
    );
  }
}
