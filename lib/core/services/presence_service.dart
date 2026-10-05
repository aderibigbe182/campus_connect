import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import 'storage_service.dart';

class PresenceService {

  // =========================
  // SET USER ONLINE
  // =========================
  static Future<void> setOnline() async {
    final token = await StorageService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('User token not found');
    }

    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.nodeBaseUrl}/api/users/online'),
        headers: {
          'Content-Type': 'application/json',

          // IMPORTANT FIX: ensure clean token
          'Authorization': 'Bearer ${token.trim()}',
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to set user online: ${response.body}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // SET USER OFFLINE
  // =========================
  static Future<void> setOffline() async {
    final token = await StorageService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('User token not found');
    }

    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.nodeBaseUrl}/api/users/offline'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token.trim()}',
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to set user offline: ${response.body}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
