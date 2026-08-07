import 'package:hive_flutter/hive_flutter.dart';

import '../models/message_model.dart';

class MessageCacheService {
  MessageCacheService._();

  static final instance = MessageCacheService._();

  Future<Box> _box() async {
    return await Hive.openBox("message_cache");
  }

  Future<void> saveMessages(
    int conversationId,
    List<MessageModel> messages,
  ) async {
    final box = await _box();

    final json = messages
        .map((e) => e.toJson())
        .toList();

    await box.put(
      conversationId.toString(),
      json,
    );
  }

  Future<List<MessageModel>> getMessages(
    int conversationId,
  ) async {
    final box = await _box();

    final data =
        box.get(conversationId.toString());

    if (data == null) {
      return [];
    }

    return (data as List)
        .map(
          (e) => MessageModel.fromJson(
            Map<String, dynamic>.from(e),
          ),
        )
        .toList();
  }

  Future<void> clearConversation(
    int conversationId,
  ) async {
    final box = await _box();

    await box.delete(
      conversationId.toString(),
    );
  }
}