import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/services/help_feedback_service.dart';
import '../models/help_feedback_model.dart';

class HelpFeedbackRepository {
  HelpFeedbackRepository._();

  static final HelpFeedbackRepository instance =
      HelpFeedbackRepository._();

  static const String _cacheKey =
      "help_feedback_settings_cache";

  /// -------------------------------
  /// Load Local Settings
  /// -------------------------------
  Future<HelpFeedbackSettings> getLocalSettings() async {
    final prefs =
        await SharedPreferences.getInstance();

    final jsonString =
        prefs.getString(_cacheKey);

    if (jsonString == null) {
      return HelpFeedbackSettings.defaults();
    }

    try {
      final Map<String, dynamic> json =
          jsonDecode(jsonString);

      return HelpFeedbackSettings.fromJson(json);
    } catch (_) {
      return HelpFeedbackSettings.defaults();
    }
  }

  /// -------------------------------
  /// Save Local Settings
  /// -------------------------------
  Future<void> saveLocalSettings(
    HelpFeedbackSettings settings,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      _cacheKey,
      jsonEncode(settings.toJson()),
    );
  }

  /// -------------------------------
  /// Download From Backend
  /// -------------------------------
  Future<HelpFeedbackSettings> getRemoteSettings() async {
    final settings =
        await HelpFeedbackSettingsService.getSettings();

    if (settings == null) {
      return await getLocalSettings();
    }

    await saveLocalSettings(settings);

    return settings;
  }

  /// -------------------------------
  /// Upload To Backend
  /// -------------------------------
  Future<bool> updateRemoteSettings(
    HelpFeedbackSettings settings,
  ) async {
    final success =
        await HelpFeedbackSettingsService.updateSettings(
      settings,
    );

    if (success) {
      await saveLocalSettings(settings);
    }

    return success;
  }

  /// -------------------------------
  /// Sync Local & Backend
  /// -------------------------------
  Future<HelpFeedbackSettings> syncSettings() async {
    try {
      final remote =
          await HelpFeedbackSettingsService.getSettings();

      if (remote != null) {
        await saveLocalSettings(remote);

        return remote;
      }

      return await getLocalSettings();
    } catch (_) {
      return await getLocalSettings();
    }
  }

  /// -------------------------------
  /// Save Everything
  /// -------------------------------
  Future<bool> save(
    HelpFeedbackSettings settings,
  ) async {
    await saveLocalSettings(settings);

    return await updateRemoteSettings(settings);
  }

  /// -------------------------------
  /// Send Feedback
  /// -------------------------------
  Future<bool> sendFeedback({
    required String subject,
    required String message,
  }) async {
    return await HelpFeedbackSettingsService.sendFeedback(
      subject: subject,
      message: message,
    );
  }

  /// -------------------------------
  /// Refresh Settings
  /// -------------------------------
  Future<HelpFeedbackSettings> refresh() async {
    return await syncSettings();
  }

  /// -------------------------------
  /// Clear Local Cache
  /// -------------------------------
  Future<void> clearCache() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove(_cacheKey);
  }
}
