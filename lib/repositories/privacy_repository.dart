import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/services/privacy_settings_service.dart';
import '../models/privacy_settings.dart';

class PrivacyRepository {
  PrivacyRepository._();

  static final PrivacyRepository instance =
      PrivacyRepository._();

  static const String _cacheKey =
      "privacy_settings_cache";

  /// -------------------------------
  /// Load Local Settings
  /// -------------------------------
  Future<PrivacySettings> getLocalSettings() async {
    final prefs =
        await SharedPreferences.getInstance();

    final jsonString =
        prefs.getString(_cacheKey);

    if (jsonString == null) {
      return PrivacySettings.defaults();
    }

    try {
      final Map<String, dynamic> json =
          jsonDecode(jsonString);

      return PrivacySettings.fromJson(json);
    } catch (_) {
      return PrivacySettings.defaults();
    }
  }

  /// -------------------------------
  /// Save Local Settings
  /// -------------------------------
  Future<void> saveLocalSettings(
    PrivacySettings settings,
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
  Future<PrivacySettings> getRemoteSettings() async {
    final settings =
        await PrivacySettingsService.getSettings();

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
    PrivacySettings settings,
  ) async {
    final success =
        await PrivacySettingsService.updateSettings(
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
  Future<PrivacySettings> syncSettings() async {
    try {
      final remote =
          await PrivacySettingsService.getSettings();

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
    PrivacySettings settings,
  ) async {
    await saveLocalSettings(settings);

    return await updateRemoteSettings(settings);
  }

  /// -------------------------------
  /// Reset Settings
  /// -------------------------------
  Future<PrivacySettings> resetSettings() async {
    final defaults =
        PrivacySettings.defaults();

    await saveLocalSettings(defaults);

    await PrivacySettingsService.updateSettings(
      defaults,
    );

    return defaults;
  }

  /// -------------------------------
  /// Refresh Settings
  /// -------------------------------
  Future<PrivacySettings> refresh() async {
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