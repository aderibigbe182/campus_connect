import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import 'storage_service.dart';
import '../../models/conversation_model.dart';

class ConversationService {

  Future<List<ConversationModel>> getConversations() async {

    final token = await StorageService.getToken();

    final response = await http.get(

      Uri.parse(

        "${ApiConstants.baseUrl}/api/chat/conversations",

      ),

      headers: {

        "Authorization": "Bearer $token",

      },

    );

    if (response.statusCode == 200) {

      final List data = jsonDecode(response.body);

      return data

          .map(

            (e) => ConversationModel.fromJson(e),

          )

          .toList();

    }

    throw Exception("Failed to load conversations");

  }

}