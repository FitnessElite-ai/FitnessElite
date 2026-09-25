import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/services/persistence_providers.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../shared/animations/fade_in_animation.dart';
import '../../../shared/animations/glass_entrance_animation.dart';
import '../../../shared/animations/slide_in_animation.dart';
import '../../../shared/widgets/fitness_elite_logo.dart';
import '../../../shared/widgets/glass_card.dart';
import '../domain/fitness_profile.dart';
import 'providers/health_assessment_provider.dart';

/// Multi-step Health Assessment & BMI Screening Screen for FitnessElite.ai.
class HealthAssessmentScreen extends ConsumerStatefulWidget {
  const HealthAssessmentScreen({super.key});

  @override
  ConsumerState<HealthAssessmentScreen> createState() =>
      _HealthAssessmentScreenState();
}

class _HealthAssessmentScreenState
    extends ConsumerState<HealthAssessmentScreen> {
  final _step1FormKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _heightCmController;
  late TextEditingController _weightKgController;
  late TextEditingController _heightFtController;
  late TextEditingController _heightInController;
  late TextEditingController _weightLbsController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(healthAssessmentNotifierProvider);

    _nameController = TextEditingController(text: state.name);
    _ageController = TextEditingController(text: state.age.toString());
    _heightCmController =
        TextEditingController(text: state.heightCm.toString());
    _weightKgController =
        TextEditingController(text: state.weightKg.toString());
    _heightFtController =
        TextEditingController(text: state.heightFt.toString());
    _heightInController =
        TextEditingController(text: state.heightIn.toString());
    _weightLbsController =
        TextEditingController(text: state.weightLbs.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightCmController.dispose();
    _weightKgController.dispose();
    _heightFtController.dispose();
    _heightInController.dispose();
    _weightLbsController.dispose();
    super.dispose();
  }

  void _onNext() {
    final state = ref.read(healthAssessmentNotifierProvider);
    final notifier = ref.read(healthAssessmentNotifierProvider.notifier);

    if (state.currentStep == 0) {
      if (!(_step1FormKey.currentState?.validate() ?? false)) return;

      final age = int.tryParse(_ageController.text) ?? 25;
      final heightCm = double.tryParse(_heightCmController.text) ?? 175.0;
      final weightKg = double.tryParse(_weightKgController.text) ?? 70.0;
      final heightFt = int.tryParse(_heightFtController.text) ?? 5;
      final heightIn = double.tryParse(_heightInController.text) ?? 9.0;
      final weightLbs = double.tryParse(_weightLbsController.text) ?? 154.0;

      notifier.updateBasicInfo(
        name: _nameController.text.trim(),
        age: age,
        heightCm: heightCm,
        weightKg: weightKg,
        heightFt: heightFt,
        heightIn: heightIn,
        weightLbs: weightLbs,
      );
    }

    if (state.currentStep < 4) {
      notifier.nextStep();
    } else {
      _finishAssessment();
    }
  }

  void _onBack() {
    final state = ref.read(healthAssessmentNotifierProvider);
    final notifier = ref.read(healthAssessmentNotifierProvider.notifier);

    if (state.currentStep > 0) {
      notifier.previousStep();
    } else {
      context.go('/health-profile');
    }
  }

  Future<void> _finishAssessment() async {
    final locale = ref.read(localeProvider);
    final notifier = ref.read(healthAssessmentNotifierProvider.notifier);

    await notifier.completeAndSaveProfile(locale.languageCode);

    if (mounted) {
      context.go('/ai-coach');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontalPadding = ResponsiveUtils.getHorizontalPadding(context);
    final assessmentState = ref.watch(healthAssessmentNotifierProvider);
    final currentStep = assessmentState.currentStep;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _onBack,
          tooltip: 'Back',
        ),
        centerTitle: true,
        title: const FitnessEliteLogo(
          iconSize: 26,
          fontSize: 18,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar (Step X / 5)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Step ${currentStep + 1} of 5',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppColors.electricBlue,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      Text(
                        '${((currentStep + 1) * 20)}%',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (currentStep + 1) / 5.0,
                      minHeight: 6,
                      backgroundColor: isDark
                          ? AppColors.darkGlassBorder
                          : AppColors.lightGlassBorder,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.electricBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Step Content Body
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 16,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: KeyedSubtree(
                    key: ValueKey<int>(currentStep),
                    child: _buildStepView(
                      context,
                      l10n,
                      isDark,
                      assessmentState,
                    ),
                  ),
                ),
              ),
            ),

            // Navigation Actions (Back / Next / Finish)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: AppConstants.defaultPadding,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: assessmentState.isSaving ? null : _onNext,
                  child: assessmentState.isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.black,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              currentStep == 4
                                  ? l10n.finishAssessment
                                  : l10n.next,
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              currentStep == 4
                                  ? Icons.check_circle_rounded
                                  : Icons.arrow_forward_rounded,
                              size: 20,
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepView(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
    HealthAssessmentState state,
  ) {
    switch (state.currentStep) {
      case 0:
        return _buildStep1BasicInfo(context, l10n, isDark, state);
      case 1:
        return _buildStep2ActivityLevel(context, l10n, isDark, state);
      case 2:
        return _buildStep3FitnessGoal(context, l10n, isDark, state);
      case 3:
        return _buildStep4Lifestyle(context, l10n, isDark, state);
      case 4:
        return _buildStep5BmiSummary(context, l10n, isDark, state);
      default:
        return const SizedBox.shrink();
    }
  }

  // STEP 1 — Basic Information Form
  Widget _buildStep1BasicInfo(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
    HealthAssessmentState state,
  ) {
    final notifier = ref.read(healthAssessmentNotifierProvider.notifier);

    return Form(
      key: _step1FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SlideInAnimation(
            direction: SlideDirection.up,
            child: Text(
              l10n.step1Title,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          const SizedBox(height: 6),
          FadeInAnimation(
            delay: const Duration(milliseconds: 150),
            child: Text(
              l10n.step1Subtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
            ),
          ),
          const SizedBox(height: 24),

          // Unit Selector Segmented Button
          GlassCard(
            padding: const EdgeInsets.all(6),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      notifier.setUnitSystem(UnitSystem.metric);
                      setState(() {
                        _heightCmController.text = state.heightCm.toString();
                        _weightKgController.text = state.weightKg.toString();
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: state.unitSystem == UnitSystem.metric
                            ? AppColors.electricBlue
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          l10n.metricUnits,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: state.unitSystem == UnitSystem.metric
                                    ? Colors.black
                                    : null,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      notifier.setUnitSystem(UnitSystem.imperial);
                      setState(() {
                        _heightFtController.text = state.heightFt.toString();
                        _heightInController.text = state.heightIn.toString();
                        _weightLbsController.text = state.weightLbs.toString();
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: state.unitSystem == UnitSystem.imperial
                            ? AppColors.electricBlue
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          l10n.imperialUnits,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: state.unitSystem == UnitSystem.imperial
                                    ? Colors.black
                                    : null,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Full Name
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: _buildInputDecoration(
              context,
              label: l10n.fullName,
              hint: l10n.fullNameHint,
              icon: Icons.person_outline_rounded,
              isDark: isDark,
            ),
          ),

          const SizedBox(height: 16),

          // Age & Sex Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  style: Theme.of(context).textTheme.bodyMedium,
                  validator: (value) {
                    final age = int.tryParse(value ?? '');
                    if (age == null || age < 10 || age > 120) {
                      return '10-120';
                    }
                    return null;
                  },
                  decoration: _buildInputDecoration(
                    context,
                    label: l10n.age,
                    hint: '25',
                    icon: Icons.cake_outlined,
                    isDark: isDark,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String>(
                  initialValue: state.sex,
                  style: Theme.of(context).textTheme.bodyMedium,
                  items: [
                    DropdownMenuItem(value: 'Male', child: Text(l10n.male)),
                    DropdownMenuItem(value: 'Female', child: Text(l10n.female)),
                    DropdownMenuItem(
                        value: 'Other', child: Text(l10n.otherSex)),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      notifier.updateBasicInfo(sex: val);
                    }
                  },
                  decoration: _buildInputDecoration(
                    context,
                    label: l10n.sex,
                    hint: '',
                    icon: Icons.wc_rounded,
                    isDark: isDark,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Height & Weight Fields
          if (state.unitSystem == UnitSystem.metric) ...[
            TextFormField(
              controller: _heightCmController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: Theme.of(context).textTheme.bodyMedium,
              validator: (value) {
                final val = double.tryParse(value ?? '');
                if (val == null || val < 50 || val > 250) {
                  return 'Enter valid height (50-250 cm)';
                }
                return null;
              },
              decoration: _buildInputDecoration(
                context,
                label: l10n.heightCm,
                hint: '175',
                icon: Icons.height_rounded,
                isDark: isDark,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _weightKgController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: Theme.of(context).textTheme.bodyMedium,
              validator: (value) {
                final val = double.tryParse(value ?? '');
                if (val == null || val < 20 || val > 300) {
                  return 'Enter valid weight (20-300 kg)';
                }
                return null;
              },
              decoration: _buildInputDecoration(
                context,
                label: l10n.weightKg,
                hint: '70',
                icon: Icons.monitor_weight_outlined,
                isDark: isDark,
              ),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _heightFtController,
                    keyboardType: TextInputType.number,
                    style: Theme.of(context).textTheme.bodyMedium,
                    validator: (value) {
                      final val = int.tryParse(value ?? '');
                      if (val == null || val < 2 || val > 8) {
                        return '2-8 ft';
                      }
                      return null;
                    },
                    decoration: _buildInputDecoration(
                      context,
                      label: l10n.heightFt,
                      hint: '5',
                      icon: Icons.height_rounded,
                      isDark: isDark,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _heightInController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: Theme.of(context).textTheme.bodyMedium,
                    validator: (value) {
                      final val = double.tryParse(value ?? '');
                      if (val == null || val < 0 || val >= 12) {
                        return '0-11 in';
                      }
                      return null;
                    },
                    decoration: _buildInputDecoration(
                      context,
                      label: l10n.heightIn,
                      hint: '9',
                      icon: Icons.height_rounded,
                      isDark: isDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _weightLbsController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: Theme.of(context).textTheme.bodyMedium,
              validator: (value) {
                final val = double.tryParse(value ?? '');
                if (val == null || val < 40 || val > 660) {
                  return 'Enter valid weight (40-660 lbs)';
                }
                return null;
              },
              decoration: _buildInputDecoration(
                context,
                label: l10n.weightLbs,
                hint: '154',
                icon: Icons.monitor_weight_outlined,
                isDark: isDark,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // STEP 2 — Activity Level
  Widget _buildStep2ActivityLevel(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
    HealthAssessmentState state,
  ) {
    final notifier = ref.read(healthAssessmentNotifierProvider.notifier);

    final options = [
      (title: l10n.sedentary, desc: l10n.sedentaryDesc, icon: Icons.airline_seat_recline_normal_rounded),
      (title: l10n.lightlyActive, desc: l10n.lightlyActiveDesc, icon: Icons.directions_walk_rounded),
      (title: l10n.moderatelyActive, desc: l10n.moderatelyActiveDesc, icon: Icons.directions_run_rounded),
      (title: l10n.veryActive, desc: l10n.veryActiveDesc, icon: Icons.fitness_center_rounded),
      (title: l10n.extremelyActive, desc: l10n.extremelyActiveDesc, icon: Icons.sports_gymnastics_rounded),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SlideInAnimation(
          direction: SlideDirection.up,
          child: Text(
            l10n.step2Title,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        const SizedBox(height: 6),
        FadeInAnimation(
          delay: const Duration(milliseconds: 150),
          child: Text(
            l10n.step2Subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
          ),
        ),
        const SizedBox(height: 24),

        ...options.map((opt) {
          final isSelected = state.activityLevel == opt.title;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GlassCard(
              onTap: () => notifier.setActivityLevel(opt.title),
              backgroundColor: isSelected
                  ? AppColors.electricBlue.withValues(alpha: 0.18)
                  : null,
              borderColor: isSelected ? AppColors.electricBlue : null,
              enableGlow: isSelected,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? AppColors.electricBlue
                          : (isDark
                              ? AppColors.darkSurfaceVariant
                              : AppColors.lightSurfaceVariant),
                    ),
                    child: Icon(
                      opt.icon,
                      color: isSelected ? Colors.black : AppColors.electricBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          opt.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          opt.desc,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.electricBlue,
                      size: 22,
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // STEP 3 — Fitness Goal
  Widget _buildStep3FitnessGoal(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
    HealthAssessmentState state,
  ) {
    final notifier = ref.read(healthAssessmentNotifierProvider.notifier);

    final goals = [
      (title: l10n.loseWeight, icon: Icons.trending_down_rounded),
      (title: l10n.buildMuscle, icon: Icons.fitness_center_rounded),
      (title: l10n.improveFitness, icon: Icons.speed_rounded),
      (title: l10n.improveEndurance, icon: Icons.directions_run_rounded),
      (title: l10n.maintainWeight, icon: Icons.balance_rounded),
      (title: l10n.improveHealth, icon: Icons.favorite_rounded),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SlideInAnimation(
          direction: SlideDirection.up,
          child: Text(
            l10n.step3Title,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        const SizedBox(height: 6),
        FadeInAnimation(
          delay: const Duration(milliseconds: 150),
          child: Text(
            l10n.step3Subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
          ),
        ),
        const SizedBox(height: 24),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.25,
          ),
          itemCount: goals.length,
          itemBuilder: (context, index) {
            final goal = goals[index];
            final isSelected = state.primaryGoal == goal.title;

            return GlassCard(
              onTap: () => notifier.setPrimaryGoal(goal.title),
              backgroundColor: isSelected
                  ? AppColors.electricBlue.withValues(alpha: 0.18)
                  : null,
              borderColor: isSelected ? AppColors.electricBlue : null,
              enableGlow: isSelected,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    goal.icon,
                    color: isSelected
                        ? AppColors.electricBlue
                        : (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary),
                    size: 32,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    goal.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? AppColors.electricBlue : null,
                        ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // STEP 4 — Lifestyle
  Widget _buildStep4Lifestyle(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
    HealthAssessmentState state,
  ) {
    final notifier = ref.read(healthAssessmentNotifierProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SlideInAnimation(
          direction: SlideDirection.up,
          child: Text(
            l10n.step4Title,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        const SizedBox(height: 6),
        FadeInAnimation(
          delay: const Duration(milliseconds: 150),
          child: Text(
            l10n.step4Subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
          ),
        ),
        const SizedBox(height: 24),

        // Workout time per day
        _buildSelectableChipsGroup(
          context,
          title: l10n.workoutTimePerDay,
          options: ['15-30 min', '30-45 min', '45-60 min', '60+ min'],
          selected: state.workoutAvailability,
          onSelected: (val) =>
              notifier.setLifestyleInfo(workoutAvailability: val),
          isDark: isDark,
        ),

        const SizedBox(height: 20),

        // Preferred days per week
        _buildSelectableChipsGroup(
          context,
          title: l10n.workoutDaysPerWeek,
          options: ['2-3 days', '3-4 days', '4-5 days', '5-6 days', 'Every day'],
          selected: state.workoutDays,
          onSelected: (val) => notifier.setLifestyleInfo(workoutDays: val),
          isDark: isDark,
        ),

        const SizedBox(height: 20),

        // Equipment
        _buildSelectableChipsGroup(
          context,
          title: l10n.equipmentAvailable,
          options: [
            'Bodyweight only',
            'Dumbbells',
            'Full Gym',
            'Resistance Bands'
          ],
          selected: state.equipment,
          onSelected: (val) => notifier.setLifestyleInfo(equipment: val),
          isDark: isDark,
        ),

        const SizedBox(height: 20),

        // Sleep Duration
        _buildSelectableChipsGroup(
          context,
          title: l10n.sleepDuration,
          options: ['< 6 hours', '6-7 hours', '7-8 hours', '8+ hours'],
          selected: state.sleepDuration,
          onSelected: (val) => notifier.setLifestyleInfo(sleepDuration: val),
          isDark: isDark,
        ),
      ],
    );
  }

  // STEP 5 — BMI & Summary
  Widget _buildStep5BmiSummary(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
    HealthAssessmentState state,
  ) {
    final bmi = state.calculatedBmi;
    final category = state.bmiCategoryName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SlideInAnimation(
          direction: SlideDirection.up,
          child: Text(
            l10n.step5Title,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        const SizedBox(height: 6),
        FadeInAnimation(
          delay: const Duration(milliseconds: 150),
          child: Text(
            l10n.step5Subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
          ),
        ),
        const SizedBox(height: 24),

        // BMI Meter Glass Card
        GlassEntranceAnimation(
          child: GlassCard(
            enableGlow: true,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  l10n.bmiValue,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.electricBlue,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$bmi',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontSize: 54,
                        fontWeight: FontWeight.w900,
                        color: AppColors.electricBlue,
                      ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.electricBlue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.electricBlue),
                  ),
                  child: Text(
                    category,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.electricBlue,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Medical Disclaimer Glass Card
        GlassCard(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: AppColors.electricBlue,
                size: 24,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.bmiDisclaimerTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.bmiDisclaimerText,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSelectableChipsGroup(
    BuildContext context, {
    required String title,
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelected,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((opt) {
            final isSelected = selected == opt;
            return ChoiceChip(
              label: Text(opt),
              selected: isSelected,
              onSelected: (_) => onSelected(opt),
              selectedColor: AppColors.electricBlue,
              backgroundColor: isDark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.lightSurfaceVariant,
              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? Colors.black
                        : (isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary),
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.electricBlue
                      : (isDark
                          ? AppColors.darkGlassBorder
                          : AppColors.lightGlassBorder),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration(
    BuildContext context, {
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: AppColors.electricBlue,
        size: 22,
      ),
      filled: true,
      fillColor: isDark
          ? AppColors.darkSurfaceVariant
          : AppColors.lightSurfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark
              ? AppColors.darkGlassBorder
              : AppColors.lightGlassBorder,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.electricBlue,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
    );
  }
}
