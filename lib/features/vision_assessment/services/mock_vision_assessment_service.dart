import '../../ai_coach/models/complete_fitness_profile.dart';
import '../models/vision_assessment.dart';
import '../models/vision_insight.dart';
import '../models/vision_photo.dart';
import 'vision_assessment_service.dart';

/// Production-ready Mock Vision Assessment Service.
/// Simulates visual AI analysis ("AI Vision Preview") locally without cloud API calls or image uploads.
/// Provides conservative, useful visual baseline insights without fake precise body measurements.
class MockVisionAssessmentService implements VisionAssessmentService {
  @override
  Future<VisionAssessment> analyze({
    required List<VisionPhoto> photos,
    required CompleteFitnessProfile profile,
  }) async {
    VisionPhoto? front = photos.where((p) => p.type == PhotoType.front).firstOrNull;
    if (front == null && photos.isNotEmpty) {
      front = photos.first;
    }
    final side = photos.where((p) => p.type == PhotoType.side).firstOrNull;
    final back = photos.where((p) => p.type == PhotoType.back).firstOrNull;

    front ??= VisionPhoto(
      id: 'photo_demo',
      filePath: '',
      type: PhotoType.front,
      timestamp: DateTime.now(),
    );

    return analyzeAssessment(
      frontPhoto: front,
      sidePhoto: side,
      backPhoto: back,
    );
  }

  @override
  Future<VisionAssessment> analyzeAssessment({
    required VisionPhoto frontPhoto,
    VisionPhoto? sidePhoto,
    VisionPhoto? backPhoto,
  }) async {
    // Simulated processing delay (~300ms)
    await Future.delayed(const Duration(milliseconds: 300));

    final insights = [
      const VisionInsight(
        category: 'POSTURE',
        title: 'Neutral Standing Alignment',
        description:
            'Your assessment can establish a visual baseline for posture and alignment tracking.',
        confidence: ConfidenceLevel.moderate,
        recommendation:
            'Maintain neutral spine posture and core engagement during compound training.',
      ),
      const VisionInsight(
        category: 'BODY BALANCE',
        title: 'Visual Fitness Pattern',
        description:
            'Future assessments can help compare visible changes in overall body balance.',
        confidence: ConfidenceLevel.moderate,
        recommendation:
            'Prioritize balanced push-to-pull volume across your weekly workouts.',
      ),
      const VisionInsight(
        category: 'TRAINING FOCUS',
        title: 'Core & Mobility Focus',
        description:
            'Your plan can prioritize balanced strength, mobility, and consistency based on your profile.',
        confidence: ConfidenceLevel.moderate,
        recommendation:
            'Integrate hip mobility exercises and core stability movements into your routines.',
      ),
      const VisionInsight(
        category: 'PROGRESS BASELINE',
        title: 'Visual Starting Baseline',
        description:
            'This assessment has been saved as your visual starting point for future progress tracking.',
        confidence: ConfidenceLevel.high,
        recommendation:
            'Capture updated comparison photos every 4-6 weeks under similar lighting.',
      ),
    ];

    return VisionAssessment(
      id: 'vis_${DateTime.now().millisecondsSinceEpoch}',
      frontPhoto: frontPhoto,
      sidePhoto: sidePhoto,
      backPhoto: backPhoto,
      isCompleted: true,
      insights: insights,
      timestamp: DateTime.now(),
    );
  }
}
