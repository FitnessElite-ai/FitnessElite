import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/persistence_providers.dart';
import '../ai_coach/providers/ai_coach_provider.dart';
import '../auth/presentation/providers/auth_provider.dart';
import '../../shared/animations/fade_in_animation.dart';
import '../../shared/animations/glass_entrance_animation.dart';
import '../../shared/animations/scale_in_animation.dart';
import '../../shared/widgets/fitness_elite_logo.dart';
import '../../shared/widgets/glass_card.dart';

/// Immersive, Calm, and Fast App Launch Experience for FitnessElite.ai.
/// Displays personalized welcoming quotes, brand logo animation, and smooth transition to Home in ~2.0s.
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
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.25, end: 0.85).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Fast, non-blocking splash transition (~2.0 seconds) for returning users
    _navTimer = Timer(const Duration(milliseconds: 2000), () {
      if (mounted) {
        final authState = ref.read(authNotifierProvider);
        final isOnboardingCompleted = ref.read(onboardingStateProvider);

        if (authState.isAuthenticated || isOnboardingCompleted) {
          _navigateToHome();
        }
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
      context.go('/home');
      return;
    }

    final isOnboardingCompleted = ref.read(onboardingStateProvider);
    if (isOnboardingCompleted) {
      context.go('/home');
    } else {
      context.go('/language-selection');
    }
  }

  void _navigateToHome() {
    _navigateToNextScreen();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final authState = ref.watch(authNotifierProvider);
    final aiState = ref.watch(conversationNotifierProvider);
    final isOnboardingCompleted = ref.watch(onboardingStateProvider);

    final isReturningUser = authState.isAuthenticated || isOnboardingCompleted;
    final userName = aiState.completeProfile?.healthProfile.name ?? 'Athlete';
    final firstName = userName.split(' ').first;

    String personalizedSubtitle = 'Your 30-minute session is ready.';
    if (aiState.completeProfile == null) {
      personalizedSubtitle = 'Ready for today\'s session?';
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ambient animated subtle glow background
            AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Positioned(
                  top: size.height * 0.20,
                  child: Container(
                    width: size.width * 0.85,
                    height: size.width * 0.85,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.electricBlue.withValues(alpha: _glowAnimation.value * 0.22),
                          AppColors.deepViolet.withValues(alpha: _glowAnimation.value * 0.12),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Center branding composition
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Signature FitnessElite Logo
                    ScaleInAnimation(
                      duration: const Duration(milliseconds: 600),
                      initialScale: 0.8,
                      child: const FitnessEliteLogo(
                        iconSize: 68.0,
                        fontSize: 34.0,
                        showText: true,
                        showTagline: false,
                      ),
                    ),

                    const SizedBox(height: 36),

                    if (isReturningUser)
                      GlassEntranceAnimation(
                        delay: const Duration(milliseconds: 300),
                        child: GlassCard(
                          borderRadius: 20,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                          enableGlow: true,
                          child: Column(
                            children: [
                              Text(
                                'Welcome back, $firstName',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                personalizedSubtitle,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.electricBlue,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      GlassEntranceAnimation(
                        delay: const Duration(milliseconds: 300),
                        child: GlassCard(
                          borderRadius: 20,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                          enableGlow: true,
                          child: Column(
                            children: [
                              const Text(
                                'Welcome to FitnessElite.ai',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.electricBlue,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Your journey starts here.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

            // Bottom CTA for First-Time Users or Quick Action for Returning Users
            Positioned(
              bottom: 32,
              left: AppConstants.defaultPadding,
              right: AppConstants.defaultPadding,
              child: FadeInAnimation(
                delay: const Duration(milliseconds: 500),
                child: Column(
                  children: [
                    if (!isReturningUser) ...[
                      Text(
                        'Let\'s build something personal.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _navigateToNextScreen,
                          icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                          label: const Text('Get Started'),
                        ),
                      ),
                    ] else ...[
                      TextButton.icon(
                        onPressed: _navigateToHome,
                        icon: const Icon(Icons.arrow_forward_rounded,
                            color: AppColors.electricBlue, size: 18),
                        label: const Text(
                          'Entering Home...',
                          style: TextStyle(
                            color: AppColors.electricBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
