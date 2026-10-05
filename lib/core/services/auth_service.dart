import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import 'storage_service.dart';

/// Authentication is served by the Node/Express backend (/api/auth).
class AuthService {
  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String username,
    required String phone,
    required String email,
    required String password,
    required String university,
  }) async {
    final result = await _send('/register', {
      'full_name': fullName.trim(),
      'username': username.trim(),
      'phone': phone.trim(),
      'email': email.trim(),
      'password': password,
      'university': university.trim(),
    });
    await _saveSession(result);
    return result;
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final result = await _send('/login', {
      'email': email.trim(),
      'password': password,
    });
    await _saveSession(result);
    return result;
  }

  static Future<Map<String, dynamic>> currentUser() async {
    final token = await StorageService.getToken();
    if (token == null || token.isEmpty) throw Exception('Authentication required.');
    final response = await http.get(
      Uri.parse('${ApiConstants.nodeApi}/auth/me'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );
    return _checked(response);
  }

  static Future<Map<String, dynamic>> _send(String route, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.nodeApi}/auth$route'),
      headers: const {'Accept': 'application/json', 'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _checked(response);
  }

  static Map<String, dynamic> _checked(http.Response response) {
    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      decoded = null;
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map
          ? (decoded['message'] ?? decoded['error'] ?? decoded['detail'] ?? 'Request failed').toString()
          : 'Request failed (${response.statusCode}).';
      throw Exception(message);
    }
    if (decoded is! Map) throw Exception('The server returned an invalid response.');
    return Map<String, dynamic>.from(decoded);
  }

  static Future<void> _saveSession(Map<String, dynamic> response) async {
    final token = response['token']?.toString();
    if (token == null || token.isEmpty) throw Exception('The server did not return an access token.');
    await StorageService.saveToken(token);
    final user = response['user'];
    if (user is Map && user['id'] is num) {
      await StorageService.saveUserId((user['id'] as num).toInt());
    }
  }

  static Future<void> signInWithGoogle() async {
    throw UnimplementedError('Google OAuth requires the Node backend OAuth callback setup.');
  }
}
