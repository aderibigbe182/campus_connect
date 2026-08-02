import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  Map<String, dynamic>? _user;
  String? _token;

  Map<String, dynamic>? get user => _user;

  String? get token => _token;

  bool get isLoggedIn =>
      _user != null && _token != null;

  int get currentUserId =>
      _user?["id"] ?? 0;

  String get fullName =>
      _user?["full_name"] ?? "";

  String get username =>
      _user?["username"] ?? "";

  String? get profilePicture =>
      _user?["profile_picture"];

  void setUser({
    required Map<String, dynamic> user,
    required String token,
  }) {
    _user = user;
    _token = token;
    notifyListeners();
  }

  void updateUser(Map<String, dynamic> user) {
    _user = user;
    notifyListeners();
  }

  void logout() {
    _user = null;
    _token = null;
    notifyListeners();
  }
}