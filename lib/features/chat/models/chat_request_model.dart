class ChatRequestModel {
  final String id;
  final String senderId;
  final String receiverId;

  final String senderName;
  final String? senderUsername;
  final String? senderProfilePicture;

  final String status;
  final DateTime createdAt;

  ChatRequestModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.senderName,
    this.senderUsername,
    this.senderProfilePicture,
    required this.status,
    required this.createdAt,
  });

  factory ChatRequestModel.fromJson(Map<String, dynamic> json) {
    final sender = json["sender"] ?? {};

    return ChatRequestModel(
      id: json["id"].toString(),
      senderId: sender["id"]?.toString() ??
          json["sender_id"]?.toString() ??
          "",
      receiverId: json["receiver_id"]?.toString() ??
          "",
      senderName:
          sender["full_name"] ??
          sender["name"] ??
          "",
      senderUsername:
          sender["username"],
      senderProfilePicture:
          sender["profile_picture"],
      status:
          json["status"] ?? "pending",
      createdAt: DateTime.parse(
        json["created_at"],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "sender_id": senderId,
      "receiver_id": receiverId,
      "status": status,
      "created_at": createdAt.toIso8601String(),
      "sender": {
        "id": senderId,
        "full_name": senderName,
        "username": senderUsername,
        "profile_picture":
            senderProfilePicture,
      },
    };
  }
}