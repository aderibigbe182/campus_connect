import 'dart:convert';

import 'package:http/http.dart' as http;

import '../services/storage_service.dart';
import '../../models/notification_settings.dart';

class NotificationSettingsService {
  static const String baseUrl =
      "https://campus-connect-backend-6pwg.onrender.com";

  static Future<NotificationSettings?> getSettings() async {
    try {
      final token = await StorageService.getToken();

      if (token == null) return null;

      final response = await http.get(
        Uri.parse(
          "$baseUrl/api/users/notification-settings",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        return NotificationSettings.fromJson(json);
      }

      return null;
    } catch (e) {
      print("Notification GET Error: $e");
      return null;
    }
  }

  static Future<bool> updateSettings(
    NotificationSettings settings,
  ) async {
    try {
      final token = await StorageService.getToken();

      if (token == null) return false;

      final response = await http.put(
        Uri.parse(
          "$baseUrl/api/users/notification-settings",
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
      print("Notification PUT Error: $e");
      return false;
    }
  }

  static Future<bool> resetSettings() async {
    try {
      final token = await StorageService.getToken();

      if (token == null) return false;

      final response = await http.put(
        Uri.parse(
          "$baseUrl/api/users/notification-settings/reset",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Notification Reset Error: $e");
      return false;
    }
  }

  static Future<bool> testConnection() async {
    try {
      final token = await StorageService.getToken();

      if (token == null) return false;

      final response = await http.get(
        Uri.parse(
          "$baseUrl/api/users/notification-settings",
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
