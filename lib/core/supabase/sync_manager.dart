// ═══════════════════════════════════════════════════════════════
//  lib/core/supabase/sync_manager.dart
//  محاسبة النفس — Local↔Remote Sync Manager
// ═══════════════════════════════════════════════════════════════

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/app_database.dart';
import '../../core/providers/database_providers.dart';
import 'supabase_service.dart';
import 'supabase_providers.dart';

class SyncManager {
  static bool _syncing = false;

  /// Full synchronization on App Start
  static Future<void> fullSync(WidgetRef ref) async {
    if (_syncing) return;
    final isOnline = ref.read(connectivityProvider).value ?? false;
    final isAuth = ref.read(currentUserProvider) != null;
    if (!isOnline || !isAuth) return;

    _syncing = true;
    try {
      await _syncDailyRecords(ref);
      await _syncSettings(ref);
      // await _syncStats(ref);
    } finally {
      _syncing = false;
    }
  }

  static Future<void> _syncDailyRecords(WidgetRef ref) async {
    final from = DateTime.now().subtract(const Duration(days: 30));
    final remote = await SupabaseService.getRecordsRange(
      from: from,
      to: DateTime.now(),
    );

    // Syncing logic: update local if remote is newer, or simple upsert
    // for (final record in remote) {
    //   await ref.read(dailyRecordDaoProvider).upsertFromRemote(record);
    // }
  }

  static Future<void> _syncSettings(WidgetRef ref) async {
    final remote = await SupabaseService.getSettings();
    if (remote == null) return;

    final dao = ref.read(settingsDaoProvider);
    // Example: syncing specific keys
    if (remote['madhab'] != null) await dao.set('madhab', remote['madhab']);
    if (remote['ramadan_mode'] != null) {
      await dao.set('ramadanMode', remote['ramadan_mode'].toString());
    }
  }

  /// Single record sync (call after local update)
  static Future<void> syncDailyRecord(WidgetRef ref, DailyRecord record) async {
    final isOnline = ref.read(connectivityProvider).value ?? false;
    final isAuth = ref.read(currentUserProvider) != null;
    if (!isOnline || !isAuth) return;

    await SupabaseService.upsertDailyRecord({
      'date': record.date.toIso8601String().split('T')[0],
      'fajr_status': record.fajrStatus.index,
      'dhuhr_status': record.dhuhrStatus.index,
      'asr_status': record.asrStatus.index,
      'maghrib_status': record.maghribStatus.index,
      'isha_status': record.ishaStatus.index,
      'night_prayer': record.nightPrayer,
      'quran_pages': record.quranPages,
      'morning_adhkar': record.morningAdhkar,
      'evening_adhkar': record.eveningAdhkar,
      'fasting_type': record.fastingType.index,
      'sadaqah': record.sadaqah,
      'net_points': record.netPoints,
      'taqwa_points': record.taqwaPoints,
      'notes': record.notes,
    });
  }
}
