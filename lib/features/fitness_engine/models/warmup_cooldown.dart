import 'dart:convert';

/// Model representing a Warmup or Cooldown protocol item.
class WarmupCooldownItem {
  final String name;
  final String targetArea;
  final int durationSeconds;
  final String instructions;
  final String breathingGuidance;

  const WarmupCooldownItem({
    required this.name,
    required this.targetArea,
    required this.durationSeconds,
    required this.instructions,
    required this.breathingGuidance,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'targetArea': targetArea,
      'durationSeconds': durationSeconds,
      'instructions': instructions,
      'breathingGuidance': breathingGuidance,
    };
  }

  factory WarmupCooldownItem.fromMap(Map<String, dynamic> map) {
    return WarmupCooldownItem(
      name: map['name'] as String? ?? 'Movement',
      targetArea: map['targetArea'] as String? ?? 'Full Body',
      durationSeconds: (map['durationSeconds'] as num?)?.toInt() ?? 60,
      instructions: map['instructions'] as String? ?? '',
      breathingGuidance: map['breathingGuidance'] as String? ?? 'Controlled breathing.',
    );
  }

  String toJson() => json.encode(toMap());

  factory WarmupCooldownItem.fromJson(String source) =>
      WarmupCooldownItem.fromMap(json.decode(source) as Map<String, dynamic>);
}

/// Helper routines for dynamic Warmup and Cooldown generation.
class WarmupCooldownLibrary {
  static List<WarmupCooldownItem> getWarmupForFocus(String focus) {
    final lower = focus.toLowerCase();
    if (lower.contains('upper') || lower.contains('chest') || lower.contains('back')) {
      return const [
        WarmupCooldownItem(
          name: 'Arm Circles & Hugs',
          targetArea: 'Shoulders & Chest',
          durationSeconds: 60,
          instructions: 'Circle arms forward and backward 30s each, then swing across chest.',
          breathingGuidance: 'Inhale as arms open wide, exhale as arms cross chest.',
        ),
        WarmupCooldownItem(
          name: 'Thoracic Windmills',
          targetArea: 'Upper Spine & Lats',
          durationSeconds: 60,
          instructions: 'Rotate upper torso smoothly from side to side in standing stance.',
          breathingGuidance: 'Exhale at end of each side rotation.',
        ),
      ];
    } else if (lower.contains('lower') || lower.contains('leg') || lower.contains('glute')) {
      return const [
        WarmupCooldownItem(
          name: 'Leg Swings & Hip Rotations',
          targetArea: 'Hips & Quadriceps',
          durationSeconds: 60,
          instructions: 'Swing leg forward/backward 30s each side with balance support.',
          breathingGuidance: 'Breathe rhythmically with swing pace.',
        ),
        WarmupCooldownItem(
          name: 'Bodyweight Good Mornings',
          targetArea: 'Hamstrings & Glutes',
          durationSeconds: 60,
          instructions: 'Hands behind head, hinge at hips keeping back flat.',
          breathingGuidance: 'Inhale as hips hinge back, exhale as you stand up.',
        ),
      ];
    } else {
      return const [
        WarmupCooldownItem(
          name: 'Jumping Jacks / March in Place',
          targetArea: 'Full Body Cardio',
          durationSeconds: 60,
          instructions: 'Rhythmic full body warm-up to increase heart rate.',
          breathingGuidance: 'Inhale through nose, exhale through mouth steadily.',
        ),
        WarmupCooldownItem(
          name: 'Bodyweight Squats & Arm Reaches',
          targetArea: 'Full Body Mobility',
          durationSeconds: 60,
          instructions: 'Gentle squat reaching arms overhead at top.',
          breathingGuidance: 'Inhale as you lower, exhale as you stand and reach.',
        ),
      ];
    }
  }

  static List<WarmupCooldownItem> getCooldownForFocus(String focus) {
    return const [
      WarmupCooldownItem(
        name: 'Standing Quad & Hamstring Stretch',
        targetArea: 'Lower Body Flexors',
        durationSeconds: 60,
        instructions: 'Hold ankle behind for quad stretch 30s each, then heel forward for hamstring.',
        breathingGuidance: 'Deep, slow diaphragmatic nasal breathing.',
      ),
      WarmupCooldownItem(
        name: 'Doorway Chest & Lats Extension',
        targetArea: 'Upper Body Release',
        durationSeconds: 60,
        instructions: 'Gentle static chest stretch in doorway or against wall.',
        breathingGuidance: 'Exhale deeply into each 30s static hold.',
      ),
    ];
  }
}
