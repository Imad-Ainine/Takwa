// ═══════════════════════════════════════════════════════════════
//  lib/core/database/daos.dart
//  محاسبة النفس — Data Access Objects (DAOs)
// ═══════════════════════════════════════════════════════════════

import 'package:drift/drift.dart';
import 'app_database.dart';
part 'daos.g.dart';

// ─────────────────────────────────────────
//  DAO 1: DailyRecordDao
// ─────────────────────────────────────────
@DriftAccessor(tables: [DailyRecords, ProhibitionsLog, CustomIbadahLog])
class DailyRecordDao extends DatabaseAccessor<AppDatabase>
    with _$DailyRecordDaoMixin {
  DailyRecordDao(super.db);

  Future<DailyRecord?> getTodayRecord() {
    final today = _dateOnly(DateTime.now());
    return (select(dailyRecords)..where((r) => r.date.equals(today)))
        .getSingleOrNull();
  }

  Future<DailyRecord> getOrCreateToday() async {
    final existing = await getTodayRecord();
    if (existing != null) return existing;

    final id = await into(dailyRecords).insert(
      DailyRecordsCompanion(date: Value(_dateOnly(DateTime.now()))),
    );
    return (select(dailyRecords)..where((r) => r.id.equals(id))).getSingle();
  }

  Future<void> updatePrayerStatus({
    required int recordId,
    required String prayerName,
    required PrayerStatus status,
  }) async {
    final companion = _prayerCompanion(prayerName, status);
    await (update(dailyRecords)..where((r) => r.id.equals(recordId)))
        .write(companion);
    await _recalcPoints(recordId);
  }

  Future<void> updateQuran({
    required int recordId,
    int? pages,
    double? juzaa,
  }) async {
    await (update(dailyRecords)..where((r) => r.id.equals(recordId))).write(
      DailyRecordsCompanion(
        quranPages: pages != null ? Value(pages) : const Value.absent(),
        quranJuzaa: juzaa != null ? Value(juzaa) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await _recalcPoints(recordId);
  }

  Future<void> updateQuranPages(int recordId, int pages) =>
      updateQuran(recordId: recordId, pages: pages);

  Future<void> updateAdhkar({
    required int recordId,
    bool? morning,
    bool? evening,
    bool? afterPrayer,
  }) async {
    await (update(dailyRecords)..where((r) => r.id.equals(recordId))).write(
      DailyRecordsCompanion(
        morningAdhkar: morning != null ? Value(morning) : const Value.absent(),
        eveningAdhkar: evening != null ? Value(evening) : const Value.absent(),
        afterPrayerAdhkar:
            afterPrayer != null ? Value(afterPrayer) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await _recalcPoints(recordId);
  }

  Future<void> toggleAdhkar(int recordId, String key, bool value) {
    return updateAdhkar(
      recordId: recordId,
      morning: key == 'morning' ? value : null,
      evening: key == 'evening' ? value : null,
      afterPrayer: key == 'afterPrayer' ? value : null,
    );
  }

  Future<void> toggleSadaqah(int recordId, bool value) async {
    await (update(dailyRecords)..where((r) => r.id.equals(recordId)))
        .write(DailyRecordsCompanion(
      sadaqah: Value(value),
      updatedAt: Value(DateTime.now()),
    ));
    await _recalcPoints(recordId);
  }

  Future<void> toggleNightPrayer(int recordId, bool value) async {
    await (update(dailyRecords)..where((r) => r.id.equals(recordId)))
        .write(DailyRecordsCompanion(
      nightPrayer: Value(value),
      updatedAt: Value(DateTime.now()),
    ));
    await _recalcPoints(recordId);
  }

  Future<void> updateFasting(int recordId, FastingType type) async {
    await (update(dailyRecords)..where((r) => r.id.equals(recordId)))
        .write(DailyRecordsCompanion(
      fastingType: Value(type),
      updatedAt: Value(DateTime.now()),
    ));
    await _recalcPoints(recordId);
  }

  Future<void> logProhibition({
    required int recordId,
    required ProhibitionCategory category,
    required bool committed,
    String? customName,
    int timesCount = 1,
    int deductPoints = 10,
  }) async {
    final existing = await (select(prohibitionsLog)
          ..where((p) =>
              p.recordId.equals(recordId) & p.category.equals(category.index)))
        .getSingleOrNull();

    if (existing != null) {
      await (update(prohibitionsLog)..where((p) => p.id.equals(existing.id)))
          .write(ProhibitionsLogCompanion(
        committed: Value(committed),
        timesCount: Value(timesCount),
      ));
    } else {
      await into(prohibitionsLog).insert(ProhibitionsLogCompanion(
        recordId: Value(recordId),
        date: Value(DateTime.now()),
        category: Value(category),
        committed: Value(committed),
        customName: Value(customName),
        timesCount: Value(timesCount),
        deductPoints: Value(deductPoints),
      ));
    }
    await _recalcPoints(recordId);
  }

  Future<List<ProhibitionsLogData>> getTodayProhibitions(int recordId) {
    return (select(prohibitionsLog)..where((p) => p.recordId.equals(recordId)))
        .get();
  }

  Future<DailyRecord?> getRecordByDate(DateTime date) {
    return (select(dailyRecords)..where((r) => r.date.equals(_dateOnly(date))))
        .getSingleOrNull();
  }

  Future<List<DailyRecord>> getLastNDays(int n) {
    final from = DateTime.now().subtract(Duration(days: n));
    return (select(dailyRecords)
          ..where((r) => r.date.isBiggerOrEqualValue(from))
          ..orderBy([(r) => OrderingTerm.desc(r.date)]))
        .get();
  }

  Stream<DailyRecord?> watchTodayRecord() {
    final today = _dateOnly(DateTime.now());
    return (select(dailyRecords)..where((r) => r.date.equals(today)))
        .watchSingleOrNull();
  }

  int _prayerPoints(PrayerStatus status) {
    return switch (status) {
      PrayerStatus.performed => 10,
      PrayerStatus.qadaa => 5,
      _ => 0,
    };
  }

  Future<void> _recalcPoints(int recordId) async {
    final record = await (select(dailyRecords)
          ..where((r) => r.id.equals(recordId)))
        .getSingle();

    int points = 0;

    points += _prayerPoints(PrayerStatus.values[record.fajrStatus.index]);
    points += _prayerPoints(PrayerStatus.values[record.dhuhrStatus.index]);
    points += _prayerPoints(PrayerStatus.values[record.asrStatus.index]);
    points += _prayerPoints(PrayerStatus.values[record.maghribStatus.index]);
    points += _prayerPoints(PrayerStatus.values[record.ishaStatus.index]);
    if (record.nightPrayer) points += 15;
    if (record.witr) points += 5;
    points += record.rawatib * 2;

    points += record.quranPages * 1;
    points += (record.quranJuzaa * 10).toInt();

    if (record.morningAdhkar) points += 5;
    if (record.eveningAdhkar) points += 5;
    if (record.afterPrayerAdhkar) points += 3;

    if (record.fastingType.index == FastingType.fard.index) points += 20;
    if (record.fastingType.index == FastingType.nafl.index) points += 10;

    if (record.sadaqah) points += 10;

    final prohibs = await getTodayProhibitions(recordId);
    int deducted = 0;
    for (final p in prohibs) {
      if (p.committed) deducted += p.deductPoints * p.timesCount;
    }

    await (update(dailyRecords)..where((r) => r.id.equals(recordId))).write(
      DailyRecordsCompanion(
        taqwaPoints: Value(points),
        deductedPoints: Value(deducted),
        netPoints: Value(points - deducted),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  DailyRecordsCompanion _prayerCompanion(String name, PrayerStatus s) {
    final v = Value<PrayerStatus>(s);
    return switch (name) {
      'fajr' => DailyRecordsCompanion(fajrStatus: v),
      'dhuhr' => DailyRecordsCompanion(dhuhrStatus: v),
      'asr' => DailyRecordsCompanion(asrStatus: v),
      'maghrib' => DailyRecordsCompanion(maghribStatus: v),
      'isha' => DailyRecordsCompanion(ishaStatus: v),
      _ => const DailyRecordsCompanion(),
    };
  }
}

// ─────────────────────────────────────────
//  DAO 2: StatsDao
// ─────────────────────────────────────────
@DriftAccessor(tables: [DailyRecords, ProhibitionsLog, Achievements])
class StatsDao extends DatabaseAccessor<AppDatabase> with _$StatsDaoMixin {
  StatsDao(super.db);

  Future<int> getMonthlyPoints(int year, int month) async {
    final from = DateTime(year, month, 1);
    final to = DateTime(year, month + 1, 0);
    final rows = await (select(dailyRecords)
          ..where((r) => r.date.isBetweenValues(from, to)))
        .get();
    return rows.fold<int>(0, (sum, r) => sum + r.netPoints);
  }

  Future<int> getLongestStreak() async {
    final records = await (select(dailyRecords)
          ..orderBy([(r) => OrderingTerm.asc(r.date)]))
        .get();

    int longest = 0;
    int current = 0;
    DateTime? prev;

    for (final r in records) {
      if (r.netPoints > 0) {
        if (prev != null && r.date.difference(prev).inDays == 1) {
          current++;
        } else {
          current = 1;
        }
        if (current > longest) longest = current;
        prev = r.date;
      } else {
        current = 0;
        prev = null;
      }
    }
    return longest;
  }

  Future<int> getCurrentStreak() async {
    final records = await (select(dailyRecords)
          ..orderBy([(r) => OrderingTerm.desc(r.date)])
          ..limit(60))
        .get();

    int streak = 0;
    DateTime? prev;

    for (final r in records) {
      if (r.netPoints > 0) {
        if (prev == null) {
          streak = 1;
          prev = r.date;
        } else if (prev.difference(r.date).inDays == 1) {
          streak++;
          prev = r.date;
        } else {
          break;
        }
      } else {
        break;
      }
    }
    return streak;
  }

  Future<double> getPrayerAttendanceRate(int year, int month) async {
    final from = DateTime(year, month, 1);
    final to = DateTime(year, month + 1, 0);
    final rows = await (select(dailyRecords)
          ..where((r) => r.date.isBetweenValues(from, to)))
        .get();

    if (rows.isEmpty) return 0;

    int total = rows.length * 5;
    int performed = 0;

    for (final r in rows) {
      for (final status in [
        r.fajrStatus,
        r.dhuhrStatus,
        r.asrStatus,
        r.maghribStatus,
        r.ishaStatus,
      ]) {
        if (status == PrayerStatus.performed) performed++;
      }
    }
    return performed / total;
  }

  Future<int> getMonthlyQuranPages(int year, int month) async {
    final from = DateTime(year, month, 1);
    final to = DateTime(year, month + 1, 0);
    final rows = await (select(dailyRecords)
          ..where((r) => r.date.isBetweenValues(from, to)))
        .get();
    return rows.fold<int>(0, (sum, r) => sum + r.quranPages);
  }

  Future<List<WeeklyPoint>> getWeeklyPoints() async {
    final results = <WeeklyPoint>[];
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final d = DateTime(date.year, date.month, date.day);
      final record = await (select(dailyRecords)
            ..where((r) => r.date.equals(d)))
          .getSingleOrNull();
      results.add(WeeklyPoint(
        date: d,
        points: record?.netPoints ?? 0,
      ));
    }
    return results;
  }

  TaqwaLevel getTaqwaLevel(int totalPoints) {
    if (totalPoints >= 600) return TaqwaLevel.mutaqi;
    if (totalPoints >= 300) return TaqwaLevel.mujahid;
    if (totalPoints >= 100) return TaqwaLevel.salik;
    return TaqwaLevel.mubtadi;
  }

  Future<MonthStats> getMonthStats(int year, int month) async {
    return MonthStats(
      totalPoints: await getMonthlyPoints(year, month),
      longestStreak: await getLongestStreak(),
      currentStreak: await getCurrentStreak(),
      prayerRate: await getPrayerAttendanceRate(year, month),
      quranPages: await getMonthlyQuranPages(year, month),
    );
  }

  Future<void> addAchievement({
    required String type,
    required String titleAr,
    required String descAr,
    required String emoji,
    int pointsReward = 0,
  }) async {
    final existing = await (select(achievements)
          ..where((a) => a.type.equals(type)))
        .getSingleOrNull();
    if (existing != null) return;

    await into(achievements).insert(AchievementsCompanion(
      type: Value(type),
      titleAr: Value(titleAr),
      descAr: Value(descAr),
      emoji: Value(emoji),
      pointsReward: Value(pointsReward),
      earnedAt: Value(DateTime.now()),
    ));
  }

  Future<List<Achievement>> checkAndGrantAchievements() async {
    final newAchievements = <Achievement>[];
    final streak = await getCurrentStreak();
    final now = DateTime.now();

    // 1. Streaks
    if (streak >= 3) {
      await _tryGrant('streak_3', 'البداية الطيبة',
          'حافظت على المحاسبة لثلاثة أيام متواصلة', '🌱', 20);
    }
    if (streak >= 7) {
      await _tryGrant(
          'streak_7', 'الأسبوع المثالي', 'سبعة أيام من الالتزام والمحاسبة', '🌿', 50);
    }
    if (streak >= 30) {
      await _tryGrant(
          'streak_30', 'المجاهد المثابر', 'ثلاثون يوماً من مراقبة النفس والتقوى', '⚔️', 200);
    }

    // 2. Quran
    final quranPages = await getMonthlyQuranPages(now.year, now.month);
    if (quranPages >= 30) {
      await _tryGrant(
          'quran_juz', 'أهل القرآن', 'ختمت جزءاً كاملاً من كتاب الله', '📖', 100);
    }

    // 3. Today's tasks (Dynamic)
    final todayDate = DateTime(now.year, now.month, now.day);
    final today = await (select(dailyRecords)..where((r) => r.date.equals(todayDate)))
        .getSingleOrNull();

    if (today != null) {
      if (today.netPoints > 0) {
        await _tryGrant('daily_muhasaba', 'المحاسب المجتهد',
            'أكملت محاسبة النفس لهذا اليوم', '📝', 10);
      }
      if (today.morningAdhkar) {
        await _tryGrant('morning_adhkar', 'نور الصباح',
            'أكملت أذكار الصباح بالكامل', '🌅', 5);
      }
      if (today.eveningAdhkar) {
        await _tryGrant('evening_adhkar', 'تحصين المساء',
            'أكملت أذكار المساء بالكامل', '🌙', 5);
      }
      if (today.sadaqah) {
        await _tryGrant('first_sadaqah', 'اليد المعطية',
            'أخرجت أول صدقة لك عبر التطبيق', '💰', 30);
      }
    }

    // 4. Points Milestones
    final totalPoints = await getMonthlyPoints(now.year, now.month);
    if (totalPoints >= 100) {
      await _tryGrant('points_100', 'مئة خطوة', 'جمعت أول 100 نقطة تقوى', '🎖️', 50);
    }
    if (totalPoints >= 3000) {
       await _tryGrant('points_1000', 'فارس التقوى', 'بلغت 1000 نقطة في مسيرتك', '🏆', 500);
    }

    return newAchievements;
  }

  Future<void> _tryGrant(
      String type, String title, String desc, String emoji, int pts) async {
    final exists = await (select(achievements)
          ..where((a) => a.type.equals(type)))
        .getSingleOrNull();
    if (exists == null) {
      await addAchievement(
          type: type,
          titleAr: title,
          descAr: desc,
          emoji: emoji,
          pointsReward: pts);
    }
  }
}

// ─────────────────────────────────────────
//  DAO 3: SettingsDao
// ─────────────────────────────────────────
@DriftAccessor(tables: [UserSettings])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.db);

  Future<String?> get(String key) async {
    final row = await (select(userSettings)..where((s) => s.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> set(String key, String value) async {
    await into(userSettings).insertOnConflictUpdate(
      UserSettingsCompanion(key: Value(key), value: Value(value)),
    );
  }

  Future<bool> getBool(String key, {bool defaultVal = false}) async {
    final v = await get(key);
    return v == null ? defaultVal : v == 'true';
  }

  Future<void> setBool(String key, bool value) => set(key, value.toString());

  Stream<String?> watch(String key) {
    return (select(userSettings)..where((s) => s.key.equals(key)))
        .watchSingleOrNull()
        .map((r) => r?.value);
  }
}

// ─────────────────────────────────────────
//  DATA MODELS
// ─────────────────────────────────────────

class WeeklyPoint {
  final DateTime date;
  final int points;
  WeeklyPoint({required this.date, required this.points});

  String get dayLabel {
    const days = ['أح', 'إث', 'ثل', 'أر', 'خم', 'جم', 'سب'];
    return days[date.weekday % 7];
  }
}

class MonthStats {
  final int totalPoints;
  final int longestStreak;
  final int currentStreak;
  final double prayerRate;
  final int quranPages;

  MonthStats({
    required this.totalPoints,
    required this.longestStreak,
    required this.currentStreak,
    required this.prayerRate,
    required this.quranPages,
  });

  TaqwaLevel get level {
    if (totalPoints >= 600) return TaqwaLevel.mutaqi;
    if (totalPoints >= 300) return TaqwaLevel.mujahid;
    if (totalPoints >= 100) return TaqwaLevel.salik;
    return TaqwaLevel.mubtadi;
  }

  String get levelLabel => switch (level) {
        TaqwaLevel.mubtadi => 'مبتدئ 🌱',
        TaqwaLevel.salik => 'سالك 🌿',
        TaqwaLevel.mujahid => 'مجاهد ⚔️',
        TaqwaLevel.mutaqi => 'متقي ✨',
      };

  int get prayerPercent => (prayerRate * 100).round();
}
