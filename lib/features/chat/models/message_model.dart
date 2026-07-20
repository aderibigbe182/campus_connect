class MessageModel {
  final int id;
  final int conversationId;
  final int senderId;
  final String message;
  final String messageType;
  final bool seen;
  final bool delivered;
  final bool isEdited;
  final bool isDeleted;
  final String? fileUrl;
  final DateTime createdAt;
  final bool sending;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.message,
    required this.messageType,
    required this.seen,
    required this.delivered,
    required this.isEdited,
    required this.isDeleted,
    this.fileUrl,
    required this.createdAt,
    this.sending = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json["id"],
      conversationId: json["conversation_id"],
      senderId: json["sender_id"],
      message: json["message"] ?? "",
      messageType: json["message_type"] ?? "text",
      seen: json["seen"] ?? false,
      delivered: json["delivered"] ?? false,
      isEdited: json["is_edited"] ?? false,
      isDeleted: json["is_deleted"] ?? false,
      fileUrl: json["file_url"],
      createdAt: DateTime.parse(json["created_at"]),
    );
  }
}
