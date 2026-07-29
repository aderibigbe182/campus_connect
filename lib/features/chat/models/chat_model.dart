import 'message_model.dart';

class ChatModel {
  final int id;
  final String conversationId;

  final int otherUserId;
  final String otherUserName;
  final String? otherUserAvatar;
  final bool isOnline;

  final MessageModel? lastMessage;

  final int unreadCount;

  final bool isPinned;
  final bool isMuted;
  final bool isArchived;

  final DateTime updatedAt;

  const ChatModel({
    required this.id,
    required this.conversationId,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatar,
    this.isOnline = false,
    this.lastMessage,
    this.unreadCount = 0,
    this.isPinned = false,
    this.isMuted = false,
    this.isArchived = false,
    required this.updatedAt,
  });
    ChatModel copyWith({
    int? id,
    String? conversationId,
    int? otherUserId,
    String? otherUserName,
    String? otherUserAvatar,
    bool? isOnline,
    MessageModel? lastMessage,
    int? unreadCount,
    bool? isPinned,
    bool? isMuted,
    bool? isArchived,
    DateTime? updatedAt,
  }) {
    return ChatModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      otherUserId: otherUserId ?? this.otherUserId,
      otherUserName: otherUserName ?? this.otherUserName,
      otherUserAvatar: otherUserAvatar ?? this.otherUserAvatar,
      isOnline: isOnline ?? this.isOnline,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      isPinned: isPinned ?? this.isPinned,
      isMuted: isMuted ?? this.isMuted,
      isArchived: isArchived ?? this.isArchived,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] ?? 0,
      conversationId: json['conversation_id']?.toString() ?? '',
      otherUserId: json['other_user_id'] ?? 0,
      otherUserName: json['other_user_name'] ?? '',
      otherUserAvatar: json['other_user_avatar'],
      isOnline: json['is_online'] ?? false,
      lastMessage: json['last_message'] != null
          ? MessageModel.fromJson(json['last_message'])
          : null,
      unreadCount: json['unread_count'] ?? 0,
      isPinned: json['is_pinned'] ?? false,
      isMuted: json['is_muted'] ?? false,
      isArchived: json['is_archived'] ?? false,
      updatedAt: DateTime.tryParse(
            json['updated_at']?.toString() ?? '',
          ) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'other_user_id': otherUserId,
      'other_user_name': otherUserName,
      'other_user_avatar': otherUserAvatar,
      'is_online': isOnline,
      'last_message': lastMessage?.toJson(),
      'unread_count': unreadCount,
      'is_pinned': isPinned,
      'is_muted': isMuted,
      'is_archived': isArchived,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}