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
import '../../providers/vision_assessment_provider.dart';

/// Screen performing AI Vision Analysis with stage progression animation.
class VisionAnalysisScreen extends ConsumerStatefulWidget {
  const VisionAnalysisScreen({super.key});

  @override
  ConsumerState<VisionAnalysisScreen> createState() =>
      _VisionAnalysisScreenState();
}

class _VisionAnalysisScreenState extends ConsumerState<VisionAnalysisScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Trigger analysis asynchronously on initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAnalysis();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startAnalysis() async {
    final notifier = ref.read(visionAssessmentNotifierProvider.notifier);
    final result = await notifier.runAnalysis();

    if (mounted && result != null) {
      context.go('/vision-results');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(visionAssessmentNotifierProvider);
    final horizontalPadding = ResponsiveUtils.getHorizontalPadding(context);

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
              // Pulsing Scanning Ring Animation
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
                          blurRadius: 30 * _pulseController.value,
                          spreadRadius: 8 * _pulseController.value,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
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
                  l10n.analyzingTitle,
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
                        state.analysisStage.isNotEmpty
                            ? state.analysisStage
                            : l10n.stageAnalyzingPatterns,
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
