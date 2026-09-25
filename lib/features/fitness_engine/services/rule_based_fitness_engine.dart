import '../../ai_coach/models/complete_fitness_profile.dart';
import '../models/exercise.dart';
import '../models/fitness_goal.dart';
import '../models/fitness_plan.dart';
import '../models/meal.dart';
import '../models/nutrition_plan.dart';
import '../models/recovery_plan.dart';
import '../models/workout_day.dart';
import '../models/workout_plan.dart';
import 'exercise_library.dart';
import 'fitness_engine_service.dart';

/// Rule-based, deterministic implementation of FitnessEngineService.
/// Transforms HealthProfile + FitnessPreferences + optional VisionAssessment
/// into a structured, highly personalized FitnessPlan.
class RuleBasedFitnessEngine implements FitnessEngineService {
  @override
  Future<FitnessPlan> generatePlan({
    required CompleteFitnessProfile profile,
  }) async {
    final hp = profile.healthProfile;
    final pref = profile.fitnessPreferences;
    final vision = profile.visionAssessment;

    // 1. Determine Goal
    final goalStr = (pref.primaryGoal.isNotEmpty ? pref.primaryGoal : hp.primaryGoal).toLowerCase();
    final isFatLoss = goalStr.contains('lose') || goalStr.contains('fat') || goalStr.contains('weight');
    final isMuscle = goalStr.contains('muscle') || goalStr.contains('build');
    final isStrength = goalStr.contains('strong') || goalStr.contains('strength');
    final isEndurance = goalStr.contains('endurance') || goalStr.contains('stamina');

    String primaryGoalTitle = 'Improve Overall Fitness';
    if (isFatLoss) primaryGoalTitle = 'Lose Fat & Tone Body';
    if (isMuscle) primaryGoalTitle = 'Build Muscle & Hypertrophy';
    if (isStrength) primaryGoalTitle = 'Get Stronger & Increase Power';
    if (isEndurance) primaryGoalTitle = 'Improve Endurance & Cardiovascular Fitness';

    // 2. BMR & TDEE Calculations (Mifflin-St Jeor)
    final double weight = hp.weightKg > 0 ? hp.weightKg : 70.0;
    final double height = hp.heightCm > 0 ? hp.heightCm : 170.0;
    final int age = hp.age > 0 ? hp.age : 25;
    final bool isMale = hp.sex.toLowerCase() == 'male';

    double bmr;
    if (isMale) {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }

    // Activity multiplier
    double actMultiplier = 1.375;
    final actLevel = hp.activityLevel.toLowerCase();
    if (actLevel.contains('sedentary')) actMultiplier = 1.2;
    if (actLevel.contains('light')) actMultiplier = 1.375;
    if (actLevel.contains('moderate')) actMultiplier = 1.55;
    if (actLevel.contains('very') || actLevel.contains('hard')) actMultiplier = 1.725;
    if (actLevel.contains('extreme')) actMultiplier = 1.9;

    final double tdee = bmr * actMultiplier;

    // Calorie target
    int targetCalories = tdee.round();
    if (isFatLoss) {
      targetCalories = (tdee * 0.82).round();
      final minCal = isMale ? 1500 : 1200;
      if (targetCalories < minCal) targetCalories = minCal;
    } else if (isMuscle) {
      targetCalories = (tdee * 1.10).round();
    }

    // Protein target (grams per kg)
    double proteinPerKg = 1.5;
    if (isMuscle || isStrength) proteinPerKg = 2.0;
    if (isFatLoss) proteinPerKg = 1.9;
    if (isEndurance) proteinPerKg = 1.4;

    final int proteinGrams = (weight * proteinPerKg).round().clamp(60, 240);
    final int fatGrams = ((targetCalories * 0.25) / 9).round().clamp(35, 110);
    final int carbsGrams = ((targetCalories - (proteinGrams * 4) - (fatGrams * 9)) / 4).round().clamp(80, 450);
    final double hydrationLiters = (weight * 0.035).clamp(2.0, 4.5);

    // 3. Nutrition Meals according to Dietary Preference
    final dietPref = (pref.dietaryPreference.isNotEmpty ? pref.dietaryPreference : hp.dietaryPreference);
    final meals = _generateSampleMeals(dietPref, targetCalories, proteinGrams);

    final nutritionPlan = NutritionPlan(
      dailyCalories: targetCalories,
      proteinGrams: proteinGrams,
      carbsGrams: carbsGrams,
      fatGrams: fatGrams,
      hydrationLiters: double.parse(hydrationLiters.toStringAsFixed(1)),
      dietaryPreference: dietPref,
      guidanceNotes: 'Estimated daily targets based on metabolic energy expenditure.',
      meals: meals,
    );

    // 4. Workout Plan & Schedule Generation
    final timeStr = (pref.dailyTrainingTime.isNotEmpty ? pref.dailyTrainingTime : hp.workoutAvailability).toLowerCase();
    int sessionMin = 30;
    if (timeStr.contains('15')) sessionMin = 15;
    if (timeStr.contains('30')) sessionMin = 30;
    if (timeStr.contains('45')) sessionMin = 45;
    if (timeStr.contains('60') || timeStr.contains('60+')) sessionMin = 60;

    final locationStr = pref.preferredLocation.toLowerCase();
    final isGym = locationStr.contains('gym');

    final expLevel = pref.experienceLevel.isNotEmpty ? pref.experienceLevel : 'Beginner';

    // Equipment filtering
    String equipmentPref = 'Bodyweight';
    if (isGym) {
      equipmentPref = 'Full Gym';
    } else if (hp.equipment.toLowerCase().contains('dumbbell')) {
      equipmentPref = 'Dumbbells';
    }

    // Vision Assessment integration
    bool hasPostureFocus = false;
    if (vision != null && vision.completed) {
      final text = vision.insights.map((i) => '${i.category} ${i.description}'.toLowerCase()).join(' ');
      if (text.contains('posture') || text.contains('alignment') || text.contains('mobility')) {
        hasPostureFocus = true;
      }
    }

    final weeklySchedule = _generateWeeklySchedule(
      sessionMin: sessionMin,
      equipmentPref: equipmentPref,
      expLevel: expLevel,
      hasPostureFocus: hasPostureFocus,
      isFatLoss: isFatLoss,
      isMuscle: isMuscle,
    );

    final workoutPlan = WorkoutPlan(
      title: '$sessionMin-Min ${isGym ? "Gym" : "Home"} $primaryGoalTitle Split',
      description: 'Personalized $expLevel level program tailored for $sessionMin minutes per session.',
      weeklyFrequency: weeklySchedule.where((d) => d.isWorkout).length,
      days: weeklySchedule,
    );

    // 5. Recovery Plan
    final recoveryPlan = RecoveryPlan(
      sleepTargetHours: hp.sleepDuration.isNotEmpty ? hp.sleepDuration : '7-8 hours',
      restDaysPerWeek: weeklySchedule.where((d) => d.isRest || d.isRecovery).length,
      hydrationGuidance: '${hydrationLiters.toStringAsFixed(1)} Liters daily',
      mobilityRecommendation: hasPostureFocus
          ? 'Daily 10-min posture & thoracic mobility protocol (Cat-Cow, Dead Bug, Plank).'
          : 'Daily 8-10 min dynamic mobility stretching post-workout.',
      recoveryNotes: 'Prioritize consistent sleep and active recovery to support muscle repair.',
    );

    // 6. Target Goals Metrics
    final targetMetrics = [
      FitnessGoal(
        metric: 'Workout Consistency',
        baseline: '0 sessions/wk',
        target: '${workoutPlan.weeklyFrequency} sessions/wk',
        unit: 'sessions',
        timeframe: '4 weeks',
      ),
      FitnessGoal(
        metric: 'Weekly Training Volume',
        baseline: '0 min',
        target: '${workoutPlan.weeklyFrequency * sessionMin} min/wk',
        unit: 'min',
        timeframe: '4 weeks',
      ),
      if (isFatLoss)
        FitnessGoal(
          metric: 'Estimated Target Weight',
          baseline: '${weight.toStringAsFixed(1)} kg',
          target: '${(weight - 2.5).toStringAsFixed(1)} kg',
          unit: 'kg',
          timeframe: '6 weeks',
        )
      else if (isMuscle)
        FitnessGoal(
          metric: 'Strength & Lean Baseline',
          baseline: '${weight.toStringAsFixed(1)} kg',
          target: '${(weight + 1.5).toStringAsFixed(1)} kg',
          unit: 'kg',
          timeframe: '8 weeks',
        )
      else
        FitnessGoal(
          metric: 'Daily Energy & Fitness Index',
          baseline: 'Base',
          target: '+20%',
          unit: '%',
          timeframe: '4 weeks',
        ),
    ];

    // 7. Dynamic Summary
    final summary = _generateSummary(
      name: hp.name,
      goal: primaryGoalTitle,
      durationMin: sessionMin,
      location: isGym ? 'Gym' : 'Home',
      frequency: workoutPlan.weeklyFrequency,
      hasVision: vision != null && vision.completed,
    );

    return FitnessPlan(
      id: 'plan_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      durationWeeks: 4,
      summary: summary,
      primaryGoal: primaryGoalTitle,
      targetMetrics: targetMetrics,
      weeklySchedule: weeklySchedule,
      workoutPlan: workoutPlan,
      nutritionPlan: nutritionPlan,
      recoveryPlan: recoveryPlan,
    );
  }

  List<Meal> _generateSampleMeals(String dietPref, int targetCalories, int targetProtein) {
    final isVeg = dietPref.toLowerCase().contains('veg') && !dietPref.toLowerCase().contains('non');
    final isVegan = dietPref.toLowerCase().contains('vegan');
    final isEggetarian = dietPref.toLowerCase().contains('egg');

    if (isVegan) {
      return [
        Meal(
          id: 'meal_1',
          name: 'Oats with Almond Butter & Chia Seeds',
          type: 'Breakfast',
          calories: (targetCalories * 0.25).round(),
          proteinGrams: (targetProtein * 0.22).round(),
          carbsGrams: 55,
          fatGrams: 14,
          description: 'Rolled oats cooked in almond milk topped with chia seeds and berries.',
          dietaryTags: ['Vegan', 'Plant-Based'],
        ),
        Meal(
          id: 'meal_2',
          name: 'Tofu Vegetable Stir-Fry & Brown Rice',
          type: 'Lunch',
          calories: (targetCalories * 0.35).round(),
          proteinGrams: (targetProtein * 0.35).round(),
          carbsGrams: 65,
          fatGrams: 16,
          description: 'Firm tofu sautéed with mixed bell peppers, broccoli, and brown rice.',
          dietaryTags: ['Vegan', 'High Protein'],
        ),
        Meal(
          id: 'meal_3',
          name: 'Chana Masala (Chickpea Curry) & Whole Wheat Roti',
          type: 'Dinner',
          calories: (targetCalories * 0.30).round(),
          proteinGrams: (targetProtein * 0.30).round(),
          carbsGrams: 60,
          fatGrams: 12,
          description: 'Protein-dense spiced chickpea curry served with 2 whole wheat rotis and salad.',
          dietaryTags: ['Vegan', 'Fiber Rich'],
        ),
        Meal(
          id: 'meal_4',
          name: 'Handful of Roasted Chana & Almonds',
          type: 'Snack',
          calories: (targetCalories * 0.10).round(),
          proteinGrams: (targetProtein * 0.13).round(),
          carbsGrams: 15,
          fatGrams: 8,
          description: 'Crunchy roasted chickpeas with raw almonds.',
          dietaryTags: ['Vegan', 'Snack'],
        ),
      ];
    } else if (isVeg) {
      return [
        Meal(
          id: 'meal_1',
          name: 'Paneer & Spinach Scramble / Sprouts Salad',
          type: 'Breakfast',
          calories: (targetCalories * 0.25).round(),
          proteinGrams: (targetProtein * 0.25).round(),
          carbsGrams: 30,
          fatGrams: 18,
          description: 'Fresh paneer tossed with spinach, tomatoes, and sprouted moong.',
          dietaryTags: ['Vegetarian', 'High Protein'],
        ),
        Meal(
          id: 'meal_2',
          name: 'Dal Tadka, Paneer Bhurji & Basmati Rice',
          type: 'Lunch',
          calories: (targetCalories * 0.35).round(),
          proteinGrams: (targetProtein * 0.35).round(),
          carbsGrams: 65,
          fatGrams: 18,
          description: 'Yellow dal with fresh paneer bhurji, steamed rice, and cucumber curd.',
          dietaryTags: ['Vegetarian', 'Balanced'],
        ),
        Meal(
          id: 'meal_3',
          name: 'Soya Chunk Curry & Whole Wheat Roti',
          type: 'Dinner',
          calories: (targetCalories * 0.30).round(),
          proteinGrams: (targetProtein * 0.30).round(),
          carbsGrams: 50,
          fatGrams: 12,
          description: 'High-protein soya chunks cooked in onion-tomato gravy with 2 rotis.',
          dietaryTags: ['Vegetarian', 'High Protein'],
        ),
        Meal(
          id: 'meal_4',
          name: 'Greek Yogurt / Curd with Honey & Walnuts',
          type: 'Snack',
          calories: (targetCalories * 0.10).round(),
          proteinGrams: (targetProtein * 0.10).round(),
          carbsGrams: 18,
          fatGrams: 8,
          description: 'Probiotic curd topped with crushed walnuts.',
          dietaryTags: ['Vegetarian', 'Healthy Fat'],
        ),
      ];
    } else if (isEggetarian) {
      return [
        Meal(
          id: 'meal_1',
          name: '3 Whole Eggs Omelette with Vegetables & Toast',
          type: 'Breakfast',
          calories: (targetCalories * 0.25).round(),
          proteinGrams: (targetProtein * 0.28).round(),
          carbsGrams: 28,
          fatGrams: 16,
          description: 'Whisked eggs cooked with onions, peppers, and whole grain toast.',
          dietaryTags: ['Eggetarian', 'High Protein'],
        ),
        Meal(
          id: 'meal_2',
          name: 'Egg Curry, Dal & Rice',
          type: 'Lunch',
          calories: (targetCalories * 0.35).round(),
          proteinGrams: (targetProtein * 0.34).round(),
          carbsGrams: 60,
          fatGrams: 18,
          description: '2 boiled egg curry served with dal and brown rice.',
          dietaryTags: ['Eggetarian'],
        ),
        Meal(
          id: 'meal_3',
          name: 'Paneer Tikka & Salad',
          type: 'Dinner',
          calories: (targetCalories * 0.30).round(),
          proteinGrams: (targetProtein * 0.28).round(),
          carbsGrams: 20,
          fatGrams: 18,
          description: 'Grilled paneer cubes marinated in yogurt and spices.',
          dietaryTags: ['Vegetarian', 'Low Carb'],
        ),
        Meal(
          id: 'meal_4',
          name: 'Boiled Eggs & Green Tea',
          type: 'Snack',
          calories: (targetCalories * 0.10).round(),
          proteinGrams: (targetProtein * 0.10).round(),
          carbsGrams: 2,
          fatGrams: 10,
          description: '2 hard boiled eggs seasoned with black pepper.',
          dietaryTags: ['Eggetarian', 'Quick Snack'],
        ),
      ];
    } else {
      // Non-Vegetarian / Flexible
      return [
        Meal(
          id: 'meal_1',
          name: 'Egg White Scramble & Oatmeal',
          type: 'Breakfast',
          calories: (targetCalories * 0.25).round(),
          proteinGrams: (targetProtein * 0.28).round(),
          carbsGrams: 40,
          fatGrams: 10,
          description: 'Egg whites cooked with spinach served alongside warm cinnamon oatmeal.',
          dietaryTags: ['High Protein', 'Balanced'],
        ),
        Meal(
          id: 'meal_2',
          name: 'Grilled Chicken Breast, Brown Rice & Steamed Veggies',
          type: 'Lunch',
          calories: (targetCalories * 0.35).round(),
          proteinGrams: (targetProtein * 0.38).round(),
          carbsGrams: 55,
          fatGrams: 12,
          description: 'Herb seasoned chicken breast with fragrant brown rice and green beans.',
          dietaryTags: ['High Protein', 'Lean Meal'],
        ),
        Meal(
          id: 'meal_3',
          name: 'Fish Curry / Grilled Fish & Roti with Salad',
          type: 'Dinner',
          calories: (targetCalories * 0.30).round(),
          proteinGrams: (targetProtein * 0.26).round(),
          carbsGrams: 45,
          fatGrams: 14,
          description: 'Pan-seared fish cooked in light spices served with 2 whole wheat rotis.',
          dietaryTags: ['Omega-3 Rich', 'High Protein'],
        ),
        Meal(
          id: 'meal_4',
          name: 'Whey Protein Shake / Paneer Cubes & Almonds',
          type: 'Snack',
          calories: (targetCalories * 0.10).round(),
          proteinGrams: (targetProtein * 0.08).round(),
          carbsGrams: 10,
          fatGrams: 8,
          description: 'Quick protein refueling snack.',
          dietaryTags: ['Post-Workout'],
        ),
      ];
    }
  }

  List<WorkoutDay> _generateWeeklySchedule({
    required int sessionMin,
    required String equipmentPref,
    required String expLevel,
    required bool hasPostureFocus,
    required bool isFatLoss,
    required bool isMuscle,
  }) {
    final availableExercises = ExerciseLibrary.filterExercises(
      equipmentPreference: equipmentPref,
      experienceLevel: expLevel,
    );

    int exerciseCount = 4;
    if (sessionMin == 15) exerciseCount = 3;
    if (sessionMin == 30) exerciseCount = 4;
    if (sessionMin == 45) exerciseCount = 5;
    if (sessionMin == 60) exerciseCount = 5;

    List<Exercise> getExercisesForGroup(String muscleGroup) {
      var matches = availableExercises.where((e) => e.muscleGroup.toLowerCase() == muscleGroup.toLowerCase()).toList();
      if (matches.isEmpty) {
        matches = ExerciseLibrary.catalog.where((e) => e.muscleGroup.toLowerCase() == muscleGroup.toLowerCase()).toList();
      }
      return matches.take(exerciseCount).toList();
    }

    final chestEx = getExercisesForGroup('Chest');
    final backEx = getExercisesForGroup('Back');
    final legsEx = getExercisesForGroup('Legs');
    final glutesEx = getExercisesForGroup('Glutes');
    final shouldersEx = getExercisesForGroup('Shoulders');
    final coreEx = getExercisesForGroup('Core');
    final cardioEx = getExercisesForGroup('Full Body');
    final mobilityEx = getExercisesForGroup('Mobility');

    final upperList = [...chestEx, ...backEx, ...shouldersEx].take(exerciseCount).toList();
    final lowerList = [...legsEx, ...glutesEx, ...coreEx].take(exerciseCount).toList();
    final fullList = [...chestEx.take(1), ...backEx.take(1), ...legsEx.take(1), ...coreEx.take(1), ...cardioEx.take(1)].take(exerciseCount).toList();

    if (hasPostureFocus) {
      if (mobilityEx.isNotEmpty && fullList.isNotEmpty) {
        fullList[0] = mobilityEx.first;
      }
    }

    return [
      WorkoutDay(
        day: 'Monday',
        title: 'Upper Body Strength',
        focus: 'Chest, Back & Shoulders',
        type: 'workout',
        durationMinutes: sessionMin,
        exercises: upperList,
      ),
      WorkoutDay(
        day: 'Tuesday',
        title: 'Lower Body & Core',
        focus: 'Quadriceps, Glutes & Abs',
        type: 'workout',
        durationMinutes: sessionMin,
        exercises: lowerList,
      ),
      WorkoutDay(
        day: 'Wednesday',
        title: 'Active Recovery & Mobility',
        focus: 'Postural Realignment & Light Stretching',
        type: 'recovery',
        durationMinutes: 20,
        exercises: mobilityEx.take(2).toList(),
      ),
      WorkoutDay(
        day: 'Thursday',
        title: 'Full Body Conditioning',
        focus: 'Compound Strength & Endurance',
        type: 'workout',
        durationMinutes: sessionMin,
        exercises: fullList,
      ),
      WorkoutDay(
        day: 'Friday',
        title: 'Core & Mobility Focus',
        focus: 'Abdominal Strength & Hip Flexibility',
        type: 'workout',
        durationMinutes: sessionMin,
        exercises: [...coreEx, ...mobilityEx].take(exerciseCount).toList(),
      ),
      WorkoutDay(
        day: 'Saturday',
        title: 'Rest & Complete Recovery',
        focus: 'Full Body Rest & Muscle Repair',
        type: 'rest',
        durationMinutes: 0,
        exercises: const [],
      ),
      WorkoutDay(
        day: 'Sunday',
        title: 'Rest & Complete Recovery',
        focus: 'Full Body Rest & Mental Recharge',
        type: 'rest',
        durationMinutes: 0,
        exercises: const [],
      ),
    ];
  }

  String _generateSummary({
    required String name,
    required String goal,
    required int durationMin,
    required String location,
    required int frequency,
    required bool hasVision,
  }) {
    final athleteName = name.isNotEmpty ? name : 'Athlete';
    final visionClause = hasVision ? ' and incorporating your visual baseline insights' : '';

    return 'Welcome, $athleteName! Your personalized plan is built around $frequency weekly $durationMin-minute $location sessions$visionClause. Your primary target is $goal with progressive overload and sustainable nutrition.';
  }
}
