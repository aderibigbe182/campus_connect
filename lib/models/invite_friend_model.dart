class InviteFriendSettings {
  final String referralCode;

  final String inviteLink;

  final int totalInvites;

  final int successfulInvites;

  final int rewardPoints;

  final bool notificationsEnabled;

  const InviteFriendSettings({
    required this.referralCode,
    required this.inviteLink,
    required this.totalInvites,
    required this.successfulInvites,
    required this.rewardPoints,
    required this.notificationsEnabled,
  });

  factory InviteFriendSettings.defaults() {
    return const InviteFriendSettings(
      referralCode: "",
      inviteLink: "",
      totalInvites: 0,
      successfulInvites: 0,
      rewardPoints: 0,
      notificationsEnabled: true,
    );
  }

  factory InviteFriendSettings.fromJson(
    Map<String, dynamic> json,
  ) {
    return InviteFriendSettings(
      referralCode:
          json["referral_code"] ?? "",

      inviteLink:
          json["invite_link"] ?? "",

      totalInvites:
          json["total_invites"] ?? 0,

      successfulInvites:
          json["successful_invites"] ?? 0,

      rewardPoints:
          json["reward_points"] ?? 0,

      notificationsEnabled:
          json["notifications_enabled"] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "referral_code": referralCode,
      "invite_link": inviteLink,
      "total_invites": totalInvites,
      "successful_invites":
          successfulInvites,
      "reward_points": rewardPoints,
      "notifications_enabled":
          notificationsEnabled,
    };
  }

  InviteFriendSettings copyWith({
    String? referralCode,
    String? inviteLink,
    int? totalInvites,
    int? successfulInvites,
    int? rewardPoints,
    bool? notificationsEnabled,
  }) {
    return InviteFriendSettings(
      referralCode:
          referralCode ?? this.referralCode,

      inviteLink:
          inviteLink ?? this.inviteLink,

      totalInvites:
          totalInvites ?? this.totalInvites,

      successfulInvites:
          successfulInvites ??
              this.successfulInvites,

      rewardPoints:
          rewardPoints ?? this.rewardPoints,

      notificationsEnabled:
          notificationsEnabled ??
              this.notificationsEnabled,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is InviteFriendSettings &&
        other.referralCode ==
            referralCode &&
        other.inviteLink == inviteLink &&
        other.totalInvites ==
            totalInvites &&
        other.successfulInvites ==
            successfulInvites &&
        other.rewardPoints ==
            rewardPoints &&
        other.notificationsEnabled ==
            notificationsEnabled;
  }

  @override
  int get hashCode {
    return Object.hash(
      referralCode,
      inviteLink,
      totalInvites,
      successfulInvites,
      rewardPoints,
      notificationsEnabled,
    );
  }

  @override
  String toString() {
    return '''
InviteFriendSettings(
referralCode: $referralCode,
inviteLink: $inviteLink,
totalInvites: $totalInvites,
successfulInvites: $successfulInvites,
rewardPoints: $rewardPoints,
notificationsEnabled: $notificationsEnabled
)
''';
  }
}
