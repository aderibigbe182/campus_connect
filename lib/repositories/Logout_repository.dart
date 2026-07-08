import 'package:shared_preferences/shared_preferences.dart';

import '../core/services/logout_service.dart';
import '../core/services/storage_service.dart';

class LogoutRepository {
  LogoutRepository._();

  static final LogoutRepository instance =
      LogoutRepository._();

  /// Logout user completely
  Future<bool> logout() async {
    try {
      // Notify backend
      await LogoutService.logout();

      // Remove stored token
      await StorageService.deleteToken();

      // Remove every cached preference
      final prefs =
          await SharedPreferences.getInstance();

      await prefs.clear();

      return true;
    } catch (e) {
      print("Logout Repository Error: $e");
      return false;
    }
  }

  /// Check if current session is still valid
  Future<bool> isSessionValid() async {
    return await LogoutService.validateSession();
  }

  /// Refresh JWT Token
  Future<bool> refreshSession() async {
    try {
      final newToken =
          await LogoutService.refreshToken();

      if (newToken == null) {
        return false;
      }

      await StorageService.saveToken(newToken);

      return true;
    } catch (e) {
      print("Refresh Session Error: $e");
      return false;
    }
  }
}