import 'dart:convert';

/// Model representing a recommended meal.
class Meal {
  final String id;
  final String name;
  final String type; // "Breakfast", "Lunch", "Dinner", "Snack"
  final int calories;
  final int proteinGrams;
  final int carbsGrams;
  final int fatGrams;
  final String description;
  final List<String> dietaryTags;

  const Meal({
    required this.id,
    required this.name,
    required this.type,
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    required this.description,
    this.dietaryTags = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'calories': calories,
      'proteinGrams': proteinGrams,
      'carbsGrams': carbsGrams,
      'fatGrams': fatGrams,
      'description': description,
      'dietaryTags': dietaryTags,
    };
  }

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? 'Healthy Meal',
      type: map['type'] as String? ?? 'Meal',
      calories: (map['calories'] as num?)?.toInt() ?? 400,
      proteinGrams: (map['proteinGrams'] as num?)?.toInt() ?? 25,
      carbsGrams: (map['carbsGrams'] as num?)?.toInt() ?? 45,
      fatGrams: (map['fatGrams'] as num?)?.toInt() ?? 12,
      description: map['description'] as String? ?? '',
      dietaryTags: (map['dietaryTags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  String toJson() => json.encode(toMap());

  factory Meal.fromJson(String source) =>
      Meal.fromMap(json.decode(source) as Map<String, dynamic>);
}
