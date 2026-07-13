import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/services/storage_service.dart';
import '../../../core/constants/api_constants.dart';

import '../models/chat_model.dart';

class ChatService {
  Future<List<ChatModel>> getChats() async {
    final token = await StorageService.getToken();

    final response = await http.get(
      Uri.parse("${ApiConstants.baseUrl}/api/chat/conversations"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load chats");
    }

    final body = jsonDecode(response.body);

    return (body["chats"] as List)
        .map((e) => ChatModel.fromJson(e))
        .toList();
  }
}
