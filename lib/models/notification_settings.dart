class NotificationSettings {
  final bool messageNotifications;
  final bool messagePreview;

  final bool groupNotifications;
  final bool groupPreview;

  final bool callNotifications;

  final bool notificationSound;
  final bool vibration;
  final bool popupNotification;
  final bool highPriority;
  final bool reactionNotifications;

  const NotificationSettings({
    required this.messageNotifications,
    required this.messagePreview,
    required this.groupNotifications,
    required this.groupPreview,
    required this.callNotifications,
    required this.notificationSound,
    required this.vibration,
    required this.popupNotification,
    required this.highPriority,
    required this.reactionNotifications,
  });

  factory NotificationSettings.defaults() {
    return const NotificationSettings(
      messageNotifications: true,
      messagePreview: true,
      groupNotifications: true,
      groupPreview: true,
      callNotifications: true,
      notificationSound: true,
      vibration: true,
      popupNotification: true,
      highPriority: true,
      reactionNotifications: true,
    );
  }

  factory NotificationSettings.fromJson(
    Map<String, dynamic> json,
  ) {
    return NotificationSettings(
      messageNotifications:
          json["message_notifications"] ?? true,

      messagePreview:
          json["message_preview"] ?? true,

      groupNotifications:
          json["group_notifications"] ?? true,

      groupPreview:
          json["group_preview"] ?? true,

      callNotifications:
          json["call_notifications"] ?? true,

      notificationSound:
          json["notification_sound"] ?? true,

      vibration:
          json["vibration"] ?? true,

      popupNotification:
          json["popup_notification"] ?? true,

      highPriority:
          json["high_priority"] ?? true,

      reactionNotifications:
          json["reaction_notifications"] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "message_notifications": messageNotifications,
      "message_preview": messagePreview,
      "group_notifications": groupNotifications,
      "group_preview": groupPreview,
      "call_notifications": callNotifications,
      "notification_sound": notificationSound,
      "vibration": vibration,
      "popup_notification": popupNotification,
      "high_priority": highPriority,
      "reaction_notifications": reactionNotifications,
    };
  }

  NotificationSettings copyWith({
    bool? messageNotifications,
    bool? messagePreview,
    bool? groupNotifications,
    bool? groupPreview,
    bool? callNotifications,
    bool? notificationSound,
    bool? vibration,
    bool? popupNotification,
    bool? highPriority,
    bool? reactionNotifications,
  }) {
    return NotificationSettings(
      messageNotifications:
          messageNotifications ?? this.messageNotifications,

      messagePreview:
          messagePreview ?? this.messagePreview,

      groupNotifications:
          groupNotifications ?? this.groupNotifications,

      groupPreview:
          groupPreview ?? this.groupPreview,

      callNotifications:
          callNotifications ?? this.callNotifications,

      notificationSound:
          notificationSound ?? this.notificationSound,

      vibration:
          vibration ?? this.vibration,

      popupNotification:
          popupNotification ?? this.popupNotification,

      highPriority:
          highPriority ?? this.highPriority,

      reactionNotifications:
          reactionNotifications ??
              this.reactionNotifications,
    );
  }

  @override
  String toString() {
    return '''
NotificationSettings(
messageNotifications: $messageNotifications,
messagePreview: $messagePreview,
groupNotifications: $groupNotifications,
groupPreview: $groupPreview,
callNotifications: $callNotifications,
notificationSound: $notificationSound,
vibration: $vibration,
popupNotification: $popupNotification,
highPriority: $highPriority,
reactionNotifications: $reactionNotifications
)
''';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NotificationSettings &&
        other.messageNotifications ==
            messageNotifications &&
        other.messagePreview == messagePreview &&
        other.groupNotifications ==
            groupNotifications &&
        other.groupPreview == groupPreview &&
        other.callNotifications ==
            callNotifications &&
        other.notificationSound ==
            notificationSound &&
        other.vibration == vibration &&
        other.popupNotification ==
            popupNotification &&
        other.highPriority ==
            highPriority &&
        other.reactionNotifications ==
            reactionNotifications;
  }

  @override
  int get hashCode {
    return Object.hash(
      messageNotifications,
      messagePreview,
      groupNotifications,
      groupPreview,
      callNotifications,
      notificationSound,
      vibration,
      popupNotification,
      highPriority,
      reactionNotifications,
    );
  }
}
