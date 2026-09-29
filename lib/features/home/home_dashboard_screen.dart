import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/responsive_utils.dart';
import '../../shared/animations/fade_in_animation.dart';
import '../../shared/animations/glass_entrance_animation.dart';
import '../../shared/widgets/fitness_elite_logo.dart';
import '../../shared/widgets/glass_card.dart';
import '../agent/providers/agent_provider.dart';
import '../agent/ui/widgets/agent_decision_card.dart';
import '../ai_coach/presentation/screens/ai_coach_screen.dart';
import '../ai_coach/providers/ai_coach_provider.dart';
import '../fitness_engine/models/workout_day.dart';
import '../fitness_engine/providers/fitness_engine_provider.dart';
import '../nutrition/presentation/screens/nutrition_screen.dart';
import '../profile/presentation/screens/profile_screen.dart';
import '../progress/presentation/screens/progress_screen.dart';
import '../voice/ui/widgets/voice_assistant_bottom_sheet.dart';
import '../workouts/providers/workout_session_provider.dart';
import 'demo_mode_provider.dart';

/// Main FitnessElite Dashboard with Bottom Navigation Tabs (Home, Workout, Nutrition, Progress, AI Coach, Profile).
class HomeDashboardScreen extends ConsumerStatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  ConsumerState<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends ConsumerState<HomeDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final pages = [
      const _HomeDashboardTab(),
      const _WorkoutTab(),
      const NutritionScreen(),
      const ProgressScreen(),
      const AICoachScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => VoiceAssistantBottomSheet.show(context),
        backgroundColor: AppColors.electricBlue,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.mic_rounded, size: 20),
        label: const Text('Ask FitnessElite.ai', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded, color: AppColors.electricBlue),
            label: 'Home',
          ),
          NavigationDestination(
            icon: const Icon(Icons.fitness_center_outlined),
            selectedIcon: const Icon(Icons.fitness_center_rounded, color: AppColors.electricBlue),
            label: l10n.workouts,
          ),
          NavigationDestination(
            icon: const Icon(Icons.restaurant_outlined),
            selectedIcon: const Icon(Icons.restaurant_rounded, color: AppColors.electricBlue),
            label: l10n.nutrition,
          ),
          NavigationDestination(
            icon: const Icon(Icons.insights_outlined),
            selectedIcon: const Icon(Icons.insights_rounded, color: AppColors.electricBlue),
            label: l10n.progress,
          ),
          NavigationDestination(
            icon: const Icon(Icons.auto_awesome_outlined),
            selectedIcon: const Icon(Icons.auto_awesome_rounded, color: AppColors.electricBlue),
            label: l10n.aiCoach,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: const Icon(Icons.person_rounded, color: AppColors.electricBlue),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _HomeDashboardTab extends ConsumerWidget {
  const _HomeDashboardTab();

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontalPadding = ResponsiveUtils.getHorizontalPadding(context);
    final engineState = ref.watch(fitnessEngineNotifierProvider);
    final aiState = ref.watch(conversationNotifierProvider);
    final historyRepo = ref.watch(workoutHistoryRepositoryProvider);
    final agentState = ref.watch(agentNotifierProvider);
    final isDemo = ref.watch(demoModeNotifierProvider);

    final name = aiState.completeProfile?.healthProfile.name ?? 'Athlete';
    final firstName = name.split(' ').first;
    final plan = engineState.currentPlan;
    final streak = historyRepo.getCurrentStreak();

    WorkoutDay? todayWorkout;
    if (plan != null && plan.weeklySchedule.isNotEmpty) {
      final todayIndex = (DateTime.now().weekday - 1) % plan.weeklySchedule.length;
      todayWorkout = plan.weeklySchedule[todayIndex];
    }

    final greeting = _getGreeting();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const FitnessEliteLogo(iconSize: 26, fontSize: 18),
        actions: [
          IconButton(
            icon: Icon(
              isDemo ? Icons.tune_rounded : Icons.tune_outlined,
              color: isDemo ? AppColors.electricBlue : null,
            ),
            tooltip: 'Toggle Demo Competition Mode',
            onPressed: () {
              ref.read(demoModeNotifierProvider.notifier).toggleDemoMode(ref);
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (isDemo) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade900,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'DEMO MODE ACTIVE (Synthetic Competition Profile)',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800),
                              ),
                              GestureDetector(
                                onTap: () => ref
                                    .read(demoModeNotifierProvider.notifier)
                                    .toggleDemoMode(ref),
                                child: const Text('Exit Demo',
                                    style: TextStyle(
                                        color: AppColors.electricBlue,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Greeting & Agent Status
                      FadeInAnimation(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$greeting, $firstName',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w900,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Colors.greenAccent,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Your Fitness Agent • Watching your progress',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppColors.electricBlue,
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.auto_awesome_rounded,
                                  color: AppColors.electricBlue),
                              tooltip: 'Agent Intelligence',
                              onPressed: () => context.push('/agent-intelligence'),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // HERO CARD: YOUR NEXT STEP
                      if (todayWorkout != null) ...[
                        GlassEntranceAnimation(
                          child: GlassCard(
                            padding: const EdgeInsets.all(20),
                            enableGlow: true,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.electricBlue
                                            .withValues(alpha: 0.18),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        "YOUR NEXT STEP",
                                        style: TextStyle(
                                          color: AppColors.electricBlue,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${todayWorkout.durationMinutes} MIN',
                                      style: const TextStyle(
                                        color: AppColors.electricBlue,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  todayWorkout.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(fontWeight: FontWeight.w900),
                                ),
                                Text(
                                  todayWorkout.focus,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.lightTextSecondary,
                                      ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      ref
                                          .read(workoutSessionNotifierProvider
                                              .notifier)
                                          .startWorkout(todayWorkout!);
                                      context.go('/workout-execution');
                                    },
                                    icon: const Icon(Icons.play_arrow_rounded,
                                        size: 22),
                                    label: const Text('Start Workout'),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Center(
                                  child: Text(
                                    'AI selected for you based on recovery & schedule',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          fontSize: 11,
                                          color: AppColors.electricBlue,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // AI INSIGHT CARD
                      GlassEntranceAnimation(
                        delay: const Duration(milliseconds: 100),
                        child: GlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: AppColors.primaryGradient,
                                ),
                                child: const Icon(Icons.auto_awesome_rounded,
                                    color: Colors.black, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'AI INSIGHT',
                                      style: TextStyle(
                                        color: AppColors.electricBlue,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'You\'re building consistency. $streak day training streak active.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () => context.push('/agent-intelligence'),
                                child: const Text('View Why',
                                    style: TextStyle(
                                        color: AppColors.electricBlue,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800)),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // AI DECISION CARD IF ACTIVE
                      if (agentState.lastDecision != null) ...[
                        GlassEntranceAnimation(
                          delay: const Duration(milliseconds: 150),
                          child: AgentDecisionCard(
                            decision: agentState.lastDecision!,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // TODAY: WORKOUT, NUTRITION, RECOVERY (3 COMPACT CARDS)
                      const Text(
                        'TODAY',
                        style: TextStyle(
                          color: AppColors.electricBlue,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Expanded(
                            child: GlassCard(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.fitness_center_rounded,
                                      size: 18, color: AppColors.electricBlue),
                                  const SizedBox(height: 6),
                                  const Text('Workout',
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.electricBlue)),
                                  Text(
                                    todayWorkout != null
                                        ? '${todayWorkout.durationMinutes}m'
                                        : 'Rest Day',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                            fontWeight: FontWeight.w800),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GlassCard(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.restaurant_rounded,
                                      size: 18, color: AppColors.electricBlue),
                                  const SizedBox(height: 6),
                                  const Text('Nutrition',
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.electricBlue)),
                                  Text(
                                    plan != null
                                        ? '${plan.nutritionPlan.proteinGrams}g Protein'
                                        : 'Target Set',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                            fontWeight: FontWeight.w800),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GlassCard(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.favorite_rounded,
                                      size: 18, color: AppColors.electricBlue),
                                  const SizedBox(height: 6),
                                  const Text('Recovery',
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.electricBlue)),
                                  Text(
                                    '84% Good',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                            fontWeight: FontWeight.w800),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // AI COACH PROMPT CARD
                      GlassEntranceAnimation(
                        delay: const Duration(milliseconds: 200),
                        child: GlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.electricBlue
                                      .withValues(alpha: 0.15),
                                ),
                                child: const Icon(Icons.chat_bubble_outline_rounded,
                                    color: AppColors.electricBlue, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Need to adjust today\'s plan?',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                              fontWeight: FontWeight.w800),
                                    ),
                                    Text(
                                      'Tell FitnessElite.ai if you\'re short on time or fatigued.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.arrow_forward_rounded,
                                    color: AppColors.electricBlue),
                                onPressed: () => context.go('/ai-coach'),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Quick Links Bar
                      GlassCard(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton.icon(
                              onPressed: () => context.push('/agent-activity'),
                              icon: const Icon(Icons.timeline_rounded,
                                  size: 16, color: AppColors.electricBlue),
                              label: const Text('AI Activity',
                                  style: TextStyle(fontSize: 11)),
                            ),
                            const Text('•',
                                style:
                                    TextStyle(color: AppColors.electricBlue)),
                            TextButton.icon(
                              onPressed: () => context.push('/agent-memory'),
                              icon: const Icon(Icons.psychology_rounded,
                                  size: 16, color: AppColors.electricBlue),
                              label: const Text('Your AI Knows',
                                  style: TextStyle(fontSize: 11)),
                            ),
                            const Text('•',
                                style:
                                    TextStyle(color: AppColors.electricBlue)),
                            TextButton.icon(
                              onPressed: () =>
                                  context.push('/agent-intelligence'),
                              icon: const Icon(Icons.auto_awesome_rounded,
                                  size: 16, color: AppColors.electricBlue),
                              label: const Text('Agent',
                                  style: TextStyle(fontSize: 11)),
                            ),
                          ],
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

class _WorkoutTab extends ConsumerWidget {
  const _WorkoutTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engineState = ref.watch(fitnessEngineNotifierProvider);
    final plan = engineState.currentPlan?.workoutPlan;

    if (plan == null) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const FitnessEliteLogo(iconSize: 26, fontSize: 18),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No workout plan active yet.'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context.go('/plan-generation'),
                child: const Text('Generate Plan'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const FitnessEliteLogo(iconSize: 26, fontSize: 18),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                plan.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 12),
              ...plan.days.map((day) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${day.day} • ${day.title}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                Text(
                                  day.focus,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          if (day.isWorkout)
                            ElevatedButton(
                              onPressed: () {
                                ref
                                    .read(workoutSessionNotifierProvider.notifier)
                                    .startWorkout(day);
                                context.go('/workout-execution');
                              },
                              child: const Text('Start'),
                            ),
                        ],
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
