// ═══════════════════════════════════════════════════════════════
//  lib/core/database/app_database.dart
//  محاسبة النفس — Complete Local Database (Drift / SQLite)
// ═══════════════════════════════════════════════════════════════

import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// ─────────────────────────────────────────
//  ENUMS
// ─────────────────────────────────────────

/// حالة الصلاة
enum PrayerStatus {
  notDue, // لم يحن وقتها
  pending, // حان وقتها لم تُؤدَّ
  performed, // أُديت في وقتها
  qadaa, // قُضيت خارج الوقت
  missed, // فاتت
}

/// نوع الصيام
enum FastingType {
  none, // لم يصم
  fard, // فريضة (رمضان)
  nafl, // نافلة
  makruh, // أفطر بعذر
}

/// فئة المحظور
enum ProhibitionCategory {
  ghadhBasar, // غضّ البصر
  gheeba, // الغيبة
  nameema, // النميمة
  kadhb, // الكذب
  ghaDab, // الغضب
  idaatWaqt, // إضاعة الوقت
  custom, // مخصص
}

/// مستوى التقوى
enum TaqwaLevel {
  mubtadi, // مبتدئ  0–99
  salik, // سالك   100–299
  mujahid, // مجاهد  300–599
  mutaqi, // متقي   600+
}

// ─────────────────────────────────────────
//  TABLE: daily_records
// ─────────────────────────────────────────
class DailyRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime().unique()();

  // ── الصلوات ──
  IntColumn get fajrStatus =>
      intEnum<PrayerStatus>().withDefault(const Constant(0))();
  IntColumn get dhuhrStatus =>
      intEnum<PrayerStatus>().withDefault(const Constant(0))();
  IntColumn get asrStatus =>
      intEnum<PrayerStatus>().withDefault(const Constant(0))();
  IntColumn get maghribStatus =>
      intEnum<PrayerStatus>().withDefault(const Constant(0))();
  IntColumn get ishaStatus =>
      intEnum<PrayerStatus>().withDefault(const Constant(0))();
  BoolColumn get nightPrayer => boolean().withDefault(const Constant(false))();
  BoolColumn get witr => boolean().withDefault(const Constant(false))();
  IntColumn get rawatib => integer().withDefault(const Constant(0))();

  // ── القرآن ──
  IntColumn get quranPages => integer().withDefault(const Constant(0))();
  IntColumn get quranVerses => integer().withDefault(const Constant(0))();
  RealColumn get quranJuzaa => real().withDefault(const Constant(0.0))();

  // ── الأذكار ──
  BoolColumn get morningAdhkar =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get eveningAdhkar =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get afterPrayerAdhkar =>
      boolean().withDefault(const Constant(false))();
  IntColumn get tasbeehCount => integer().withDefault(const Constant(0))();

  // ── الصيام ──
  IntColumn get fastingType =>
      intEnum<FastingType>().withDefault(const Constant(0))();

  // ── الصدقة ──
  BoolColumn get sadaqah => boolean().withDefault(const Constant(false))();
  RealColumn get sadaqahAmount => real().withDefault(const Constant(0.0))();

  // ── النقاط المحسوبة ──
  IntColumn get taqwaPoints => integer().withDefault(const Constant(0))();
  IntColumn get deductedPoints => integer().withDefault(const Constant(0))();
  IntColumn get netPoints => integer().withDefault(const Constant(0))();

  // ── الملاحظات ──
  TextColumn get notes => text().withLength(max: 500).nullable()();
  TextColumn get mood => text().withLength(max: 50).nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// ─────────────────────────────────────────
//  TABLE: prohibitions_log
// ─────────────────────────────────────────
class ProhibitionsLog extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get recordId => integer().references(DailyRecords, #id)();
  DateTimeColumn get date => dateTime()();
  IntColumn get category => intEnum<ProhibitionCategory>()();
  TextColumn get customName => text().withLength(max: 100).nullable()();
  BoolColumn get committed => boolean().withDefault(const Constant(false))();
  IntColumn get timesCount => integer().withDefault(const Constant(0))();
  IntColumn get deductPoints => integer().withDefault(const Constant(10))();
  TextColumn get notes => text().withLength(max: 200).nullable()();
}

// ─────────────────────────────────────────
//  TABLE: prayer_times_cache
// ─────────────────────────────────────────
class PrayerTimesCache extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime().unique()();
  TextColumn get fajr => text()();
  TextColumn get sunrise => text()();
  TextColumn get dhuhr => text()();
  TextColumn get asr => text()();
  TextColumn get maghrib => text()();
  TextColumn get isha => text()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  TextColumn get method => text().withDefault(const Constant('MWL'))();
}

// ─────────────────────────────────────────
//  TABLE: achievements
// ─────────────────────────────────────────
class Achievements extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => text()();
  TextColumn get titleAr => text()();
  TextColumn get descAr => text()();
  TextColumn get emoji => text()();
  IntColumn get pointsReward => integer().withDefault(const Constant(0))();
  DateTimeColumn get earnedAt => dateTime()();
  BoolColumn get seen => boolean().withDefault(const Constant(false))();
}

// ─────────────────────────────────────────
//  TABLE: custom_ibadah
// ─────────────────────────────────────────
class CustomIbadah extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nameAr => text()();
  TextColumn get emoji => text().withDefault(const Constant('⭐'))();
  BoolColumn get isPositive => boolean().withDefault(const Constant(true))();
  IntColumn get points => integer().withDefault(const Constant(5))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

// ─────────────────────────────────────────
//  TABLE: custom_ibadah_log
// ─────────────────────────────────────────
class CustomIbadahLog extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get ibadahId => integer().references(CustomIbadah, #id)();
  IntColumn get recordId => integer().references(DailyRecords, #id)();
  DateTimeColumn get date => dateTime()();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
  IntColumn get count => integer().withDefault(const Constant(1))();
}

// ─────────────────────────────────────────
//  TABLE: user_settings
// ─────────────────────────────────────────
class UserSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

// ─────────────────────────────────────────
//  TABLE: ramadan_progress
// ─────────────────────────────────────────
class RamadanProgress extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get year => integer()();
  IntColumn get dayNumber => integer()();
  IntColumn get recordId =>
      integer().references(DailyRecords, #id).nullable()();
  TextColumn get duaOfDay => text().nullable()();
  BoolColumn get iHyaLayl => boolean().withDefault(const Constant(false))();
  IntColumn get totalPoints => integer().withDefault(const Constant(0))();

  @override
  List<Set<Column>> get uniqueKeys => [
        {year, dayNumber},
      ];
}

// ─────────────────────────────────────────
//  DATABASE CLASS
// ─────────────────────────────────────────
@DriftDatabase(tables: [
  DailyRecords,
  ProhibitionsLog,
  PrayerTimesCache,
  Achievements,
  CustomIbadah,
  CustomIbadahLog,
  UserSettings,
  RamadanProgress,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await _seedDefaultData();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // Future migrations here
        },
      );

  Future<void> _seedDefaultData() async {
    await _insertSetting('madhab', 'shafi');
    await _insertSetting('calcMethod', 'MWL');
    await _insertSetting('ramadanMode', 'false');
    await _insertSetting('prayerReminder', 'true');
    await _insertSetting('eveningMuhasabaReminder', 'true');
    await _insertSetting('eveningReminderTime', '21:00');
    await _insertSetting('language', 'ar');

    final defaultIbadaat = [
      ('قراءة حديث', '📚', true, 3),
      ('دعاء مخصص', '🤲', true, 5),
      ('صلة الرحم', '👨‍👩‍👧', true, 10),
      ('غضّ البصر', '👁️', false, -10),
      ('الغيبة', '🗣️', false, -10),
    ];
    for (final item in defaultIbadaat) {
      await into(customIbadah).insert(CustomIbadahCompanion(
        nameAr: Value(item.$1),
        emoji: Value(item.$2),
        isPositive: Value(item.$3),
        points: Value(item.$4),
      ));
    }
  }

  Future<void> _insertSetting(String key, String value) async {
    await into(userSettings).insertOnConflictUpdate(
      UserSettingsCompanion(key: Value(key), value: Value(value)),
    );
  }
}

// ─────────────────────────────────────────
//  DATABASE CONNECTION
// ─────────────────────────────────────────
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'muhasaba.db'));
    return NativeDatabase.createInBackground(file);
  });
}
