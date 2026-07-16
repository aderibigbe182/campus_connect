import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '/screens/main/pages/profile_page.dart';
import '/screens/search/search_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const profile = '/profile';
  static const search = '/search';

  static final Map<String, WidgetBuilder> routes = {
    onboarding: (_) => const OnboardingScreen(),
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    home: (_) => const HomeScreen(),
    profile: (context) => const ProfilePage(),
    search: (context) => const SearchScreen(),
  };
}