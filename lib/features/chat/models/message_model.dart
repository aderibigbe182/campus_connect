enum MessageType {
  text,
  image,
  video,
  audio,
  file,
}

enum MessageStatus {
  sending,
  sent,
 delivered,
  seen,
}

class MessageModel {
  final String id;
  final String conversationId;

  final String senderId;
  final String senderName;

  final String text;

  final MessageType messageType;

  final String? imageUrl;
  final String? fileUrl;
  final String? thumbnailUrl;

  final String? replyTo;

  final Map<String, String> reactions;

  final MessageStatus status;

  final DateTime timestamp;

  final bool isEdited;
  final bool isDeleted;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.messageType,
    this.imageUrl,
    this.fileUrl,
    this.thumbnailUrl,
    this.replyTo,
    this.reactions = const {},
    this.status = MessageStatus.sent,
    required this.timestamp,
    this.isEdited = false,
    this.isDeleted = false,
  });

  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderName,
    String? text,
    MessageType? messageType,
    String? imageUrl,
    String? fileUrl,
    String? thumbnailUrl,
    String? replyTo,
    Map<String, String>? reactions,
    MessageStatus? status,
    DateTime? timestamp,
    bool? isEdited,
    bool? isDeleted,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      text: text ?? this.text,
      messageType: messageType ?? this.messageType,
      imageUrl: imageUrl ?? this.imageUrl,
      fileUrl: fileUrl ?? this.fileUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      replyTo: replyTo ?? this.replyTo,
      reactions: reactions ?? this.reactions,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json["id"] ?? "",
      conversationId: json["conversationId"] ?? "",
      senderId: json["senderId"] ?? "",
      senderName: json["senderName"] ?? "",
      text: json["text"] ?? "",
      messageType: MessageType.values.firstWhere(
        (e) => e.name == json["messageType"],
        orElse: () => MessageType.text,
      ),
      imageUrl: json["imageUrl"],
      fileUrl: json["fileUrl"],
      thumbnailUrl: json["thumbnailUrl"],
      replyTo: json["replyTo"],
      reactions: Map<String, String>.from(
        json["reactions"] ?? {},
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.name == json["status"],
        orElse: () => MessageStatus.sent,
      ),
      timestamp: DateTime.parse(json["timestamp"]),
      isEdited: json["isEdited"] ?? false,
      isDeleted: json["isDeleted"] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "conversationId": conversationId,
      "senderId": senderId,
      "senderName": senderName,
      "text": text,
      "messageType": messageType.name,
      "imageUrl": imageUrl,
      "fileUrl": fileUrl,
      "thumbnailUrl": thumbnailUrl,
      "replyTo": replyTo,
      "reactions": reactions,
      "status": status.name,
      "timestamp": timestamp.toIso8601String(),
      "isEdited": isEdited,
      "isDeleted": isDeleted,
    };
  }
}