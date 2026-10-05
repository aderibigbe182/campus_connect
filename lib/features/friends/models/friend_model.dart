class FriendModel {
  final int id;
  final String fullName;
  final String username;
  final String email;
  final String? university;
  final String? faculty;
  final String? department;
  final String? yearOfStudy;
  final String? bio;
  final String? profilePicture;

  const FriendModel({
    required this.id,
    required this.fullName,
    required this.username,
    required this.email,
    this.university,
    this.faculty,
    this.department,
    this.yearOfStudy,
    this.bio,
    this.profilePicture,
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    return FriendModel(
      id: int.tryParse('${json['id']}') ?? 0,
      fullName: json['full_name']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      university: json['university']?.toString(),
      faculty: json['faculty']?.toString(),
      department: json['department']?.toString(),
      yearOfStudy: json['year_of_study']?.toString(),
      bio: json['bio']?.toString(),
      profilePicture: json['profile_picture']?.toString(),
    );
  }
}