import 'package:equatable/equatable.dart';

class StoryReplyModel extends Equatable {
  final int id;

  final int storyId;

  final int senderId;

  final String senderName;

  final String? senderProfilePicture;

  final String message;

  final DateTime createdAt;

  const StoryReplyModel({
    required this.id,
    required this.storyId,
    required this.senderId,
    required this.senderName,
    this.senderProfilePicture,
    required this.message,
    required this.createdAt,
  });

 factory StoryReplyModel.fromJson(
  Map<String, dynamic> json,
) {
  return StoryReplyModel(
    id: (json['id'] as num?)?.toInt() ?? 0,

    storyId:
        (json['story_id'] as num?)?.toInt() ?? 0,

    senderId:
        (json['sender_id'] as num?)?.toInt() ?? 0,

    senderName:
        json['sender_name']?.toString() ?? '',

    senderProfilePicture:
        json['sender_profile_picture']
            ?.toString(),

    message:
        json['message']?.toString() ?? '',

    createdAt: DateTime.tryParse(
          json['created_at']?.toString() ?? '',
        ) ??
        DateTime.now(),
  );
}

  Map<String, dynamic> toJson() {
  return {
    'id': id,
    'story_id': storyId,
    'sender_id': senderId,
    'sender_name': senderName,
    'sender_profile_picture': senderProfilePicture,
    'message': message,
    'created_at': createdAt.toIso8601String(),
  }..removeWhere(
      (key, value) => value == null,
    );
}

  StoryReplyModel copyWith({
    int? id,
    int? storyId,
    int? senderId,
    String? senderName,
    String? senderProfilePicture,
    String? message,
    DateTime? createdAt,
  }) {
    return StoryReplyModel(
      id: id ?? this.id,

      storyId: storyId ?? this.storyId,

      senderId: senderId ?? this.senderId,

      senderName:
          senderName ?? this.senderName,

      senderProfilePicture:
          senderProfilePicture ??
              this.senderProfilePicture,

      message: message ?? this.message,

      createdAt:
          createdAt ?? this.createdAt,
    );
  }
  @override
List<Object?> get props => [
      id,
      storyId,
      senderId,
      senderName,
      senderProfilePicture,
      message,
      createdAt,
    ];
}
