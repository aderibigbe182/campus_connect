class GroupMemberModel {
  final int id;
  final int userId;
  final String fullName;
  final String username;
  final String? profilePicture;
  final String role;
  final bool isAdmin;

  const GroupMemberModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.username,
    this.profilePicture,
    required this.role,
    required this.isAdmin,
  });

  factory GroupMemberModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final role =
        json['role']?.toString() ?? 'member';

    return GroupMemberModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId:
          (json['user_id'] as num?)?.toInt() ??
              0,
      fullName:
          json['full_name']?.toString() ?? '',
      username:
          json['username']?.toString() ?? '',
      profilePicture:
          json['profile_picture']?.toString(),
      role: role,
      isAdmin:
          json['is_admin'] == true ||
          role == 'admin' ||
          role == 'owner',
    );
  }
}