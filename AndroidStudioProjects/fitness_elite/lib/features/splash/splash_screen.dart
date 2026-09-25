import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/persistence_providers.dart';
import '../auth/presentation/providers/auth_provider.dart';
import '../../shared/animations/fade_in_animation.dart';
import '../../shared/animations/glass_entrance_animation.dart';
import '../../shared/animations/scale_in_animation.dart';
import '../../shared/widgets/fitness_elite_logo.dart';
import '../../shared/widgets/glass_card.dart';

/// Fast, non-blocking FitnessElite.ai Launch Screen.
/// Displays branding and auto-navigates based on onboarding completion status in ~1.2s.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.85).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Fast, non-blocking splash transition (~1.2 seconds)
    _navTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) {
        _navigateToNextScreen();
      }
    });
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _glowController.dispose();
    super.dispose();
  }

  void _navigateToNextScreen() {
    final authState = ref.read(authNotifierProvider);
    if (authState.isAuthenticated) {
      context.go('/health-profile');
      return;
    }

    final isOnboardingCompleted = ref.read(onboardingStateProvider);
    if (isOnboardingCompleted) {
      context.go('/auth');
    } else {
      context.go('/language-selection');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ambient animated gradient glow background
            AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Positioned(
                  top: size.height * 0.22,
                  child: Container(
                    width: size.width * 0.8,
                    height: size.width * 0.8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.electricBlue.withValues(alpha: _glowAnimation.value * 0.25),
                          AppColors.deepViolet.withValues(alpha: _glowAnimation.value * 0.15),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Center branding & logo composition
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Signature FitnessElite Logo + Tagline
                    ScaleInAnimation(
                      duration: const Duration(milliseconds: 700),
                      initialScale: 0.75,
                      child: FitnessEliteLogo(
                        iconSize: 68.0,
                        fontSize: 36.0,
                        showText: true,
                        showTagline: true,
                        taglineText: l10n.taglineCaps,
                        primaryTextColor: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Fast Status Card ("Your journey starts here.")
                    GlassEntranceAnimation(
                      delay: const Duration(milliseconds: 400),
                      child: GlassCard(
                        borderRadius: 20,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        enableGlow: true,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.auto_awesome_rounded,
                              color: AppColors.electricBlue,
                              size: 20,
                            ),
                            const SizedBox(width: 14),
                            Text(
                              l10n.journeyStartsHere,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: AppColors.darkTextPrimary,
                                    fontWeight: FontWeight.w600,
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

            // Bottom Continue Action
            Positioned(
              bottom: 32,
              left: AppConstants.defaultPadding,
              right: AppConstants.defaultPadding,
              child: FadeInAnimation(
                delay: const Duration(milliseconds: 600),
                child: Center(
                  child: TextButton.icon(
                    onPressed: _navigateToNextScreen,
                    icon: const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.electricBlue,
                      size: 20,
                    ),
                    label: Text(
                      l10n.getStarted,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.electricBlue,
                          ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
