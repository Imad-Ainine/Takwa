import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/daos.dart';
import '../../../core/providers/database_providers.dart';
import '../../../core/providers/shared_preferences_provider.dart';
import '../../../core/supabase/sync_manager.dart';
import '../../../core/notifications/notifications_service.dart';
import '../data/settings_prefs_bridge.dart';
import '../data/user_preferences.dart';

enum NotificationCategory { prayer, adhkar, reminders, all, none }

final userPreferencesProvider =
    AsyncNotifierProvider<UserPreferencesNotifier, UserPreferences>(() {
      return UserPreferencesNotifier();
    });

class UserPreferencesNotifier extends AsyncNotifier<UserPreferences> {
  late SettingsDao _dao;
  late SettingsPrefsBridge _prefsBridge;

  @override
  Future<UserPreferences> build() async {
    _dao = ref.watch(settingsDaoProvider);
    _prefsBridge = SettingsPrefsBridge(ref.watch(sharedPreferencesProvider));

    // Read all raw local settings
    final allSettings = await _dao.getAllSettings();
    final prefs = UserPreferences.fromMap(allSettings);

    return prefs;
  }

  /// Update a single preference. It updates the local database immediately,
  /// triggers a sync to Supabase in the background, and updates the reactive state.
  Future<void> updatePref(
    String key,
    dynamic value, {
    NotificationCategory category = NotificationCategory.all,
    bool haptic = true,
  }) async {
    if (haptic) unawaited(HapticFeedback.lightImpact());

    // 1. Save directly to local SQLite
    await _dao.set(key, value.toString());

    // 2. Trigger syncManager to push the change
    unawaited(ref.read(syncManagerProvider).syncSettings());

    // 3. Immediately re-build state from local defaults
    final allSettings = await _dao.getAllSettings();
    state = AsyncData(UserPreferences.fromMap(allSettings));

    // 4. Trigger granular notification rescheduling
    if (category != NotificationCategory.none) {
      unawaited(ref.read(notificationsManagerProvider).reschedule(category));
    }

    // 5. Sync to SharedPreferences for background isolates
    unawaited(_prefsBridge.mirror(key, value));
  }

  /// Helper method for modifying multiple preferences at once
  Future<void> updateMultiplePrefs(
    Map<String, dynamic> updates, {
    NotificationCategory category = NotificationCategory.all,
    bool haptic = true,
  }) async {
    if (haptic) unawaited(HapticFeedback.mediumImpact());

    for (final entry in updates.entries) {
      await _dao.set(entry.key, entry.value.toString());
    }
    unawaited(ref.read(syncManagerProvider).syncSettings());
    final allSettings = await _dao.getAllSettings();
    state = AsyncData(UserPreferences.fromMap(allSettings));

    // Trigger granular notification rescheduling
    if (category != NotificationCategory.none) {
      unawaited(ref.read(notificationsManagerProvider).reschedule(category));
    }

    // Sync all to SharedPreferences
    for (final entry in updates.entries) {
      unawaited(_prefsBridge.mirror(entry.key, entry.value));
    }
  }
}
