import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/responsive_utils.dart';
import '../../shared/animations/fade_in_animation.dart';
import '../../shared/animations/glass_entrance_animation.dart';
import '../../shared/animations/slide_in_animation.dart';
import '../../shared/widgets/fitness_elite_logo.dart';
import '../../shared/widgets/glass_card.dart';
import '../auth/presentation/providers/auth_provider.dart';

/// Placeholder screen for Health Profile step.
/// Displayed immediately after successful authentication.
class HealthProfilePlaceholderScreen extends ConsumerWidget {
  const HealthProfilePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontalPadding = ResponsiveUtils.getHorizontalPadding(context);
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const FitnessEliteLogo(
          iconSize: 26,
          fontSize: 18,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: l10n.signOut,
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/auth');
              }
            },
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
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // User Avatar Icon
                        SlideInAnimation(
                          direction: SlideDirection.down,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.primaryGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.electricBlue
                                      .withValues(alpha: 0.35),
                                  blurRadius: 24,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              color: Colors.black,
                              size: 44,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Title: "Let's get to know you."
                        SlideInAnimation(
                          direction: SlideDirection.up,
                          child: Text(
                            l10n.healthProfileTitle,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        if (user != null) ...[
                          FadeInAnimation(
                            delay: const Duration(milliseconds: 200),
                            child: Text(
                              user.fullName.isNotEmpty
                                  ? user.fullName
                                  : user.email,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: AppColors.electricBlue,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          FadeInAnimation(
                            delay: const Duration(milliseconds: 300),
                            child: Text(
                              user.email,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 32),

                        // Status Card
                        GlassEntranceAnimation(
                          delay: const Duration(milliseconds: 400),
                          child: GlassCard(
                            enableGlow: true,
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.favorite_rounded,
                                  color: AppColors.electricBlue,
                                  size: 32,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  l10n.healthAssessment,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Personalized biometric profiling, BMI baseline, and activity goal analysis.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.lightTextSecondary,
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
              ),

              // Bottom Actions (Start Health Assessment / Sign Out)
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
                          onPressed: () => context.go('/health-assessment'),
                          icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                          label: Text(l10n.healthAssessment),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await ref.read(authNotifierProvider.notifier).signOut();
                            if (context.mounted) {
                              context.go('/auth');
                            }
                          },
                          icon: const Icon(Icons.logout_rounded, size: 20),
                          label: Text(l10n.signOut),
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
