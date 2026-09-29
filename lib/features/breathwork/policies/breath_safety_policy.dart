/// Centralized safety policy enforcing safe, beginner-friendly breathwork practices.
class BreathSafetyPolicy {
  static const String initialSafetyNote =
      'Keep your breathing comfortable and natural. Stop immediately if you feel dizzy, faint, or short of breath.';

  static bool validateInstructions(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('hold breath for 2 minutes') ||
        lower.contains('hyperventilate') ||
        lower.contains('cure asthma') ||
        lower.contains('treat disease') ||
        lower.contains('while driving')) {
      return false;
    }
    return true;
  }

  static String sanitizeText(String text) {
    if (!validateInstructions(text)) {
      return 'Maintain comfortable, rhythmic breathing without forcing your breath.';
    }
    return text;
  }
}
