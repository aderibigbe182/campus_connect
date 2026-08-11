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

  final int? requestId;
  final int? requestSenderId;
  final int? requestReceiverId;

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
    this.requestId,
    this.requestSenderId,
    this.requestReceiverId,
  });
factory ConversationModel.fromJson(
  Map<String, dynamic> json,
) {
  return ConversationModel(
    conversationId: int.tryParse(
          json["conversation_id"]?.toString() ?? "",
        ) ??
        0,

    receiverId: int.tryParse(
          json["receiver_id"]?.toString() ?? "",
        ) ??
        0,

    fullName: json["full_name"]?.toString() ?? "",
    username: json["username"]?.toString() ?? "",

    profilePicture: json["profile_picture"]?.toString(),

    isOnline: json["is_online"] == true,

    lastSeen: json["last_seen"] == null
        ? null
        : DateTime.tryParse(
            json["last_seen"].toString(),
          ),

    lastMessage: json["message"]?.toString(),

    lastMessageType:
        json["message_type"]?.toString(),

    lastMessageTime:
        json["created_at"] == null
            ? null
            : DateTime.tryParse(
                json["created_at"].toString(),
              ),

    unreadCount: int.tryParse(
          json["unread_count"]?.toString() ?? "0",
        ) ??
        0,

    relationshipStatus:
        json["relationship_status"]?.toString() ??
            "none",

    requestId: json["request_id"] == null
        ? null
        : int.tryParse(
            json["request_id"].toString(),
          ),

    requestSenderId:
        json["request_sender_id"] == null
            ? null
            : int.tryParse(
                json["request_sender_id"].toString(),
              ),

    requestReceiverId:
        json["request_receiver_id"] == null
            ? null
            : int.tryParse(
                json["request_receiver_id"].toString(),
              ),
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
  int? requestId,
  int? requestSenderId,
  int? requestReceiverId,
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
    requestId:
        requestId ?? this.requestId,

    requestSenderId:
        requestSenderId ??
        this.requestSenderId,

    requestReceiverId:
        requestReceiverId ??
        this.requestReceiverId,  
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
    "request_id": requestId,
    "request_sender_id": requestSenderId,
    "request_receiver_id": requestReceiverId,
  };
}
// ==========================================
// REQUEST / RELATIONSHIP HELPERS
// ==========================================

  bool isPendingRequest() {
    return relationshipStatus == "pending";
  }

  bool isRequestSender(int currentUserId) {
    return requestSenderId == currentUserId;
  }

  bool isRequestReceiver(int currentUserId) {
    return requestReceiverId == currentUserId;
  }
}