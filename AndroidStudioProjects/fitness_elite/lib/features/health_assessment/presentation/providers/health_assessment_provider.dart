import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/persistence_providers.dart';
import '../../data/fitness_profile_repository.dart';
import '../../domain/bmi_calculator.dart';
import '../../domain/fitness_profile.dart';

final fitnessProfileRepositoryProvider =
    Provider<FitnessProfileRepository>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return LocalFitnessProfileRepository(storage);
});

class HealthAssessmentState {
  final int currentStep;
  final UnitSystem unitSystem;
  final String name;
  final int age;
  final String sex;
  final double heightCm;
  final double weightKg;
  final int heightFt;
  final double heightIn;
  final double weightLbs;
  final String activityLevel;
  final String primaryGoal;
  final String workoutAvailability;
  final String workoutDays;
  final String equipment;
  final String sleepDuration;
  final String dietaryPreference;
  final bool isSaving;
  final FitnessProfile? savedProfile;

  const HealthAssessmentState({
    this.currentStep = 0,
    this.unitSystem = UnitSystem.metric,
    this.name = '',
    this.age = 25,
    this.sex = 'Male',
    this.heightCm = 175.0,
    this.weightKg = 70.0,
    this.heightFt = 5,
    this.heightIn = 9.0,
    this.weightLbs = 154.0,
    this.activityLevel = 'Moderately Active',
    this.primaryGoal = 'Improve overall health',
    this.workoutAvailability = '30-45 min',
    this.workoutDays = '3-4 days',
    this.equipment = 'Bodyweight only',
    this.sleepDuration = '7-8 hours',
    this.dietaryPreference = 'Anything',
    this.isSaving = false,
    this.savedProfile,
  });

  HealthAssessmentState copyWith({
    int? currentStep,
    UnitSystem? unitSystem,
    String? name,
    int? age,
    String? sex,
    double? heightCm,
    double? weightKg,
    int? heightFt,
    double? heightIn,
    double? weightLbs,
    String? activityLevel,
    String? primaryGoal,
    String? workoutAvailability,
    String? workoutDays,
    String? equipment,
    String? sleepDuration,
    String? dietaryPreference,
    bool? isSaving,
    FitnessProfile? savedProfile,
  }) {
    return HealthAssessmentState(
      currentStep: currentStep ?? this.currentStep,
      unitSystem: unitSystem ?? this.unitSystem,
      name: name ?? this.name,
      age: age ?? this.age,
      sex: sex ?? this.sex,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      heightFt: heightFt ?? this.heightFt,
      heightIn: heightIn ?? this.heightIn,
      weightLbs: weightLbs ?? this.weightLbs,
      activityLevel: activityLevel ?? this.activityLevel,
      primaryGoal: primaryGoal ?? this.primaryGoal,
      workoutAvailability: workoutAvailability ?? this.workoutAvailability,
      workoutDays: workoutDays ?? this.workoutDays,
      equipment: equipment ?? this.equipment,
      sleepDuration: sleepDuration ?? this.sleepDuration,
      dietaryPreference: dietaryPreference ?? this.dietaryPreference,
      isSaving: isSaving ?? this.isSaving,
      savedProfile: savedProfile ?? this.savedProfile,
    );
  }

  double get calculatedBmi => BmiCalculator.calculateBmi(weightKg, heightCm);

  String get bmiCategoryName => BmiCalculator.getCategoryName(calculatedBmi);
}

class HealthAssessmentNotifier extends Notifier<HealthAssessmentState> {
  late final FitnessProfileRepository _repository;

  @override
  HealthAssessmentState build() {
    _repository = ref.watch(fitnessProfileRepositoryProvider);
    final existingProfile = _repository.getFitnessProfile();

    if (existingProfile != null) {
      final ftIn = BmiCalculator.cmToFtIn(existingProfile.heightCm);
      final lbs = BmiCalculator.kgToLbs(existingProfile.weightKg);

      return HealthAssessmentState(
        name: existingProfile.name,
        age: existingProfile.age,
        sex: existingProfile.sex,
        heightCm: existingProfile.heightCm,
        weightKg: existingProfile.weightKg,
        heightFt: ftIn.feet,
        heightIn: ftIn.inches,
        weightLbs: double.parse(lbs.toStringAsFixed(1)),
        unitSystem: existingProfile.unitSystem,
        activityLevel: existingProfile.activityLevel,
        primaryGoal: existingProfile.primaryGoal,
        workoutAvailability: existingProfile.workoutAvailability,
        workoutDays: existingProfile.workoutDays,
        equipment: existingProfile.equipment,
        sleepDuration: existingProfile.sleepDuration,
        dietaryPreference: existingProfile.dietaryPreference,
        savedProfile: existingProfile,
      );
    }

    return const HealthAssessmentState();
  }

  void nextStep() {
    if (state.currentStep < 4) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void setStep(int step) {
    if (step >= 0 && step <= 4) {
      state = state.copyWith(currentStep: step);
    }
  }

  void setUnitSystem(UnitSystem system) {
    if (system == UnitSystem.imperial) {
      final ftIn = BmiCalculator.cmToFtIn(state.heightCm);
      final lbs = BmiCalculator.kgToLbs(state.weightKg);
      state = state.copyWith(
        unitSystem: system,
        heightFt: ftIn.feet,
        heightIn: ftIn.inches,
        weightLbs: double.parse(lbs.toStringAsFixed(1)),
      );
    } else {
      final cm = BmiCalculator.ftInToCm(state.heightFt, state.heightIn);
      final kg = BmiCalculator.lbsToKg(state.weightLbs);
      state = state.copyWith(
        unitSystem: system,
        heightCm: double.parse(cm.toStringAsFixed(1)),
        weightKg: double.parse(kg.toStringAsFixed(1)),
      );
    }
  }

  void updateBasicInfo({
    String? name,
    int? age,
    String? sex,
    double? heightCm,
    double? weightKg,
    int? heightFt,
    double? heightIn,
    double? weightLbs,
  }) {
    double newCm = heightCm ?? state.heightCm;
    double newKg = weightKg ?? state.weightKg;
    int newFt = heightFt ?? state.heightFt;
    double newIn = heightIn ?? state.heightIn;
    double newLbs = weightLbs ?? state.weightLbs;

    if (state.unitSystem == UnitSystem.imperial) {
      newCm = BmiCalculator.ftInToCm(newFt, newIn);
      newKg = BmiCalculator.lbsToKg(newLbs);
    } else {
      final ftIn = BmiCalculator.cmToFtIn(newCm);
      newFt = ftIn.feet;
      newIn = ftIn.inches;
      newLbs = BmiCalculator.kgToLbs(newKg);
    }

    state = state.copyWith(
      name: name ?? state.name,
      age: age ?? state.age,
      sex: sex ?? state.sex,
      heightCm: double.parse(newCm.toStringAsFixed(1)),
      weightKg: double.parse(newKg.toStringAsFixed(1)),
      heightFt: newFt,
      heightIn: double.parse(newIn.toStringAsFixed(1)),
      weightLbs: double.parse(newLbs.toStringAsFixed(1)),
    );
  }

  void setActivityLevel(String level) {
    state = state.copyWith(activityLevel: level);
  }

  void setPrimaryGoal(String goal) {
    state = state.copyWith(primaryGoal: goal);
  }

  void setLifestyleInfo({
    String? workoutAvailability,
    String? workoutDays,
    String? equipment,
    String? sleepDuration,
    String? dietaryPreference,
  }) {
    state = state.copyWith(
      workoutAvailability: workoutAvailability ?? state.workoutAvailability,
      workoutDays: workoutDays ?? state.workoutDays,
      equipment: equipment ?? state.equipment,
      sleepDuration: sleepDuration ?? state.sleepDuration,
      dietaryPreference: dietaryPreference ?? state.dietaryPreference,
    );
  }

  Future<FitnessProfile> completeAndSaveProfile(String languageCode) async {
    state = state.copyWith(isSaving: true);

    final profile = FitnessProfile(
      name: state.name.isNotEmpty ? state.name : 'Fitness Elite Athlete',
      age: state.age,
      sex: state.sex,
      heightCm: state.heightCm,
      weightKg: state.weightKg,
      unitSystem: state.unitSystem,
      bmi: state.calculatedBmi,
      bmiCategory: state.bmiCategoryName,
      activityLevel: state.activityLevel,
      primaryGoal: state.primaryGoal,
      workoutAvailability: state.workoutAvailability,
      workoutDays: state.workoutDays,
      equipment: state.equipment,
      sleepDuration: state.sleepDuration,
      dietaryPreference: state.dietaryPreference,
      preferredLanguage: languageCode,
    );

    await _repository.saveFitnessProfile(profile);

    state = state.copyWith(
      isSaving: false,
      savedProfile: profile,
    );

    return profile;
  }
}

final healthAssessmentNotifierProvider = NotifierProvider<
    HealthAssessmentNotifier, HealthAssessmentState>(
  HealthAssessmentNotifier.new,
);
