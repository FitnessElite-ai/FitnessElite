import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/animations/glass_entrance_animation.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../providers/ai_coach_provider.dart';

class ProfileSummaryCard extends StatelessWidget {
  final ConversationState state;
  final VoidCallback onBuildPlanPressed;

  const ProfileSummaryCard({
    super.key,
    required this.state,
    required this.onBuildPlanPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GlassEntranceAnimation(
      child: GlassCard(
        enableGlow: true,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.black,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Here's what I understand about you",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            _SummaryRow(
              icon: Icons.flag_rounded,
              label: 'Goal',
              value: state.primaryGoal,
            ),
            const SizedBox(height: 8),

            _SummaryRow(
              icon: Icons.timer_rounded,
              label: 'Training time',
              value: state.dailyTrainingTime,
            ),
            const SizedBox(height: 8),

            _SummaryRow(
              icon: Icons.location_on_rounded,
              label: 'Training location',
              value: state.preferredLocation,
            ),
            const SizedBox(height: 8),

            _SummaryRow(
              icon: Icons.equalizer_rounded,
              label: 'Experience',
              value: state.experienceLevel,
            ),
            const SizedBox(height: 8),

            _SummaryRow(
              icon: Icons.battery_saver_rounded,
              label: 'Consistency barrier',
              value: state.consistencyBarrier,
            ),
            const SizedBox(height: 8),

            _SummaryRow(
              icon: Icons.restaurant_rounded,
              label: 'Diet',
              value: state.dietaryPreference,
            ),

            if (state.additionalNotes.isNotEmpty &&
                state.additionalNotes != 'No additional notes') ...[
              const SizedBox(height: 8),
              _SummaryRow(
                icon: Icons.note_rounded,
                label: 'Additional notes',
                value: state.additionalNotes,
              ),
            ],

            const SizedBox(height: 20),

            Text(
              'Next step: Visual Fitness Baseline',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: onBuildPlanPressed,
                icon: const Icon(Icons.center_focus_strong_rounded, size: 20),
                label: const Text('Continue to Vision Assessment →'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.electricBlue),
        const SizedBox(width: 8),
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Expanded(
          child: Text(
            value.isNotEmpty ? value : 'Not specified',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }
}
