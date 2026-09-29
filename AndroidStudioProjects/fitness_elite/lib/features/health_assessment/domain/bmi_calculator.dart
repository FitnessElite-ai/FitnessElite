enum BmiCategoryType { underweight, normal, overweight, obesity }

/// Pure local calculation and unit conversion utilities for Health Assessment.
class BmiCalculator {
  /// Converts weight in lbs to kg
  static double lbsToKg(double lbs) => lbs * 0.45359237;

  /// Converts weight in kg to lbs
  static double kgToLbs(double kg) => kg / 0.45359237;

  /// Converts feet and inches to cm
  static double ftInToCm(int feet, double inches) {
    final totalInches = (feet * 12) + inches;
    return totalInches * 2.54;
  }

  /// Converts cm to feet and inches
  static ({int feet, double inches}) cmToFtIn(double cm) {
    final totalInches = cm / 2.54;
    final feet = totalInches ~/ 12;
    final inches = totalInches % 12;
    return (feet: feet, inches: double.parse(inches.toStringAsFixed(1)));
  }

  /// Calculates BMI = weightKg / (heightMeters * heightMeters)
  static double calculateBmi(double weightKg, double heightCm) {
    if (heightCm <= 0 || weightKg <= 0) return 0.0;
    final heightMeters = heightCm / 100.0;
    final bmi = weightKg / (heightMeters * heightMeters);
    return double.parse(bmi.toStringAsFixed(1));
  }

  /// Categorizes BMI value
  static BmiCategoryType getCategoryType(double bmi) {
    if (bmi < 18.5) {
      return BmiCategoryType.underweight;
    } else if (bmi < 25.0) {
      return BmiCategoryType.normal;
    } else if (bmi < 30.0) {
      return BmiCategoryType.overweight;
    } else {
      return BmiCategoryType.obesity;
    }
  }

  static String getCategoryName(double bmi) {
    final cat = getCategoryType(bmi);
    switch (cat) {
      case BmiCategoryType.underweight:
        return 'Underweight';
      case BmiCategoryType.normal:
        return 'Normal weight';
      case BmiCategoryType.overweight:
        return 'Overweight';
      case BmiCategoryType.obesity:
        return 'Obesity';
    }
  }
}
