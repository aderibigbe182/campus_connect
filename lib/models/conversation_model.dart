import 'user_model.dart';

class ConversationModel {

  final int id;

  final UserModel user;

  final String lastMessage;

  final DateTime? lastMessageTime;

  final int unreadCount;

  final bool pinned;

  final bool archived;

  final bool muted;

  ConversationModel({

    required this.id,

    required this.user,

    required this.lastMessage,

    this.lastMessageTime,

    required this.unreadCount,

    required this.pinned,

    required this.archived,

    required this.muted,

  });

  factory ConversationModel.fromJson(

    Map<String, dynamic> json,

  ) {

    return ConversationModel(

      id: json["id"],

      user: UserModel.fromJson(

        json["user"],

      ),

      lastMessage:

          json["last_message"] ?? "",

      lastMessageTime:

          json["last_message_time"] == null

              ? null

              : DateTime.parse(

                  json["last_message_time"],

                ),

      unreadCount:

          json["unread_count"] ?? 0,

      pinned:

          json["pinned"] ?? false,

      archived:

          json["archived"] ?? false,

      muted:

          json["muted"] ?? false,

    );

  }

}