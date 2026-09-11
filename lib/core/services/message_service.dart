import 'dart:convert';

import 'package:http/http.dart' as http;

import 'storage_service.dart';
import '/features/chat/models/message_model.dart';

class MessageService {

  String get _baseUrl => 'https://campus-connect-api.onrender.com';

  Future<List<MessageModel>> getMessages(
  int conversationId, {
  int page = 1,
  int limit = 30,
}) async {
    final token = await StorageService.getToken();

    final response = await http.get(

      Uri.parse(

        "$_baseUrl/api/messages/$conversationId",

      ),

      headers: {

        "Authorization": "Bearer $token",

      },

    );

    if (response.statusCode == 200) {

      final List data = jsonDecode(

        response.body,

      );

      return data

          .map(

            (e) => MessageModel.fromJson(e),

          )

          .toList();

    }

    throw Exception(

      "Failed to load messages",

    );

  }

  Future<MessageModel> sendMessage({

    required int conversationId,

    required String message,

    String messageType = "text",

  }) async {

    final token = await StorageService.getToken();

    final response = await http.post(

      Uri.parse(

        "$_baseUrl/api/messages",

      ),

      headers: {

        "Authorization": "Bearer $token",

        "Content-Type": "application/json",

      },

      body: jsonEncode({

        "conversation_id": conversationId,

        "message": message,

        "message_type": messageType,

      }),

    );

    if (response.statusCode == 201) {

      return MessageModel.fromJson(

        jsonDecode(response.body),

      );

    }

    throw Exception(

      "Failed to send message",

    );

  }

  Future<void> deleteMessage(

    int messageId,

  ) async {

    final token = await StorageService.getToken();

    final response = await http.delete(

      Uri.parse(

        "$_baseUrl/api/messages/$messageId",

      ),

      headers: {

        "Authorization": "Bearer $token",

      },

    );

    if (response.statusCode != 200) {

      throw Exception(

        "Failed to delete message",

      );

    }

  }

}