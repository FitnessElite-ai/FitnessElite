import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/animations/glass_entrance_animation.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../models/recovery_plan.dart';

class RecoveryPreviewCard extends StatelessWidget {
  final RecoveryPlan plan;
  final int delayMs;

  const RecoveryPreviewCard({
    super.key,
    required this.plan,
    this.delayMs = 400,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassEntranceAnimation(
      delay: Duration(milliseconds: delayMs),
      child: GlassCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: AppColors.primaryGradient,
                  ),
                  child: const Icon(
                    Icons.bedtime_rounded,
                    color: Colors.black,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RECOVERY & SLEEP',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.electricBlue,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                      ),
                      Text(
                        'Sleep, Hydration & Mobility Protocol',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(),
            const SizedBox(height: 10),

            _RecoveryRow(
              icon: Icons.nightlight_rounded,
              title: 'Sleep Target',
              value: plan.sleepTargetHours,
            ),
            const SizedBox(height: 8),

            _RecoveryRow(
              icon: Icons.water_drop_rounded,
              title: 'Hydration Target',
              value: plan.hydrationGuidance,
            ),
            const SizedBox(height: 8),

            _RecoveryRow(
              icon: Icons.self_improvement_rounded,
              title: 'Mobility & Posture',
              value: plan.mobilityRecommendation,
            ),
            const SizedBox(height: 8),

            _RecoveryRow(
              icon: Icons.battery_saver_rounded,
              title: 'Rest Days',
              value: '${plan.restDaysPerWeek} days per week',
            ),

            const SizedBox(height: 10),
            Text(
              plan.recoveryNotes,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecoveryRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _RecoveryRow({
    required this.icon,
    required this.title,
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
          width: 120,
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }
}
