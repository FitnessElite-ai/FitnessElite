import '../../ai_coach/models/complete_fitness_profile.dart';
import '../models/vision_assessment.dart';
import '../models/vision_photo.dart';

/// Abstract service interface for Vision AI photo analysis.
/// Decoupled so a production computer-vision API/model can replace MockVisionAssessmentService.
abstract class VisionAssessmentService {
  Future<VisionAssessment> analyze({
    required List<VisionPhoto> photos,
    required CompleteFitnessProfile profile,
  });

  Future<VisionAssessment> analyzeAssessment({
    required VisionPhoto frontPhoto,
    VisionPhoto? sidePhoto,
    VisionPhoto? backPhoto,
  });
}
