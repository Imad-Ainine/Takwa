// ═══════════════════════════════════════════════════════════════
//  lib/core/providers/database_providers.dart
//  محاسبة النفس — Riverpod Providers
// ═══════════════════════════════════════════════════════════════

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muhasabah/core/database/app_database.dart';
import 'package:muhasabah/core/database/daos.dart';

// ── Singleton database ──
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

// ── DAOs ──
final dailyRecordDaoProvider = Provider<DailyRecordDao>((ref) {
  return DailyRecordDao(ref.watch(appDatabaseProvider));
});

final statsDaoProvider = Provider<StatsDao>((ref) {
  return StatsDao(ref.watch(appDatabaseProvider));
});

final settingsDaoProvider = Provider<SettingsDao>((ref) {
  return SettingsDao(ref.watch(appDatabaseProvider));
});

// ── سجل اليوم (Stream) ──
final todayRecordProvider = StreamProvider<DailyRecord?>((ref) {
  return ref.watch(dailyRecordDaoProvider).watchTodayRecord();
});

// ── نقاط الأسبوع ──
final weeklyPointsProvider = FutureProvider<List<WeeklyPoint>>((ref) {
  return ref.watch(statsDaoProvider).getWeeklyPoints();
});

// ── إحصائيات الشهر الحالي ──
final monthStatsProvider = FutureProvider<MonthStats>((ref) {
  final now = DateTime.now();
  return ref.watch(statsDaoProvider).getMonthStats(now.year, now.month);
});

// ── السلسلة الحالية ──
final currentStreakProvider = FutureProvider<int>((ref) {
  return ref.watch(statsDaoProvider).getCurrentStreak();
});

// ── إعداد معين ──
final settingProvider = FutureProvider.family<String?, String>((ref, key) {
  return ref.watch(settingsDaoProvider).get(key);
});

// ── وضع رمضان ──
final ramadanModeProvider = StreamProvider<bool>((ref) {
  return ref
      .watch(settingsDaoProvider)
      .watch('ramadanMode')
      .map((v) => v == 'true');
});

// ── فحص إكمال التهيئة ──
final onboardingDoneProvider = FutureProvider<bool>((ref) async {
  final v = await ref.watch(settingsDaoProvider).get('onboardingDone');
  return v == 'true';
});
