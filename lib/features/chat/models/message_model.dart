import 'reaction_model.dart';
import 'reply_message_model.dart';
class MessageModel {
  final int id;
  final int conversationId;
  final int senderId;
  String message;
  final String messageType;
  final bool seen;
  final bool delivered;
  final bool isEdited;
  final bool isDeleted;
  final String? fileUrl;
  final DateTime createdAt;
  final List<ReactionModel> reactions;
  final bool sending;
  bool edited;
  ReplyMessageModel? replyTo;


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
    this.edited = false,
    this.replyTo,
    this.reactions = const [],
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
      reactions:
    (json["reactions"] as List?)
        ?.map(
          (e) => ReactionModel.fromJson(e),
        )
        .toList() ??
    [],
    );
  }
MessageModel copyWith({
  bool? delivered,
  bool? seen,
  bool? sending,
  bool? edited,
  List<ReactionModel>? reactions,
}) {
  return MessageModel(
    id: id,
    senderId: senderId,
    message: message,
    createdAt: createdAt,
    delivered:
        delivered ?? this.delivered,
    seen: seen ?? this.seen,
    sending:
        sending ?? this.sending,
    edited:
        edited ?? this.edited,
    replyTo: replyTo,
    reactions:
    reactions ?? this.reactions,
  );
}
}
