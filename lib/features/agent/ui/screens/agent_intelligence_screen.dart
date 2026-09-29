import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/animations/fade_in_animation.dart';
import '../../../../shared/animations/glass_entrance_animation.dart';
import '../../../../shared/widgets/fitness_elite_logo.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../models/agent_state.dart';
import '../../providers/agent_provider.dart';

/// Consumer-focused AI Fitness Agent Intelligence & Activity Overview Screen.
/// Replaces technical pipeline terminology with clean, human consumer language.
class AgentIntelligenceScreen extends ConsumerWidget {
  const AgentIntelligenceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontalPadding = ResponsiveUtils.getHorizontalPadding(context);
    final agentState = ref.watch(agentNotifierProvider);
    final notifier = ref.read(agentNotifierProvider.notifier);

    final consumerSteps = [
      ('Your Profile', 'Personal context loaded', Icons.person_rounded, AgentCycleStage.observe),
      ('Personal Context', 'Preferences & targets retrieved', Icons.psychology_rounded, AgentCycleStage.understand),
      ('Today\'s Signals', 'Recent workouts & energy reviewed', Icons.sensors_rounded, AgentCycleStage.plan),
      ('AI Analysis', 'Recovery & goals evaluated', Icons.auto_awesome_rounded, AgentCycleStage.decide),
      ('Smart Decision', 'Today\'s session optimized safely', Icons.shield_rounded, AgentCycleStage.act),
      ('Plan Adaptation', 'Workout volume & schedule adapted', Icons.tune_rounded, AgentCycleStage.reflect),
      ('Learning From You', 'Learned preference saved to memory', Icons.save_rounded, AgentCycleStage.adapt),
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
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
        title: const FitnessEliteLogo(iconSize: 26, fontSize: 18),
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
                      // Header
                      FadeInAnimation(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI FITNESS AGENT',
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Your plan adapts as you progress.',
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

                      // Status & Trigger Card
                      GlassEntranceAnimation(
                        child: GlassCard(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: Colors.greenAccent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Fitness Agent • Active',
                                    style: const TextStyle(
                                      color: AppColors.electricBlue,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                agentState.statusMessage,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton.icon(
                                  onPressed: agentState.isRunning
                                      ? null
                                      : () => notifier.triggerAgentCycle(),
                                  icon: agentState.isRunning
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.black,
                                          ),
                                        )
                                      : const Icon(Icons.bolt_rounded, size: 20),
                                  label: Text(agentState.isRunning
                                      ? 'Analyzing Progress...'
                                      : 'Run Today\'s Analysis'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // TODAY'S INTELLIGENCE CHECKLIST
                      GlassEntranceAnimation(
                        delay: const Duration(milliseconds: 100),
                        child: GlassCard(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "TODAY'S INTELLIGENCE",
                                style: TextStyle(
                                  color: AppColors.electricBlue,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Your agent reviewed:',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 10),
                              const _CheckItem('Recent workouts & completion rate'),
                              const _CheckItem('Recovery signals & sleep index'),
                              const _CheckItem('Weekly streak & goal progress'),
                              const _CheckItem('Personalized training preferences'),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // WHAT CHANGED CARD
                      if (agentState.lastDecision != null) ...[
                        GlassEntranceAnimation(
                          delay: const Duration(milliseconds: 150),
                          child: GlassCard(
                            padding: const EdgeInsets.all(18),
                            enableGlow: true,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'WHAT CHANGED',
                                  style: TextStyle(
                                    color: AppColors.electricBlue,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  agentState.lastDecision!.decision,
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Reason: ${agentState.lastDecision!.reason}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.lightTextSecondary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // YOUR AGENT'S ACTIVITY VERTICAL TIMELINE
                      Text(
                        "YOUR AGENT'S ACTIVITY",
                        style: const TextStyle(
                          color: AppColors.electricBlue,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 12),

                      ...consumerSteps.map((step) {
                        final isActive = agentState.activeStage == step.$4 || agentState.isRunning;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: GlassCard(
                            padding: const EdgeInsets.all(14),
                            enableGlow: isActive,
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: isActive ? AppColors.primaryGradient : null,
                                    color: !isActive ? AppColors.electricBlue.withValues(alpha: 0.15) : null,
                                  ),
                                  child: Icon(
                                    step.$3,
                                    size: 18,
                                    color: isActive ? Colors.black : AppColors.electricBlue,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        step.$1,
                                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                      Text(
                                        step.$2,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              fontSize: 11,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.electricBlue,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                      const SizedBox(height: 16),

                      // WHY THIS MATTERS FOOTER
                      GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: const [
                            Text(
                              'WHY THIS MATTERS',
                              style: TextStyle(
                                color: AppColors.electricBlue,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.0,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'FitnessElite.ai continuously adapts your plan to what actually happens in your life.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
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

class _CheckItem extends StatelessWidget {
  final String text;
  const _CheckItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.check_rounded, color: AppColors.electricBlue, size: 16),
          const SizedBox(width: 8),
          Text(text, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
