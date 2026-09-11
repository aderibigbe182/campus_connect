import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../../../core/services/storage_service.dart';
import '../models/user_profile_model.dart';

class UserProfileService {
  UserProfileService._();

  static Future<String> _token() async {
    final token = await StorageService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Authentication required.');
    }

    return token;
  }

  static Map<String, String> _headers(String token) {
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Map<String, String> _jsonHeaders(String token) {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<UserProfileModel> getCurrentProfile() async {
    final token = await _token();

    final response = await http.get(
      Uri.parse('${ApiConstants.pythonBaseUrl}/api/users/profile'),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      return UserProfileModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw Exception(_errorMessage(response));
  }

  static Future<UserProfileModel> getUserProfile(int userId) async {
    final token = await _token();

    final response = await http.get(
      Uri.parse('${ApiConstants.pythonBaseUrl}/api/users/$userId'),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      return UserProfileModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw Exception(_errorMessage(response));
  }

  static Future<UserProfileModel> updateProfile({
    required String fullName,
    required String username,
    required String bio,
    required String department,
    required String level,
    required List<String> interests,
  }) async {
    final token = await _token();

    final response = await http.put(
      Uri.parse('${ApiConstants.pythonBaseUrl}/api/users/profile'),
      headers: _jsonHeaders(token),
      body: jsonEncode({
        'full_name': fullName.trim(),
        'username': username.trim(),
        'bio': bio.trim(),
        'department': department.trim(),
        'level': level.trim(),
        'interests': interests
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .join(','),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(_errorMessage(response));
    }

    return getCurrentProfile();
  }

  static Future<String> uploadProfilePicture({
    required List<int> imageBytes,
    required String fileName,
  }) async {
    final token = await _token();

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        '${ApiConstants.pythonBaseUrl}/api/users/profile_picture',
      ),
    );

    request.headers['Accept'] = 'application/json';
    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(
      http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: fileName,
      ),
    );

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception(_errorMessageFromBody(body));
    }

    final data = jsonDecode(body) as Map<String, dynamic>;

    return data['profile_picture']?.toString() ?? '';
  }

  static Future<void> setOnline() async {
    final token = await _token();

    final response = await http.put(
      Uri.parse('${ApiConstants.pythonBaseUrl}/api/users/online'),
      headers: _headers(token),
    );

    if (response.statusCode != 200) {
      throw Exception(_errorMessage(response));
    }
  }

  static Future<void> setOffline() async {
    final token = await _token();

    final response = await http.put(
      Uri.parse('${ApiConstants.pythonBaseUrl}/api/users/offline'),
      headers: _headers(token),
    );

    if (response.statusCode != 200) {
      throw Exception(_errorMessage(response));
    }
  }

  static String _errorMessage(http.Response response) {
    return _errorMessageFromBody(
      response.body,
      fallback:
          'Request failed with status ${response.statusCode}.',
    );
  }

  static String _errorMessageFromBody(
    String body, {
    String fallback = 'Request failed.',
  }) {
    try {
      final data = jsonDecode(body);

      if (data is Map<String, dynamic>) {
        return data['message']?.toString() ??
            data['error']?.toString() ??
            fallback;
      }
    } catch (_) {}

    return body.isEmpty ? fallback : body;
  }
}