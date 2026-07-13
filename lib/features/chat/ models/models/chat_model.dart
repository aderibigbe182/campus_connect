class ChatModel {
  final int conversationId;
  final int receiverId;
  final String fullName;
  final String username;
  final String? profilePicture;
  final bool isOnline;
  final String? lastMessage;
  final String? messageType;
  final String? lastMessageTime;
  final int unreadCount;

  ChatModel({
    required this.conversationId,
    required this.receiverId,
    required this.fullName,
    required this.username,
    this.profilePicture,
    required this.isOnline,
    this.lastMessage,
    this.messageType,
    this.lastMessageTime,
    required this.unreadCount,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      conversationId: json["conversation_id"],
      receiverId: json["receiver_id"],
      fullName: json["full_name"] ?? "",
      username: json["username"] ?? "",
      profilePicture: json["profile_picture"],
      isOnline: json["is_online"] ?? false,
      lastMessage: json["message"],
      messageType: json["message_type"],
      lastMessageTime: json["created_at"],
      unreadCount: json["unread_count"] ?? 0,
    );
  }
}
