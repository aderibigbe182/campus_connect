import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiConstants {
  static const baseUrl = 'https://campus-connect-backend-6pwg.onrender.com';
}

class StorageService {

  // =========================
  // 🔐 TOKEN STORAGE (LOGIN SYSTEM)
  // =========================

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // =========================
  // 📤 FILE UPLOAD (BACKEND)
  // =========================

  static Future<String?> uploadFile({
    required Uint8List fileBytes,
    required String fileName,
  }) async {

    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/api/upload');

      final request = http.MultipartRequest('POST', uri);

      // detect file type
      final mimeType = lookupMimeType(fileName) ?? 'image/jpeg';
      final mimeSplit = mimeType.split('/');

      request.files.add(
        await http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName,
          contentType: MediaType(mimeSplit[0], mimeSplit[1]),
        ),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseBody; // backend should return URL or JSON
      } else {
        throw 'Upload failed: $responseBody';
      }

    } catch (e) {
      throw 'File upload error: $e';
    }
  }
}