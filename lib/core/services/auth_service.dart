import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/storage_service.dart';

class ApiConstants {
  static const baseUrl = 'https://campus-connect-backend-6pwg.onrender.com';
}

class AuthService {

  // =====================
  // REGISTER
  // =====================
  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String username,
    required String phone,
    required String email,
    required String password,
    required String university,
  }) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/api/auth/register');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'full_name': fullName.trim(),
          'username': username.trim(),
          'phone': phone.trim(),
          'email': email.trim(),
          'password': password.trim(),
          'university': university.trim(),
        }),
      );
      
      print("STATUS CODE: ${response.statusCode}");
      print("BODY: ${response.body}");
      
      final data = jsonDecode(response.body);

      if (response.statusCode == 201 ||
    response.statusCode == 200) {

  final user = data['user'];

  if (user != null && user['id'] != null) {
    final userId = int.tryParse(
      user['id'].toString(),
    );

    if (userId != null) {
      await StorageService.saveUserId(userId);

      print(
        "REGISTERED USER ID SAVED: $userId",
      );
    }
  }

  if (data['token'] != null) {
    await StorageService.saveToken(
      data['token'].toString(),
    );
  }

  return data;
} else {
        throw Exception(
          data['message'] ?? 'Registration failed'
          );
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // =====================
  // LOGIN
  // =====================
  static Future<Map<String, dynamic>> login({
  required String email,
  required String password,
}) async {
  try {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}/api/auth/login',
    );

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    print("LOGIN STATUS: ${response.statusCode}");
    print("LOGIN BODY: ${response.body}");

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {

      // ==========================
      // SAVE TOKEN
      // ==========================

      final token = data['token'];

      if (token != null) {
        await StorageService.saveToken(
          token.toString(),
        );
      }

      // ==========================
      // SAVE USER ID
      // ==========================

      final user = data['user'];

      if (user != null && user['id'] != null) {
        final userId = int.tryParse(
          user['id'].toString(),
        );

        if (userId != null) {
          await StorageService.saveUserId(
            userId,
          );

          print(
            "LOGGED IN USER ID SAVED: $userId",
          );
        }
      }

      return data;
    } else {
      throw Exception(
        data['message'] ?? 'Login failed',
      );
    }
  } catch (e) {
    throw Exception(e.toString());
  }
}
  // =====================
  // GOOGLE LOGIN (optional later)
  // =====================
  static Future<void> signInWithGoogle() async {
    // implement later (Google OAuth backend or Firebase hybrid)
  }
}