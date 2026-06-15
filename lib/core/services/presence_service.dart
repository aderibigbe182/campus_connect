import 'package:http/http.dart' as http;
import 'storage_service.dart';

class ApiConstants {
  static const baseUrl =
      'https://campus-connect-backend-6pwg.onrender.com';
}

class PresenceService {

  // =========================
  // SET USER ONLINE
  // =========================
  static Future<void> setOnline() async {
    final token = await StorageService.getToken();

    print("TOKEN FROM STORAGE = $token");

    if (token == null || token.isEmpty) {
      throw Exception('User token not found');
    }

    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/api/users/online'),
        headers: {
          'Content-Type': 'application/json',

          // IMPORTANT FIX: ensure clean token
          'Authorization': 'Bearer ${token.trim()}',
        },
      );

      print("STATUS FROM ONLINE = ${response.statusCode}");
      print("BODY FROM ONLINE = ${response.body}");

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to set user online: ${response.body}',
        );
      }
    } catch (e) {
      print("ONLINE ERROR = $e");
      rethrow;
    }
  }

  // =========================
  // SET USER OFFLINE
  // =========================
  static Future<void> setOffline() async {
    final token = await StorageService.getToken();

    print("TOKEN FROM STORAGE = $token");

    if (token == null || token.isEmpty) {
      throw Exception('User token not found');
    }

    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/api/users/offline'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token.trim()}',
        },
      );

      print("STATUS FROM OFFLINE = ${response.statusCode}");
      print("BODY FROM OFFLINE = ${response.body}");

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to set user offline: ${response.body}',
        );
      }
    } catch (e) {
      print("OFFLINE ERROR = $e");
      rethrow;
    }
  }
}