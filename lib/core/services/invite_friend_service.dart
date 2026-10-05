import 'dart:convert';

import 'package:http/http.dart' as http;

import '../services/storage_service.dart';
import '../../models/invite_friend_model.dart';

class InviteFriendSettingsService {
  static const String baseUrl =
      "https://campus-connect-backend-6pwg.onrender.com";

  static Future<InviteFriendSettings?> getSettings() async {
    try {
      final token = await StorageService.getToken();

      if (token == null) return null;

      final response = await http.get(
        Uri.parse(
          "$baseUrl/api/users/invite-settings",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        return InviteFriendSettings.fromJson(json);
      }

      return null;
    } catch (e) {
      print("Invite Settings GET Error: $e");
      return null;
    }
  }

  static Future<bool> updateSettings(
    InviteFriendSettings settings,
  ) async {
    try {
      final token = await StorageService.getToken();

      if (token == null) return false;

      final response = await http.put(
        Uri.parse(
          "$baseUrl/api/users/invite-settings",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(
          settings.toJson(),
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Invite Settings PUT Error: $e");
      return false;
    }
  }

  static Future<String?> generateInviteLink() async {
    try {
      final token = await StorageService.getToken();

      if (token == null) return null;

      final response = await http.post(
        Uri.parse(
          "$baseUrl/api/users/generate-invite-link",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        return json["invite_link"];
      }

      return null;
    } catch (e) {
      print("Generate Invite Link Error: $e");
      return null;
    }
  }

  static Future<bool> registerInviteSent() async {
    try {
      final token = await StorageService.getToken();

      if (token == null) return false;

      final response = await http.post(
        Uri.parse(
          "$baseUrl/api/users/invite-sent",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      return response.statusCode == 200 ||
          response.statusCode == 201;
    } catch (e) {
      print("Invite Sent Error: $e");
      return false;
    }
  }

  static Future<bool> testConnection() async {
    try {
      final token = await StorageService.getToken();

      if (token == null) return false;

      final response = await http.get(
        Uri.parse(
          "$baseUrl/api/users/invite-settings",
        ),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}