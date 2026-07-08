class MessageModel {

  final int id;

  final int conversationId;

  final int senderId;

  final String message;

  final String messageType;

  final bool edited;

  final bool deleted;

  final DateTime createdAt;

  final bool delivered;

final bool seen;

  MessageModel({

    required this.id,

    required this.conversationId,

    required this.senderId,

    required this.message,

    required this.messageType,

    required this.edited,

    required this.deleted,

    required this.createdAt,
    required this.delivered,
    required this.seen,
  });

  factory MessageModel.fromJson(

    Map<String, dynamic> json,

  ) {

    return MessageModel(

      id: json["id"],

      conversationId: json["conversation_id"],

      senderId: json["sender_id"],

      message: json["message"] ?? "",

      messageType: json["message_type"] ?? "text",

      edited: json["edited"] ?? false,

      deleted: json["deleted"] ?? false,

      delivered: json["delivered"] ?? false,

      seen: json["seen"] ?? false,

      createdAt: DateTime.parse(

        json["created_at"],

      ),

    );

  }

}