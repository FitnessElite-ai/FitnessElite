import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/fitness_elite_logo.dart';
import '../../../../shared/widgets/glass_card.dart';

/// Shareable milestone progress card widget for social sharing (Influencer & Growth Loop).
class ShareableProgressCard extends StatelessWidget {
  final int streakDays;
  final int completedWorkouts;
  final String primaryGoal;

  const ShareableProgressCard({
    super.key,
    required this.streakDays,
    required this.completedWorkouts,
    required this.primaryGoal,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      enableGlow: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const FitnessEliteLogo(iconSize: 28, fontSize: 20),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
            ),
            child: const Icon(Icons.emoji_events_rounded, color: Colors.black, size: 36),
          ),
          const SizedBox(height: 14),
          Text(
            '$streakDays-DAY STREAK',
            style: const TextStyle(
              color: AppColors.electricBlue,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Goal: $primaryGoal',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Completed $completedWorkouts training sessions with autonomous AI plan adaptations.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          const Text(
            'POWERED BY FITNESSELITE.AI',
            style: TextStyle(
              color: AppColors.electricBlue,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
