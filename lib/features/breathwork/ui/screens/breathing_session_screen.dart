import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/widgets/fitness_elite_logo.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../models/breathing_exercise.dart';
import '../../policies/breath_safety_policy.dart';
import '../../services/breathing_library.dart';
import '../../services/breathing_session_engine.dart';

/// Immersive, Calm Breathing Player Screen with animated breathing circle & voice/haptic toggles.
class BreathingSessionScreen extends StatefulWidget {
  final BreathingExercise? exercise;
  const BreathingSessionScreen({super.key, this.exercise});

  @override
  State<BreathingSessionScreen> createState() => _BreathingSessionScreenState();
}

class _BreathingSessionScreenState extends State<BreathingSessionScreen>
    with SingleTickerProviderStateMixin {
  late final BreathingExercise _activeExercise;
  late final BreathingSessionEngine _engine;
  late BreathingSessionState _state;
  late AnimationController _circleAnimationController;
  late Animation<double> _scaleAnimation;

  bool _isVoiceGuidanceOn = true;
  bool _isHapticsOn = true;

  @override
  void initState() {
    super.initState();
    _activeExercise = widget.exercise ?? BreathingLibrary.getDefaultSession();

    _circleAnimationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _activeExercise.inhaleSeconds),
    );

    _scaleAnimation = Tween<double>(begin: 0.65, end: 1.15).animate(
      CurvedAnimation(parent: _circleAnimationController, curve: Curves.easeInOut),
    );

    _engine = BreathingSessionEngine(
      exercise: _activeExercise,
      onTick: (state) {
        if (!mounted) return;
        setState(() {
          _state = state;
        });

        // Trigger animation based on breathing phase
        if (state.phase == BreathPhase.inhaling) {
          _circleAnimationController.duration = Duration(seconds: _activeExercise.inhaleSeconds);
          _circleAnimationController.forward(from: 0.0);
        } else if (state.phase == BreathPhase.exhaling) {
          _circleAnimationController.duration = Duration(seconds: _activeExercise.exhaleSeconds);
          _circleAnimationController.reverse(from: 1.0);
        }
      },
    );

    _state = BreathingSessionState(
      totalCycles: _activeExercise.cycles,
      totalSecondsRemaining: _activeExercise.durationSeconds,
    );

    _engine.start();

    // Show initial concise safety note
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showSafetyDialogIfNeeded();
    });
  }

  void _showSafetyDialogIfNeeded() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Breathwork Safety Note', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text(BreathSafetyPolicy.initialSafetyNote),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _engine.dispose();
    _circleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontalPadding = ResponsiveUtils.getHorizontalPadding(context);
    final mediaQuery = MediaQuery.of(context);
    final disableAnimations = mediaQuery.accessibleNavigation;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 22),
          onPressed: () {
            if (GoRouter.maybeOf(context) != null && context.canPop()) {
              context.pop();
            } else if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/home');
            }
          },
          tooltip: 'Back',
        ),
        title: Text(
          'Breathwork',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        actions: [
          const FitnessEliteLogo(iconSize: 22, fontSize: 16),
          const SizedBox(width: 12),
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
                      // Header Card
                      GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _activeExercise.name,
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w900,
                                      ),
                                ),
                                Text(
                                  'Cycle ${_state.currentCycle} of ${_state.totalCycles}',
                                  style: const TextStyle(
                                    color: AppColors.electricBlue,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    _isVoiceGuidanceOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                                    color: AppColors.electricBlue,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(() => _isVoiceGuidanceOn = !_isVoiceGuidanceOn),
                                  tooltip: 'Voice Guidance Toggle',
                                ),
                                IconButton(
                                  icon: Icon(
                                    _isHapticsOn ? Icons.vibration_rounded : Icons.mobile_off_rounded,
                                    color: AppColors.electricBlue,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(() => _isHapticsOn = !_isHapticsOn),
                                  tooltip: 'Haptics Toggle',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // CENTRAL ANIMATED BREATHING CIRCLE
                      Center(
                        child: AnimatedBuilder(
                          animation: _scaleAnimation,
                          builder: (context, child) {
                            final scale = disableAnimations ? 1.0 : _scaleAnimation.value;
                            return Transform.scale(
                              scale: scale,
                              child: Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: AppColors.primaryGradient,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.electricBlue.withValues(alpha: 0.35),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _state.phaseLabel,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${_state.phaseSecondsRemaining}s',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 28,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Instructions Note
                      GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          _activeExercise.instructions,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Controls
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _engine.stop();
                          Navigator.of(context).pop();
                        },
                        child: const Text('Stop'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_state.phase == BreathPhase.paused) {
                            _engine.resume();
                          } else {
                            _engine.pause();
                          }
                        },
                        child: Text(_state.phase == BreathPhase.paused ? 'Resume' : 'Pause'),
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
