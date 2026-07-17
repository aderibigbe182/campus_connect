import 'package:equatable/equatable.dart';

class StoryReactionModel extends Equatable {
  final int id;

  final int storyId;

  final int userId;

  final String fullName;

  final String? profilePicture;

  final String reaction;

  final DateTime createdAt;

  const StoryReactionModel({
    required this.id,
    required this.storyId,
    required this.userId,
    required this.fullName,
    this.profilePicture,
    required this.reaction,
    required this.createdAt,
  });

  factory StoryReactionModel.fromJson(
  Map<String, dynamic> json,
) {
  return StoryReactionModel(
    id: (json['id'] as num?)?.toInt() ?? 0,

    storyId:
        (json['story_id'] as num?)?.toInt() ?? 0,

    userId:
        (json['user_id'] as num?)?.toInt() ?? 0,

    fullName:
        json['full_name']?.toString() ?? '',

    profilePicture:
        json['profile_picture']?.toString(),

    reaction:
        json['reaction']?.toString() ?? '❤️',

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
    'user_id': userId,
    'full_name': fullName,
    'profile_picture': profilePicture,
    'reaction': reaction,
    'created_at': createdAt.toIso8601String(),
  }..removeWhere(
      (key, value) => value == null,
    );
}

  StoryReactionModel copyWith({
    int? id,
    int? storyId,
    int? userId,
    String? fullName,
    String? profilePicture,
    String? reaction,
    DateTime? createdAt,
  }) {
    return StoryReactionModel(
      id: id ?? this.id,

      storyId: storyId ?? this.storyId,

      userId: userId ?? this.userId,

      fullName: fullName ?? this.fullName,

      profilePicture:
          profilePicture ??
              this.profilePicture,

      reaction: reaction ?? this.reaction,

      createdAt:
          createdAt ?? this.createdAt,
    );
  }
  @override
List<Object?> get props => [
      id,
      storyId,
      userId,
      fullName,
      profilePicture,
      reaction,
      createdAt,
    ];
}