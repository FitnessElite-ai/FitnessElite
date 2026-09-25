import '../models/exercise.dart';

/// Comprehensive local exercise catalog containing exercise-specific setup, execution,
/// breathing pattern, form cues, common mistakes, safety notes, and variations.
class ExerciseLibrary {
  static const List<Exercise> catalog = [
    // --- CHEST ---
    Exercise(
      id: 'chest_pushup',
      name: 'Push-ups',
      muscleGroup: 'Chest',
      targetMuscles: ['Pectoralis Major', 'Anterior Deltoids', 'Triceps Brachii', 'Core'],
      equipmentRequirement: 'Bodyweight',
      difficulty: 'Beginner',
      sets: 3,
      reps: '10-15',
      durationSeconds: 0,
      restSeconds: 60,
      tempo: '2-0-1-0',
      setupInstructions: 'Place hands slightly wider than shoulder-width, extend legs back in a rigid plank with core engaged.',
      executionSteps: [
        'Lower chest toward the floor by bending elbows at a 45-degree angle.',
        'Pause briefly 1 inch above floor level.',
        'Press through palms to return to the top extended plank position.'
      ],
      breathingPattern: 'Inhale while lowering. Exhale while pushing upward.',
      inhaleInstruction: 'Inhale deeply through nose as you bend elbows and lower your body.',
      exhaleInstruction: 'Exhale forcefully through mouth as you press upward away from floor.',
      formCues: ['Keep glutes squeezed and spine neutral.', 'Prevent hips from sagging.', 'Keep elbows angled back, not flared outward.'],
      commonMistakes: ['Sagging lower back', 'Flaring elbows out at 90 degrees', 'Incomplete range of motion'],
      safetyNotes: 'Maintain wrist alignment. Stop if sharp shoulder pain occurs.',
      easierVariation: 'Incline Push-ups / Knee Push-ups',
      harderVariation: 'Decline Push-ups / Diamond Push-ups',
    ),
    Exercise(
      id: 'chest_db_bench',
      name: 'Dumbbell Bench Press',
      muscleGroup: 'Chest',
      targetMuscles: ['Pectoralis Major', 'Triceps', 'Front Deltoids'],
      equipmentRequirement: 'Dumbbells',
      difficulty: 'Intermediate',
      sets: 3,
      reps: '8-12',
      durationSeconds: 0,
      restSeconds: 90,
      tempo: '3-0-1-0',
      setupInstructions: 'Sit on bench edge with dumbbells resting on thighs, lie back while bringing weights over mid-chest.',
      executionSteps: [
        'Lower dumbbells smoothly to the sides of lower chest with elbows at 45 degrees.',
        'Press dumbbells back up until arms are extended above sternum without clacking weights.'
      ],
      breathingPattern: 'Inhale while lowering. Exhale while pressing upward.',
      inhaleInstruction: 'Inhale as you lower dumbbells toward chest level.',
      exhaleInstruction: 'Exhale as you press weights upward overhead.',
      formCues: ['Plant feet firmly on floor.', 'Keep shoulder blades retracted into bench.', 'Maintain slight arch in lower back.'],
      commonMistakes: ['Bouncing weights off chest', 'Arching lower back excessively', 'Flaring elbows'],
      safetyNotes: 'Use a spotter or lower weights safely to floor if fatigued.',
      easierVariation: 'Floor Dumbbell Press',
      harderVariation: 'Incline Dumbbell Press',
    ),
    Exercise(
      id: 'chest_barbell_press',
      name: 'Barbell Bench Press',
      muscleGroup: 'Chest',
      targetMuscles: ['Pectoralis Major', 'Triceps Brachii', 'Anterior Deltoid'],
      equipmentRequirement: 'Full Gym',
      difficulty: 'Intermediate',
      sets: 4,
      reps: '6-10',
      durationSeconds: 0,
      restSeconds: 90,
      tempo: '2-1-1-0',
      setupInstructions: 'Lie flat under rack, grip bar slightly wider than shoulder-width, unrack with locked arms over chest.',
      executionSteps: [
        'Lower bar under control until it lightly touches lower sternum.',
        'Drive bar vertically upward until elbows reach lockout.'
      ],
      breathingPattern: 'Inhale while lowering. Exhale while pressing upward.',
      inhaleInstruction: 'Take a deep breath and lower bar under full control.',
      exhaleInstruction: 'Exhale powerfully past the sticking point near the top.',
      formCues: ['Drive feet into floor.', 'Keep wrists stacked straight above elbows.', 'Squeeze bar tight.'],
      commonMistakes: ['Lifting hips off bench', 'Heaving bar off chest', 'Wrists bending backward'],
      safetyNotes: 'Always use safety collars and a spotter for heavy loads.',
      easierVariation: 'Dumbbell Bench Press',
      harderVariation: 'Pause Bench Press',
    ),

    // --- BACK ---
    Exercise(
      id: 'back_doorway_row',
      name: 'Bodyweight Inverted Rows',
      muscleGroup: 'Back',
      targetMuscles: ['Latissimus Dorsi', 'Rhomboids', 'Rear Deltoids', 'Biceps'],
      equipmentRequirement: 'Bodyweight',
      difficulty: 'Beginner',
      sets: 3,
      reps: '10-12',
      durationSeconds: 0,
      restSeconds: 60,
      tempo: '2-0-1-1',
      setupInstructions: 'Position under sturdy bar or strap handles with body straight and heels planted on floor.',
      executionSteps: [
        'Pull chest toward handles by retracting shoulder blades and flexing elbows.',
        'Pause for 1 second at top contraction.',
        'Lower body back down with fully extended arms.'
      ],
      breathingPattern: 'Inhale while lowering. Exhale while pulling upward.',
      inhaleInstruction: 'Inhale as you lower your body away from handles.',
      exhaleInstruction: 'Exhale as you pull your chest up to the handles.',
      formCues: ['Maintain straight line from shoulders to ankles.', 'Squeeze shoulder blades together.'],
      commonMistakes: ['Hipping up or sagging waist', 'Pulling with arms only without back contraction'],
      safetyNotes: 'Ensure handles or doorframe anchoring is 100% secure before pulling bodyweight.',
      easierVariation: 'Doorframe Standing Row',
      harderVariation: 'Feet-Elevated Inverted Row',
    ),
    Exercise(
      id: 'back_db_row',
      name: 'Single-Arm Dumbbell Row',
      muscleGroup: 'Back',
      targetMuscles: ['Latissimus Dorsi', 'Rhomboids', 'Brachialis'],
      equipmentRequirement: 'Dumbbells',
      difficulty: 'Beginner',
      sets: 3,
      reps: '10-12',
      durationSeconds: 0,
      restSeconds: 60,
      tempo: '2-0-1-0',
      setupInstructions: 'Place left knee and left hand on bench, flat torso parallel to floor, holding dumbbell in right hand.',
      executionSteps: [
        'Row dumbbell toward hip crease, driving elbow backward.',
        'Squeeze back muscle at top.',
        'Lower dumbbell under control to full arm stretch.'
      ],
      breathingPattern: 'Inhale while lowering. Exhale while rowing upward.',
      inhaleInstruction: 'Inhale as dumbbell lowers toward floor.',
      exhaleInstruction: 'Exhale as you pull dumbbell toward hip.',
      formCues: ['Keep spine flat and head neutral.', 'Do not rotate torso at top.'],
      commonMistakes: ['Yanking weight with momentum', 'Rounding lower back'],
      safetyNotes: 'Maintain stable 3-point contact base on bench and floor.',
      easierVariation: 'Light Dumbbell Row',
      harderVariation: 'Kettlebell Gorilla Row',
    ),

    // --- SHOULDERS ---
    Exercise(
      id: 'shoulders_pike_pushup',
      name: 'Pike Push-ups',
      muscleGroup: 'Shoulders',
      targetMuscles: ['Anterior Deltoid', 'Triceps', 'Upper Pectoralis'],
      equipmentRequirement: 'Bodyweight',
      difficulty: 'Intermediate',
      sets: 3,
      reps: '8-12',
      durationSeconds: 0,
      restSeconds: 60,
      tempo: '2-0-1-0',
      setupInstructions: 'From push-up position, walk feet forward and lift hips into an inverted V shape.',
      executionSteps: [
        'Bend elbows to lower crown of head forward toward floor between hands.',
        'Press through palms diagonally backward to return to pike position.'
      ],
      breathingPattern: 'Inhale while lowering. Exhale while pushing upward.',
      inhaleInstruction: 'Inhale as head descends toward floor.',
      exhaleInstruction: 'Exhale as you push through palms back into inverted V.',
      formCues: ['Look toward knees or feet.', 'Keep hips elevated throughout.'],
      commonMistakes: ['Flaring elbows out sideways', 'Allowing hips to drop into plank'],
      safetyNotes: 'Place yoga mat under head for head protection if needed.',
      easierVariation: 'Incline Pike Push-up',
      harderVariation: 'Elevated Feet Pike Push-up / Handstand Push-up',
    ),
    Exercise(
      id: 'shoulders_db_press',
      name: 'Seated Dumbbell Overhead Press',
      muscleGroup: 'Shoulders',
      targetMuscles: ['Anterior Deltoids', 'Lateral Deltoids', 'Triceps'],
      equipmentRequirement: 'Dumbbells',
      difficulty: 'Beginner',
      sets: 3,
      reps: '10-12',
      durationSeconds: 0,
      restSeconds: 60,
      tempo: '2-0-1-0',
      setupInstructions: 'Sit tall on bench, hold dumbbells at shoulder height with palms facing forward.',
      executionSteps: [
        'Press dumbbells overhead until arms are nearly straight.',
        'Lower weights back to shoulder height under control.'
      ],
      breathingPattern: 'Inhale while lowering. Exhale while pressing upward.',
      inhaleInstruction: 'Inhale as dumbbells lower back to ear height.',
      exhaleInstruction: 'Exhale as you press weights upward overhead.',
      formCues: ['Keep core braced.', 'Avoid leaning back excessively.'],
      commonMistakes: ['Arching back excessively', 'Bouncing weights at bottom'],
      safetyNotes: 'Press smoothly without locking elbows harshly.',
      easierVariation: 'Arnold Press',
      harderVariation: 'Standing Overhead Barbell Press',
    ),

    // --- LEGS & GLUTES ---
    Exercise(
      id: 'legs_bodyweight_squat',
      name: 'Bodyweight Air Squats',
      muscleGroup: 'Legs',
      targetMuscles: ['Quadriceps', 'Gluteus Maximus', 'Hamstrings', 'Calves'],
      equipmentRequirement: 'Bodyweight',
      difficulty: 'Beginner',
      sets: 3,
      reps: '15-20',
      durationSeconds: 0,
      restSeconds: 45,
      tempo: '2-1-1-0',
      setupInstructions: 'Stand with feet shoulder-width apart, toes pointed slightly outward (10-15 degrees), arms held out for balance.',
      executionSteps: [
        'Hinge hips back and bend knees to lower thighs until parallel with floor or lower.',
        'Drive through heels and mid-foot to return to full standing stance.'
      ],
      breathingPattern: 'Inhale while lowering. Exhale while standing.',
      inhaleInstruction: 'Inhale deeply into abdomen as you squat down.',
      exhaleInstruction: 'Exhale as you drive through heels to stand back up.',
      formCues: ['Keep chest up and spine neutral.', 'Track knees over toes without caving inward.', 'Keep heels flat on floor.'],
      commonMistakes: ['Knees caving inward (valgus collapse)', 'Heels lifting off ground', 'Rounding lower back at bottom'],
      safetyNotes: 'Keep knees tracking in line with second toes. Do not collapse chest forward.',
      easierVariation: 'Box / Chair Squats',
      harderVariation: 'Goblet Squat / Jump Squats',
    ),
    Exercise(
      id: 'legs_goblet_squat',
      name: 'Dumbbell Goblet Squat',
      muscleGroup: 'Legs',
      targetMuscles: ['Quadriceps', 'Glutes', 'Core', 'Erector Spinae'],
      equipmentRequirement: 'Dumbbells',
      difficulty: 'Beginner',
      sets: 3,
      reps: '10-12',
      durationSeconds: 0,
      restSeconds: 60,
      tempo: '3-1-1-0',
      setupInstructions: 'Cupping top head of dumbbell vertically against chest, stand with shoulder-width stance.',
      executionSteps: [
        'Lower into deep squat with elbows staying inside knees.',
        'Drive upward smoothly through full foot.'
      ],
      breathingPattern: 'Inhale while lowering. Exhale while standing.',
      inhaleInstruction: 'Inhale as hips lower into squat.',
      exhaleInstruction: 'Exhale while pressing back to upright standing posture.',
      formCues: ['Hold dumbbell close to sternum.', 'Elbows brush inner thighs at bottom.'],
      commonMistakes: ['Letting weight pull upper body forward', 'Heels coming up'],
      safetyNotes: 'Maintain upright torso. If balance fails, drop dumbbell forward safely.',
      easierVariation: 'Bodyweight Air Squats',
      harderVariation: 'Barbell Back Squat',
    ),
    Exercise(
      id: 'glutes_glute_bridge',
      name: 'Glute Bridges',
      muscleGroup: 'Glutes',
      targetMuscles: ['Gluteus Maximus', 'Hamstrings', 'Core'],
      equipmentRequirement: 'Bodyweight',
      difficulty: 'Beginner',
      sets: 3,
      reps: '15-20',
      durationSeconds: 0,
      restSeconds: 45,
      tempo: '2-1-1-0',
      setupInstructions: 'Lie flat on back, knees bent, feet hip-width apart flat on floor near glutes.',
      executionSteps: [
        'Drive heels into floor to lift hips until thighs and torso form a straight line.',
        'Squeeze glutes hard for 1-2 seconds at peak elevation.',
        'Lower hips slowly back to ground.'
      ],
      breathingPattern: 'Inhale while lowering. Exhale while lifting hips.',
      inhaleInstruction: 'Inhale as hips lower to floor.',
      exhaleInstruction: 'Exhale as you squeeze glutes and drive hips upward.',
      formCues: ['Drive through heels.', 'Do not arch lower back excessively.'],
      commonMistakes: ['Overextending lumbar spine', 'Pushing from toes instead of heels'],
      safetyNotes: 'Focus contraction on glutes rather than lumbar spine.',
      easierVariation: 'Bodyweight Glute Bridge',
      harderVariation: 'Single-Leg Glute Bridge / Barbell Hip Thrust',
    ),

    // --- ARMS ---
    Exercise(
      id: 'arms_tricep_dips',
      name: 'Bench / Chair Dips',
      muscleGroup: 'Arms',
      targetMuscles: ['Triceps Brachii', 'Anterior Deltoid'],
      equipmentRequirement: 'Bodyweight',
      difficulty: 'Beginner',
      sets: 3,
      reps: '12-15',
      durationSeconds: 0,
      restSeconds: 60,
      tempo: '2-0-1-0',
      setupInstructions: 'Sit on sturdy bench, place hands next to hips, slide glutes off edge with knees bent or extended.',
      executionSteps: [
        'Lower hips toward floor by bending elbows to 90 degrees.',
        'Press upward through palms to lock out arms.'
      ],
      breathingPattern: 'Inhale while lowering. Exhale while pressing upward.',
      inhaleInstruction: 'Inhale as hips descend.',
      exhaleInstruction: 'Exhale as you straighten elbows to top position.',
      formCues: ['Keep back close to bench.', 'Do not dip below 90 degrees elbow flexion.'],
      commonMistakes: ['Shrugging shoulders up to ears', 'Flaring elbows outward'],
      safetyNotes: 'Keep shoulders retracted. Avoid dipping too deep if shoulder joint clicks.',
      easierVariation: 'Bent-Knee Bench Dips',
      harderVariation: 'Parallel Bar Dips',
    ),
    Exercise(
      id: 'arms_bicep_curls',
      name: 'Dumbbell Bicep Curls',
      muscleGroup: 'Arms',
      targetMuscles: ['Biceps Brachii', 'Brachialis'],
      equipmentRequirement: 'Dumbbells',
      difficulty: 'Beginner',
      sets: 3,
      reps: '12-15',
      durationSeconds: 0,
      restSeconds: 45,
      tempo: '2-0-1-0',
      setupInstructions: 'Stand tall holding dumbbells at sides, palms facing forward, elbows pinned near ribcage.',
      executionSteps: [
        'Curl dumbbells upward toward shoulders while keeping upper arms motionless.',
        'Lower dumbbells back down under control to full extension.'
      ],
      breathingPattern: 'Inhale while lowering. Exhale while curling.',
      inhaleInstruction: 'Inhale as dumbbells lower back to sides.',
      exhaleInstruction: 'Exhale as you curl dumbbells upward toward shoulders.',
      formCues: ['Keep elbows glued to ribcage.', 'Avoid swinging hips for momentum.'],
      commonMistakes: ['Swinging torso', 'Lifting elbows forward'],
      safetyNotes: 'Select weight that allows smooth, strict elbow flexion.',
      easierVariation: 'Alternating Bicep Curls',
      harderVariation: 'Hammer Curls / Incline Bicep Curls',
    ),

    // --- CORE ---
    Exercise(
      id: 'core_plank',
      name: 'Forearm Plank',
      muscleGroup: 'Core',
      targetMuscles: ['Rectus Abdominis', 'Transverse Abdominis', 'Glutes'],
      equipmentRequirement: 'Bodyweight',
      difficulty: 'Beginner',
      sets: 3,
      reps: '45-60 sec',
      durationSeconds: 60,
      restSeconds: 45,
      tempo: 'Static Hold',
      setupInstructions: 'Lie face down, prop up on forearms with elbows under shoulders, toes tucked on floor.',
      executionSteps: [
        'Lift knees and hips off floor to form a straight line from head to heels.',
        'Maintain isometric core tension throughout prescribed time.'
      ],
      breathingPattern: 'Maintain controlled, continuous rhythmic breathing without holding breath.',
      inhaleInstruction: 'Inhale steadily through nose while keeping core tight.',
      exhaleInstruction: 'Exhale slowly through mouth without losing abdominal bracing.',
      formCues: ['Squeeze glutes and abs.', 'Keep neck neutral looking at hands.'],
      commonMistakes: ['Sagging lower back', 'Piking hips up high', 'Holding breath'],
      safetyNotes: 'If lower back aches, drop knees to mat immediately.',
      easierVariation: 'Knee Forearm Plank',
      harderVariation: 'Plank with Shoulder Taps / Weighted Plank',
    ),
    Exercise(
      id: 'core_deadbug',
      name: 'Dead Bug',
      muscleGroup: 'Core',
      targetMuscles: ['Transverse Abdominis', 'Obliques', 'Hip Flexors'],
      equipmentRequirement: 'Bodyweight',
      difficulty: 'Beginner',
      sets: 3,
      reps: '12 each side',
      durationSeconds: 0,
      restSeconds: 45,
      tempo: '2-1-2-0',
      setupInstructions: 'Lie on back, arms pointing to ceiling, knees bent at 90 degrees directly above hips.',
      executionSteps: [
        'Slowly lower right arm overhead while extending left leg out straight near floor.',
        'Return to starting 90-degree position and repeat opposite arm and leg.'
      ],
      breathingPattern: 'Inhale to prepare. Exhale as arm and leg extend outward.',
      inhaleInstruction: 'Inhale as extended limb returns back to start.',
      exhaleInstruction: 'Exhale as opposite arm and leg extend toward floor.',
      formCues: ['Keep lower back glued flat to floor.', 'Move limbs with slow control.'],
      commonMistakes: ['Arching lower back off floor', 'Moving too fast'],
      safetyNotes: 'Focus on pressing lumbar spine into floor throughout movement.',
      easierVariation: 'Dead Bug (Legs Only)',
      harderVariation: 'Band-Resisted Dead Bug',
    ),

    // --- CARDIO & FULL BODY ---
    Exercise(
      id: 'cardio_jumping_jacks',
      name: 'Jumping Jacks & Mountain Climbers',
      muscleGroup: 'Full Body',
      targetMuscles: ['Full Body', 'Cardiovascular System'],
      equipmentRequirement: 'Bodyweight',
      difficulty: 'Beginner',
      sets: 3,
      reps: '45 sec',
      durationSeconds: 45,
      restSeconds: 30,
      tempo: 'Rhythmic Cardio',
      setupInstructions: 'Stand tall with feet together and hands at sides.',
      executionSteps: [
        'Jump feet outward while sweeping arms overhead.',
        'Jump back to starting stance in rhythmic cadence.'
      ],
      breathingPattern: 'Use natural, steady rhythmic breathing matched to jump cadence.',
      inhaleInstruction: 'Inhale rhythmically through nose every 2-3 jumps.',
      exhaleInstruction: 'Exhale steadily through mouth.',
      formCues: ['Land softly on balls of feet.', 'Maintain soft bend in knees.'],
      commonMistakes: ['Landing hard on heels', 'Holding breath'],
      safetyNotes: 'Wear supportive shoes. Step side-to-side for low impact.',
      easierVariation: 'Step Jacks (Low Impact)',
      harderVariation: 'Burpees / High Knees',
    ),

    // --- MOBILITY & POSTURE ---
    Exercise(
      id: 'mobility_cat_cow',
      name: 'Cat-Cow Stretch & Thoracic Mobility',
      muscleGroup: 'Mobility',
      targetMuscles: ['Erector Spinae', 'Thoracic Spine', 'Core'],
      equipmentRequirement: 'Bodyweight',
      difficulty: 'Beginner',
      sets: 2,
      reps: '10-12 reps',
      durationSeconds: 0,
      restSeconds: 30,
      tempo: '3-1-3-1',
      setupInstructions: 'Begin on hands and knees (quadruped) with wrists under shoulders and knees under hips.',
      executionSteps: [
        'Inhale into Cow pose: drop belly toward floor, lift chest and tailbone.',
        'Exhale into Cat pose: arch back upward toward ceiling, tuck chin to chest.'
      ],
      breathingPattern: 'Inhale to arch into Cow. Exhale to round into Cat.',
      inhaleInstruction: 'Inhale smoothly as chest lifts and belly lowers.',
      exhaleInstruction: 'Exhale deeply as spine arches upward toward ceiling.',
      formCues: ['Move fluidly through each segment of spine.', 'Avoid forcing neck range.'],
      commonMistakes: ['Rushing through movement', 'Bending elbows'],
      safetyNotes: 'Keep movement painless and smooth.',
      easierVariation: 'Seated Cat-Cow',
      harderVariation: 'Thread the Needle Thoracic Twist',
    ),
  ];

  static List<Exercise> filterExercises({
    required String equipmentPreference,
    required String experienceLevel,
    String? preferredMuscleGroup,
  }) {
    return catalog.where((e) {
      bool matchesEquipment = true;
      final eq = equipmentPreference.toLowerCase();

      if (eq.contains('bodyweight') || eq.contains('home')) {
        matchesEquipment = e.equipmentRequirement == 'Bodyweight' || e.equipmentRequirement == 'Dumbbells';
      } else if (eq.contains('dumbbell')) {
        matchesEquipment = e.equipmentRequirement == 'Bodyweight' || e.equipmentRequirement == 'Dumbbells';
      }

      bool matchesMuscle = true;
      if (preferredMuscleGroup != null && preferredMuscleGroup.isNotEmpty) {
        matchesMuscle = e.muscleGroup.toLowerCase() == preferredMuscleGroup.toLowerCase();
      }

      return matchesEquipment && matchesMuscle;
    }).toList();
  }

  /// Select exercise alternative / substitution based on equipment or difficulty
  static Exercise? getAlternative(Exercise original, {String? targetDifficulty, String? targetEquipment}) {
    final matches = catalog.where((e) {
      if (e.id == original.id) return false;
      return e.muscleGroup == original.muscleGroup;
    }).toList();

    if (matches.isEmpty) return null;

    if (targetEquipment != null && targetEquipment.isNotEmpty) {
      final eqMatch = matches.where((e) => e.equipmentRequirement.toLowerCase() == targetEquipment.toLowerCase()).firstOrNull;
      if (eqMatch != null) return eqMatch;
    }

    if (targetDifficulty != null && targetDifficulty.isNotEmpty) {
      final diffMatch = matches.where((e) => e.difficulty.toLowerCase() == targetDifficulty.toLowerCase()).firstOrNull;
      if (diffMatch != null) return diffMatch;
    }

    return matches.first;
  }
}
