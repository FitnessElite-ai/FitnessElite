import 'dart:convert';

/// Comprehensive Exercise model containing detailed biometric, form, breathing, and safety coaching parameters.
class Exercise {
  final String id;
  final String name;
  final String muscleGroup;
  final List<String> targetMuscles;
  final String equipmentRequirement;
  final String difficulty;
  final int sets;
  final String reps;
  final int durationSeconds;
  final int restSeconds;
  final String tempo;
  final String setupInstructions;
  final List<String> executionSteps;
  final String breathingPattern;
  final String inhaleInstruction;
  final String exhaleInstruction;
  final List<String> formCues;
  final List<String> commonMistakes;
  final String safetyNotes;
  final String easierVariation;
  final String harderVariation;

  const Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    this.targetMuscles = const [],
    required this.equipmentRequirement,
    required this.difficulty,
    required this.sets,
    required this.reps,
    this.durationSeconds = 0,
    required this.restSeconds,
    this.tempo = '2-0-2-0',
    required this.setupInstructions,
    this.executionSteps = const [],
    required this.breathingPattern,
    required this.inhaleInstruction,
    required this.exhaleInstruction,
    this.formCues = const [],
    this.commonMistakes = const [],
    required this.safetyNotes,
    this.easierVariation = '',
    this.harderVariation = '',
  });

  String get equipment => equipmentRequirement;

  Exercise copyWith({
    String? id,
    String? name,
    String? muscleGroup,
    List<String>? targetMuscles,
    String? equipmentRequirement,
    String? difficulty,
    int? sets,
    String? reps,
    int? durationSeconds,
    int? restSeconds,
    String? tempo,
    String? setupInstructions,
    List<String>? executionSteps,
    String? breathingPattern,
    String? inhaleInstruction,
    String? exhaleInstruction,
    List<String>? formCues,
    List<String>? commonMistakes,
    String? safetyNotes,
    String? easierVariation,
    String? harderVariation,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      targetMuscles: targetMuscles ?? this.targetMuscles,
      equipmentRequirement: equipmentRequirement ?? this.equipmentRequirement,
      difficulty: difficulty ?? this.difficulty,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      restSeconds: restSeconds ?? this.restSeconds,
      tempo: tempo ?? this.tempo,
      setupInstructions: setupInstructions ?? this.setupInstructions,
      executionSteps: executionSteps ?? this.executionSteps,
      breathingPattern: breathingPattern ?? this.breathingPattern,
      inhaleInstruction: inhaleInstruction ?? this.inhaleInstruction,
      exhaleInstruction: exhaleInstruction ?? this.exhaleInstruction,
      formCues: formCues ?? this.formCues,
      commonMistakes: commonMistakes ?? this.commonMistakes,
      safetyNotes: safetyNotes ?? this.safetyNotes,
      easierVariation: easierVariation ?? this.easierVariation,
      harderVariation: harderVariation ?? this.harderVariation,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'muscleGroup': muscleGroup,
      'targetMuscles': targetMuscles,
      'equipmentRequirement': equipmentRequirement,
      'equipment': equipmentRequirement,
      'difficulty': difficulty,
      'sets': sets,
      'reps': reps,
      'durationSeconds': durationSeconds,
      'restSeconds': restSeconds,
      'tempo': tempo,
      'setupInstructions': setupInstructions,
      'executionSteps': executionSteps,
      'breathingPattern': breathingPattern,
      'inhaleInstruction': inhaleInstruction,
      'exhaleInstruction': exhaleInstruction,
      'formCues': formCues,
      'commonMistakes': commonMistakes,
      'safetyNotes': safetyNotes,
      'easierVariation': easierVariation,
      'harderVariation': harderVariation,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? 'Exercise',
      muscleGroup: map['muscleGroup'] as String? ?? 'Full Body',
      targetMuscles: (map['targetMuscles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      equipmentRequirement: (map['equipmentRequirement'] as String?) ??
          (map['equipment'] as String?) ??
          'Bodyweight',
      difficulty: map['difficulty'] as String? ?? 'Beginner',
      sets: (map['sets'] as num?)?.toInt() ?? 3,
      reps: map['reps'] as String? ?? '10-12',
      durationSeconds: (map['durationSeconds'] as num?)?.toInt() ?? 0,
      restSeconds: (map['restSeconds'] as num?)?.toInt() ?? 60,
      tempo: map['tempo'] as String? ?? '2-0-2-0',
      setupInstructions: map['setupInstructions'] as String? ?? '',
      executionSteps: (map['executionSteps'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      breathingPattern: map['breathingPattern'] as String? ??
          'Controlled rhythmic breathing.',
      inhaleInstruction:
          map['inhaleInstruction'] as String? ?? 'Inhale during lowering.',
      exhaleInstruction:
          map['exhaleInstruction'] as String? ?? 'Exhale during press.',
      formCues: (map['formCues'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      commonMistakes: (map['commonMistakes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      safetyNotes: map['safetyNotes'] as String? ?? 'Maintain a neutral spine.',
      easierVariation: map['easierVariation'] as String? ?? '',
      harderVariation: map['harderVariation'] as String? ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Exercise.fromJson(String source) =>
      Exercise.fromMap(json.decode(source) as Map<String, dynamic>);
}
