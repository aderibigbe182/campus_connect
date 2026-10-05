class PrivacySettings {
  final String lastSeen;

  final String profilePhoto;

  final String about;

  final String status;

  final String groups;

  final bool readReceipts;

  final bool autoAcceptRequests;

  const PrivacySettings({
    required this.lastSeen,
    required this.profilePhoto,
    required this.about,
    required this.status,
    required this.groups,
    required this.readReceipts,
    required this.autoAcceptRequests,
  });

  factory PrivacySettings.defaults() {
    return const PrivacySettings(
      lastSeen: "Nobody",
      profilePhoto: "Everyone",
      about: "Everyone",
      status: "My contacts",
      groups: "My contacts",
      readReceipts: true,
      autoAcceptRequests: false,
    );
  }

  factory PrivacySettings.fromJson(
    Map<String, dynamic> json,
  ) {
    return PrivacySettings(
      lastSeen:
          json["last_seen"] ?? "Nobody",

      profilePhoto:
          json["profile_photo"] ?? "Everyone",

      about:
          json["about"] ?? "Everyone",

      status:
          json["status"] ?? "My contacts",

      groups:
          json["groups"] ?? "My contacts",

      readReceipts:
          json["read_receipts"] ?? true,

      autoAcceptRequests:
          json["auto_accept_requests"] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "last_seen": lastSeen,
      "profile_photo": profilePhoto,
      "about": about,
      "status": status,
      "groups": groups,
      "read_receipts": readReceipts,
      "auto_accept_requests":
          autoAcceptRequests,
    };
  }

  PrivacySettings copyWith({
    String? lastSeen,
    String? profilePhoto,
    String? about,
    String? status,
    String? groups,
    bool? readReceipts,
    bool? autoAcceptRequests,
  }) {
    return PrivacySettings(
      lastSeen:
          lastSeen ?? this.lastSeen,

      profilePhoto:
          profilePhoto ??
              this.profilePhoto,

      about:
          about ?? this.about,

      status:
          status ?? this.status,

      groups:
          groups ?? this.groups,

      readReceipts:
          readReceipts ??
              this.readReceipts,

      autoAcceptRequests:
          autoAcceptRequests ??
              this.autoAcceptRequests,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is PrivacySettings &&
        other.lastSeen == lastSeen &&
        other.profilePhoto ==
            profilePhoto &&
        other.about == about &&
        other.status == status &&
        other.groups == groups &&
        other.readReceipts ==
            readReceipts &&
        other.autoAcceptRequests ==
            autoAcceptRequests;
  }

  @override
  int get hashCode {
    return Object.hash(
      lastSeen,
      profilePhoto,
      about,
      status,
      groups,
      readReceipts,
      autoAcceptRequests,
    );
  }

  @override
  String toString() {
    return '''
PrivacySettings(
lastSeen: $lastSeen,
profilePhoto: $profilePhoto,
about: $about,
status: $status,
groups: $groups,
readReceipts: $readReceipts,
autoAcceptRequests: $autoAcceptRequests
)
''';
  }
}