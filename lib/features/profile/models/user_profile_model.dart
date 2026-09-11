class UserProfileModel {
  final int id;
  final String fullName;
  final String username;
  final String email;
  final String? university;
  final String? bio;
  final String? interests;
  final String? department;
  final String? level;
  final String? profilePicture;
  final bool isOnline;
  final DateTime? lastSeen;
  final DateTime? createdAt;

  const UserProfileModel({
    required this.id,
    required this.fullName,
    required this.username,
    required this.email,
    this.university,
    this.bio,
    this.interests,
    this.department,
    this.level,
    this.profilePicture,
    required this.isOnline,
    this.lastSeen,
    this.createdAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      fullName: json['full_name']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      university: json['university']?.toString(),
      bio: json['bio']?.toString(),
      interests: _parseInterests(json['interests']),
      department: json['department']?.toString(),
      level: json['level']?.toString(),
      profilePicture: json['profile_picture']?.toString(),
      isOnline: json['is_online'] == true,
      lastSeen: _parseDate(json['last_seen']),
      createdAt: _parseDate(json['created_at']),
    );
  }

  static String? _parseInterests(dynamic value) {
    if (value == null) return null;

    if (value is List) {
      return value
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .join(', ');
    }

    final text = value.toString().trim();

    return text.isEmpty ? null : text;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(value.toString());
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'username': username,
      'email': email,
      'university': university,
      'bio': bio,
      'interests': interests,
      'department': department,
      'level': level,
      'profile_picture': profilePicture,
      'is_online': isOnline,
      'last_seen': lastSeen?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }
}