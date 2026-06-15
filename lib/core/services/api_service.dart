import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://your-backend-url.com/api";

  Future<dynamic> get(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint'));

    return jsonDecode(response.body);
  }

  Future<dynamic> post(String endpoint, Map data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      body: jsonEncode(data),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    return jsonDecode(response.body);
  }
}