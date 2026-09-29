import 'dart:convert';
import 'yoga_pose.dart';

/// Representation of an active Yoga & Mobility Journey Session.
class YogaSession {
  final String id;
  final String title;
  final String category; // "Morning Mobility", "Recovery Yoga", "Post-Workout Stretch", "Evening Wind-Down"
  final int durationMinutes;
  final List<YogaPose> poses;
  final String guidanceNotes;

  const YogaSession({
    required this.id,
    required this.title,
    required this.category,
    required this.durationMinutes,
    required this.poses,
    required this.guidanceNotes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'durationMinutes': durationMinutes,
      'poses': poses.map((p) => p.toMap()).toList(),
      'guidanceNotes': guidanceNotes,
    };
  }

  factory YogaSession.fromMap(Map<String, dynamic> map) {
    return YogaSession(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? 'Yoga Session',
      category: map['category'] as String? ?? 'Recovery Yoga',
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 10,
      poses: (map['poses'] as List<dynamic>?)
              ?.map((p) => YogaPose.fromMap(p as Map<String, dynamic>))
              .toList() ??
          [],
      guidanceNotes: map['guidanceNotes'] as String? ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory YogaSession.fromJson(String source) =>
      YogaSession.fromMap(json.decode(source) as Map<String, dynamic>);
}
