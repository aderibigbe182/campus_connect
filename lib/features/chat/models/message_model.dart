import 'reply_message_model.dart';
import 'reaction_model.dart';

class MessageModel {
  final int id;
  final int conversationId;
  final int senderId;

  String message;

  final String messageType;

  final DateTime createdAt;

  bool delivered;
  bool seen;
  bool sending;

  bool edited;
  bool isEdited;
  bool isDeleted;

  final ReplyMessageModel? replyTo;

  final List<ReactionModel> reactions;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.message,
    required this.messageType,
    required this.createdAt,
    this.delivered = false,
    this.seen = false,
    this.sending = false,
    this.edited = false,
    this.isEdited = false,
    this.isDeleted = false,
    this.replyTo,
    this.reactions = const [],
  });

  MessageModel copyWith({
    int? id,
    int? conversationId,
    int? senderId,
    String? message,
    String? messageType,
    DateTime? createdAt,
    bool? delivered,
    bool? seen,
    bool? sending,
    bool? edited,
    bool? isEdited,
    bool? isDeleted,
    ReplyMessageModel? replyTo,
    List<ReactionModel>? reactions,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      message: message ?? this.message,
      messageType: messageType ?? this.messageType,
      createdAt: createdAt ?? this.createdAt,
      delivered: delivered ?? this.delivered,
      seen: seen ?? this.seen,
      sending: sending ?? this.sending,
      edited: edited ?? this.edited,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
      replyTo: replyTo ?? this.replyTo,
      reactions: reactions ?? this.reactions,
    );
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json["id"] ?? 0,
      conversationId: json["conversation_id"] ??
          json["conversationId"] ??
          0,
      senderId: json["sender_id"] ??
          json["senderId"] ??
          0,
      message: json["message"] ?? "",
      messageType: json["message_type"] ??
          json["messageType"] ??
          "text",
      createdAt: DateTime.tryParse(
              json["created_at"] ??
                  json["createdAt"] ??
                  "") ??
          DateTime.now(),
      delivered: json["delivered"] ?? false,
      seen: json["seen"] ?? false,
      sending: false,
      edited: json["edited"] ?? false,
      isEdited: json["isEdited"] ?? false,
      isDeleted: json["isDeleted"] ?? false,
      replyTo: null,
      reactions: json["reactions"] != null
          ? (json["reactions"] as List)
              .map(
                (e) => ReactionModel.fromJson(e),
              )
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "conversation_id": conversationId,
      "sender_id": senderId,
      "message": message,
      "message_type": messageType,
      "created_at": createdAt.toIso8601String(),
      "delivered": delivered,
      "seen": seen,
      "edited": edited,
      "isEdited": isEdited,
      "isDeleted": isDeleted,
      "reply_to":  null,
      "reactions": reactions
          .map((e) => e.toJson())
          .toList(),
    };
  }
}