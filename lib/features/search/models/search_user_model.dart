class SearchUserModel {
  final String id;
  final String fullName;
  final String username;
  final String? profilePicture;
  final bool isOnline;

  SearchUserModel({
    required this.id,
    required this.fullName,
    required this.username,
    this.profilePicture,
    required this.isOnline,
  });

  factory SearchUserModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return SearchUserModel(
      id: json["id"].toString(),
      fullName: json["full_name"] ?? "",
      username: json["username"] ?? "",
      profilePicture: json["profile_picture"],
      isOnline: json["is_online"] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "full_name": fullName,
      "username": username,
      "profile_picture": profilePicture,
      "is_online": isOnline,
    };
  }
}