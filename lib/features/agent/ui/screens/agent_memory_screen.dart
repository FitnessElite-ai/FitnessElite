import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/animations/fade_in_animation.dart';
import '../../../../shared/animations/glass_entrance_animation.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../providers/agent_provider.dart';

/// "YOUR FITNESS MEMORY" screen enabling full user transparency and preference control.
class AgentMemoryScreen extends ConsumerWidget {
  const AgentMemoryScreen({super.key});

  IconData _getIconForCategory(String category) {
    final cat = category.toUpperCase();
    if (cat.contains('EXERCISE') || cat.contains('WORKOUT')) return Icons.fitness_center_rounded;
    if (cat.contains('NUTRITION') || cat.contains('DIET')) return Icons.restaurant_rounded;
    if (cat.contains('RECOVERY') || cat.contains('SLEEP')) return Icons.battery_charging_full_rounded;
    if (cat.contains('GOAL')) return Icons.flag_rounded;
    return Icons.psychology_rounded;
  }

  String _formatCategoryLabel(String category) {
    final clean = category.replaceAll('_', ' ').toLowerCase();
    if (clean.isEmpty) return 'Preference';
    return clean[0].toUpperCase() + clean.substring(1);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontalPadding = ResponsiveUtils.getHorizontalPadding(context);
    final agentState = ref.watch(agentNotifierProvider);
    final notifier = ref.read(agentNotifierProvider.notifier);

    final memories = agentState.memories;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 22),
          onPressed: () {
            if (GoRouter.maybeOf(context) != null && context.canPop()) {
              context.pop();
            } else if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/home');
            }
          },
          tooltip: 'Back',
        ),
        title: Text(
          'Your Fitness Memory',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FadeInAnimation(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'YOUR FITNESS MEMORY',
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'FitnessElite.ai learns what works for you.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      if (memories.isEmpty) ...[
                        GlassCard(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: const [
                              Icon(Icons.psychology_outlined,
                                  size: 40, color: AppColors.electricBlue),
                              SizedBox(height: 10),
                              Text('No preferences saved yet.'),
                              SizedBox(height: 4),
                              Text(
                                'As you complete workouts and log feedback, FitnessElite.ai will save your training preferences here.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        ...memories.map((m) {
                          final icon = _getIconForCategory(m.category);
                          final catLabel = _formatCategoryLabel(m.category);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: GlassEntranceAnimation(
                              child: GlassCard(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.electricBlue
                                            .withValues(alpha: 0.15),
                                      ),
                                      child: Icon(icon,
                                          color: AppColors.electricBlue,
                                          size: 18),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            catLabel,
                                            style: const TextStyle(
                                              color: AppColors.electricBlue,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            m.value,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall
                                                ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.w800),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Learned from ${m.source}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: isDark
                                                      ? AppColors
                                                          .darkTextSecondary
                                                      : AppColors
                                                          .lightTextSecondary,
                                                  fontSize: 11,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                          Icons.close_rounded,
                                          color: AppColors.error,
                                          size: 20),
                                      onPressed: () =>
                                          notifier.forgetMemory(m.id),
                                      tooltip: 'Remove Preference',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
