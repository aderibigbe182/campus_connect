class SearchMessageModel {
  final String id;
  final String conversationId;

  final String senderName;
  final String username;

  final String message;

  final DateTime createdAt;

  SearchMessageModel({
    required this.id,
    required this.conversationId,
    required this.senderName,
    required this.username,
    required this.message,
    required this.createdAt,
  });

  factory SearchMessageModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return SearchMessageModel(
      id: json["id"].toString(),
      conversationId:
          json["conversation_id"].toString(),
      senderName:
          json["full_name"] ?? "",
      username:
          json["username"] ?? "",
      message:
          json["message"] ?? "",
      createdAt: DateTime.parse(
        json["created_at"],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "conversation_id": conversationId,
      "full_name": senderName,
      "username": username,
      "message": message,
      "created_at":
          createdAt.toIso8601String(),
    };
  }
}