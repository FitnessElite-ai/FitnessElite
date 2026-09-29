import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/persistence_providers.dart';
import '../../core/utils/responsive_utils.dart';
import '../../shared/animations/fade_in_animation.dart';
import '../../shared/animations/glass_entrance_animation.dart';
import '../../shared/animations/slide_in_animation.dart';
import '../../shared/widgets/fitness_elite_logo.dart';
import '../../shared/widgets/glass_card.dart';

/// Foundation screen for Auth flow.
/// Prepares routing & UI container for future authentication implementation.
class AuthFoundationScreen extends ConsumerWidget {
  const AuthFoundationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontalPadding = ResponsiveUtils.getHorizontalPadding(context);

    void navigateToLanguageSelection() {
      ref.read(onboardingStateProvider.notifier).resetOnboarding();
      context.go('/language-selection');
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: navigateToLanguageSelection,
          tooltip: l10n.revisitOnboarding,
        ),
        title: const FitnessEliteLogo(
          iconSize: 28,
          fontSize: 20,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language_rounded),
            onPressed: navigateToLanguageSelection,
            tooltip: l10n.changeLanguage,
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
                      const SizedBox(height: 20),

                      // Header
                      SlideInAnimation(
                        direction: SlideDirection.up,
                        child: Text(
                          l10n.authTitle,
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                      ),

                      const SizedBox(height: 8),

                      FadeInAnimation(
                        delay: const Duration(milliseconds: 200),
                        child: Text(
                          l10n.authSubtitle,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Auth Glass Container Placeholder
                      GlassEntranceAnimation(
                        delay: const Duration(milliseconds: 300),
                        child: GlassCard(
                          enableGlow: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: AppColors.primaryGradient,
                                    ),
                                    child: const Icon(
                                      Icons.lock_outline_rounded,
                                      color: Colors.black,
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
                                          'Biometric Authentication Hub',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge,
                                        ),
                                        Text(
                                          'Ready for Auth Provider Integration',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Authentication foundation is initialized. Full login, social auth, and biometric flow will be integrated here.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Actions to Revisit Language Selection & Onboarding
              Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
                child: GlassEntranceAnimation(
                  delay: const Duration(milliseconds: 500),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: navigateToLanguageSelection,
                          icon: const Icon(Icons.language_rounded, size: 20),
                          label: Text(l10n.revisitOnboarding),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ref
                                .read(onboardingStateProvider.notifier)
                                .resetOnboarding();
                            context.go('/');
                          },
                          icon: const Icon(Icons.refresh_rounded, size: 20),
                          label: Text(l10n.getStarted),
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
