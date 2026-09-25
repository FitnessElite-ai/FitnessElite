import 'dart:convert';

enum PhotoType { front, side, back }

/// Domain model representing a captured user photo for visual assessment.
class VisionPhoto {
  final String id;
  final String filePath;
  final PhotoType type;
  final DateTime timestamp;

  const VisionPhoto({
    required this.id,
    required this.filePath,
    required this.type,
    required this.timestamp,
  });

  String get localPath => filePath;
  DateTime get createdAt => timestamp;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'filePath': filePath,
      'localPath': filePath,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'createdAt': timestamp.toIso8601String(),
    };
  }

  factory VisionPhoto.fromMap(Map<String, dynamic> map) {
    final path = (map['localPath'] as String?) ?? (map['filePath'] as String?) ?? '';
    final timeStr = (map['createdAt'] as String?) ?? (map['timestamp'] as String?);
    return VisionPhoto(
      id: map['id'] as String? ?? '',
      filePath: path,
      type: PhotoType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => PhotoType.front,
      ),
      timestamp: timeStr != null ? DateTime.parse(timeStr) : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory VisionPhoto.fromJson(String source) =>
      VisionPhoto.fromMap(json.decode(source) as Map<String, dynamic>);
}
