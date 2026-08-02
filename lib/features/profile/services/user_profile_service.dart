import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/services/storage_service.dart';
import '../models/user_profile_model.dart';

class UserProfileService {
  static const String baseUrl =
      "https://campus-connect-backend-6pwg.onrender.com";

  /// ===========================
  /// Get another user's profile
  /// ===========================
  static Future<UserProfileModel> getUserProfile(
    int userId,
  ) async {
    final token = await StorageService.getToken();

    final response = await http.get(
      Uri.parse(
        "$baseUrl/api/users/$userId",
      ),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return UserProfileModel.fromJson(
        jsonDecode(response.body),
      );
    }

    throw Exception(
      "Failed to load user profile.",
    );
  }

  /// ======================================
  /// Get existing conversation or create one
  /// ======================================
  static Future<int> getOrCreateConversation(
    int userId,
  ) async {
    final token = await StorageService.getToken();

    final response = await http.post(
      Uri.parse(
        "$baseUrl/api/chat/conversation/$userId",
      ),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final json =
          jsonDecode(response.body);

      return json["conversationId"];
    }

    throw Exception(
      "Unable to create conversation.",
    );
  }
}