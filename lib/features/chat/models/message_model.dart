class MessageModel {
  final int id;
  final int conversationId;
  final int senderId;
  final String content;

  final bool isDelivered;
  final DateTime? deliveredAt;

  final bool isRead;
  final DateTime? readAt;

  final bool isEdited;
  final DateTime? editedAt;

  final bool isForwarded;
  final int? forwardedFromMessageId;

  final bool isDeleted;
  final DateTime? deletedAt;
  final bool deletedForEveryone;

  final List<MessageMedia> media;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.isDelivered,
    this.deliveredAt,
    required this.isRead,
    this.readAt,
    required this.isEdited,
    this.editedAt,
    required this.isForwarded,
    this.forwardedFromMessageId,
    required this.isDeleted,
    this.deletedAt,
    required this.deletedForEveryone,
    required this.media,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final mediaJson = json['media'];
    final statuses = json['statuses'] is List ? json['statuses'] as List : const [];
    final hasDelivered = statuses.whereType<Map>().any((s) => s['status'] == 'delivered' || s['status'] == 'read');
    final hasRead = statuses.whereType<Map>().any((s) => s['status'] == 'read');
    final mediaUrl = json['media_url']?.toString();

    return MessageModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      conversationId: (json['conversation_id'] as num?)?.toInt() ??
          (json['chat_id'] as num?)?.toInt() ?? 0,
      senderId:
          (json['sender_id'] as num?)?.toInt() ?? 0,
      content: json['content']?.toString() ?? '',
      isDelivered: json['is_delivered'] == true || hasDelivered,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.tryParse(
              json['delivered_at'].toString(),
            )
          : null,
      isRead: json['is_read'] == true || hasRead,
      readAt: json['read_at'] != null
          ? DateTime.tryParse(
              json['read_at'].toString(),
            )
          : null,
      isEdited: json['is_edited'] == true,
      editedAt: json['edited_at'] != null
          ? DateTime.tryParse(
              json['edited_at'].toString(),
            )
          : json['updated_at'] != null && json['is_edited'] == true
              ? DateTime.tryParse(json['updated_at'].toString())
              : null,
      isForwarded: json['is_forwarded'] == true,
      forwardedFromMessageId:
          (json['forwarded_from_message_id'] as num?)?.toInt(),
      isDeleted: json['is_deleted'] == true || json['deleted_for_everyone'] == true,
      deletedAt: json['deleted_at'] != null
          ? DateTime.tryParse(
              json['deleted_at'].toString(),
            )
          : null,
      deletedForEveryone:
          json['deleted_for_everyone'] == true,
      media: mediaJson is List
          ? mediaJson
              .map(
                (e) => MessageMedia.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList()
          : mediaUrl != null && mediaUrl.isNotEmpty
              ? [MessageMedia(id: 0, fileName: '', filePath: mediaUrl,
                  fileType: json['media_mime']?.toString(), fileSize: 0,
                  isViewOnce: json['is_view_once'] == true, hasBeenViewed: false)]
          : const [],
      createdAt: DateTime.tryParse(
            json['created_at']?.toString() ?? '',
          ) ??
          DateTime.now(),
    );
  }
}

class MessageMedia {
  final int id;
  final String fileName;
  final String filePath;
  final String? fileType;
  final int fileSize;
  final bool isViewOnce;
  final bool hasBeenViewed;
  final DateTime? viewedAt;

  const MessageMedia({
    required this.id,
    required this.fileName,
    required this.filePath,
    this.fileType,
    required this.fileSize,
    required this.isViewOnce,
    required this.hasBeenViewed,
    this.viewedAt,
  });

  factory MessageMedia.fromJson(Map<String, dynamic> json) {
    return MessageMedia(
      id: (json['id'] as num?)?.toInt() ?? 0,
      fileName: json['file_name']?.toString() ?? '',
      filePath: json['file_path']?.toString() ?? '',
      fileType: json['file_type']?.toString(),
      fileSize:
          (json['file_size'] as num?)?.toInt() ?? 0,
      isViewOnce: json['is_view_once'] == true,
      hasBeenViewed: json['has_been_viewed'] == true,
      viewedAt: json['viewed_at'] != null
          ? DateTime.tryParse(
              json['viewed_at'].toString(),
            )
          : null,
    );
  }
}
