import 'package:go_router/go_router.dart';
import '../../features/agent/ui/screens/agent_activity_screen.dart';
import '../../features/agent/ui/screens/agent_intelligence_screen.dart';
import '../../features/agent/ui/screens/agent_memory_screen.dart';
import '../../features/ai_coach/presentation/screens/ai_coach_screen.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/fitness_engine/presentation/screens/personalized_plan_screen.dart';
import '../../features/fitness_engine/presentation/screens/plan_generation_screen.dart';
import '../../features/health_assessment/health_profile_placeholder_screen.dart';
import '../../features/health_assessment/presentation/health_assessment_screen.dart';
import '../../features/home/home_dashboard_screen.dart';
import '../../features/language_selection/language_selection_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/subscription/presentation/screens/paywall_screen.dart';
import '../../features/vision_assessment/presentation/screens/vision_analysis_screen.dart';
import '../../features/vision_assessment/presentation/screens/vision_capture_screen.dart';
import '../../features/vision_assessment/presentation/screens/vision_intro_screen.dart';
import '../../features/vision_assessment/presentation/screens/vision_results_screen.dart';
import '../../features/workouts/presentation/screens/workout_complete_screen.dart';
import '../../features/workouts/presentation/screens/workout_execution_screen.dart';

/// Central GoRouter configuration for FitnessElite.ai.
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
      path: '/vision-assessment',
      name: 'vision-assessment',
      builder: (context, state) => const VisionIntroScreen(),
    ),
    GoRoute(
      path: '/vision-intro',
      name: 'vision-intro',
      builder: (context, state) => const VisionIntroScreen(),
    ),
    GoRoute(
      path: '/vision-capture',
      name: 'vision-capture',
      builder: (context, state) => const VisionCaptureScreen(),
    ),
    GoRoute(
      path: '/vision-analysis',
      name: 'vision-analysis',
      builder: (context, state) => const VisionAnalysisScreen(),
    ),
    GoRoute(
      path: '/vision-results',
      name: 'vision-results',
      builder: (context, state) => const VisionResultsScreen(),
    ),
    GoRoute(
      path: '/plan-generation',
      name: 'plan-generation',
      builder: (context, state) => const PlanGenerationScreen(),
    ),
    GoRoute(
      path: '/plan-preview',
      name: 'plan-preview',
      builder: (context, state) => const PlanGenerationScreen(),
    ),
    GoRoute(
      path: '/personalized-plan',
      name: 'personalized-plan',
      builder: (context, state) => const PersonalizedPlanScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeDashboardScreen(),
    ),
    GoRoute(
      path: '/workout-execution',
      name: 'workout-execution',
      builder: (context, state) => const WorkoutExecutionScreen(),
    ),
    GoRoute(
      path: '/workout-complete',
      name: 'workout-complete',
      builder: (context, state) => const WorkoutCompleteScreen(),
    ),
    GoRoute(
      path: '/paywall',
      name: 'paywall',
      builder: (context, state) => const PaywallScreen(),
    ),
    GoRoute(
      path: '/agent-intelligence',
      name: 'agent-intelligence',
      builder: (context, state) => const AgentIntelligenceScreen(),
    ),
    GoRoute(
      path: '/agent-memory',
      name: 'agent-memory',
      builder: (context, state) => const AgentMemoryScreen(),
    ),
    GoRoute(
      path: '/agent-activity',
      name: 'agent-activity',
      builder: (context, state) => const AgentActivityScreen(),
    ),
  ],
);
