import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/daos.dart';
import '../../../core/providers/database_providers.dart';
import '../../../core/supabase/sync_manager.dart';
import '../../../core/notifications/notifications_service.dart';
import '../data/user_preferences.dart';

final userPreferencesProvider =
    AsyncNotifierProvider<UserPreferencesNotifier, UserPreferences>(() {
  return UserPreferencesNotifier();
});

class UserPreferencesNotifier extends AsyncNotifier<UserPreferences> {
  late SettingsDao _dao;

  @override
  Future<UserPreferences> build() async {
    _dao = ref.watch(settingsDaoProvider);

    // Read all raw local settings
    final allSettings = await _dao.getAllSettings();
    final prefs = UserPreferences.fromMap(allSettings);

    return prefs;
  }

  /// Update a single preference. It updates the local database immediately,
  /// triggers a sync to Supabase in the background, and updates the reactive state.
  Future<void> updatePref(String key, dynamic value) async {
    // 1. Save directly to local SQLite
    await _dao.set(key, value.toString());

    // 2. Trigger syncManager to push the change
    unawaited(ref.read(syncManagerProvider).syncSettings());

    // 3. Immediately re-build state from local defaults
    final allSettings = await _dao.getAllSettings();
    state = AsyncData(UserPreferences.fromMap(allSettings));

    // 4. Trigger global notification reschedule to apply changes
    unawaited(ref.read(notificationsManagerProvider).reschedule());
  }
  
  /// Helper method for modifying multiple preferences at once
  Future<void> updateMultiplePrefs(Map<String, dynamic> updates) async {
    for (final entry in updates.entries) {
      await _dao.set(entry.key, entry.value.toString());
    }
    unawaited(ref.read(syncManagerProvider).syncSettings());
    final allSettings = await _dao.getAllSettings();
    state = AsyncData(UserPreferences.fromMap(allSettings));

    // Trigger global notification reschedule
    unawaited(ref.read(notificationsManagerProvider).reschedule());
  }
}
