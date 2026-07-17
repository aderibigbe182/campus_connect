import 'package:equatable/equatable.dart';

class StoryViewerModel extends Equatable {
  final int userId;

  final String fullName;

  final String? profilePicture;

  final DateTime viewedAt;

  const StoryViewerModel({
    required this.userId,
    required this.fullName,
    this.profilePicture,
    required this.viewedAt,
  });

 factory StoryViewerModel.fromJson(
  Map<String, dynamic> json,
) {
  return StoryViewerModel(
    userId:
        (json['user_id'] as num?)?.toInt() ?? 0,

    fullName:
        json['full_name']?.toString() ?? '',

    profilePicture:
        json['profile_picture']?.toString(),

    viewedAt: DateTime.tryParse(
          json['viewed_at']?.toString() ?? '',
        ) ??
        DateTime.now(),
  );
}

 Map<String, dynamic> toJson() {
  return {
    'user_id': userId,
    'full_name': fullName,
    'profile_picture': profilePicture,
    'viewed_at': viewedAt.toIso8601String(),
  }..removeWhere(
      (key, value) => value == null,
    );
}

  StoryViewerModel copyWith({
    int? userId,
    String? fullName,
    String? profilePicture,
    DateTime? viewedAt,
  }) {
    return StoryViewerModel(
      userId: userId ?? this.userId,

      fullName: fullName ?? this.fullName,

      profilePicture:
          profilePicture ??
              this.profilePicture,

      viewedAt:
          viewedAt ?? this.viewedAt,
    );
  }
 @override
List<Object?> get props => [
      userId,
      fullName,
      profilePicture,
      viewedAt,
    ];  
}