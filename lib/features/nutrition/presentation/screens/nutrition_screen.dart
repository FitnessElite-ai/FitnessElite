import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/animations/fade_in_animation.dart';
import '../../../../shared/animations/glass_entrance_animation.dart';
import '../../../../shared/widgets/fitness_elite_logo.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../fitness_engine/providers/fitness_engine_provider.dart';
import '../../providers/nutrition_provider.dart';

/// Full Nutrition Dashboard displaying target macros, meal cards, "Mark as eaten" toggles, and hydration logging.
class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontalPadding = ResponsiveUtils.getHorizontalPadding(context);
    final engineState = ref.watch(fitnessEngineNotifierProvider);
    final nutritionLog = ref.watch(nutritionNotifierProvider);
    final notifier = ref.read(nutritionNotifierProvider.notifier);

    final plan = engineState.currentPlan?.nutritionPlan;

    if (plan == null) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const FitnessEliteLogo(iconSize: 26, fontSize: 18),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.restaurant_rounded, size: 48, color: AppColors.electricBlue),
                SizedBox(height: 12),
                Text('Complete your profile to generate custom nutrition guidance.'),
              ],
            ),
          ),
        ),
      );
    }

    final eatenMeals = nutritionLog.eatenMealIds;
    final totalCaloriesEaten = plan.meals
        .where((m) => eatenMeals.contains(m.id))
        .fold(0, (sum, m) => sum + m.calories);

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
                      FadeInAnimation(
                        child: Text(
                          'Nutrition & Fueling',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Target Macros • ${plan.dietaryPreference} Focus',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.electricBlue,
                              fontWeight: FontWeight.w700,
                            ),
                      ),

                      const SizedBox(height: 20),

                      // Daily Macro Summary Card
                      GlassEntranceAnimation(
                        child: GlassCard(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'CALORIC FUEL STATUS',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: AppColors.electricBlue,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                  Text(
                                    '$totalCaloriesEaten / ${plan.dailyCalories} kcal',
                                    style: const TextStyle(
                                      color: AppColors.electricBlue,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              LinearProgressIndicator(
                                value: (totalCaloriesEaten / plan.dailyCalories)
                                    .clamp(0.0, 1.0),
                                backgroundColor: isDark
                                    ? AppColors.darkSurfaceVariant
                                    : AppColors.lightSurfaceVariant,
                                color: AppColors.electricBlue,
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _NutrientBadge(
                                    label: 'PROTEIN',
                                    value: '${plan.proteinGrams}g',
                                  ),
                                  _NutrientBadge(
                                    label: 'CARBS',
                                    value: '${plan.carbsGrams}g',
                                  ),
                                  _NutrientBadge(
                                    label: 'FATS',
                                    value: '${plan.fatGrams}g',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Hydration Tracker Card
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
                                  color: AppColors.electricBlue.withValues(alpha: 0.15),
                                ),
                                child: const Icon(
                                  Icons.water_drop_rounded,
                                  color: AppColors.electricBlue,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'HYDRATION TARGET',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: AppColors.electricBlue,
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                    Text(
                                      '${nutritionLog.hydrationLitersConsumed} / ${plan.hydrationLiters} Liters',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton.filled(
                                icon: const Icon(Icons.add_rounded, size: 20),
                                style: IconButton.styleFrom(
                                  backgroundColor: AppColors.electricBlue,
                                  foregroundColor: Colors.black,
                                ),
                                onPressed: () => notifier.addHydration(0.25),
                                tooltip: 'Add 250ml Water',
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        'Recommended Meals',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),

                      const SizedBox(height: 10),

                      // Meal Cards
                      ...plan.meals.map((meal) {
                        final isEaten = eatenMeals.contains(meal.id);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GlassEntranceAnimation(
                            child: GlassCard(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Checkbox(
                                    value: isEaten,
                                    activeColor: AppColors.electricBlue,
                                    checkColor: Colors.black,
                                    onChanged: (_) =>
                                        notifier.toggleMealEaten(meal.id),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              meal.type.toUpperCase(),
                                              style: const TextStyle(
                                                color: AppColors.electricBlue,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            Text(
                                              '${meal.calories} kcal',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          meal.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                decoration: isEaten
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          meal.description,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
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
                          ),
                        );
                      }),
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

class _NutrientBadge extends StatelessWidget {
  final String label;
  final String value;

  const _NutrientBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: AppColors.electricBlue,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}
