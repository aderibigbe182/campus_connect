import 'dart:convert';

import 'package:http/http.dart' as http;

import '../services/storage_service.dart';
import '../../models/privacy_settings.dart';

class PrivacySettingsService {
  static const String baseUrl =
      "https://campus-connect-backend-6pwg.onrender.com";

  static Future<PrivacySettings?> getSettings() async {
    try {
      final token = await StorageService.getToken();

      if (token == null) return null;

      final response = await http.get(
        Uri.parse(
          "$baseUrl/api/users/privacy-settings",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        return PrivacySettings.fromJson(json);
      }

      return null;
    } catch (e) {
      print("Privacy GET Error: $e");
      return null;
    }
  }

  static Future<bool> updateSettings(
    PrivacySettings settings,
  ) async {
    try {
      final token = await StorageService.getToken();

      if (token == null) return false;

      final response = await http.put(
        Uri.parse(
          "$baseUrl/api/users/privacy-settings",
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
      print("Privacy PUT Error: $e");
      return false;
    }
  }

  static Future<bool> resetSettings() async {
    try {
      final token = await StorageService.getToken();

      if (token == null) return false;

      final response = await http.put(
        Uri.parse(
          "$baseUrl/api/users/privacy-settings/reset",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Privacy Reset Error: $e");
      return false;
    }
  }

  static Future<bool> testConnection() async {
    try {
      final token = await StorageService.getToken();

      if (token == null) return false;

      final response = await http.get(
        Uri.parse(
          "$baseUrl/api/users/privacy-settings",
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