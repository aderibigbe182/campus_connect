class ConversationModel {
  final int conversationId;

  final int receiverId;

  final String fullName;

  final String username;

  final String? profilePicture;

  final bool isOnline;

  final DateTime? lastSeen;

  final String? lastMessage;

  final String? lastMessageType;

  final DateTime? lastMessageTime;

  final int unreadCount;

  final String relationshipStatus;

  const ConversationModel({
    required this.conversationId,
    required this.receiverId,
    required this.fullName,
    required this.username,
    this.profilePicture,
    required this.isOnline,
    this.lastSeen,
    this.lastMessage,
    this.lastMessageType,
    this.lastMessageTime,
    required this.unreadCount,
    required this.relationshipStatus,
  });

  factory ConversationModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ConversationModel(
      conversationId: json["conversation_id"],
      receiverId: json["receiver_id"],
      fullName: json["full_name"] ?? "",
      username: json["username"] ?? "",
      profilePicture: json["profile_picture"],
      isOnline: json["is_online"] ?? false,
      lastSeen: json["last_seen"] == null
          ? null
          : DateTime.parse(json["last_seen"]),
      lastMessage: json["message"],
      lastMessageType: json["message_type"],
      lastMessageTime: json["created_at"] == null
          ? null
          : DateTime.parse(json["created_at"]),
      unreadCount: json["unread_count"] ?? 0,
      relationshipStatus:
          json["relationship_status"] ?? "none",
      
    );
  }
  ConversationModel copyWith({
  int? conversationId,
  int? receiverId,
  String? fullName,
  String? username,
  String? profilePicture,
  bool? isOnline,
  DateTime? lastSeen,
  String? lastMessage,
  String? lastMessageType,
  DateTime? lastMessageTime,
  int? unreadCount,
  String? relationshipStatus,
}) {
  return ConversationModel(
    conversationId: conversationId ?? this.conversationId,
    receiverId: receiverId ?? this.receiverId,
    fullName: fullName ?? this.fullName,
    username: username ?? this.username,
    profilePicture: profilePicture ?? this.profilePicture,
    isOnline: isOnline ?? this.isOnline,
    lastSeen: lastSeen ?? this.lastSeen,
    lastMessage: lastMessage ?? this.lastMessage,
    lastMessageType: lastMessageType ?? this.lastMessageType,
    lastMessageTime: lastMessageTime ?? this.lastMessageTime,
    unreadCount: unreadCount ?? this.unreadCount,
    relationshipStatus:
        relationshipStatus ?? this.relationshipStatus,
  );
}
Map<String, dynamic> toJson() {
  return {
    "conversation_id": conversationId,
    "receiver_id": receiverId,
    "full_name": fullName,
    "username": username,
    "profile_picture": profilePicture,
    "is_online": isOnline,
    "last_seen": lastSeen?.toIso8601String(),
    "message": lastMessage,
    "message_type": lastMessageType,
    "created_at": lastMessageTime?.toIso8601String(),
    "unread_count": unreadCount,
    "relationship_status": relationshipStatus,
  };
}
}