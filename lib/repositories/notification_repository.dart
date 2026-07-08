import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/services/notification_settings_service.dart';
import '../models/notification_settings.dart';

class NotificationRepository {
  NotificationRepository._();

  static final NotificationRepository instance =
      NotificationRepository._();

  static const String _cacheKey = "notification_settings_cache";

  /// -------------------------------
  /// Load from SharedPreferences
  /// -------------------------------
  Future<NotificationSettings> getLocalSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final jsonString = prefs.getString(_cacheKey);

    if (jsonString == null) {
      return NotificationSettings.defaults();
    }

    try {
      final Map<String, dynamic> json =
          jsonDecode(jsonString);

      return NotificationSettings.fromJson(json);
    } catch (_) {
      return NotificationSettings.defaults();
    }
  }

  /// -------------------------------
  /// Save to SharedPreferences
  /// -------------------------------
  Future<void> saveLocalSettings(
      NotificationSettings settings) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _cacheKey,
      jsonEncode(settings.toJson()),
    );
  }

  /// -------------------------------
  /// Download from Backend
  /// -------------------------------
  Future<NotificationSettings> getRemoteSettings() async {
    final settings =
        await NotificationSettingsService.getSettings();

    if (settings == null) {
      return await getLocalSettings();
    }

    await saveLocalSettings(settings);

    return settings;
  }

  /// -------------------------------
  /// Upload to Backend
  /// -------------------------------
  Future<bool> updateRemoteSettings(
      NotificationSettings settings) async {
    final success =
        await NotificationSettingsService.updateSettings(
      settings,
    );

    if (success) {
      await saveLocalSettings(settings);
    }

    return success;
  }

  /// -------------------------------
  /// Sync Local & Remote
  /// -------------------------------
  Future<NotificationSettings> syncSettings() async {
    try {
      final remote =
          await NotificationSettingsService.getSettings();

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
  /// Reset Settings
  /// -------------------------------
  Future<NotificationSettings> resetSettings() async {
    final defaults = NotificationSettings.defaults();

    await saveLocalSettings(defaults);

    await NotificationSettingsService.updateSettings(
      defaults,
    );

    return defaults;
  }

  /// -------------------------------
  /// Save Everything
  /// -------------------------------
  Future<bool> save(NotificationSettings settings) async {
    await saveLocalSettings(settings);

    return await updateRemoteSettings(settings);
  }

  /// -------------------------------
  /// Clear Local Cache
  /// -------------------------------
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_cacheKey);
  }

  /// -------------------------------
  /// Refresh Settings
  /// -------------------------------
  Future<NotificationSettings> refresh() async {
    return await syncSettings();
  }
}