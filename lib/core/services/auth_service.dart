import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import 'storage_service.dart';

/// Authentication now uses the same FastAPI service as conversations.
class AuthService {
  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String username,
    required String phone,
    required String email,
    required String password,
    required String university,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.pythonApi}/auth/register'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'full_name': fullName.trim(),
        'username': username.trim(),
        'email': email.trim(),
        'password': password,
        'university': university.trim(),
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_error(response));
    }
    return login(email: email, password: password);
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.pythonApi}/auth/login'),
      headers: const {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'username': email.trim(), 'password': password},
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_error(response));
    }
    final tokenData = Map<String, dynamic>.from(jsonDecode(response.body));
    final token = tokenData['access_token']?.toString();
    if (token == null || token.isEmpty) {
      throw Exception('The server did not return an access token.');
    }
    final meResponse = await http.get(
      Uri.parse('${ApiConstants.pythonApi}/auth/me'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (meResponse.statusCode < 200 || meResponse.statusCode >= 300) {
      throw Exception(_error(meResponse));
    }
    final user = Map<String, dynamic>.from(jsonDecode(meResponse.body));
    final userId = (user['id'] as num?)?.toInt();
    if (userId != null) await StorageService.saveUserId(userId);
    await StorageService.saveToken(token);
    return {'token': token, 'user': user};
  }

  static String _error(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      return body['detail']?.toString() ?? body['message']?.toString() ?? 'Request failed.';
    } catch (_) {
      return 'Request failed (${response.statusCode}).';
    }
  }

  static Future<void> signInWithGoogle() async {
    throw UnimplementedError('Google sign-in has not been configured for the unified backend.');
  }
}
