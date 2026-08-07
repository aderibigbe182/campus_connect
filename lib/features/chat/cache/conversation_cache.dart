import 'package:hive/hive.dart';

@HiveType(typeId: 10)
class ConversationCache extends HiveObject {
  static const int typeId = 10;
  @HiveField(0)
  String conversationId;

  @HiveField(1)
  String otherUserName;

  @HiveField(2)
  int otherUserId;

  @HiveField(3)
  String? lastMessage;

  @HiveField(4)
  DateTime updatedAt;

  @HiveField(5)
  int unreadCount;

  ConversationCache({
    required this.conversationId,
    required this.otherUserName,
    required this.otherUserId,
    this.lastMessage,
    required this.updatedAt,
    required this.unreadCount,
  });
}