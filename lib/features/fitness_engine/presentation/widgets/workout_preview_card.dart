import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/animations/glass_entrance_animation.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../models/workout_plan.dart';

class WorkoutPreviewCard extends StatelessWidget {
  final WorkoutPlan plan;
  final int delayMs;

  const WorkoutPreviewCard({
    super.key,
    required this.plan,
    this.delayMs = 200,
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
                    Icons.fitness_center_rounded,
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
                        'WORKOUT PROGRAM',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.electricBlue,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                      ),
                      Text(
                        plan.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Text(
              plan.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
            ),

            const SizedBox(height: 14),
            const Divider(),
            const SizedBox(height: 10),

            // Weekly Schedule Preview List
            ...plan.days.map((day) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 90,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: day.isWorkout
                            ? AppColors.electricBlue.withValues(alpha: 0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: day.isWorkout
                            ? Border.all(
                                color: AppColors.electricBlue.withValues(alpha: 0.4))
                            : null,
                      ),
                      child: Text(
                        day.day.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: day.isWorkout
                              ? AppColors.electricBlue
                              : (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            day.title,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          Text(
                            day.focus,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                  fontSize: 11,
                                ),
                          ),
                        ],
                      ),
                    ),
                    if (day.isWorkout)
                      Text(
                        '${day.durationMinutes} min',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.electricBlue,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
