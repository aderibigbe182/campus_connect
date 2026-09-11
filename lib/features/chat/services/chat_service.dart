import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../../../core/services/storage_service.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatService {
  ChatService._();

  static final ChatService instance = ChatService._();

  Future<Map<String, String>> _headers() async {
    final token = await StorageService.getToken();

    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }

  Future<List<ChatModel>> getChats() async {
    final response = await http.get(
      Uri.parse(
        '${ApiConstants.pythonApi}/conversations/',
      ),
      headers: await _headers(),
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Failed to load chats: ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      return [];
    }

    return decoded
        .map(
          (item) => ChatModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<ChatModel> startConversation({
    required int userId,
  }) async {
    final response = await http.post(
      Uri.parse(
        '${ApiConstants.pythonApi}/conversations/start',
      ),
      headers: await _headers(),
      body: jsonEncode({
        'user_id': userId,
      }),
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Failed to start conversation: ${response.body}',
      );
    }

    return ChatModel.fromJson(
      Map<String, dynamic>.from(
        jsonDecode(response.body),
      ),
    );
  }

  Future<List<MessageModel>> getMessages({
    required int conversationId,
    int limit = 50,
    int offset = 0,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.pythonApi}/messages/conversation/$conversationId',
    ).replace(
      queryParameters: {
        'limit': '$limit',
        'offset': '$offset',
      },
    );

    final response = await http.get(
      uri,
      headers: await _headers(),
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Failed to load messages: ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      return [];
    }

    return decoded
        .map(
          (item) => MessageModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<MessageModel> sendMessage({
    required int receiverId,
    required String content,
    int? replyToMessageId,
  }) async {
    final response = await http.post(
      Uri.parse(
        '${ApiConstants.pythonApi}/messages/send',
      ),
      headers: await _headers(),
      body: jsonEncode({
        'receiver_id': receiverId,
        'content': content,
        if (replyToMessageId != null)
          'reply_to_message_id': replyToMessageId,
      }),
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Failed to send message: ${response.body}',
      );
    }

    return MessageModel.fromJson(
      Map<String, dynamic>.from(
        jsonDecode(response.body),
      ),
    );
  }

  Future<MessageModel> editMessage({
    required int messageId,
    required String content,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.pythonApi}/messages/$messageId/edit',
    ).replace(
      queryParameters: {
        'content': content,
      },
    );

    final response = await http.patch(
      uri,
      headers: await _headers(),
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Failed to edit message: ${response.body}',
      );
    }

    return MessageModel.fromJson(
      Map<String, dynamic>.from(
        jsonDecode(response.body),
      ),
    );
  }

  Future<void> deleteForMe({
    required int messageId,
  }) async {
    final response = await http.delete(
      Uri.parse(
        '${ApiConstants.pythonApi}/messages/$messageId/me',
      ),
      headers: await _headers(),
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Failed to delete message: ${response.body}',
      );
    }
  }

  Future<void> deleteForEveryone({
    required int messageId,
  }) async {
    final response = await http.delete(
      Uri.parse(
        '${ApiConstants.pythonApi}/messages/$messageId/everyone',
      ),
      headers: await _headers(),
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Failed to delete message: ${response.body}',
      );
    }
  }

  Future<void> markDelivered({
    required int messageId,
  }) async {
    final response = await http.patch(
      Uri.parse(
        '${ApiConstants.pythonApi}/messages/$messageId/deliver',
      ),
      headers: await _headers(),
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Failed to mark message delivered: ${response.body}',
      );
    }
  }

  Future<void> markRead({
    required int messageId,
  }) async {
    final response = await http.patch(
      Uri.parse(
        '${ApiConstants.pythonApi}/messages/$messageId/read',
      ),
      headers: await _headers(),
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Failed to mark message read: ${response.body}',
      );
    }
  }
}