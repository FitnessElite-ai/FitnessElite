import 'dart:convert';
import 'vision_insight.dart';
import 'vision_photo.dart';

/// Aggregated domain model for the entire Vision AI Assessment.
class VisionAssessment {
  final String id;
  final VisionPhoto? frontPhoto;
  final VisionPhoto? sidePhoto;
  final VisionPhoto? backPhoto;
  final bool isCompleted;
  final List<VisionInsight> insights;
  final DateTime timestamp;

  const VisionAssessment({
    required this.id,
    this.frontPhoto,
    this.sidePhoto,
    this.backPhoto,
    this.isCompleted = false,
    this.insights = const [],
    required this.timestamp,
  });

  bool get completed => isCompleted;
  DateTime get createdAt => timestamp;

  List<VisionPhoto> get photos => [
        ?frontPhoto,
        ?sidePhoto,
        ?backPhoto,
      ];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'frontPhoto': frontPhoto?.toMap(),
      'sidePhoto': sidePhoto?.toMap(),
      'backPhoto': backPhoto?.toMap(),
      'isCompleted': isCompleted,
      'completed': isCompleted,
      'insights': insights.map((e) => e.toMap()).toList(),
      'timestamp': timestamp.toIso8601String(),
      'createdAt': timestamp.toIso8601String(),
    };
  }

  factory VisionAssessment.fromMap(Map<String, dynamic> map) {
    final timeStr = (map['createdAt'] as String?) ?? (map['timestamp'] as String?);
    return VisionAssessment(
      id: map['id'] as String? ?? '',
      frontPhoto: map['frontPhoto'] != null
          ? VisionPhoto.fromMap(map['frontPhoto'] as Map<String, dynamic>)
          : null,
      sidePhoto: map['sidePhoto'] != null
          ? VisionPhoto.fromMap(map['sidePhoto'] as Map<String, dynamic>)
          : null,
      backPhoto: map['backPhoto'] != null
          ? VisionPhoto.fromMap(map['backPhoto'] as Map<String, dynamic>)
          : null,
      isCompleted: (map['completed'] as bool?) ?? (map['isCompleted'] as bool?) ?? false,
      insights: (map['insights'] as List<dynamic>?)
              ?.map((e) => VisionInsight.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      timestamp: timeStr != null ? DateTime.parse(timeStr) : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory VisionAssessment.fromJson(String source) =>
      VisionAssessment.fromMap(json.decode(source) as Map<String, dynamic>);
}
