import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/animations/fade_in_animation.dart';
import '../../../../shared/animations/glass_entrance_animation.dart';
import '../../../../shared/widgets/fitness_elite_logo.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../ai_coach/providers/ai_coach_provider.dart';
import '../../providers/fitness_engine_provider.dart';

/// Screen displaying animated generation stages while FitnessEngine produces a personalized plan.
class PlanGenerationScreen extends ConsumerStatefulWidget {
  const PlanGenerationScreen({super.key});

  @override
  ConsumerState<PlanGenerationScreen> createState() =>
      _PlanGenerationScreenState();
}

class _PlanGenerationScreenState extends ConsumerState<PlanGenerationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startGeneration();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startGeneration() async {
    final aiState = ref.read(conversationNotifierProvider);
    final profile = aiState.completeProfile;

    if (profile == null) {
      if (mounted && GoRouter.maybeOf(context) != null) {
        context.go('/ai-coach');
      }
      return;
    }

    final notifier = ref.read(fitnessEngineNotifierProvider.notifier);
    final plan = await notifier.generatePlanForProfile(profile);

    if (mounted && GoRouter.maybeOf(context) != null) {
      if (plan != null) {
        context.go('/personalized-plan');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(fitnessEngineNotifierProvider);
    final horizontalPadding = ResponsiveUtils.getHorizontalPadding(context);

    if (state.isError) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const FitnessEliteLogo(iconSize: 26, fontSize: 18),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.error,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  "We couldn't build your plan right now.",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          if (GoRouter.maybeOf(context) != null) {
                            context.go('/ai-coach');
                          }
                        },
                        child: Text(l10n.skip),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _startGeneration,
                        child: const Text('Try Again'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const FitnessEliteLogo(
          iconSize: 26,
          fontSize: 18,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pulsing Intelligence Engine Orb
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.electricBlue.withValues(
                            alpha: 0.2 + (_pulseController.value * 0.4),
                          ),
                          blurRadius: 32 * _pulseController.value,
                          spreadRadius: 8 * _pulseController.value,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.psychology_rounded,
                      color: Colors.black,
                      size: 64,
                    ),
                  );
                },
              ),

              const SizedBox(height: 36),

              // Title
              FadeInAnimation(
                child: Text(
                  'Building your personalized plan...',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),

              const SizedBox(height: 16),

              // Processing Stage Indicator
              GlassEntranceAnimation(
                child: GlassCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  enableGlow: true,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.electricBlue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        state.generationStage.isNotEmpty
                            ? state.generationStage
                            : 'Understanding your profile',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.electricBlue,
                              fontWeight: FontWeight.w700,
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
