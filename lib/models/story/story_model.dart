import 'package:equatable/equatable.dart';

class StoryModel extends Equatable {
  final int id;

  final int userId;

  final String? fullName;

  final String? profilePicture;

  final String mediaUrl;

  final String mediaType;

  final String? caption;

  final DateTime createdAt;

  final DateTime expiresAt;

  final bool hasViewed;

  const StoryModel({
    required this.id,
    required this.userId,
    this.fullName,
    this.profilePicture,
    required this.mediaUrl,
    required this.mediaType,
    this.caption,
    required this.createdAt,
    required this.expiresAt,
    this.hasViewed = false,
  });

  factory StoryModel.fromJson(
  Map<String, dynamic> json,
) {
  return StoryModel(
    id: (json['id'] as num?)?.toInt() ?? 0,

    userId:
        (json['user_id'] as num?)?.toInt() ?? 0,

    fullName:
        json['full_name']?.toString(),

    profilePicture:
        json['profile_picture']?.toString(),

    mediaUrl:
        json['media_url']?.toString() ?? '',

    mediaType:
        json['media_type']?.toString() ?? 'image',

    caption:
        json['caption']?.toString(),

    createdAt: DateTime.tryParse(
          json['created_at']?.toString() ?? '',
        ) ??
        DateTime.now(),

    expiresAt: DateTime.tryParse(
          json['expires_at']?.toString() ?? '',
        ) ??
        DateTime.now().add(
          const Duration(hours: 24),
        ),

    hasViewed:
        json['has_viewed'] == true,
  );
}

  Map<String, dynamic> toJson() {
  return {
    'id': id,
    'user_id': userId,
    'full_name': fullName,
    'profile_picture': profilePicture,
    'media_url': mediaUrl,
    'media_type': mediaType,
    'caption': caption,
    'created_at': createdAt.toIso8601String(),
    'expires_at': expiresAt.toIso8601String(),
    'has_viewed': hasViewed,
  }..removeWhere(
      (key, value) => value == null,
    );
}

  StoryModel copyWith({
    int? id,
    int? userId,
    String? fullName,
    String? profilePicture,
    String? mediaUrl,
    String? mediaType,
    String? caption,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? hasViewed,
  }) {
    return StoryModel(
      id: id ?? this.id,

      userId: userId ?? this.userId,

      fullName: fullName ?? this.fullName,

      profilePicture:
          profilePicture ??
              this.profilePicture,

      mediaUrl: mediaUrl ?? this.mediaUrl,

      mediaType:
          mediaType ?? this.mediaType,

      caption: caption ?? this.caption,

      createdAt:
          createdAt ?? this.createdAt,

      expiresAt:
          expiresAt ?? this.expiresAt,

      hasViewed:
          hasViewed ?? this.hasViewed,
    );
  }
  @override
List<Object?> get props => [
      id,
      userId,
      fullName,
      profilePicture,
      mediaUrl,
      mediaType,
      caption,
      createdAt,
      expiresAt,
      hasViewed,
    ];
  bool get isImage =>
    mediaType.toLowerCase() == 'image';
  bool get isVideo =>
    mediaType.toLowerCase() == 'video';
  bool get isExpired =>
    DateTime.now().isAfter(expiresAt);
  Duration get timeRemaining {
  final remaining =
      expiresAt.difference(DateTime.now());
  if (remaining.isNegative) {
    return Duration.zero;
  }
  return remaining;
}
int get hoursRemaining =>
    timeRemaining.inHours;
int get minutesRemaining =>
    timeRemaining.inMinutes;
bool get hasCaption =>
    caption != null &&
    caption!.trim().isNotEmpty;
bool get hasProfilePicture =>
    profilePicture != null &&
    profilePicture!.trim().isNotEmpty;

}