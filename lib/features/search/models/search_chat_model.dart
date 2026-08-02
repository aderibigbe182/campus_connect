class SearchChatModel {
  final String conversationId;
  final int currentUserId;
  final String receiverId;
  final String fullName;
  final String username;
   final bool isOnline;
  final String? profilePicture;

  final String? lastMessage;
  final String? messageType;

  final DateTime? createdAt;

  SearchChatModel({
    required this.conversationId,
    required this.currentUserId,
    required this.receiverId,
    required this.fullName,
    required this.username,
    required this.isOnline,
    this.profilePicture,
    this.lastMessage,
    this.messageType,
    this.createdAt,
  });

  factory SearchChatModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return SearchChatModel(
      conversationId:
          json["conversation_id"].toString(),
      receiverId:
          json["receiver_id"].toString(),
      fullName: json["full_name"] ?? "",
      username: json["username"] ?? "",
      profilePicture:
          json["profile_picture"],
      lastMessage: json["message"],
      messageType: json["message_type"],
      createdAt: json["created_at"] != null
          ? DateTime.parse(json["created_at"])
          : null,
      currentUserId: int.tryParse(json["current_user_id"].toString()) ?? 0,
      isOnline: json["is_online"] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "conversation_id": conversationId,
      "receiver_id": receiverId,
      "full_name": fullName,
      "username": username,
      "profile_picture": profilePicture,
      "message": lastMessage,
      "message_type": messageType,
      "created_at":
          createdAt?.toIso8601String(),
    };
  }
}