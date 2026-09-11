class ChatModel {
  final int conversationId;
  final String conversationType;
  final String? title;
  final ChatUser? otherUser;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;

  const ChatModel({
    required this.conversationId,
    required this.conversationType,
    this.title,
    this.otherUser,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      conversationId:
          (json['conversation_id'] as num?)?.toInt() ?? 0,
      conversationType:
          json['conversation_type']?.toString() ?? 'private',
      title: json['title']?.toString(),
      otherUser: json['other_user'] != null
          ? ChatUser.fromJson(
              Map<String, dynamic>.from(json['other_user']),
            )
          : null,
      lastMessage: json['last_message']?.toString(),
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.tryParse(
              json['last_message_time'].toString(),
            )
          : null,
      unreadCount:
          (json['unread_count'] as num?)?.toInt() ?? 0,
    );
  }
}

class ChatUser {
  final int id;
  final String fullName;
  final String username;
  final String? profilePicture;

  const ChatUser({
    required this.id,
    required this.fullName,
    required this.username,
    this.profilePicture,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: (json['id'] as num?)?.toInt() ?? 0,
      fullName: json['full_name']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      profilePicture: json['profile_picture']?.toString(),
    );
  }
}