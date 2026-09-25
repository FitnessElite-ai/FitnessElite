import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/persistence_providers.dart';
import '../../ai_coach/models/complete_fitness_profile.dart';
import '../../ai_coach/providers/ai_coach_provider.dart';
import '../models/vision_assessment.dart';
import '../models/vision_photo.dart';
import '../repositories/vision_assessment_repository.dart';
import '../services/mock_vision_assessment_service.dart';
import '../services/vision_assessment_service.dart';

final visionAssessmentServiceProvider = Provider<VisionAssessmentService>((ref) {
  return MockVisionAssessmentService();
});

final visionAssessmentRepositoryProvider =
    Provider<VisionAssessmentRepository>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return LocalVisionAssessmentRepository(storage);
});

class VisionAssessmentState {
  final VisionPhoto? frontPhoto;
  final VisionPhoto? sidePhoto;
  final VisionPhoto? backPhoto;
  final bool isAnalyzing;
  final String analysisStage;
  final VisionAssessment? completedAssessment;
  final bool isSkipped;
  final String? errorMessage;

  const VisionAssessmentState({
    this.frontPhoto,
    this.sidePhoto,
    this.backPhoto,
    this.isAnalyzing = false,
    this.analysisStage = '',
    this.completedAssessment,
    this.isSkipped = false,
    this.errorMessage,
  });

  VisionAssessmentState copyWith({
    VisionPhoto? frontPhoto,
    VisionPhoto? sidePhoto,
    VisionPhoto? backPhoto,
    bool? isAnalyzing,
    String? analysisStage,
    VisionAssessment? completedAssessment,
    bool? isSkipped,
    String? errorMessage,
    bool clearFront = false,
    bool clearSide = false,
    bool clearBack = false,
  }) {
    return VisionAssessmentState(
      frontPhoto: clearFront ? null : (frontPhoto ?? this.frontPhoto),
      sidePhoto: clearSide ? null : (sidePhoto ?? this.sidePhoto),
      backPhoto: clearBack ? null : (backPhoto ?? this.backPhoto),
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      analysisStage: analysisStage ?? this.analysisStage,
      completedAssessment: completedAssessment ?? this.completedAssessment,
      isSkipped: isSkipped ?? this.isSkipped,
      errorMessage: errorMessage,
    );
  }

  bool get hasRequiredFrontPhoto =>
      frontPhoto != null && frontPhoto!.filePath.isNotEmpty;
}

class VisionAssessmentNotifier extends Notifier<VisionAssessmentState> {
  late final VisionAssessmentService _service;
  late final VisionAssessmentRepository _repository;

  @override
  VisionAssessmentState build() {
    _service = ref.watch(visionAssessmentServiceProvider);
    _repository = ref.watch(visionAssessmentRepositoryProvider);

    final existingAssessment = _repository.getVisionAssessment();
    if (existingAssessment != null && existingAssessment.isCompleted) {
      return VisionAssessmentState(
        completedAssessment: existingAssessment,
        frontPhoto: existingAssessment.frontPhoto,
        sidePhoto: existingAssessment.sidePhoto,
        backPhoto: existingAssessment.backPhoto,
      );
    }

    return const VisionAssessmentState();
  }

  void setFrontPhoto(String filePath) {
    state = state.copyWith(
      frontPhoto: VisionPhoto(
        id: 'photo_front_${DateTime.now().millisecondsSinceEpoch}',
        filePath: filePath,
        type: PhotoType.front,
        timestamp: DateTime.now(),
      ),
    );
  }

  void setSidePhoto(String filePath) {
    state = state.copyWith(
      sidePhoto: VisionPhoto(
        id: 'photo_side_${DateTime.now().millisecondsSinceEpoch}',
        filePath: filePath,
        type: PhotoType.side,
        timestamp: DateTime.now(),
      ),
    );
  }

  void setBackPhoto(String filePath) {
    state = state.copyWith(
      backPhoto: VisionPhoto(
        id: 'photo_back_${DateTime.now().millisecondsSinceEpoch}',
        filePath: filePath,
        type: PhotoType.back,
        timestamp: DateTime.now(),
      ),
    );
  }

  void removePhoto(PhotoType type) {
    switch (type) {
      case PhotoType.front:
        state = state.copyWith(clearFront: true);
        break;
      case PhotoType.side:
        state = state.copyWith(clearSide: true);
        break;
      case PhotoType.back:
        state = state.copyWith(clearBack: true);
        break;
    }
  }

  void skipAssessment() {
    state = state.copyWith(
      isSkipped: true,
      completedAssessment: null,
    );
    _repository.clearVisionAssessment();

    // Ensure CompleteFitnessProfile in AICoachRepository has visionAssessment = null
    final aiRepo = ref.read(aiCoachRepositoryProvider);
    final existingComplete = aiRepo.getCompleteFitnessProfile();
    if (existingComplete != null) {
      final updatedComplete = CompleteFitnessProfile(
        healthProfile: existingComplete.healthProfile,
        fitnessPreferences: existingComplete.fitnessPreferences,
        visionAssessment: null,
        completedAt: DateTime.now(),
      );
      aiRepo.saveCompleteFitnessProfile(updatedComplete);
    }
  }

  Future<VisionAssessment?> runAnalysis() async {
    if (!state.hasRequiredFrontPhoto) {
      state = state.copyWith(
        errorMessage: 'Front photo is required for visual analysis.',
      );
      return null;
    }

    state = state.copyWith(
      isAnalyzing: true,
      analysisStage: 'Preparing images',
    );

    await Future.delayed(const Duration(milliseconds: 150));
    state = state.copyWith(analysisStage: 'Analyzing visual patterns');

    final photos = [
      if (state.frontPhoto != null) state.frontPhoto!,
      if (state.sidePhoto != null) state.sidePhoto!,
      if (state.backPhoto != null) state.backPhoto!,
    ];

    final aiRepo = ref.read(aiCoachRepositoryProvider);
    final existingComplete = aiRepo.getCompleteFitnessProfile();

    VisionAssessment assessment;
    if (existingComplete != null) {
      assessment = await _service.analyze(
        photos: photos,
        profile: existingComplete,
      );
    } else {
      assessment = await _service.analyzeAssessment(
        frontPhoto: state.frontPhoto!,
        sidePhoto: state.sidePhoto,
        backPhoto: state.backPhoto,
      );
    }

    state = state.copyWith(analysisStage: 'Building your fitness baseline');
    await Future.delayed(const Duration(milliseconds: 150));

    await _repository.saveVisionAssessment(assessment);

    // Update Complete Fitness Profile in AICoachRepository
    if (existingComplete != null) {
      final updatedComplete = CompleteFitnessProfile(
        healthProfile: existingComplete.healthProfile,
        fitnessPreferences: existingComplete.fitnessPreferences,
        visionAssessment: assessment,
        completedAt: DateTime.now(),
      );
      await aiRepo.saveCompleteFitnessProfile(updatedComplete);
    }

    state = state.copyWith(
      isAnalyzing: false,
      completedAssessment: assessment,
    );

    return assessment;
  }
}

final visionAssessmentNotifierProvider = NotifierProvider<
    VisionAssessmentNotifier, VisionAssessmentState>(
  VisionAssessmentNotifier.new,
);
