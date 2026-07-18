import 'dart:convert';

import 'package:http/http.dart' as http;

import '/core/services/storage_service.dart';
import '/features/chat/models/message_model.dart';

class ConversationService {
  static const String baseUrl =
      "https://campus-connect-backend-6pwg.onrender.com/api/chat";

  static Future<List<MessageModel>> getMessages(
      int conversationId) async {
    final token = await StorageService.getToken();

    final response = await http.get(
      Uri.parse(
          "$baseUrl/conversation/$conversationId"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load messages");
    }

    final List data = jsonDecode(response.body);

    return data
        .map(
          (e) => MessageModel.fromJson(e),
        )
        .toList();
  }
}