import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../../../core/services/storage_service.dart';

import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../models/reply_message_model.dart';

class ChatService {
  ChatService._();

  static final ChatService instance = ChatService._();

  String get _baseUrl => ApiConstants.baseUrl;

  Future<Map<String, String>> _headers({
    bool json = true,
  }) async {
    final token = await StorageService.getToken();

    return {
      if (json) 'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _replyToJson(ReplyMessageModel reply) {
    return {
      'messageId': reply.messageId,
      'sender': reply.sender,
      'message': reply.message,
    };
  }
    // ==========================
  // CHAT LIST
  // ==========================

  Future<List<ChatModel>> getChats() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/chat'),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load chats');
    }

    final List data = jsonDecode(response.body);

    return data
        .map((e) => ChatModel.fromJson(e))
        .toList();
  }

  Future<ChatModel> getChat(String conversationId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/chat/$conversationId'),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load chat');
    }

    return ChatModel.fromJson(
      jsonDecode(response.body),
    );
  }

  Future<List<MessageModel>> getMessages(
    String conversationId,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/chat/$conversationId/messages',
      ),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load messages');
    }

    final List data = jsonDecode(response.body);

    return data
        .map((e) => MessageModel.fromJson(e))
        .toList();
  }
  // ==========================
  // CONVERSATION
  // ==========================

  Future<MessageModel> sendTextMessage({
    required String conversationId,
    required String message,
    ReplyMessageModel? reply,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$_baseUrl/chat/$conversationId/messages/text',
      ),
      headers: await _headers(),
      body: jsonEncode({
        'message': message,
        if (reply != null) 'reply': _replyToJson(reply),
      }),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception('Failed to send message');
    }

    return MessageModel.fromJson(
      jsonDecode(response.body),
    );
  }

  Future<void> deleteMessageSimple({
    required String conversationId,
    required String messageId,
  }) async {
    final response = await http.delete(
      Uri.parse(
        '$_baseUrl/chat/$conversationId/messages/$messageId',
      ),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete message');
    }
  }

  Future<void> editMessagePatch({
    required String conversationId,
    required String messageId,
    required String message,
  }) async {
    final response = await http.patch(
      Uri.parse(
        '$_baseUrl/chat/$conversationId/messages/$messageId',
      ),
      headers: await _headers(),
      body: jsonEncode({
        'message': message,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to edit message');
    }
  }
  // ==========================
  // MEDIA MESSAGES
  // ==========================

  Future<MessageModel> sendImageMessage({
    required String conversationId,
    required File image,
    String? caption,
    ReplyMessageModel? reply,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        '$_baseUrl/chat/$conversationId/messages/image',
      ),
    );

    request.headers.addAll(await _headers(json: false));

    request.fields['caption'] = caption ?? '';

    if (reply != null) {
      request.fields['reply'] =
          jsonEncode(_replyToJson(reply));
    }

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        image.path,
      ),
    );

    final streamed = await request.send();

    final response =
        await http.Response.fromStream(streamed);

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception('Failed to send image');
    }

    return MessageModel.fromJson(
      jsonDecode(response.body),
    );
  }

  Future<MessageModel> sendFileMessage({
    required String conversationId,
    required File file,
    ReplyMessageModel? reply,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        '$_baseUrl/chat/$conversationId/messages/file',
      ),
    );

    request.headers.addAll(await _headers(json: false));

    if (reply != null) {
      request.fields['reply'] =
          jsonEncode(_replyToJson(reply));
    }

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
      ),
    );

    final streamed = await request.send();

    final response =
        await http.Response.fromStream(streamed);

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception('Failed to send file');
    }

    return MessageModel.fromJson(
      jsonDecode(response.body),
    );
  }

  Future<MessageModel> sendVoiceMessage({
    required String conversationId,
    required File audio,
    ReplyMessageModel? reply,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        '$_baseUrl/chat/$conversationId/messages/voice',
      ),
    );

    request.headers.addAll(await _headers(json: false));

    if (reply != null) {
      request.fields['reply'] =
          jsonEncode(_replyToJson(reply));
    }

    request.files.add(
      await http.MultipartFile.fromPath(
        'audio',
        audio.path,
      ),
    );

    final streamed = await request.send();

    final response =
        await http.Response.fromStream(streamed);

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception('Failed to send voice message');
    }

    return MessageModel.fromJson(
      jsonDecode(response.body),
    );
  }
    // ==========================
  // DELETE / EDIT MESSAGES
  // ==========================

  Future<void> deleteMessage({
    required String conversationId,
    required String messageId,
    bool deleteForEveryone = false,
  }) async {
    final response = await http.delete(
      Uri.parse(
        '$_baseUrl/chat/$conversationId/messages/$messageId',
      ),
      headers: await _headers(),
      body: jsonEncode({
        'deleteForEveryone': deleteForEveryone,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete message');
    }
  }

  Future<MessageModel> editMessage({
    required String conversationId,
    required String messageId,
    required String newMessage,
  }) async {
    final response = await http.put(
      Uri.parse(
        '$_baseUrl/chat/$conversationId/messages/$messageId',
      ),
      headers: await _headers(),
      body: jsonEncode({
        'message': newMessage,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to edit message');
    }

    return MessageModel.fromJson(
      jsonDecode(response.body),
    );
  }

  Future<void> markMessageAsRead({
    required String conversationId,
    required String messageId,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$_baseUrl/chat/$conversationId/messages/$messageId/read',
      ),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark message as read');
    }
  }
    // ==========================
  // REACTIONS & TYPING
  // ==========================

  Future<void> addReaction({
    required String conversationId,
    required String messageId,
    required String reaction,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$_baseUrl/chat/$conversationId/messages/$messageId/reaction',
      ),
      headers: await _headers(),
      body: jsonEncode({
        'reaction': reaction,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add reaction');
    }
  }

  Future<void> removeReaction({
    required String conversationId,
    required String messageId,
  }) async {
    final response = await http.delete(
      Uri.parse(
        '$_baseUrl/chat/$conversationId/messages/$messageId/reaction',
      ),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to remove reaction');
    }
  }

  Future<void> sendTypingStatus({
    required String conversationId,
    required bool typing,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$_baseUrl/chat/$conversationId/typing',
      ),
      headers: await _headers(),
      body: jsonEncode({
        'typing': typing,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update typing status');
    }
  }
    // ==========================
  // CHAT MANAGEMENT
  // ==========================

  Future<void> muteChat({
    required String conversationId,
    required bool muted,
  }) async {
    final response = await http.patch(
      Uri.parse(
        '$_baseUrl/chat/$conversationId/mute',
      ),
      headers: await _headers(),
      body: jsonEncode({
        'muted': muted,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update mute status');
    }
  }

  Future<void> archiveChat({
    required String conversationId,
    required bool archived,
  }) async {
    final response = await http.patch(
      Uri.parse(
        '$_baseUrl/chat/$conversationId/archive',
      ),
      headers: await _headers(),
      body: jsonEncode({
        'archived': archived,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to archive chat');
    }
  }

  Future<void> pinChat({
    required String conversationId,
    required bool pinned,
  }) async {
    final response = await http.patch(
      Uri.parse(
        '$_baseUrl/chat/$conversationId/pin',
      ),
      headers: await _headers(),
      body: jsonEncode({
        'pinned': pinned,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to pin chat');
    }
  }

  Future<void> clearChat({
    required String conversationId,
  }) async {
    final response = await http.delete(
      Uri.parse(
        '$_baseUrl/chat/$conversationId/clear',
      ),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to clear chat');
    }
  }

  Future<void> blockUser({
    required String userId,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$_baseUrl/users/$userId/block',
      ),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to block user');
    }
  }

  Future<List<ChatModel>> searchChats(
    String query,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/chat/search?q=$query',
      ),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to search chats');
    }

    final List data = jsonDecode(response.body);

    return data
        .map((e) => ChatModel.fromJson(e))
        .toList();
  }
}