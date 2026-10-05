import 'dart:convert';

import 'package:http/http.dart' as http;

import '../services/storage_service.dart';
import '../../models/storage_settings.dart';

class StorageSettingsService {
  static const String baseUrl =
      "https://campus-connect-backend-6pwg.onrender.com";

  static Future<StorageSettings?> getSettings() async {
    try {
      final token = await StorageService.getToken();

      if (token == null) return null;

      final response = await http.get(
        Uri.parse(
          "$baseUrl/api/users/storage-settings",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        return StorageSettings.fromJson(json);
      }

      return null;
    } catch (e) {
      print("Storage GET Error: $e");
      return null;
    }
  }

  static Future<bool> updateSettings(
    StorageSettings settings,
  ) async {
    try {
      final token = await StorageService.getToken();

      if (token == null) return false;

      final response = await http.put(
        Uri.parse(
          "$baseUrl/api/users/storage-settings",
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
      print("Storage PUT Error: $e");
      return false;
    }
  }

  static Future<bool> clearCache() async {
    try {
      final token = await StorageService.getToken();

      if (token == null) return false;

      final response = await http.post(
        Uri.parse(
          "$baseUrl/api/users/storage-settings/clear-cache",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Clear Cache Error: $e");
      return false;
    }
  }

  static Future<bool> resetSettings() async {
    try {
      final token = await StorageService.getToken();

      if (token == null) return false;

      final response = await http.put(
        Uri.parse(
          "$baseUrl/api/users/storage-settings/reset",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Storage Reset Error: $e");
      return false;
    }
  }

  static Future<bool> testConnection() async {
    try {
      final token = await StorageService.getToken();

      if (token == null) return false;

      final response = await http.get(
        Uri.parse(
          "$baseUrl/api/users/storage-settings",
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