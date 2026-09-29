import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/widgets/fitness_elite_logo.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../models/yoga_session.dart';
import '../../services/yoga_library.dart';

/// Interactive Yoga and Mobility Session Screen rendering poses, setup steps, and breathing cues.
class YogaSessionScreen extends StatefulWidget {
  final YogaSession? session;
  const YogaSessionScreen({super.key, this.session});

  @override
  State<YogaSessionScreen> createState() => _YogaSessionScreenState();
}

class _YogaSessionScreenState extends State<YogaSessionScreen> {
  late final YogaSession _activeSession;
  int _currentPoseIndex = 0;

  @override
  void initState() {
    super.initState();
    _activeSession = widget.session ?? YogaLibrary.generateRecoverySession();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontalPadding = ResponsiveUtils.getHorizontalPadding(context);
    final currentPose = _activeSession.poses[_currentPoseIndex];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const FitnessEliteLogo(iconSize: 26, fontSize: 18),
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
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _activeSession.title,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                              Text(
                                'Pose ${_currentPoseIndex + 1} of ${_activeSession.poses.length}',
                                style: const TextStyle(
                                  color: AppColors.electricBlue,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.electricBlue.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${currentPose.durationSeconds}s Hold',
                              style: const TextStyle(
                                color: AppColors.electricBlue,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Pose Card
                      GlassCard(
                        padding: const EdgeInsets.all(20),
                        enableGlow: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentPose.name,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Category: ${currentPose.category} • ${currentPose.difficulty}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'SETUP',
                              style: TextStyle(
                                color: AppColors.electricBlue,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(currentPose.setup, style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(height: 12),
                            const Text(
                              'BREATHING',
                              style: TextStyle(
                                color: AppColors.electricBlue,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(currentPose.breathing, style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(height: 12),
                            const Text(
                              'BENEFITS',
                              style: TextStyle(
                                color: AppColors.electricBlue,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(currentPose.benefits, style: Theme.of(context).textTheme.bodySmall),
                          ],
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
                    if (_currentPoseIndex > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => _currentPoseIndex--),
                          child: const Text('Previous'),
                        ),
                      ),
                    if (_currentPoseIndex > 0) const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_currentPoseIndex < _activeSession.poses.length - 1) {
                            setState(() => _currentPoseIndex++);
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
                        child: Text(
                          _currentPoseIndex < _activeSession.poses.length - 1
                              ? 'Next Pose'
                              : 'Complete Session',
                        ),
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
