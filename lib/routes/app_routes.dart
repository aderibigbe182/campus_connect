import 'package:flutter/material.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/profiles/profile_screen.dart';

class AppRoutes {

  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String chats = '/chats';
  static const String chat = '/chat';
  static const String search = '/search';
  static const String requests = '/requests';
  static const String profile = '/profile';
  static const String calls = '/calls';
  static const String groups = '/groups';
  static const String groupChat = '/group-chat';
  static Map<String, WidgetBuilder> routes = {
    onboarding: (context) =>
        const OnboardingScreen(),
    login: (context) =>
        const LoginScreen(),
    register: (context) =>
        const RegisterScreen(),
    home: (context) =>
        const HomeScreen(),
    profile: (context) =>
        const ProfileScreen(),
  };
}