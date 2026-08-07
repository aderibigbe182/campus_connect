class MessageModel {
  final int id;

  final int conversationId;

  final int senderId;

  final String? message;

  final String messageType;

  final String? fileUrl;

  final String? fileName;

  final int? fileSize;

  final int? replyToMessageId;

  final bool delivered;

  final bool seen;

  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.message,
    required this.messageType,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    this.replyToMessageId,
    required this.delivered,
    required this.seen,
    required this.createdAt,
  });

  factory MessageModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return MessageModel(
      id: json["id"],
      conversationId: json["conversation_id"],
      senderId: json["sender_id"],
      message: json["message"],
      messageType:
          json["message_type"] ?? "text",
      fileUrl: json["file_url"],
      fileName: json["file_name"],
      fileSize: json["file_size"],
      replyToMessageId:
          json["reply_to_message_id"],
      delivered:
          json["delivered"] ?? false,
      seen: json["seen"] ?? false,
      createdAt: DateTime.parse(
        json["created_at"],
      ),
    );
  }
MessageModel copyWith({
  int? id,
  int? conversationId,
  int? senderId,
  String? message,
  String? messageType,
  String? fileUrl,
  String? fileName,
  int? fileSize,
  int? replyToMessageId,
  bool? delivered,
  bool? seen,
  DateTime? createdAt,
}) {
  return MessageModel(
    id: id ?? this.id,
    conversationId:
        conversationId ?? this.conversationId,
    senderId: senderId ?? this.senderId,
    message: message ?? this.message,
    messageType: messageType ?? this.messageType,
    fileUrl: fileUrl ?? this.fileUrl,
    fileName: fileName ?? this.fileName,
    fileSize: fileSize ?? this.fileSize,
    replyToMessageId:
        replyToMessageId ?? this.replyToMessageId,
    delivered: delivered ?? this.delivered,
    seen: seen ?? this.seen,
    createdAt: createdAt ?? this.createdAt,
  );
}
Map<String, dynamic> toJson() {
  return {
    "id": id,
    "conversation_id": conversationId,
    "sender_id": senderId,
    "message": message,
    "message_type": messageType,
    "file_url": fileUrl,
    "file_name": fileName,
    "file_size": fileSize,
    "reply_to_message_id": replyToMessageId,
    "delivered": delivered,
    "seen": seen,
    "created_at": createdAt.toIso8601String(),
  };
}
}