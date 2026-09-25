import 'dart:convert';

/// Daily nutrition log for tracking eaten meals and hydration.
class DailyNutritionLog {
  final String dateKey; // e.g. "2025-05-20"
  final Set<String> eatenMealIds;
  final double hydrationLitersConsumed;

  const DailyNutritionLog({
    required this.dateKey,
    this.eatenMealIds = const {},
    this.hydrationLitersConsumed = 0.0,
  });

  DailyNutritionLog copyWith({
    String? dateKey,
    Set<String>? eatenMealIds,
    double? hydrationLitersConsumed,
  }) {
    return DailyNutritionLog(
      dateKey: dateKey ?? this.dateKey,
      eatenMealIds: eatenMealIds ?? this.eatenMealIds,
      hydrationLitersConsumed:
          hydrationLitersConsumed ?? this.hydrationLitersConsumed,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dateKey': dateKey,
      'eatenMealIds': eatenMealIds.toList(),
      'hydrationLitersConsumed': hydrationLitersConsumed,
    };
  }

  factory DailyNutritionLog.fromMap(Map<String, dynamic> map) {
    return DailyNutritionLog(
      dateKey: map['dateKey'] as String? ?? '',
      eatenMealIds: (map['eatenMealIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toSet() ??
          {},
      hydrationLitersConsumed:
          (map['hydrationLitersConsumed'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory DailyNutritionLog.fromJson(String source) =>
      DailyNutritionLog.fromMap(json.decode(source) as Map<String, dynamic>);
}
