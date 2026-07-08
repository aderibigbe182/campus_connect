class HelpFeedbackSettings {
  final bool crashReports;

  final bool diagnostics;

  final bool usageAnalytics;

  final bool contactReplies;

  final String appVersion;

  final String supportEmail;

  const HelpFeedbackSettings({
    required this.crashReports,
    required this.diagnostics,
    required this.usageAnalytics,
    required this.contactReplies,
    required this.appVersion,
    required this.supportEmail,
  });

  factory HelpFeedbackSettings.defaults() {
    return const HelpFeedbackSettings(
      crashReports: true,
      diagnostics: true,
      usageAnalytics: true,
      contactReplies: true,
      appVersion: "1.0.0",
      supportEmail: "support@campusconnect.com",
    );
  }

  factory HelpFeedbackSettings.fromJson(
    Map<String, dynamic> json,
  ) {
    return HelpFeedbackSettings(
      crashReports:
          json["crash_reports"] ?? true,

      diagnostics:
          json["diagnostics"] ?? true,

      usageAnalytics:
          json["usage_analytics"] ?? true,

      contactReplies:
          json["contact_replies"] ?? true,

      appVersion:
          json["app_version"] ?? "1.0.0",

      supportEmail:
          json["support_email"] ??
              "support@campusconnect.com",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "crash_reports": crashReports,
      "diagnostics": diagnostics,
      "usage_analytics": usageAnalytics,
      "contact_replies": contactReplies,
      "app_version": appVersion,
      "support_email": supportEmail,
    };
  }

  HelpFeedbackSettings copyWith({
    bool? crashReports,
    bool? diagnostics,
    bool? usageAnalytics,
    bool? contactReplies,
    String? appVersion,
    String? supportEmail,
  }) {
    return HelpFeedbackSettings(
      crashReports:
          crashReports ??
              this.crashReports,

      diagnostics:
          diagnostics ??
              this.diagnostics,

      usageAnalytics:
          usageAnalytics ??
              this.usageAnalytics,

      contactReplies:
          contactReplies ??
              this.contactReplies,

      appVersion:
          appVersion ??
              this.appVersion,

      supportEmail:
          supportEmail ??
              this.supportEmail,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is HelpFeedbackSettings &&
        other.crashReports ==
            crashReports &&
        other.diagnostics ==
            diagnostics &&
        other.usageAnalytics ==
            usageAnalytics &&
        other.contactReplies ==
            contactReplies &&
        other.appVersion ==
            appVersion &&
        other.supportEmail ==
            supportEmail;
  }

  @override
  int get hashCode {
    return Object.hash(
      crashReports,
      diagnostics,
      usageAnalytics,
      contactReplies,
      appVersion,
      supportEmail,
    );
  }

  @override
  String toString() {
    return '''
HelpFeedbackSettings(
crashReports: $crashReports,
diagnostics: $diagnostics,
usageAnalytics: $usageAnalytics,
contactReplies: $contactReplies,
appVersion: $appVersion,
supportEmail: $supportEmail
)
''';
  }
}