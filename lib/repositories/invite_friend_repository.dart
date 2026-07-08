import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/services/invite_friend_service.dart';
import '../models/invite_friend_model.dart';

class InviteFriendRepository {
  InviteFriendRepository._();

  static final InviteFriendRepository instance =
      InviteFriendRepository._();

  static const String _cacheKey =
      "invite_friend_settings_cache";

  /// -------------------------------
  /// Load Local Settings
  /// -------------------------------
  Future<InviteFriendSettings> getLocalSettings() async {
    final prefs =
        await SharedPreferences.getInstance();

    final jsonString =
        prefs.getString(_cacheKey);

    if (jsonString == null) {
      return InviteFriendSettings.defaults();
    }

    try {
      final Map<String, dynamic> json =
          jsonDecode(jsonString);

      return InviteFriendSettings.fromJson(json);
    } catch (_) {
      return InviteFriendSettings.defaults();
    }
  }

  /// -------------------------------
  /// Save Local Settings
  /// -------------------------------
  Future<void> saveLocalSettings(
    InviteFriendSettings settings,
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
  Future<InviteFriendSettings> getRemoteSettings() async {
    final settings =
        await InviteFriendSettingsService.getSettings();

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
    InviteFriendSettings settings,
  ) async {
    final success =
        await InviteFriendSettingsService.updateSettings(
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
  Future<InviteFriendSettings> syncSettings() async {
    try {
      final remote =
          await InviteFriendSettingsService.getSettings();

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
    InviteFriendSettings settings,
  ) async {
    await saveLocalSettings(settings);

    return await updateRemoteSettings(settings);
  }

  /// -------------------------------
  /// Generate Invite Link
  /// -------------------------------
  Future<String?> generateInviteLink() async {
    final link =
        await InviteFriendSettingsService
            .generateInviteLink();

    if (link == null) return null;

    final current =
        await getLocalSettings();

    final updated = current.copyWith(
      inviteLink: link,
    );

    await saveLocalSettings(updated);

    return link;
  }

  /// -------------------------------
  /// Register Invite Sent
  /// -------------------------------
  Future<bool> registerInviteSent() async {
    return await InviteFriendSettingsService
        .registerInviteSent();
  }

  /// -------------------------------
  /// Refresh Settings
  /// -------------------------------
  Future<InviteFriendSettings> refresh() async {
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