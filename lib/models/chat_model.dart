class ChatModel {
  final int conversationId;
  final int receiverId;
  final String fullName;
  final String username;
  final String? profilePicture;
  final bool isOnline;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final DateTime? lastSeen;

  ChatModel({
    required this.conversationId,
    required this.receiverId,
    required this.fullName,
    required this.username,
    this.profilePicture,
    required this.isOnline,
    this.lastMessage,
    this.lastMessageAt,
    this.lastSeen,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      conversationId: json["conversation_id"],
      receiverId: json["receiver_id"],
      fullName: json["full_name"],
      username: json["username"],
      profilePicture: json["profile_picture"],
      isOnline: json["is_online"] ?? false,
      lastMessage: json["last_message"],
      lastMessageAt: json["last_message_at"] == null
          ? null
          : DateTime.parse(json["last_message_at"]),
      lastSeen: json["last_seen"] == null
          ? null
          : DateTime.parse(json["last_seen"]),
    );
  }
}
