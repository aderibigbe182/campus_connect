class StorageSettings {
  final bool autoDownloadPhotos;

  final bool autoDownloadVideos;

  final bool autoDownloadDocuments;

  final bool autoDownloadAudio;

  final bool useLessDataForCalls;

  final bool wifiOnlyDownloads;

  final bool mobileDataDownloads;

  final bool roamingDownloads;

  final double storageUsedMB;

  final double cacheSizeMB;

  final double mediaSizeMB;

  const StorageSettings({
    required this.autoDownloadPhotos,
    required this.autoDownloadVideos,
    required this.autoDownloadDocuments,
    required this.autoDownloadAudio,
    required this.useLessDataForCalls,
    required this.wifiOnlyDownloads,
    required this.mobileDataDownloads,
    required this.roamingDownloads,
    required this.storageUsedMB,
    required this.cacheSizeMB,
    required this.mediaSizeMB,
  });

  factory StorageSettings.defaults() {
    return const StorageSettings(
      autoDownloadPhotos: true,
      autoDownloadVideos: false,
      autoDownloadDocuments: true,
      autoDownloadAudio: true,
      useLessDataForCalls: true,
      wifiOnlyDownloads: true,
      mobileDataDownloads: false,
      roamingDownloads: false,
      storageUsedMB: 0,
      cacheSizeMB: 0,
      mediaSizeMB: 0,
    );
  }

  factory StorageSettings.fromJson(
    Map<String, dynamic> json,
  ) {
    return StorageSettings(
      autoDownloadPhotos:
          json["auto_download_photos"] ?? true,

      autoDownloadVideos:
          json["auto_download_videos"] ?? false,

      autoDownloadDocuments:
          json["auto_download_documents"] ?? true,

      autoDownloadAudio:
          json["auto_download_audio"] ?? true,

      useLessDataForCalls:
          json["use_less_data_for_calls"] ?? true,

      wifiOnlyDownloads:
          json["wifi_only_downloads"] ?? true,

      mobileDataDownloads:
          json["mobile_data_downloads"] ?? false,

      roamingDownloads:
          json["roaming_downloads"] ?? false,

      storageUsedMB:
          (json["storage_used_mb"] ?? 0)
              .toDouble(),

      cacheSizeMB:
          (json["cache_size_mb"] ?? 0)
              .toDouble(),

      mediaSizeMB:
          (json["media_size_mb"] ?? 0)
              .toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "auto_download_photos":
          autoDownloadPhotos,
      "auto_download_videos":
          autoDownloadVideos,
      "auto_download_documents":
          autoDownloadDocuments,
      "auto_download_audio":
          autoDownloadAudio,
      "use_less_data_for_calls":
          useLessDataForCalls,
      "wifi_only_downloads":
          wifiOnlyDownloads,
      "mobile_data_downloads":
          mobileDataDownloads,
      "roaming_downloads":
          roamingDownloads,
      "storage_used_mb":
          storageUsedMB,
      "cache_size_mb":
          cacheSizeMB,
      "media_size_mb":
          mediaSizeMB,
    };
  }

  StorageSettings copyWith({
    bool? autoDownloadPhotos,
    bool? autoDownloadVideos,
    bool? autoDownloadDocuments,
    bool? autoDownloadAudio,
    bool? useLessDataForCalls,
    bool? wifiOnlyDownloads,
    bool? mobileDataDownloads,
    bool? roamingDownloads,
    double? storageUsedMB,
    double? cacheSizeMB,
    double? mediaSizeMB,
  }) {
    return StorageSettings(
      autoDownloadPhotos:
          autoDownloadPhotos ??
              this.autoDownloadPhotos,

      autoDownloadVideos:
          autoDownloadVideos ??
              this.autoDownloadVideos,

      autoDownloadDocuments:
          autoDownloadDocuments ??
              this.autoDownloadDocuments,

      autoDownloadAudio:
          autoDownloadAudio ??
              this.autoDownloadAudio,

      useLessDataForCalls:
          useLessDataForCalls ??
              this.useLessDataForCalls,

      wifiOnlyDownloads:
          wifiOnlyDownloads ??
              this.wifiOnlyDownloads,

      mobileDataDownloads:
          mobileDataDownloads ??
              this.mobileDataDownloads,

      roamingDownloads:
          roamingDownloads ??
              this.roamingDownloads,

      storageUsedMB:
          storageUsedMB ??
              this.storageUsedMB,

      cacheSizeMB:
          cacheSizeMB ??
              this.cacheSizeMB,

      mediaSizeMB:
          mediaSizeMB ??
              this.mediaSizeMB,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is StorageSettings &&
        other.autoDownloadPhotos ==
            autoDownloadPhotos &&
        other.autoDownloadVideos ==
            autoDownloadVideos &&
        other.autoDownloadDocuments ==
            autoDownloadDocuments &&
        other.autoDownloadAudio ==
            autoDownloadAudio &&
        other.useLessDataForCalls ==
            useLessDataForCalls &&
        other.wifiOnlyDownloads ==
            wifiOnlyDownloads &&
        other.mobileDataDownloads ==
            mobileDataDownloads &&
        other.roamingDownloads ==
            roamingDownloads &&
        other.storageUsedMB ==
            storageUsedMB &&
        other.cacheSizeMB ==
            cacheSizeMB &&
        other.mediaSizeMB ==
            mediaSizeMB;
  }

  @override
  int get hashCode {
    return Object.hash(
      autoDownloadPhotos,
      autoDownloadVideos,
      autoDownloadDocuments,
      autoDownloadAudio,
      useLessDataForCalls,
      wifiOnlyDownloads,
      mobileDataDownloads,
      roamingDownloads,
      storageUsedMB,
      cacheSizeMB,
      mediaSizeMB,
    );
  }

  @override
  String toString() {
    return '''
StorageSettings(
autoDownloadPhotos: $autoDownloadPhotos,
autoDownloadVideos: $autoDownloadVideos,
autoDownloadDocuments: $autoDownloadDocuments,
autoDownloadAudio: $autoDownloadAudio,
useLessDataForCalls: $useLessDataForCalls,
wifiOnlyDownloads: $wifiOnlyDownloads,
mobileDataDownloads: $mobileDataDownloads,
roamingDownloads: $roamingDownloads,
storageUsedMB: $storageUsedMB,
cacheSizeMB: $cacheSizeMB,
mediaSizeMB: $mediaSizeMB
)
''';
  }
}