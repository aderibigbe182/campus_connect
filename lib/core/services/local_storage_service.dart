import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {

  static const String onboardingKey = "seenOnboarding";

  // Save onboarding as completed
  static Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(onboardingKey, true);
  }

  // Check if onboarding was seen
  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(onboardingKey) ?? false;
  }
}