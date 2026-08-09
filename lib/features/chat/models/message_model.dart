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
    id: int.parse(json["id"].toString()),

    conversationId:
        int.parse(json["conversation_id"].toString()),

    senderId:
        int.parse(json["sender_id"].toString()),

    message: json["message"],

    messageType:
        json["message_type"]?.toString() ?? "text",

    fileUrl:
        json["file_url"]?.toString(),

    fileName:
        json["file_name"]?.toString(),

    fileSize:
        json["file_size"] == null
            ? null
            : int.parse(json["file_size"].toString()),

    replyToMessageId:
        json["reply_to_message_id"] == null
            ? null
            : int.parse(
                json["reply_to_message_id"].toString(),
              ),

    delivered:
        json["delivered"] ?? false,

    seen:
        json["seen"] ?? false,

    createdAt:
        DateTime.parse(
          json["created_at"].toString(),
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