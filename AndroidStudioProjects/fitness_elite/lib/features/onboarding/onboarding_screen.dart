import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/persistence_providers.dart';
import '../../core/utils/responsive_utils.dart';
import '../../shared/animations/glass_entrance_animation.dart';
import '../../shared/widgets/depth_container.dart';
import '../../shared/widgets/fitness_elite_logo.dart';
import '../../shared/widgets/glass_card.dart';

/// 3-Page Premium Onboarding Flow for FitnessElite.ai.
/// Page 1: "Understand your body."
/// Page 2: "Your plan. Powered by AI."
/// Page 3: "Become your stronger self."
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onSkip() {
    ref.read(onboardingStateProvider.notifier).completeOnboarding();
    context.go('/auth');
  }

  void _onNext() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      ref.read(onboardingStateProvider.notifier).completeOnboarding();
      context.go('/auth');
    }
  }

  void _onBack() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      context.go('/language-selection');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontalPadding = ResponsiveUtils.getHorizontalPadding(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _onBack,
          tooltip: 'Back',
        ),
        centerTitle: true,
        title: const FitnessEliteLogo(
          iconSize: 26,
          fontSize: 18,
        ),
        actions: [
          TextButton(
            onPressed: _onSkip,
            child: Text(
              l10n.skip,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  // Page 1
                  _OnboardingPageView(
                    headline: l10n.onboardingHeadline1,
                    subtitle: l10n.onboardingSubtitle1,
                    visualWidget: const _Page1BodyVisualization(),
                    horizontalPadding: horizontalPadding,
                  ),

                  // Page 2
                  _OnboardingPageView(
                    headline: l10n.onboardingHeadline2,
                    subtitle: l10n.onboardingSubtitle2,
                    visualWidget: const _Page2AiPlanVisualization(),
                    horizontalPadding: horizontalPadding,
                  ),

                  // Page 3
                  _OnboardingPageView(
                    headline: l10n.onboardingHeadline3,
                    subtitle: l10n.onboardingSubtitle3,
                    visualWidget: const _Page3ProgressVisualization(),
                    horizontalPadding: horizontalPadding,
                  ),
                ],
              ),
            ),

            // Bottom Navigation Controls (Page Indicator & Next/Get Started)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: AppConstants.defaultPadding,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Page Indicator Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: isActive
                              ? AppColors.electricBlue
                              : (isDark
                                  ? AppColors.darkGlassBorder
                                  : AppColors.lightGlassBorder),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color:
                                        AppColors.electricBlue.withValues(alpha: 0.5),
                                    blurRadius: 8,
                                  ),
                                ]
                              : null,
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 24),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _onNext,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPage == 2
                                ? l10n.getStarted
                                : l10n.next,
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _currentPage == 2
                                ? Icons.rocket_launch_rounded
                                : Icons.arrow_forward_rounded,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageView extends StatelessWidget {
  final String headline;
  final String subtitle;
  final Widget visualWidget;
  final double horizontalPadding;

  const _OnboardingPageView({
    required this.headline,
    required this.subtitle,
    required this.visualWidget,
    required this.horizontalPadding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        children: [
          const SizedBox(height: 8),

          // Visual
          Expanded(
            child: Center(
              child: visualWidget,
            ),
          ),

          const SizedBox(height: 16),

          // Text Content
          GlassEntranceAnimation(
            child: Column(
              children: [
                Text(
                  headline,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Visual 1: Premium abstract human / body simulation
class _Page1BodyVisualization extends StatelessWidget {
  const _Page1BodyVisualization();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DepthContainer(
      depth: 16,
      borderRadius: 24,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320, maxHeight: 260),
        padding: const EdgeInsets.all(16),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.electricBlue.withValues(alpha: 0.4),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.accessibility_new_rounded,
                  color: Colors.black,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Biomechanical Digital Twin',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Neural Body Modeling Enabled',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.electricBlue
                          : AppColors.vividBlue,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Visual 2: AI Plan & Workout/Nutrition Insights
class _Page2AiPlanVisualization extends StatelessWidget {
  const _Page2AiPlanVisualization();

  @override
  Widget build(BuildContext context) {
    return DepthContainer(
      depth: 16,
      borderRadius: 24,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320, maxHeight: 260),
        padding: const EdgeInsets.all(16),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GlassCard(
                borderRadius: 18,
                padding: const EdgeInsets.all(14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.fitness_center_rounded,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Adaptive Workout',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '98.4% Optimal Volume Target',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.electricBlue),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(
                borderRadius: 18,
                padding: const EdgeInsets.all(14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: AppColors.violetCyanGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.restaurant_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Precision Macro Fueling',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'Metabolic Optimization Active',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.electricViolet),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Visual 3: Progress & Transformation Habits
class _Page3ProgressVisualization extends StatelessWidget {
  const _Page3ProgressVisualization();

  @override
  Widget build(BuildContext context) {
    return DepthContainer(
      depth: 16,
      borderRadius: 24,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320, maxHeight: 260),
        padding: const EdgeInsets.all(16),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.electricBlue.withValues(alpha: 0.4),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: Colors.black,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              GlassCard(
                borderRadius: 18,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Column(
                  children: [
                    Text(
                      'Habit Streak: 21 Days',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Consistent Progress Trajectory',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.success,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
