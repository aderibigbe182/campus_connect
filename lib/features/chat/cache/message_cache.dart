import 'package:hive/hive.dart';

part 'message_cache.g.dart';

@HiveType(typeId: 11)
class MessageCache extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  int conversationId;

  @HiveField(2)
  int senderId;

  @HiveField(3)
  String? message;

  @HiveField(4)
  String messageType;

  @HiveField(5)
  bool delivered;

  @HiveField(6)
  bool seen;

  @HiveField(7)
  DateTime createdAt;

  MessageCache({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.message,
    required this.messageType,
    required this.delivered,
    required this.seen,
    required this.createdAt,
  });
}