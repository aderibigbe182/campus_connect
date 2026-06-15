import 'dart:convert';
import 'package:http/http.dart' as http;

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
        return data; // success
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
      final url = Uri.parse('${ApiConstants.baseUrl}/api/auth/login');

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

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data; // {token, user}
      } else {
        throw data['message'] ?? 'Login failed';
      }
    } catch (e) {
      throw e.toString();
    }
  }

  // =====================
  // GOOGLE LOGIN (optional later)
  // =====================
  static Future<void> signInWithGoogle() async {
    // implement later (Google OAuth backend or Firebase hybrid)
  }
}