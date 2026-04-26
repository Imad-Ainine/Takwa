// ═══════════════════════════════════════════════════════════════
//  lib/core/database/daos.dart
// تقوى — Data Access Objects (DAOs)
// ═══════════════════════════════════════════════════════════════

import 'package:drift/drift.dart';
import 'app_database.dart';
part 'daos.g.dart';

// ─────────────────────────────────────────
//  DAO 1: DailyRecordDao
// ─────────────────────────────────────────
@DriftAccessor(
  tables: [DailyRecords, ProhibitionsLog, CustomIbadahLog, CustomIbadah],
)
class DailyRecordDao extends DatabaseAccessor<AppDatabase>
    with _$DailyRecordDaoMixin {
  DailyRecordDao(super.db);

  Future<DailyRecord?> getTodayRecord() {
    final today = _dateOnly(DateTime.now());
    return (select(
      dailyRecords,
    )..where((r) => r.date.equals(today))).getSingleOrNull();
  }

  Future<DailyRecord> getOrCreateToday() async {
    final now = DateTime.now();
    final today = _dateOnly(now);

    // Atomic insert Or Ignore to handle race conditions
    await into(dailyRecords).insert(
      DailyRecordsCompanion(date: Value(today)),
      mode: InsertMode.insertOrIgnore,
    );

    // Fetch the record (either newly created or existed)
    return (select(
      dailyRecords,
    )..where((r) => r.date.equals(today))).getSingle();
  }

  Future<void> updatePrayerStatus({
    required int recordId,
    required String prayerName,
    required PrayerStatus status,
  }) async {
    final companion = _prayerCompanion(prayerName, status);
    await (update(
      dailyRecords,
    )..where((r) => r.id.equals(recordId))).write(companion);
    await recalcPoints(recordId);
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
    await recalcPoints(recordId);
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
        afterPrayerAdhkar: afterPrayer != null
            ? Value(afterPrayer)
            : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await recalcPoints(recordId);
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
    await (update(dailyRecords)..where((r) => r.id.equals(recordId))).write(
      DailyRecordsCompanion(
        sadaqah: Value(value),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await recalcPoints(recordId);
  }

  Future<void> toggleNightPrayer(int recordId, bool value) async {
    await (update(dailyRecords)..where((r) => r.id.equals(recordId))).write(
      DailyRecordsCompanion(
        nightPrayer: Value(value),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await recalcPoints(recordId);
  }

  Future<void> updateFasting(int recordId, FastingType type) async {
    await (update(dailyRecords)..where((r) => r.id.equals(recordId))).write(
      DailyRecordsCompanion(
        fastingType: Value(type),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await recalcPoints(recordId);
  }

  Future<void> logProhibition({
    required int recordId,
    required ProhibitionCategory category,
    required bool committed,
    int timesCount = 0,
    int deductPoints = 10,
    String? notes,
  }) async {
    await transaction(() async {
      final existing =
          await (select(prohibitionsLog)..where(
                (p) =>
                    p.recordId.equals(recordId) &
                    p.category.equals(category.index),
              ))
              .getSingleOrNull();

      if (existing != null) {
        await (update(
          prohibitionsLog,
        )..where((p) => p.id.equals(existing.id))).write(
          ProhibitionsLogCompanion(
            committed: Value(committed),
            timesCount: Value(timesCount),
            notes: Value(notes),
          ),
        );
      } else {
        await into(prohibitionsLog).insert(
          ProhibitionsLogCompanion(
            recordId: Value(recordId),
            date: Value(DateTime.now()),
            category: Value(category),
            committed: Value(committed),
            timesCount: Value(timesCount),
            deductPoints: Value(deductPoints),
            notes: Value(notes),
          ),
        );
      }
      await recalcPoints(recordId);
    });
  }

  Future<List<ProhibitionsLogData>> getTodayProhibitions(int recordId) {
    return (select(
      prohibitionsLog,
    )..where((p) => p.recordId.equals(recordId))).get();
  }

  Future<DailyRecord?> getRecordByDate(DateTime date) {
    return (select(
      dailyRecords,
    )..where((r) => r.date.equals(_dateOnly(date)))).getSingleOrNull();
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
    return (select(
      dailyRecords,
    )..where((r) => r.date.equals(today))).watchSingleOrNull();
  }

  int _prayerPoints(PrayerStatus status) {
    return switch (status) {
      PrayerStatus.performed => 10,
      PrayerStatus.qadaa => 5,
      _ => 0,
    };
  }

  Future<void> recalcPoints(int recordId) async {
    final record = await (select(
      dailyRecords,
    )..where((r) => r.id.equals(recordId))).getSingle();

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

    // ── Custom Ibadaat (Positive/Negative) ──
    final customLogs = await (select(customIbadahLog).join([
      innerJoin(
        customIbadah,
        customIbadah.id.equalsExp(customIbadahLog.ibadahId),
      ),
    ])..where(customIbadahLog.recordId.equals(recordId))).get();

    for (final row in customLogs) {
      final log = row.readTable(customIbadahLog);
      final meta = row.readTable(customIbadah);
      if (log.done) {
        final pts = meta.points * log.count;
        if (meta.isPositive) {
          points += pts;
        } else {
          deducted += pts.abs();
        }
      }
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

  /// Safely coerce a dynamic JSON value to [int].
  /// Supabase may return integer fields as [String] in some responses.
  int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  /// Safely coerce a dynamic JSON value to [bool].
  bool _toBool(dynamic v) {
    if (v == null) return false;
    if (v is bool) return v;
    final s = v.toString().toLowerCase();
    return s == 'true' || s == '1';
  }

  PrayerStatus _parsePrayerStatus(dynamic v) {
    if (v == null) return PrayerStatus.notDue;
    if (v is int) {
      if (v >= 0 && v < PrayerStatus.values.length) {
        return PrayerStatus.values[v];
      }
      return PrayerStatus.notDue;
    }
    final String s = v.toString().replaceFirst('PrayerStatus.', '');
    return PrayerStatus.values.firstWhere(
      (e) => e.name == s,
      orElse: () {
        final idx = int.tryParse(s) ?? 0;
        if (idx >= 0 && idx < PrayerStatus.values.length) {
          return PrayerStatus.values[idx];
        }
        return PrayerStatus.notDue;
      },
    );
  }

  FastingType _parseFastingType(dynamic v) {
    if (v == null) return FastingType.none;
    if (v is int) {
      if (v >= 0 && v < FastingType.values.length) return FastingType.values[v];
      return FastingType.none;
    }
    final String s = v.toString().replaceFirst('FastingType.', '');
    return FastingType.values.firstWhere(
      (e) => e.name == s,
      orElse: () {
        final idx = int.tryParse(s) ?? 0;
        if (idx >= 0 && idx < FastingType.values.length) {
          return FastingType.values[idx];
        }
        return FastingType.none;
      },
    );
  }

  /// Syncs a remote prohibition log (uses date for matching local daily records)
  Future<void> upsertProhibitionFromRemote(Map<String, dynamic> data) async {
    final dateStr = data['date'] as String;
    final date = DateTime.parse(dateStr);

    var dr = await getRecordByDate(date);
    if (dr == null) {
      await into(dailyRecords).insert(
        DailyRecordsCompanion(date: Value(date)),
        mode: InsertMode.insertOrIgnore,
      );
      dr = await getRecordByDate(date);
    }
    if (dr == null) return;

    final categoryName = data['category'] as String;
    final category = ProhibitionCategory.values.firstWhere(
      (e) => e.name == categoryName,
      orElse: () => ProhibitionCategory.custom,
    );

    final companion = ProhibitionsLogCompanion(
      recordId: Value(dr.id),
      date: Value(date),
      category: Value(category),
      committed: Value(
        (data['committed'] is bool)
            ? data['committed']
            : data['committed'] == 1,
      ),
      timesCount: Value(data['times_count'] as int? ?? 0),
      deductPoints: Value(data['deduct_points'] as int? ?? 10),
      notes: Value(data['notes'] as String?),
    );

    final existing =
        await (select(prohibitionsLog)..where(
              (p) =>
                  p.recordId.equals(dr!.id) & p.category.equals(category.index),
            ))
            .getSingleOrNull();

    if (existing != null) {
      await (update(
        prohibitionsLog,
      )..where((p) => p.id.equals(existing.id))).write(companion);
    } else {
      await into(prohibitionsLog).insert(companion);
    }
  }

  /// Sync from remote Supabase record
  Future<void> upsertFromRemote(Map<String, dynamic> data) async {
    final date = DateTime.parse(data['date'] as String);
    final companion = DailyRecordsCompanion(
      date: Value(date),
      fajrStatus: Value(_parsePrayerStatus(data['fajr_status'])),
      dhuhrStatus: Value(_parsePrayerStatus(data['dhuhr_status'])),
      asrStatus: Value(_parsePrayerStatus(data['asr_status'])),
      maghribStatus: Value(_parsePrayerStatus(data['maghrib_status'])),
      ishaStatus: Value(_parsePrayerStatus(data['isha_status'])),
      nightPrayer: Value(_toBool(data['night_prayer'])),
      quranPages: Value(_toInt(data['quran_pages'])),
      morningAdhkar: Value(_toBool(data['morning_adhkar'])),
      eveningAdhkar: Value(_toBool(data['evening_adhkar'])),
      fastingType: Value(_parseFastingType(data['fasting_type'])),
      sadaqah: Value(_toBool(data['sadaqah'])),
      netPoints: Value(_toInt(data['net_points'])),
      taqwaPoints: Value(_toInt(data['taqwa_points'])),
      notes: Value(data['notes'] as String?),
      updatedAt: Value(DateTime.now()),
    );

    await into(dailyRecords).insert(
      companion,
      onConflict: DoUpdate((old) => companion, target: [dailyRecords.date]),
    );
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
    final rows = await (select(
      dailyRecords,
    )..where((r) => r.date.isBetweenValues(from, to))).get();
    return rows.fold<int>(0, (sum, r) => sum + r.netPoints);
  }

  Future<int> getLongestStreak() async {
    final records = await (select(
      dailyRecords,
    )..orderBy([(r) => OrderingTerm.asc(r.date)])).get();

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
    final records =
        await (select(dailyRecords)
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
    final rows = await (select(
      dailyRecords,
    )..where((r) => r.date.isBetweenValues(from, to))).get();

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
    final rows = await (select(
      dailyRecords,
    )..where((r) => r.date.isBetweenValues(from, to))).get();
    return rows.fold<int>(0, (sum, r) => sum + r.quranPages);
  }

  Future<List<WeeklyPoint>> getWeeklyPoints() async {
    final results = <WeeklyPoint>[];
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final d = DateTime(date.year, date.month, date.day);
      final record = await (select(
        dailyRecords,
      )..where((r) => r.date.equals(d))).getSingleOrNull();
      results.add(WeeklyPoint(date: d, points: record?.netPoints ?? 0));
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

  Stream<MonthStats> watchMonthStats(int year, int month) {
    return customSelect(
      'SELECT 1',
      readsFrom: {dailyRecords},
    ).watch().asyncMap((_) => getMonthStats(year, month));
  }

  Stream<int> watchCurrentStreak() {
    return customSelect(
      'SELECT 1',
      readsFrom: {dailyRecords},
    ).watch().asyncMap((_) => getCurrentStreak());
  }

  Stream<List<WeeklyPoint>> watchWeeklyPoints() {
    return customSelect(
      'SELECT 1',
      readsFrom: {dailyRecords},
    ).watch().asyncMap((_) => getWeeklyPoints());
  }

  // ── Range-based queries for period selector ──

  /// Returns per-prayer attendance rates for records within [from, to].
  Future<List<PrayerRateData>> getPerPrayerRates(
    DateTime from,
    DateTime to,
  ) async {
    final rows = await (select(dailyRecords)
          ..where((r) => r.date.isBetweenValues(from, to)))
        .get();

    if (rows.isEmpty) {
      return const [
        PrayerRateData(name: 'الفجر', emoji: '🌅', rate: 0),
        PrayerRateData(name: 'الظهر', emoji: '☀️', rate: 0),
        PrayerRateData(name: 'العصر', emoji: '🌤', rate: 0),
        PrayerRateData(name: 'المغرب', emoji: '🌆', rate: 0),
        PrayerRateData(name: 'العشاء', emoji: '🌃', rate: 0),
      ];
    }

    int fajr = 0, dhuhr = 0, asr = 0, maghrib = 0, isha = 0;
    for (final r in rows) {
      if (r.fajrStatus == PrayerStatus.performed) fajr++;
      if (r.dhuhrStatus == PrayerStatus.performed) dhuhr++;
      if (r.asrStatus == PrayerStatus.performed) asr++;
      if (r.maghribStatus == PrayerStatus.performed) maghrib++;
      if (r.ishaStatus == PrayerStatus.performed) isha++;
    }
    final n = rows.length;
    return [
      PrayerRateData(name: 'الفجر', emoji: '🌅', rate: fajr / n),
      PrayerRateData(name: 'الظهر', emoji: '☀️', rate: dhuhr / n),
      PrayerRateData(name: 'العصر', emoji: '🌤', rate: asr / n),
      PrayerRateData(name: 'المغرب', emoji: '🌆', rate: maghrib / n),
      PrayerRateData(name: 'العشاء', emoji: '🌃', rate: isha / n),
    ];
  }

  /// Returns MonthStats aggregated over any date range [from, to].
  Future<MonthStats> getStatsForRange(DateTime from, DateTime to) async {
    final rows = await (select(dailyRecords)
          ..where((r) => r.date.isBetweenValues(from, to)))
        .get();

    final totalPoints = rows.fold<int>(0, (s, r) => s + r.netPoints);
    final quranPages = rows.fold<int>(0, (s, r) => s + r.quranPages);

    int performed = 0;
    for (final r in rows) {
      for (final s in [
        r.fajrStatus,
        r.dhuhrStatus,
        r.asrStatus,
        r.maghribStatus,
        r.ishaStatus,
      ]) {
        if (s == PrayerStatus.performed) performed++;
      }
    }
    final prayerRate =
        rows.isEmpty ? 0.0 : performed / (rows.length * 5);

    return MonthStats(
      totalPoints: totalPoints,
      longestStreak: await getLongestStreak(),
      currentStreak: await getCurrentStreak(),
      prayerRate: prayerRate,
      quranPages: quranPages,
    );
  }

  /// Returns one [WeeklyPoint] per day in [from..to] for the bar chart.
  Future<List<WeeklyPoint>> getPointsPerDay(
    DateTime from,
    DateTime to,
  ) async {
    final results = <WeeklyPoint>[];
    var cursor = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day);
    while (!cursor.isAfter(end)) {
      final record = await (select(dailyRecords)
            ..where((r) => r.date.equals(cursor)))
          .getSingleOrNull();
      results.add(WeeklyPoint(date: cursor, points: record?.netPoints ?? 0));
      cursor = cursor.add(const Duration(days: 1));
    }
    return results;
  }

  // ── Stream watchers for range queries ──

  Stream<MonthStats> watchStatsForRange(DateTime from, DateTime to) {
    return customSelect(
      'SELECT 1',
      readsFrom: {dailyRecords},
    ).watch().asyncMap((_) => getStatsForRange(from, to));
  }

  Stream<List<WeeklyPoint>> watchPointsPerDay(DateTime from, DateTime to) {
    return customSelect(
      'SELECT 1',
      readsFrom: {dailyRecords},
    ).watch().asyncMap((_) => getPointsPerDay(from, to));
  }

  Stream<List<PrayerRateData>> watchPerPrayerRates(
    DateTime from,
    DateTime to,
  ) {
    return customSelect(
      'SELECT 1',
      readsFrom: {dailyRecords},
    ).watch().asyncMap((_) => getPerPrayerRates(from, to));
  }

  Future<void> addAchievement({
    required String type,
    required String titleAr,
    required String descAr,
    required String emoji,
    int pointsReward = 0,
  }) async {
    final existing = await (select(
      achievements,
    )..where((a) => a.type.equals(type))).getSingleOrNull();
    if (existing != null) return;

    await into(achievements).insert(
      AchievementsCompanion(
        type: Value(type),
        titleAr: Value(titleAr),
        descAr: Value(descAr),
        emoji: Value(emoji),
        pointsReward: Value(pointsReward),
        earnedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<List<Achievement>> checkAndGrantAchievements() async {
    final newAchievements = <Achievement>[];
    final streak = await getCurrentStreak();
    final now = DateTime.now();

    // 1. Streaks
    if (streak >= 3) {
      final a = await _tryGrant(
        'streak_3',
        'البداية الطيبة',
        'حافظت على المحاسبة لثلاثة أيام متواصلة',
        '🌱',
        20,
      );
      if (a != null) newAchievements.add(a);
    }
    if (streak >= 7) {
      final a = await _tryGrant(
        'streak_7',
        'الأسبوع المثالي',
        'سبعة أيام من الالتزام والمحاسبة',
        '🌿',
        50,
      );
      if (a != null) newAchievements.add(a);
    }
    if (streak >= 30) {
      final a = await _tryGrant(
        'streak_30',
        'المجاهد المثابر',
        'ثلاثون يوماً من مراقبة النفس والتقوى',
        '⚔️',
        200,
      );
      if (a != null) newAchievements.add(a);
    }

    // 2. Quran
    final quranPages = await getMonthlyQuranPages(now.year, now.month);
    if (quranPages >= 30) {
      final a = await _tryGrant(
        'quran_juz',
        'أهل القرآن',
        'ختمت جزءاً كاملاً من كتاب الله',
        '📖',
        100,
      );
      if (a != null) newAchievements.add(a);
    }

    // 3. Today's tasks (Dynamic)
    final todayDate = DateTime(now.year, now.month, now.day);
    final today = await (select(
      dailyRecords,
    )..where((r) => r.date.equals(todayDate))).getSingleOrNull();

    if (today != null) {
      if (today.netPoints > 0) {
        final a = await _tryGrant(
          'daily_muhasaba',
          'المحاسب المجتهد',
          'أكملت محاسبة النفس لهذا اليوم',
          '📝',
          10,
        );
        if (a != null) newAchievements.add(a);
      }
      if (today.morningAdhkar) {
        final a = await _tryGrant(
          'morning_adhkar',
          'نور الصباح',
          'أكملت أذكار الصباح بالكامل',
          '🌅',
          5,
        );
        if (a != null) newAchievements.add(a);
      }
      if (today.eveningAdhkar) {
        final a = await _tryGrant(
          'evening_adhkar',
          'تحصين المساء',
          'أكملت أذكار المساء بالكامل',
          '🌙',
          5,
        );
        if (a != null) newAchievements.add(a);
      }
      if (today.sadaqah) {
        final a = await _tryGrant(
          'first_sadaqah',
          'اليد المعطية',
          'أخرجت أول صدقة لك عبر التطبيق',
          '💰',
          30,
        );
        if (a != null) newAchievements.add(a);
      }
    }

    // 4. Points Milestones
    final totalPoints = await getMonthlyPoints(now.year, now.month);
    if (totalPoints >= 100) {
      final a = await _tryGrant(
        'points_100',
        'مئة خطوة',
        'جمعت أول 100 نقطة تقوى',
        '🎖️',
        50,
      );
      if (a != null) newAchievements.add(a);
    }
    if (totalPoints >= 3000) {
      final a = await _tryGrant(
        'points_1000',
        'فارس التقوى',
        'بلغت 1000 نقطة في مسيرتك',
        '🏆',
        500,
      );
      if (a != null) newAchievements.add(a);
    }

    return newAchievements;
  }

  Future<Achievement?> _tryGrant(
    String type,
    String title,
    String desc,
    String emoji,
    int pts,
  ) async {
    final exists = await (select(
      achievements,
    )..where((a) => a.type.equals(type))).getSingleOrNull();
    if (exists == null) {
      final id = await into(achievements).insert(
        AchievementsCompanion(
          type: Value(type),
          titleAr: Value(title),
          descAr: Value(desc),
          emoji: Value(emoji),
          pointsReward: Value(pts),
          earnedAt: Value(DateTime.now()),
        ),
      );
      return (select(achievements)..where((a) => a.id.equals(id))).getSingle();
    }
    return null;
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
    final row = await (select(
      userSettings,
    )..where((s) => s.key.equals(key))).getSingleOrNull();
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

  Future<Map<String, String>> getAllSettings() async {
    final rows = await select(userSettings).get();
    return {for (var row in rows) row.key: row.value};
  }

  Future<void> upsertFromRemote(Map<String, dynamic> data) async {
    // Map every Supabase column name → local key used by SettingsDao.set()
    // Local key must match what UserPreferences.fromMap() looks up.
    final mapping = <String, String>{
      // Prayer calculation
      'madhab': 'madhab',
      'calc_method': 'calcMethod',

      // General toggles
      'prayer_reminder': 'prayerReminder',
      'pre_adhan_notif': 'preAdhanNotif',
      'iqama_notif': 'iqamaNotif',

      // Wake-up
      'wake_up_before_fajr': 'wakeUpBeforeFajr',
      'wake_up_time': 'wakeUpTime',

      // Adhkar reminders
      'morning_adhkar_reminder': 'morningAdhkarReminder',
      'evening_adhkar_reminder': 'eveningAdhkarReminder',
      'adhkar_notif_enabled': 'adhkarNotifEnabled',
      'morning_adhkar_time': 'morningAdhkarTime',
      'evening_adhkar_time': 'eveningAdhkarTime',
      'sleep_adhkar_time': 'sleepAdhkarTime',
      'after_fajr_adhkar': 'afterFajrAdhkar',
      'after_asr_adhkar': 'afterAsrAdhkar',

      // Muhasaba
      'muhasaba_reminder': 'eveningMuhasabaReminder',
      'evening_reminder_time': 'eveningReminderTime',

      // Extra reminders
      'daily_duas_on': 'dailyDuasOn',
      'special_reminders_on': 'specialRemindersOn',
      'fasting_reminders_on': 'fastingRemindersOn',

      // Appearance / mode
      'ramadan_mode': 'ramadanMode',
      'theme_mode': 'themeMode',
      'language': 'language',

      // Adhan sound
      'adhan_sound': 'adhan_sound',

      // Overlay / screen settings
      'overlay_popups_enabled': 'overlayEnabled',
      'adhan_sound_enabled': 'adhan_sound_enabled',
      'adhan_screen_enabled': 'adhan_screen_enabled',
      'popup_interval_minutes': 'popupIntervalMins',
    };

    for (final entry in mapping.entries) {
      if (data.containsKey(entry.key) && data[entry.key] != null) {
        await set(entry.value, data[entry.key].toString());
      }
    }
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

  String get fullDayName {
    const days = ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
    return days[date.weekday % 7];
  }

  String get shortDayName {
    const days = ['ح', 'ن', 'ث', 'ر', 'خ', 'ج', 'س'];
    return days[date.weekday % 7];
  }
}

/// Per-prayer attendance rate for a given date range.
class PrayerRateData {
  final String name;
  final String emoji;
  final double rate;
  const PrayerRateData({
    required this.name,
    required this.emoji,
    required this.rate,
  });
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

// ─────────────────────────────────────────
//  DAO 4: RemindersDao
// ─────────────────────────────────────────
@DriftAccessor(tables: [Reminders])
class RemindersDao extends DatabaseAccessor<AppDatabase>
    with _$RemindersDaoMixin {
  RemindersDao(super.db);

  /// Watch all reminders ordered by creation date
  Stream<List<Reminder>> watchAll() {
    return (select(
      reminders,
    )..orderBy([(r) => OrderingTerm.desc(r.createdAt)])).watch();
  }

  /// Insert a new reminder
  Future<int> addReminder({
    required String title,
    required String iconName,
    required String time,
  }) {
    return into(reminders).insert(
      RemindersCompanion(
        title: Value(title),
        iconName: Value(iconName),
        time: Value(time),
      ),
    );
  }

  /// Toggle enabled / disabled for a reminder
  Future<void> toggleEnabled(int id, bool isEnabled) {
    return (update(reminders)..where((r) => r.id.equals(id))).write(
      RemindersCompanion(isEnabled: Value(isEnabled)),
    );
  }

  /// Delete a reminder by id
  Future<int> deleteReminder(int id) {
    return (delete(reminders)..where((r) => r.id.equals(id))).go();
  }

  /// Sync from remote Supabase record
  Future<void> upsertFromRemote(Map<String, dynamic> data) async {
    final companion = RemindersCompanion(
      title: Value(data['title'] as String),
      iconName: Value(data['icon_name'] as String? ?? 'favorite_rounded'),
      time: Value(data['time'] as String),
      isEnabled: Value(data['is_enabled'] as bool? ?? true),
      // We don't necessarily want to force the ID from remote if it's auto-incrementing locally,
      // but we need a way to link them. For now, we'll use the local_id if provided.
    );

    final localId = data['local_id'] as int?;
    if (localId != null) {
      await into(reminders).insertOnConflictUpdate(
        companion.copyWith(id: Value(localId)),
      );
    } else {
      await into(reminders).insert(companion);
    }
  }
}

// ═══════════════════════════════════════════════════════════════
//  CUSTOM IBADAH DAO
// ═══════════════════════════════════════════════════════════════
@DriftAccessor(tables: [CustomIbadah, CustomIbadahLog, DailyRecords])
class CustomIbadahDao extends DatabaseAccessor<AppDatabase>
    with _$CustomIbadahDaoMixin {
  CustomIbadahDao(super.db);

  // --- Ibadah Defs ---
  Stream<List<CustomIbadahData>> watchActiveIbadat(bool isPositive) {
    return (select(customIbadah)
          ..where(
            (i) => i.isActive.equals(true) & i.isPositive.equals(isPositive),
          )
          ..orderBy([(i) => OrderingTerm.asc(i.sortOrder)]))
        .watch();
  }

  Stream<List<CustomIbadahData>> watchAllIbadat(bool isPositive) {
    return (select(customIbadah)
          ..where((i) => i.isPositive.equals(isPositive))
          ..orderBy([
            (i) => OrderingTerm.desc(i.isActive),
            (i) => OrderingTerm.asc(i.sortOrder),
          ]))
        .watch();
  }

  Future<List<CustomIbadahData>> getAllIbadat() {
    return select(customIbadah).get();
  }

  Future<int> addIbadah(CustomIbadahCompanion comp) {
    return into(customIbadah).insert(comp);
  }

  Future<void> updateIbadah(CustomIbadahCompanion comp) {
    return (update(
      customIbadah,
    )..where((t) => t.id.equals(comp.id.value))).write(comp);
  }

  Future<void> deleteIbadah(int id) {
    return (delete(customIbadah)..where((t) => t.id.equals(id))).go();
  }

  // --- Syncing (Remote -> Local) ---
  Future<void> upsertCustomIbadahFromRemote(Map<String, dynamic> data) async {
    final id = data['id'] as int;
    final companion = CustomIbadahCompanion(
      id: Value(id),
      nameAr: Value(data['name_ar'] as String),
      emoji: Value(data['emoji'] as String? ?? '⭐'),
      isPositive: Value(data['is_positive'] as bool? ?? true),
      points: Value(data['points'] as int? ?? 5),
      isActive: Value(data['is_active'] as bool? ?? true),
      sortOrder: Value(data['sort_order'] as int? ?? 0),
    );
    await into(customIbadah).insertOnConflictUpdate(companion);
  }

  Future<void> upsertCustomIbadahLogFromRemote(
    Map<String, dynamic> data,
  ) async {
    final dateStr = data['date'] as String;
    final date = DateTime.parse(dateStr);

    final dr = await (select(
      dailyRecords,
    )..where((r) => r.date.equals(date))).getSingleOrNull();
    int drId;
    if (dr == null) {
      drId = await into(dailyRecords).insert(
        DailyRecordsCompanion(date: Value(date)),
        mode: InsertMode.insertOrIgnore,
      );
      if (drId == 0 || drId == -1) {
        final existingDr = await (select(
          dailyRecords,
        )..where((r) => r.date.equals(date))).getSingle();
        drId = existingDr.id;
      }
    } else {
      drId = dr.id;
    }

    final ibadahId = data['ibadah_id'] as int;
    final companion = CustomIbadahLogCompanion(
      ibadahId: Value(ibadahId),
      recordId: Value(drId),
      date: Value(date),
      done: Value(data['done'] as bool? ?? false),
      count: Value(data['count'] as int? ?? 1),
    );

    final existing =
        await (select(customIbadahLog)..where(
              (l) => l.recordId.equals(drId) & l.ibadahId.equals(ibadahId),
            ))
            .getSingleOrNull();

    if (existing != null) {
      await (update(
        customIbadahLog,
      )..where((l) => l.id.equals(existing.id))).write(companion);
    } else {
      await into(customIbadahLog).insert(companion);
    }
    await DailyRecordDao(db).recalcPoints(drId);
  }

  // --- Logging (Local -> Remote later) ---
  Stream<List<CustomIbadahLogData>> watchLogsForDate(DateTime date) {
    return (select(customIbadahLog)..where((t) => t.date.equals(date))).watch();
  }

  Future<List<CustomIbadahLogData>> getLogsForDate(DateTime date) {
    return (select(customIbadahLog)..where((t) => t.date.equals(date))).get();
  }

  Future<void> logIbadah(
    int ibadahId,
    DateTime date,
    bool done,
    int count,
  ) async {
    final dr = await (select(dailyRecords)..where((r) => r.date.equals(date)))
        .getSingleOrNull();
    int drId;
    if (dr == null) {
      drId = await into(dailyRecords).insert(
        DailyRecordsCompanion(date: Value(date)),
        mode: InsertMode.insertOrIgnore,
      );
      if (drId == 0 || drId == -1) {
        final existingDr = await (select(dailyRecords)
              ..where((r) => r.date.equals(date)))
            .getSingle();
        drId = existingDr.id;
      }
    } else {
      drId = dr.id;
    }

    final existing = await (select(customIbadahLog)
          ..where((l) => l.recordId.equals(drId) & l.ibadahId.equals(ibadahId)))
        .getSingleOrNull();

    if (existing != null) {
      await (update(customIbadahLog)..where((l) => l.id.equals(existing.id)))
          .write(
        CustomIbadahLogCompanion(done: Value(done), count: Value(count)),
      );
    } else {
      await into(customIbadahLog).insert(
        CustomIbadahLogCompanion(
          ibadahId: Value(ibadahId),
          recordId: Value(drId),
          date: Value(date),
          done: Value(done),
          count: Value(count),
        ),
      );
    }
    await DailyRecordDao(db).recalcPoints(drId);
  }
}
