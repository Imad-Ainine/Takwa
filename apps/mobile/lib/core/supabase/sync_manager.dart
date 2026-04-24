// ═══════════════════════════════════════════════════════════════
//  lib/core/supabase/sync_manager.dart
//  تقوى — Local↔Remote Sync Manager
// ═══════════════════════════════════════════════════════════════

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/app_database.dart';
import '../../core/providers/database_providers.dart';
import 'supabase_service.dart';
import 'supabase_providers.dart';
import '../providers/favorites_providers.dart';

final syncManagerProvider = Provider((ref) => SyncManager(ref));

class SyncManager {
  final Ref _ref;
  SyncManager(this._ref);

  static bool _syncing = false;

  /// Full synchronization on App Start
  Future<void> fullSync() async {
    if (_syncing) return;
    final isOnline = _ref.read(connectivityProvider).value ?? false;
    final isAuth = _ref.read(currentUserProvider) != null;
    if (!isOnline || !isAuth) return;

    _syncing = true;
    try {
      await _syncDailyRecords();
      await _syncProhibitions();
      await _syncCustomIbadah();
      await _syncAchievements();
      await _syncSettings();
      await _syncStats();
    } finally {
      _syncing = false;
    }
  }

  Future<void> _syncDailyRecords() async {
    final from = DateTime.now().subtract(const Duration(days: 30));
    final remoteRecords = await SupabaseService.getRecordsRange(
      from: from,
      to: DateTime.now(),
    );

    final dao = _ref.read(dailyRecordDaoProvider);
    for (final record in remoteRecords) {
      await dao.upsertFromRemote(record);
    }
  }

  Future<void> _syncProhibitions() async {
    final from = DateTime.now().subtract(const Duration(days: 14));
    final remoteLogs = await SupabaseService.getProhibitionLogs(
      from: from,
      to: DateTime.now(),
    );

    final dao = _ref.read(dailyRecordDaoProvider);
    for (final log in remoteLogs) {
      await dao.upsertProhibitionFromRemote(log);
    }
  }

  Future<void> _syncCustomIbadah() async {
    final remoteIbadah = await SupabaseService.getCustomIbadah();
    final remoteLogs = await SupabaseService.getCustomIbadahLogs(
      from: DateTime.now().subtract(const Duration(days: 14)),
      to: DateTime.now(),
    );

    final ibadahDao = _ref.read(customIbadahDaoProvider);
    for (final item in remoteIbadah) {
      await ibadahDao.upsertCustomIbadahFromRemote(item);
    }
    for (final log in remoteLogs) {
      await ibadahDao.upsertCustomIbadahLogFromRemote(log);
    }
  }

  Future<void> _syncAchievements() async {
    final remoteAchievements = await SupabaseService.getEarnedAchievements();
    final statsDao = _ref.read(statsDaoProvider);

    for (final data in remoteAchievements) {
      await statsDao.addAchievement(
        type: data['type'],
        titleAr: data['title_ar'] ?? '',
        descAr: data['desc_ar'] ?? '',
        emoji: data['emoji'] ?? '✨',
        pointsReward: data['points_reward'] ?? 0,
      );
    }
  }

  Future<void> _syncSettings() async {
    final remote = await SupabaseService.getSettings();
    final dao = _ref.read(settingsDaoProvider);

    if (remote != null) {
      // If we have remote settings, pull them down
      await dao.upsertFromRemote(remote);

      if (remote['favorite_adhkar'] != null) {
        final adhkar = remote['favorite_adhkar'] as List<dynamic>;
        _ref.read(favoriteAdhkarProvider.notifier).syncFromRemote(adhkar);
      }
      if (remote['favorite_duas'] != null) {
        final duas = remote['favorite_duas'] as List<dynamic>;
        _ref.read(favoriteDuasProvider.notifier).syncFromRemote(duas);
      }
    } else {
      // If no remote settings exist (new user), push local defaults
      await syncSettings();
    }
  }

  Future<void> _syncStats() async {
    final stats = await _ref
        .read(statsDaoProvider)
        .getMonthStats(DateTime.now().year, DateTime.now().month);

    await SupabaseService.updateUserStats(
      totalPoints: stats.totalPoints,
      currentStreak: stats.currentStreak,
      longestStreak: stats.longestStreak,
      quranPages: stats.quranPages,
    );
  }

  /// Single record sync (call after local update)
  Future<void> syncDailyRecord(DailyRecord record) async {
    final isOnline = _ref.read(connectivityProvider).value ?? false;
    final isAuth = _ref.read(currentUserProvider) != null;
    if (!isOnline || !isAuth) return;

    await SupabaseService.upsertDailyRecord({
      'date': record.date.toIso8601String().split('T')[0],
      'fajr_status': record.fajrStatus.name,
      'dhuhr_status': record.dhuhrStatus.name,
      'asr_status': record.asrStatus.name,
      'maghrib_status': record.maghribStatus.name,
      'isha_status': record.ishaStatus.name,
      'night_prayer': record.nightPrayer,
      'witr': record.witr,
      'rawatib': record.rawatib,
      'quran_pages': record.quranPages,
      'quran_verses': record.quranVerses,
      'quran_juzaa': record.quranJuzaa,
      'morning_adhkar': record.morningAdhkar,
      'evening_adhkar': record.eveningAdhkar,
      'after_prayer_adhkar': record.afterPrayerAdhkar,
      'tasbeeh_count': record.tasbeehCount,
      'fasting_type': record.fastingType.name,
      'sadaqah': record.sadaqah,
      'sadaqah_amount': record.sadaqahAmount,
      'net_points': record.netPoints,
      'taqwa_points': record.taqwaPoints,
      'deducted_points': record.deductedPoints,
      'mood': record.mood,
      'notes': record.notes,
    });
  }

  /// Sync newly earned achievement
  Future<void> syncAchievement(Achievement achievement) async {
    final isOnline = _ref.read(connectivityProvider).value ?? false;
    final isAuth = _ref.read(currentUserProvider) != null;
    if (!isOnline || !isAuth) return;

    await SupabaseService.upsertAchievement({
      'type': achievement.type,
      'title_ar': achievement.titleAr,
      'desc_ar': achievement.descAr,
      'emoji': achievement.emoji,
      'points_reward': achievement.pointsReward,
      'earned_at': achievement.earnedAt.toIso8601String(),
    });
  }

  /// Sync prohibition log
  Future<void> syncProhibition(ProhibitionsLogData log) async {
    final isOnline = _ref.read(connectivityProvider).value ?? false;
    final isAuth = _ref.read(currentUserProvider) != null;
    if (!isOnline || !isAuth) return;

    await SupabaseService.upsertProhibitionLog({
      'record_id': log.recordId,
      'date': log.date.toIso8601String().split('T')[0],
      'category': log.category.name,
      'committed': log.committed,
      'times_count': log.timesCount,
      'deduct_points': log.deductPoints,
      'notes': log.notes,
    });
  }

  /// Sync custom ibadah
  Future<void> syncCustomIbadah(CustomIbadahData ibadah) async {
    final isOnline = _ref.read(connectivityProvider).value ?? false;
    final isAuth = _ref.read(currentUserProvider) != null;
    if (!isOnline || !isAuth) return;

    await SupabaseService.upsertCustomIbadah({
      'id': ibadah.id,
      'name_ar': ibadah.nameAr,
      'emoji': ibadah.emoji,
      'is_positive': ibadah.isPositive,
      'points': ibadah.points,
      'is_active': ibadah.isActive,
      'sort_order': ibadah.sortOrder,
    });
  }

  /// Delete custom ibadah
  Future<void> deleteCustomIbadah(int id) async {
    final isOnline = _ref.read(connectivityProvider).value ?? false;
    final isAuth = _ref.read(currentUserProvider) != null;
    if (!isOnline || !isAuth) return;

    try {
      await SupabaseService.deleteCustomIbadah(id);
    } catch (e) {
      // Log or handle error
    }
  }

  /// Sync custom ibadah log
  Future<void> syncCustomIbadahLog(CustomIbadahLogData log) async {
    final isOnline = _ref.read(connectivityProvider).value ?? false;
    final isAuth = _ref.read(currentUserProvider) != null;
    if (!isOnline || !isAuth) return;

    try {
      await SupabaseService.upsertCustomIbadahLog({
        'ibadah_id': log.ibadahId,
        'date': log.date.toIso8601String().split('T')[0],
        'done': log.done,
        'count': log.count,
      });
    } catch (e) {
      if (e.toString().contains('23503')) {
        // Foreign key violation: custom_ibadah might be missing on remote
        try {
          final dao = _ref.read(customIbadahDaoProvider);
          final ibadahItems = await dao.getAllIbadat();
          final ibadah = ibadahItems.where((i) => i.id == log.ibadahId).firstOrNull;
          
          if (ibadah != null) {
            await syncCustomIbadah(ibadah);
            // Retry log sync
            await SupabaseService.upsertCustomIbadahLog({
              'ibadah_id': log.ibadahId,
              'date': log.date.toIso8601String().split('T')[0],
              'done': log.done,
              'count': log.count,
            });
          }
        } catch (retryError) {
          // Fallback or ignore
        }
      }
    }
  }

  /// Sync all local settings to Supabase
  Future<void> syncSettings() async {
    final isOnline = _ref.read(connectivityProvider).value ?? false;
    final isAuth = _ref.read(currentUserProvider) != null;
    if (!isOnline || !isAuth) return;

    final dao = _ref.read(settingsDaoProvider);
    final settings = await dao.getAllSettings();
    if (settings.isNotEmpty) {
      await SupabaseService.updateSettings(settings);
    }
  }
}
