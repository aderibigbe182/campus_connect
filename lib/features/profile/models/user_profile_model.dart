class UserProfileModel {
  final int id;
  final String fullName;
  final String username;
  final String email;
  final String university;
  final String? profilePicture;
  final String? bio;
  final String? interests;
  final String? department;
  final String? level;
  final bool isOnline;
  final DateTime? lastSeen;
  final DateTime? createdAt;

  UserProfileModel({
    required this.id,
    required this.fullName,
    required this.username,
    required this.email,
    required this.university,
    this.profilePicture,
    this.bio,
    this.interests,
    this.department,
    this.level,
    required this.isOnline,
    this.lastSeen,
    this.createdAt,
  });

  factory UserProfileModel.fromJson(
      Map<String, dynamic> json) {
    return UserProfileModel(
      id: json["id"],
      fullName: json["full_name"] ?? "",
      username: json["username"] ?? "",
      email: json["email"] ?? "",
      university: json["university"] ?? "",
      profilePicture: json["profile_picture"],
      bio: json["bio"],
      interests: json["interests"],
      department: json["department"],
      level: json["level"],
      isOnline: json["is_online"] ?? false,
      lastSeen: json["last_seen"] != null
          ? DateTime.parse(json["last_seen"])
          : null,
      createdAt: json["created_at"] != null
          ? DateTime.parse(json["created_at"])
          : null,
    );
  }
}