import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/services/storage_settings_service.dart';
import '../models/storage_settings.dart';

class StorageRepository {
  StorageRepository._();

  static final StorageRepository instance =
      StorageRepository._();

  static const String _cacheKey =
      "storage_settings_cache";

  /// -------------------------------
  /// Load Local Settings
  /// -------------------------------
  Future<StorageSettings> getLocalSettings() async {
    final prefs =
        await SharedPreferences.getInstance();

    final jsonString =
        prefs.getString(_cacheKey);

    if (jsonString == null) {
      return StorageSettings.defaults();
    }

    try {
      final Map<String, dynamic> json =
          jsonDecode(jsonString);

      return StorageSettings.fromJson(json);
    } catch (_) {
      return StorageSettings.defaults();
    }
  }

  /// -------------------------------
  /// Save Local Settings
  /// -------------------------------
  Future<void> saveLocalSettings(
    StorageSettings settings,
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
  Future<StorageSettings> getRemoteSettings() async {
    final settings =
        await StorageSettingsService.getSettings();

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
    StorageSettings settings,
  ) async {
    final success =
        await StorageSettingsService.updateSettings(
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
  Future<StorageSettings> syncSettings() async {
    try {
      final remote =
          await StorageSettingsService.getSettings();

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
    StorageSettings settings,
  ) async {
    await saveLocalSettings(settings);

    return await updateRemoteSettings(settings);
  }

  /// -------------------------------
  /// Clear Cache
  /// -------------------------------
  Future<bool> clearCache() async {
    final success =
        await StorageSettingsService.clearCache();

    if (success) {
      final current =
          await getLocalSettings();

      final updated = current.copyWith(
        cacheSizeMB: 0,
      );

      await saveLocalSettings(updated);
    }

    return success;
  }

  /// -------------------------------
  /// Reset Settings
  /// -------------------------------
  Future<StorageSettings> resetSettings() async {
    final defaults =
        StorageSettings.defaults();

    await saveLocalSettings(defaults);

    await StorageSettingsService.updateSettings(
      defaults,
    );

    return defaults;
  }

  /// -------------------------------
  /// Refresh Settings
  /// -------------------------------
  Future<StorageSettings> refresh() async {
    return await syncSettings();
  }

  /// -------------------------------
  /// Clear Local Cache
  /// -------------------------------
  Future<void> clearLocalCache() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove(_cacheKey);
  }
}