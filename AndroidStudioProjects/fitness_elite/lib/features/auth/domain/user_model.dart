import 'dart:convert';

/// Domain model representing an authenticated FitnessElite.ai user.
class AuthUser {
  final String id;
  final String email;
  final String fullName;
  final bool isEmailVerified;
  final DateTime createdAt;

  const AuthUser({
    required this.id,
    required this.email,
    required this.fullName,
    this.isEmailVerified = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'isEmailVerified': isEmailVerified,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AuthUser.fromMap(Map<String, dynamic> map) {
    return AuthUser(
      id: map['id'] as String? ?? '',
      email: map['email'] as String? ?? '',
      fullName: map['fullName'] as String? ?? '',
      isEmailVerified: map['isEmailVerified'] as bool? ?? true,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory AuthUser.fromJson(String source) =>
      AuthUser.fromMap(json.decode(source) as Map<String, dynamic>);
}
