class ChatRequestModel {
  final int requestId;

  final int senderId;

  final int receiverId;

  final String senderName;

  final String? senderUsername;

  final String? senderProfilePicture;

  final String status;

  final DateTime createdAt;

  const ChatRequestModel({
    required this.requestId,
    required this.senderId,
    required this.receiverId,
    required this.senderName,
    this.senderUsername,
    this.senderProfilePicture,
    required this.status,
    required this.createdAt,
  });

  factory ChatRequestModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ChatRequestModel(
      requestId: json["request_id"],
      senderId: json["sender_id"],
      receiverId: json["receiver_id"],
      senderName: json["full_name"] ?? "",
      senderUsername: json["username"],
      senderProfilePicture:
          json["profile_picture"],
      status: json["status"] ?? "pending",
      createdAt: DateTime.parse(
        json["created_at"],
      ),
    );
  }
}