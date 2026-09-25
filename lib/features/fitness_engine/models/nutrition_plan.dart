import 'dart:convert';
import 'meal.dart';

/// Personalized Nutrition Plan model with estimated daily macros and recommended meals.
class NutritionPlan {
  final int dailyCalories;
  final int proteinGrams;
  final int carbsGrams;
  final int fatGrams;
  final double hydrationLiters;
  final String dietaryPreference;
  final String guidanceNotes;
  final List<Meal> meals;

  const NutritionPlan({
    required this.dailyCalories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    required this.hydrationLiters,
    required this.dietaryPreference,
    required this.guidanceNotes,
    this.meals = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'dailyCalories': dailyCalories,
      'proteinGrams': proteinGrams,
      'carbsGrams': carbsGrams,
      'fatGrams': fatGrams,
      'hydrationLiters': hydrationLiters,
      'dietaryPreference': dietaryPreference,
      'guidanceNotes': guidanceNotes,
      'meals': meals.map((e) => e.toMap()).toList(),
    };
  }

  factory NutritionPlan.fromMap(Map<String, dynamic> map) {
    return NutritionPlan(
      dailyCalories: (map['dailyCalories'] as num?)?.toInt() ?? 2000,
      proteinGrams: (map['proteinGrams'] as num?)?.toInt() ?? 130,
      carbsGrams: (map['carbsGrams'] as num?)?.toInt() ?? 220,
      fatGrams: (map['fatGrams'] as num?)?.toInt() ?? 65,
      hydrationLiters: (map['hydrationLiters'] as num?)?.toDouble() ?? 2.5,
      dietaryPreference: map['dietaryPreference'] as String? ?? 'Flexible',
      guidanceNotes: map['guidanceNotes'] as String? ?? '',
      meals: (map['meals'] as List<dynamic>?)
              ?.map((e) => Meal.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  String toJson() => json.encode(toMap());

  factory NutritionPlan.fromJson(String source) =>
      NutritionPlan.fromMap(json.decode(source) as Map<String, dynamic>);
}
