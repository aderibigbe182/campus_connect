class UserSearchModel {
  final int id;
  final String fullName;
  final String username;
  final String? university;
  final String? profilePicture;

  const UserSearchModel({
    required this.id,
    required this.fullName,
    required this.username,
    this.university,
    this.profilePicture,
  });

  factory UserSearchModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserSearchModel(
      id: int.tryParse('${json['id']}') ?? 0,
      fullName: json['full_name']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      university: json['university']?.toString(),
      profilePicture:
          json['profile_picture']?.toString(),
    );
  }
}