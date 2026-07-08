class UserModel {

  final int id;

  final String fullName;

  final String username;

  final String? profilePicture;

  final bool isOnline;

  final DateTime? lastSeen;

  UserModel({

    required this.id,

    required this.fullName,

    required this.username,

    this.profilePicture,

    required this.isOnline,

    this.lastSeen,

  });

  factory UserModel.fromJson(

    Map<String, dynamic> json,

  ) {

    return UserModel(

      id: json["id"],

      fullName: json["full_name"],

      username: json["username"],

      profilePicture: json["profile_picture"],

      isOnline: json["is_online"] ?? false,

      lastSeen: json["last_seen"] == null

          ? null

          : DateTime.parse(

              json["last_seen"],

            ),

    );

  }

}