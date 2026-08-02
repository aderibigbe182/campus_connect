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

  UserProfileModel({
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

  factory UserProfileModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserProfileModel(
      id: json["id"],
      fullName: json["full_name"] ?? "",
      username: json["username"] ?? "",
      email: json["email"] ?? "",
      university: json["university"],
      bio: json["bio"],
      interests: json["interests"],
      department: json["department"],
      level: json["level"],
      profilePicture: json["profile_picture"],
      isOnline: json["is_online"] ?? false,
      lastSeen: json["last_seen"] == null
          ? null
          : DateTime.parse(json["last_seen"]),
      createdAt: json["created_at"] == null
          ? null
          : DateTime.parse(json["created_at"]),
    );
  }
}