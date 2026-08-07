import 'package:hive/hive.dart';

class ChatCacheService {
  ChatCacheService._();

  static final ChatCacheService instance =
      ChatCacheService._();

  final Box _box = Hive.box("chat_cache");

  // ===========================
  // Messages
  // ===========================

  Future<void> saveMessages(
    int conversationId,
    List<Map<String, dynamic>> messages,
  ) async {
    await _box.put(
      "messages_$conversationId",
      messages,
    );
  }

  List<Map<String, dynamic>> loadMessages(
    int conversationId,
  ) {
    final data =
        _box.get("messages_$conversationId");

    if (data == null) {
      return [];
    }

    return List<Map<String, dynamic>>.from(data);
  }

  // ===========================
  // Chats
  // ===========================

  Future<void> saveChats(
    List<Map<String, dynamic>> chats,
  ) async {
    await _box.put(
      "chat_list",
      chats,
    );
  }

  List<Map<String, dynamic>> loadChats() {
    final data = _box.get("chat_list");

    if (data == null) {
      return [];
    }

    return List<Map<String, dynamic>>.from(data);
  }

  // ===========================
  // Clear
  // ===========================

  Future<void> clear() async {
    await _box.clear();
  }
  
}