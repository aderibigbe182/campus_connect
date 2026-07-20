import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';

class SendMessageService {
  static Future<bool> sendMessage({
    required int conversationId,
    required String message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
          "${ApiConstants.baseUrl}/chat/conversations/$conversationId/messages",
        ),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "message": message,
        }),
      );

      return response.statusCode == 200 ||
          response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }
}