import 'package:go_router/go_router.dart';
import '../../features/ai_coach/presentation/screens/ai_coach_screen.dart';
import '../../features/ai_coach/presentation/screens/plan_preview_screen.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/health_assessment/health_profile_placeholder_screen.dart';
import '../../features/health_assessment/presentation/health_assessment_screen.dart';
import '../../features/home/home_placeholder_screen.dart';
import '../../features/language_selection/language_selection_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/splash/splash_screen.dart';

/// Central GoRouter configuration for FitnessElite.ai.
/// Routes: `/` (Splash), `/language-selection`, `/onboarding`, `/auth`, `/health-profile`, `/health-assessment`, `/ai-coach`, `/plan-preview`, `/home`.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/language-selection',
      name: 'language-selection',
      builder: (context, state) => const LanguageSelectionScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/auth',
      name: 'auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/health-profile',
      name: 'health-profile',
      builder: (context, state) => const HealthProfilePlaceholderScreen(),
    ),
    GoRoute(
      path: '/health-assessment',
      name: 'health-assessment',
      builder: (context, state) => const HealthAssessmentScreen(),
    ),
    GoRoute(
      path: '/ai-coach',
      name: 'ai-coach',
      builder: (context, state) => const AICoachScreen(),
    ),
    GoRoute(
      path: '/plan-preview',
      name: 'plan-preview',
      builder: (context, state) => const PlanPreviewScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomePlaceholderScreen(),
    ),
  ],
);
