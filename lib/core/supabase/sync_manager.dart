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
      await _syncAchievements(ref);
      await _syncSettings(ref);
      await _syncStats(ref);
    } finally {
      _syncing = false;
    }
  }

  static Future<void> _syncDailyRecords(WidgetRef ref) async {
    final from = DateTime.now().subtract(const Duration(days: 30));
    final remoteRecords = await SupabaseService.getRecordsRange(
      from: from,
      to: DateTime.now(),
    );

    final dao = ref.read(dailyRecordDaoProvider);
    for (final record in remoteRecords) {
      await dao.upsertFromRemote(record);
    }
  }

  static Future<void> _syncAchievements(WidgetRef ref) async {
    final remoteAchievements = await SupabaseService.getEarnedAchievements();
    final statsDao = ref.read(statsDaoProvider);

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

  static Future<void> _syncSettings(WidgetRef ref) async {
    final remote = await SupabaseService.getSettings();
    if (remote == null) return;

    final dao = ref.read(settingsDaoProvider);
    await dao.upsertFromRemote(remote);

    if (remote['favorite_adhkar'] != null) {
      final adhkar = remote['favorite_adhkar'] as List<dynamic>;
      ref.read(favoriteAdhkarProvider.notifier).syncFromRemote(adhkar);
    }
    if (remote['favorite_duas'] != null) {
      final duas = remote['favorite_duas'] as List<dynamic>;
      ref.read(favoriteDuasProvider.notifier).syncFromRemote(duas);
    }
  }

  static Future<void> _syncStats(WidgetRef ref) async {
    final stats = await ref
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
  static Future<void> syncDailyRecord(WidgetRef ref, DailyRecord record) async {
    final isOnline = ref.read(connectivityProvider).value ?? false;
    final isAuth = ref.read(currentUserProvider) != null;
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
  static Future<void> syncAchievement(
    WidgetRef ref,
    Achievement achievement,
  ) async {
    final isOnline = ref.read(connectivityProvider).value ?? false;
    final isAuth = ref.read(currentUserProvider) != null;
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
}
