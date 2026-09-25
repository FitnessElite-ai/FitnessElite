import '../../../core/services/local_storage_service.dart';
import '../models/vision_assessment.dart';

abstract class VisionAssessmentRepository {
  VisionAssessment? getVisionAssessment();
  Future<bool> saveVisionAssessment(VisionAssessment assessment);
  Future<bool> clearVisionAssessment();
  bool isVisionAssessmentCompleted();
}

class LocalVisionAssessmentRepository implements VisionAssessmentRepository {
  static const String _keyVisionAssessmentData = 'fe_vision_assessment_data';
  static const String _keyVisionCompleted = 'fe_vision_assessment_completed';

  final LocalStorageService _storage;

  LocalVisionAssessmentRepository(this._storage);

  @override
  VisionAssessment? getVisionAssessment() {
    final data = _storage.getString(_keyVisionAssessmentData);
    if (data != null && data.isNotEmpty) {
      try {
        return VisionAssessment.fromJson(data);
      } catch (_) {}
    }
    return null;
  }

  @override
  Future<bool> saveVisionAssessment(VisionAssessment assessment) async {
    await _storage.setString(_keyVisionAssessmentData, assessment.toJson());
    return await _storage.setString(_keyVisionCompleted, 'true');
  }

  @override
  Future<bool> clearVisionAssessment() async {
    await _storage.remove(_keyVisionAssessmentData);
    return await _storage.remove(_keyVisionCompleted);
  }

  @override
  bool isVisionAssessmentCompleted() {
    return _storage.getString(_keyVisionCompleted) == 'true';
  }
}
