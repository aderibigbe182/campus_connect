import 'dart:convert';

import 'package:http/http.dart' as http;

import '../services/storage_service.dart';
import '../../models/help_feedback_model.dart';

class HelpFeedbackSettingsService {
  static const String baseUrl =
      "https://campus-connect-backend-6pwg.onrender.com";

  static Future<HelpFeedbackSettings?> getSettings() async {
    try {
      final token = await StorageService.getToken();

      if (token == null) return null;

      final response = await http.get(
        Uri.parse(
          "$baseUrl/api/users/help-feedback-settings",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        return HelpFeedbackSettings.fromJson(json);
      }

      return null;
    } catch (e) {
      print("Help & Feedback GET Error: $e");
      return null;
    }
  }

  static Future<bool> updateSettings(
    HelpFeedbackSettings settings,
  ) async {
    try {
      final token = await StorageService.getToken();

      if (token == null) return false;

      final response = await http.put(
        Uri.parse(
          "$baseUrl/api/users/help-feedback-settings",
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
      print("Help & Feedback PUT Error: $e");
      return false;
    }
  }

  static Future<bool> sendFeedback({
    required String subject,
    required String message,
  }) async {
    try {
      final token = await StorageService.getToken();

      if (token == null) return false;

      final response = await http.post(
        Uri.parse(
          "$baseUrl/api/users/send-feedback",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "subject": subject,
          "message": message,
        }),
      );

      return response.statusCode == 200 ||
          response.statusCode == 201;
    } catch (e) {
      print("Send Feedback Error: $e");
      return false;
    }
  }

  static Future<bool> testConnection() async {
    try {
      final token = await StorageService.getToken();

      if (token == null) return false;

      final response = await http.get(
        Uri.parse(
          "$baseUrl/api/users/help-feedback-settings",
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