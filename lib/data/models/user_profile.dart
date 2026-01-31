/// User profile model – ข้อมูลผู้ใช้.
class UserProfile {
  const UserProfile({
    required this.id,
    this.email,
    this.displayName,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String? email;
  final String? displayName;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String?,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
