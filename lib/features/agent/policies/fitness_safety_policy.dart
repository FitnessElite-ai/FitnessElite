/// Centralized fitness safety policy validating all agent outputs and user-facing text.
class FitnessSafetyPolicy {
  static bool validateText(String text) {
    final lower = text.toLowerCase();

    // Prohibited unsafe phrases
    if (lower.contains('you have a disease') ||
        lower.contains('medical diagnosis') ||
        lower.contains('exact body fat is') ||
        lower.contains('exact muscle mass is') ||
        lower.contains('stop taking medication') ||
        lower.contains('eat under 800 calories') ||
        lower.contains('starve yourself')) {
      return false;
    }

    return true;
  }

  static String sanitizeText(String text) {
    if (!validateText(text)) {
      return "FitnessElite AI provides estimated fitness guidance only and is not a substitute for clinical medical advice.";
    }
    return text;
  }
}
