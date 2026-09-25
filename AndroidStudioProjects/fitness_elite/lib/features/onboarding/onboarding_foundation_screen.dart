import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/theme_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/ai_service.dart';
import '../../core/utils/responsive_utils.dart';
import '../../shared/animations/fade_in_animation.dart';
import '../../shared/animations/glass_entrance_animation.dart';
import '../../shared/animations/slide_in_animation.dart';
import '../../shared/widgets/depth_container.dart';
import '../../shared/widgets/fitness_elite_logo.dart';
import '../../shared/widgets/glass_card.dart';

/// Foundation screen for Onboarding flow.
/// Demonstrates responsive layout, glassmorphic UI, 3D depth, entrance animations,
/// ThemeMode switching via Riverpod, and lazy asynchronous AI initialization.
class OnboardingFoundationScreen extends ConsumerWidget {
  const OnboardingFoundationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final aiState = ref.watch(aiServiceProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontalPadding = ResponsiveUtils.getHorizontalPadding(context);

    return Scaffold(
      appBar: AppBar(
        title: const FitnessEliteLogo(
          iconSize: 28,
          fontSize: 20,
        ),
        actions: [
          // Theme Switcher Menu
          PopupMenuButton<ThemeMode>(
            icon: Icon(
              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: isDark ? AppColors.electricBlue : AppColors.vividBlue,
            ),
            tooltip: l10n.switchTheme,
            initialValue: themeMode,
            onSelected: (mode) {
              ref.read(themeModeProvider.notifier).setThemeMode(mode);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: ThemeMode.system,
                child: Row(
                  children: [
                    const Icon(Icons.brightness_auto_rounded, size: 20),
                    const SizedBox(width: 12),
                    Text(l10n.systemTheme),
                  ],
                ),
              ),
              PopupMenuItem(
                value: ThemeMode.light,
                child: Row(
                  children: [
                    const Icon(Icons.light_mode_rounded, size: 20),
                    const SizedBox(width: 12),
                    Text(l10n.lightTheme),
                  ],
                ),
              ),
              PopupMenuItem(
                value: ThemeMode.dark,
                child: Row(
                  children: [
                    const Icon(Icons.dark_mode_rounded, size: 20),
                    const SizedBox(width: 12),
                    Text(l10n.darkTheme),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),

                      // Title Header
                      SlideInAnimation(
                        direction: SlideDirection.up,
                        child: Text(
                          l10n.onboardingTitle,
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                      ),

                      const SizedBox(height: 8),

                      FadeInAnimation(
                        delay: const Duration(milliseconds: 200),
                        child: Text(
                          l10n.onboardingSubtitle,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Glassmorphic Card Showcase (Lazy AI Engine Card)
                      GlassEntranceAnimation(
                        delay: const Duration(milliseconds: 300),
                        child: GlassCard(
                          enableGlow: true,
                          onTap: () {
                            ref
                                .read(aiServiceProvider.notifier)
                                .initializeLazily();
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppColors.electricBlue.withValues(alpha: 0.15)
                                          : AppColors.vividBlue.withValues(alpha: 0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.auto_awesome_rounded,
                                      color: isDark
                                          ? AppColors.electricBlue
                                          : AppColors.vividBlue,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.aiCoach,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge,
                                        ),
                                        Text(
                                          'Adaptive Neural Fitness Engine',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.welcomeSubtitle,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 12),

                              // Asynchronous Lazy AI Status Indicator
                              if (aiState.status == AiServiceStatus.initializing)
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Connecting AI Engine in background...',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: AppColors.electricBlue),
                                    ),
                                  ],
                                )
                              else if (aiState.status == AiServiceStatus.ready)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: AppColors.success,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'AI Engine Active',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: AppColors.success),
                                    ),
                                  ],
                                )
                              else if (aiState.status == AiServiceStatus.error)
                                InkWell(
                                  onTap: () {
                                    ref
                                        .read(aiServiceProvider.notifier)
                                        .retryInitialization();
                                  },
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.warning_amber_rounded,
                                        color: AppColors.warning,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          aiState.errorMessage ?? 'Tap to retry AI connection',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(color: AppColors.warning),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Text(
                                  'Tap card to connect AI engine asynchronously',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: isDark
                                            ? AppColors.darkTextMuted
                                            : AppColors.lightTextMuted,
                                      ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 3D Depth Card Showcase
                      GlassEntranceAnimation(
                        delay: const Duration(milliseconds: 500),
                        child: DepthContainer(
                          depth: 16,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: AppColors.violetCyanGradient,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.fit_screen_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.visionAssessment,
                                      style:
                                          Theme.of(context).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Subtle 3D Depth Foundation',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Bottom Action Button
              Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
                child: GlassEntranceAnimation(
                  delay: const Duration(milliseconds: 700),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => context.go('/auth'),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(l10n.continueButton),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
                    ),
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
