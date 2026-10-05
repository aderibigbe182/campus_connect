import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../services/storage_service.dart';

class LogoutService {
  /// Logout current user
  static Future<bool> logout() async {
    try {
      final token =
          await StorageService.getToken();

      if (token == null) return true;

      final response = await http.post(
        Uri.parse(
          "${ApiConstants.nodeApi}/auth/logout",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      return response.statusCode == 200 ||
          response.statusCode == 204;
    } catch (e) {
      print("Logout Error: $e");
      return false;
    }
  }

  /// Check whether token is still valid
  static Future<bool> validateSession() async {
    try {
      final token =
          await StorageService.getToken();

      if (token == null) return false;

      final response = await http.get(
        Uri.parse(
          "${ApiConstants.nodeApi}/auth/validate-token",
        ),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Validate Session Error: $e");
      return false;
    }
  }

  /// Refresh Access Token (optional)
  static Future<String?> refreshToken() async {
    try {
      final token =
          await StorageService.getToken();

      if (token == null) return null;

      final response = await http.post(
        Uri.parse(
          "${ApiConstants.nodeApi}/auth/refresh-token",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final json =
            jsonDecode(response.body);

        return json["token"];
      }

      return null;
    } catch (e) {
      print("Refresh Token Error: $e");
      return null;
    }
  }
}
