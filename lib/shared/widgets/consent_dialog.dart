import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Modal dialog providing explicit consent UX for Vision AI, Notifications, and Telemetry.
class ConsentDialog extends StatelessWidget {
  final String title;
  final String description;
  final String primaryButtonText;
  final String secondaryButtonText;
  final VoidCallback onAccepted;
  final VoidCallback? onDeclined;

  const ConsentDialog({
    super.key,
    required this.title,
    required this.description,
    this.primaryButtonText = 'I Agree & Continue',
    this.secondaryButtonText = 'Not Now',
    required this.onAccepted,
    this.onDeclined,
  });

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String description,
    String primaryButtonText = 'I Agree & Continue',
    String secondaryButtonText = 'Not Now',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => ConsentDialog(
        title: title,
        description: description,
        primaryButtonText: primaryButtonText,
        secondaryButtonText: secondaryButtonText,
        onAccepted: () => Navigator.of(ctx).pop(true),
        onDeclined: () => Navigator.of(ctx).pop(false),
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.shield_outlined, color: AppColors.electricBlue, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
      content: Text(
        description,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (onDeclined != null) {
              onDeclined!();
            } else {
              Navigator.of(context).pop(false);
            }
          },
          child: Text(secondaryButtonText),
        ),
        ElevatedButton(
          onPressed: onAccepted,
          child: Text(primaryButtonText),
        ),
      ],
    );
  }
}
