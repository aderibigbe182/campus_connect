class ReactionModel {
  final int userId;
  final String emoji;

  const ReactionModel({
    required this.userId,
    required this.emoji,
  });

  factory ReactionModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ReactionModel(
      userId: int.tryParse(json["userId"].toString()) ?? 0,
      emoji: json["emoji"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "emoji": emoji,
    };
  }
}