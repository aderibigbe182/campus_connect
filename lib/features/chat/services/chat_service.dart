import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../../../core/services/storage_service.dart';
import '../models/message_model.dart';

class ChatService {
  ChatService._();

  static final ChatService instance = ChatService._();

  final StorageService _storage = StorageService();

  String get _baseUrl => ApiConstants.baseUrl;

  Future<Map<String, String>> _headers() async {
    final token = await _storage.getToken();

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ==========================================================
  // LOAD CONVERSATION
  // ==========================================================

  Future<List<MessageModel>> getConversation(
    String conversationId,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/api/chat/conversations/$conversationId/messages',
      ),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load conversation');
    }

    final body = jsonDecode(response.body);

    final List data =
        body is List ? body : (body['messages'] ?? []);

    return data
        .map((e) => MessageModel.fromJson(e))
        .toList();
  }

  // ==========================================================
  // LOAD RECENT CHATS
  // ==========================================================

  Future<List<dynamic>> getConversations() async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/api/chat/conversations',
      ),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load conversations');
    }

    final body = jsonDecode(response.body);

    if (body is List) return body;

    return body['conversations'] ?? [];
  }

  // ==========================================================
  // LOAD OLDER MESSAGES (PAGINATION)
  // ==========================================================

  Future<List<MessageModel>> loadOlderMessages({
    required String conversationId,
    required int page,
    int limit = 30,
  }) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/api/chat/conversations/$conversationId/messages?page=$page&limit=$limit',
      ),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load older messages');
    }

    final body = jsonDecode(response.body);

    final List data =
        body is List ? body : (body['messages'] ?? []);

    return data
        .map((e) => MessageModel.fromJson(e))
        .toList();
  }
}
  // ==========================================================
  // SEND TEXT MESSAGE
  // ==========================================================

  Future<MessageModel> sendMessage({
    required String conversationId,
    required String message,
    ReplyMessageModel? reply,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$_baseUrl/api/chat/messages/send',
      ),
      headers: await _headers(),
      body: jsonEncode({
        "conversation_id": conversationId,
        "message": message,
        "reply": reply?.toJson(),
      }),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception("Failed to send message");
    }

    return MessageModel.fromJson(
      jsonDecode(response.body),
    );
  }

  // ==========================================================
  // SEND IMAGE
  // ==========================================================

  Future<MessageModel> sendImage({
    required String conversationId,
    required String imageUrl,
    String? caption,
    ReplyMessageModel? reply,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$_baseUrl/api/chat/messages/image',
      ),
      headers: await _headers(),
      body: jsonEncode({
        "conversation_id": conversationId,
        "image_url": imageUrl,
        "caption": caption,
        "reply": reply?.toJson(),
      }),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception("Failed to send image");
    }

    return MessageModel.fromJson(
      jsonDecode(response.body),
    );
  }

  // ==========================================================
  // SEND FILE
  // ==========================================================

  Future<MessageModel> sendFile({
    required String conversationId,
    required String fileUrl,
    required String fileName,
    required int fileSize,
    ReplyMessageModel? reply,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$_baseUrl/api/chat/messages/file',
      ),
      headers: await _headers(),
      body: jsonEncode({
        "conversation_id": conversationId,
        "file_url": fileUrl,
        "file_name": fileName,
        "file_size": fileSize,
        "reply": reply?.toJson(),
      }),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception("Failed to send file");
    }

    return MessageModel.fromJson(
      jsonDecode(response.body),
    );
  }

  // ==========================================================
  // EDIT MESSAGE
  // ==========================================================

  Future<void> editMessage({
    required String messageId,
    required String newMessage,
  }) async {
    final response = await http.put(
      Uri.parse(
        '$_baseUrl/api/chat/messages/$messageId',
      ),
      headers: await _headers(),
      body: jsonEncode({
        "message": newMessage,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to edit message");
    }
  }

  // ==========================================================
  // DELETE MESSAGE
  // ==========================================================

  Future<void> deleteMessage(
    String messageId,
  ) async {
    final response = await http.delete(
      Uri.parse(
        '$_baseUrl/api/chat/messages/$messageId',
      ),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to delete message");
    }
  }

  // ==========================================================
  // REACT TO MESSAGE
  // ==========================================================

  Future<void> reactToMessage({
    required String messageId,
    required String emoji,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$_baseUrl/api/chat/messages/$messageId/reaction',
      ),
      headers: await _headers(),
      body: jsonEncode({
        "emoji": emoji,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to react");
    }
  }

  // ==========================================================
  // REMOVE REACTION
  // ==========================================================

  Future<void> removeReaction(
    String messageId,
  ) async {
    final response = await http.delete(
      Uri.parse(
        '$_baseUrl/api/chat/messages/$messageId/reaction',
      ),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to remove reaction");
    }
  }
  // ==========================================
// MESSAGE REACTIONS
// ==========================================

Future<bool> addReaction({
  required String conversationId,
  required String messageId,
  required String emoji,
}) async {
  final token = await StorageService.getToken();

  final response = await http.post(
    Uri.parse(
      "$baseUrl/api/chat/$conversationId/messages/$messageId/reactions",
    ),
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "emoji": emoji,
    }),
  );

  return response.statusCode == 200;
}

Future<bool> removeReaction({
  required String conversationId,
  required String messageId,
}) async {
  final token = await StorageService.getToken();

  final response = await http.delete(
    Uri.parse(
      "$baseUrl/api/chat/$conversationId/messages/$messageId/reactions",
    ),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  return response.statusCode == 200;
}

Future<List<Map<String, dynamic>>> getReactionUsers({
  required String conversationId,
  required String messageId,
}) async {
  final token = await StorageService.getToken();

  final response = await http.get(
    Uri.parse(
      "$baseUrl/api/chat/$conversationId/messages/$messageId/reactions",
    ),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    return List<Map<String, dynamic>>.from(
      data["users"] ?? [],
    );
  }

  return [];
}
// ==========================================
// TYPING INDICATOR
// ==========================================

Future<void> startTyping({
  required String conversationId,
}) async {
  final token = await StorageService.getToken();

  await http.post(
    Uri.parse(
      "$baseUrl/api/chat/$conversationId/typing/start",
    ),
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
  );
}

Future<void> stopTyping({
  required String conversationId,
}) async {
  final token = await StorageService.getToken();

  await http.post(
    Uri.parse(
      "$baseUrl/api/chat/$conversationId/typing/stop",
    ),
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
  );
}

// ==========================================
// READ RECEIPTS
// ==========================================

Future<bool> markMessageAsRead({
  required String conversationId,
  required String messageId,
}) async {
  final token = await StorageService.getToken();

  final response = await http.post(
    Uri.parse(
      "$baseUrl/api/chat/$conversationId/messages/$messageId/read",
    ),
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
  );

  return response.statusCode == 200;
}

Future<bool> markConversationAsRead({
  required String conversationId,
}) async {
  final token = await StorageService.getToken();

  final response = await http.post(
    Uri.parse(
      "$baseUrl/api/chat/$conversationId/read",
    ),
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
  );

  return response.statusCode == 200;
}
// ==========================================
// SEARCH MESSAGES
// ==========================================

Future<List<MessageModel>> searchMessages({
  required String conversationId,
  required String query,
}) async {
  final token = await StorageService.getToken();

  final response = await http.get(
    Uri.parse(
      "$baseUrl/api/chat/$conversationId/search?query=$query",
    ),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    return (data["messages"] as List)
        .map((e) => MessageModel.fromJson(e))
        .toList();
  }

  return [];
}

// ==========================================
// PIN CHAT
// ==========================================

Future<bool> pinConversation(
  String conversationId,
) async {
  final token = await StorageService.getToken();

  final response = await http.post(
    Uri.parse(
      "$baseUrl/api/chat/$conversationId/pin",
    ),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  return response.statusCode == 200;
}

// ==========================================
// UNPIN CHAT
// ==========================================

Future<bool> unpinConversation(
  String conversationId,
) async {
  final token = await StorageService.getToken();

  final response = await http.delete(
    Uri.parse(
      "$baseUrl/api/chat/$conversationId/pin",
    ),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  return response.statusCode == 200;
}

// ==========================================
// MUTE CHAT
// ==========================================

Future<bool> muteConversation(
  String conversationId,
) async {
  final token = await StorageService.getToken();

  final response = await http.post(
    Uri.parse(
      "$baseUrl/api/chat/$conversationId/mute",
    ),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  return response.statusCode == 200;
}

// ==========================================
// UNMUTE CHAT
// ==========================================

Future<bool> unmuteConversation(
  String conversationId,
) async {
  final token = await StorageService.getToken();

  final response = await http.delete(
    Uri.parse(
      "$baseUrl/api/chat/$conversationId/mute",
    ),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  return response.statusCode == 200;
}
// ==========================================
// ARCHIVE CHAT
// ==========================================

Future<bool> archiveConversation(
  String conversationId,
) async {
  final token = await StorageService.getToken();

  final response = await http.post(
    Uri.parse(
      "$baseUrl/api/chat/$conversationId/archive",
    ),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  return response.statusCode == 200;
}

// ==========================================
// UNARCHIVE CHAT
// ==========================================

Future<bool> unarchiveConversation(
  String conversationId,
) async {
  final token = await StorageService.getToken();

  final response = await http.delete(
    Uri.parse(
      "$baseUrl/api/chat/$conversationId/archive",
    ),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  return response.statusCode == 200;
}

// ==========================================
// DELETE CONVERSATION
// ==========================================

Future<bool> deleteConversation(
  String conversationId,
) async {
  final token = await StorageService.getToken();

  final response = await http.delete(
    Uri.parse(
      "$baseUrl/api/chat/$conversationId",
    ),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  return response.statusCode == 200;
}

// ==========================================
// CLEAR CHAT
// ==========================================

Future<bool> clearConversation(
  String conversationId,
) async {
  final token = await StorageService.getToken();

  final response = await http.delete(
    Uri.parse(
      "$baseUrl/api/chat/$conversationId/messages",
    ),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  return response.statusCode == 200;
}
// ==========================================
// BLOCK USER
// ==========================================

Future<bool> blockUser({
  required String userId,
}) async {
  final token = await StorageService.getToken();

  final response = await http.post(
    Uri.parse(
      "$baseUrl/api/chat/block/$userId",
    ),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  return response.statusCode == 200;
}

// ==========================================
// UNBLOCK USER
// ==========================================

Future<bool> unblockUser({
  required String userId,
}) async {
  final token = await StorageService.getToken();

  final response = await http.delete(
    Uri.parse(
      "$baseUrl/api/chat/block/$userId",
    ),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  return response.statusCode == 200;
}

// ==========================================
// REPORT USER
// ==========================================

Future<bool> reportUser({
  required String userId,
  required String reason,
}) async {
  final token = await StorageService.getToken();

  final response = await http.post(
    Uri.parse(
      "$baseUrl/api/chat/report",
    ),
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "user_id": userId,
      "reason": reason,
    }),
  );

  return response.statusCode == 200;
}

// ==========================================
// LEAVE CONVERSATION
// ==========================================

Future<bool> leaveConversation(
  String conversationId,
) async {
  final token = await StorageService.getToken();

  final response = await http.post(
    Uri.parse(
      "$baseUrl/api/chat/$conversationId/leave",
    ),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  return response.statusCode == 200;
}
// ==========================================
// FORWARD MESSAGE
// ==========================================

Future<bool> forwardMessage({
  required String messageId,
  required List<String> conversationIds,
}) async {
  final token = await StorageService.getToken();

  final response = await http.post(
    Uri.parse(
      "$baseUrl/api/chat/messages/$messageId/forward",
    ),
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "conversation_ids": conversationIds,
    }),
  );

  return response.statusCode == 200;
}

// ==========================================
// STAR MESSAGE
// ==========================================

Future<bool> starMessage(
  String messageId,
) async {
  final token = await StorageService.getToken();

  final response = await http.post(
    Uri.parse(
      "$baseUrl/api/chat/messages/$messageId/star",
    ),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  return response.statusCode == 200;
}

// ==========================================
// UNSTAR MESSAGE
// ==========================================

Future<bool> unstarMessage(
  String messageId,
) async {
  final token = await StorageService.getToken();

  final response = await http.delete(
    Uri.parse(
      "$baseUrl/api/chat/messages/$messageId/star",
    ),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  return response.statusCode == 200;
}

// ==========================================
// GET STARRED MESSAGES
// ==========================================

Future<List<MessageModel>> getStarredMessages() async {
  final token = await StorageService.getToken();

  final response = await http.get(
    Uri.parse(
      "$baseUrl/api/chat/messages/starred",
    ),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    return (data["messages"] as List)
        .map((e) => MessageModel.fromJson(e))
        .toList();
  }

  return [];
}

// ==========================================
// DISPOSE / CLEANUP
// ==========================================

void dispose() {
  // Reserved for future stream controllers or socket listeners.
}