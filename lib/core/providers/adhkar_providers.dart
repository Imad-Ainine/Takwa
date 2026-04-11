// ═══════════════════════════════════════════════════════════════
//  lib/features/adhkar/data/adhkar_data.dart
//  lib/features/adhkar/providers/adhkar_providers.dart
//  محاسبة النفس — Adhkar Data + Providers + Notification Service
// ═══════════════════════════════════════════════════════════════

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:math' as math;

import '../../../core/theme/app_theme.dart';

// ═══════════════════════════════════════════════════════════════
//  MODELS
// ═══════════════════════════════════════════════════════════════
enum AdhkarCategory { morning, evening, afterPrayer, sleep, misc }

class DhikrItem {
  final int id;
  final String arabic;
  final String? transliteration;
  final String? fadl; // الفضل والفائدة
  final String? source; // المصدر
  final int count; // عدد التكرار
  final AdhkarCategory category;

  const DhikrItem({
    required this.id,
    required this.arabic,
    required this.count,
    required this.category,
    this.transliteration,
    this.fadl,
    this.source,
  });
}

// ═══════════════════════════════════════════════════════════════
//  ADHKAR DATA  (بيانات حقيقية من حصن المسلم)
// ═══════════════════════════════════════════════════════════════
const kAdhkarData = <AdhkarCategory, List<DhikrItem>>{
  // ────────────── الصباح ──────────────
  AdhkarCategory.morning: [
    DhikrItem(
      id: 101,
      arabic:
          'أَعُوذُ بِاللَّهِ مِنَ الشَّيطانِ الرَّجِيمِ\nاللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ',
      count: 1,
      category: AdhkarCategory.morning,
      transliteration: 'آية الكرسي',
      fadl: 'من قرأها حين يصبح أُجير من الجن حتى يمسي',
      source: 'صحيح الترغيب',
    ),
    DhikrItem(
      id: 102,
      arabic:
          'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
      count: 1,
      category: AdhkarCategory.morning,
      fadl: 'كانَ مِن حِرزٍ له مِن الشيطان يومه ذلك',
      source: 'صحيح مسلم',
    ),
    DhikrItem(
      id: 103,
      arabic:
          'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ النُّشُورُ',
      count: 1,
      category: AdhkarCategory.morning,
      source: 'سنن أبي داود',
    ),
    DhikrItem(
      id: 104,
      arabic:
          'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَٰهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ',
      count: 1,
      category: AdhkarCategory.morning,
      transliteration: 'سيد الاستغفار',
      fadl: 'من قالها موقناً بها فمات من يومه دخل الجنة',
      source: 'صحيح البخاري',
    ),
    DhikrItem(
      id: 105,
      arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
      count: 100,
      category: AdhkarCategory.morning,
      fadl: 'من قالها مئة مرة حُطَّت خطاياه وإن كانت مثل زبد البحر',
      source: 'متفق عليه',
    ),
    DhikrItem(
      id: 106,
      arabic:
          'لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
      count: 10,
      category: AdhkarCategory.morning,
      fadl: 'كانت له عِدل عشر رقاب، وكُتبت له مئة حسنة',
      source: 'صحيح البخاري',
    ),
    DhikrItem(
      id: 107,
      arabic:
          'اللَّهُمَّ عَافِنِي فِي بَدَنِي، اللَّهُمَّ عَافِنِي فِي سَمْعِي، اللَّهُمَّ عَافِنِي فِي بَصَرِي، لَا إِلَٰهَ إِلَّا أَنْتَ',
      count: 3,
      category: AdhkarCategory.morning,
      source: 'سنن أبي داود',
    ),
  ],

  // ────────────── المساء ──────────────
  AdhkarCategory.evening: [
    DhikrItem(
      id: 201,
      arabic:
          'أَعُوذُ بِاللَّهِ مِنَ الشَّيطانِ الرَّجِيمِ\nاللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
      count: 1,
      category: AdhkarCategory.evening,
      transliteration: 'آية الكرسي',
      fadl: 'من قرأها حين يمسي أُجير من الجن حتى يصبح',
      source: 'صحيح الترغيب',
    ),
    DhikrItem(
      id: 202,
      arabic:
          'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
      count: 1,
      category: AdhkarCategory.evening,
      source: 'صحيح مسلم',
    ),
    DhikrItem(
      id: 203,
      arabic:
          'اللَّهُمَّ إِنِّي أَمْسَيْتُ أُشْهِدُكَ، وَأُشْهِدُ حَمَلَةَ عَرْشِكَ، وَمَلَائِكَتَكَ، وَجَمِيعَ خَلْقِكَ، أَنَّكَ أَنْتَ اللَّهُ لَا إِلَٰهَ إِلَّا أَنْتَ وَحْدَكَ لَا شَرِيكَ لَكَ، وَأَنَّ مُحَمَّدًا عَبْدُكَ وَرَسُولُكَ',
      count: 4,
      category: AdhkarCategory.evening,
      fadl: 'أعتقه الله ربع النار',
      source: 'سنن أبي داود',
    ),
    DhikrItem(
      id: 204,
      arabic:
          'اللَّهُمَّ مَا أَمْسَى بِي مِنْ نِعْمَةٍ، أَوْ بِأَحَدٍ مِنْ خَلْقِكَ، فَمِنْكَ وَحْدَكَ لَا شَرِيكَ لَكَ، فَلَكَ الْحَمْدُ وَلَكَ الشُّكْرُ',
      count: 1,
      category: AdhkarCategory.evening,
      fadl: 'أدّى شكر يومه',
      source: 'صحيح ابن حبان',
    ),
    DhikrItem(
      id: 205,
      arabic:
          'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ، وَأَعُوذُ بِكَ مِنَ الْعَجْزِ وَالْكَسَلِ، وَأَعُوذُ بِكَ مِنَ الْجُبْنِ وَالْبُخْلِ، وَأَعُوذُ بِكَ مِنْ غَلَبَةِ الدَّيْنِ وَقَهْرِ الرِّجَالِ',
      count: 1,
      category: AdhkarCategory.evening,
      source: 'صحيح البخاري',
    ),
    DhikrItem(
      id: 206,
      arabic:
          'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
      count: 3,
      category: AdhkarCategory.evening,
      fadl: 'لم يضره شيء',
      source: 'سنن أبي داود',
    ),
  ],

  // ────────────── بعد الصلاة ──────────────
  AdhkarCategory.afterPrayer: [
    DhikrItem(
      id: 301,
      arabic: 'أَسْتَغْفِرُ اللَّهَ',
      count: 3,
      category: AdhkarCategory.afterPrayer,
      source: 'صحيح مسلم',
    ),
    DhikrItem(
      id: 302,
      arabic:
          'اللَّهُمَّ أَنْتَ السَّلَامُ، وَمِنْكَ السَّلَامُ، تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ',
      count: 1,
      category: AdhkarCategory.afterPrayer,
      source: 'صحيح مسلم',
    ),
    DhikrItem(
      id: 303,
      arabic: 'سُبْحَانَ اللَّهِ',
      count: 33,
      category: AdhkarCategory.afterPrayer,
      source: 'متفق عليه',
    ),
    DhikrItem(
      id: 304,
      arabic: 'الْحَمْدُ لِلَّهِ',
      count: 33,
      category: AdhkarCategory.afterPrayer,
      source: 'متفق عليه',
    ),
    DhikrItem(
      id: 305,
      arabic: 'اللَّهُ أَكْبَرُ',
      count: 33,
      category: AdhkarCategory.afterPrayer,
      fadl: 'من سبّح وحمد وكبّر دبر كل صلاة غُفرت ذنوبه',
      source: 'متفق عليه',
    ),
    DhikrItem(
      id: 306,
      arabic:
          'لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
      count: 1,
      category: AdhkarCategory.afterPrayer,
      fadl: 'من قالها بعد كل صلاة غُفرت ذنوبه وإن كانت مثل زبد البحر',
      source: 'صحيح مسلم',
    ),
    DhikrItem(
      id: 307,
      arabic:
          'آية الكرسي\nاللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
      count: 1,
      category: AdhkarCategory.afterPrayer,
      fadl: 'من قرأها دبر كل صلاة مكتوبة لم يمنعه من دخول الجنة إلا الموت',
      source: 'النسائي — صحيح',
    ),
  ],

  // ────────────── النوم ──────────────
  AdhkarCategory.sleep: [
    DhikrItem(
      id: 401,
      arabic: 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
      count: 1,
      category: AdhkarCategory.sleep,
      source: 'صحيح البخاري',
    ),
    DhikrItem(
      id: 402,
      arabic: 'اللَّهُمَّ قِنِي عَذَابَكَ يَوْمَ تَبْعَثُ عِبَادَكَ',
      count: 3,
      category: AdhkarCategory.sleep,
      source: 'سنن أبي داود',
    ),
    DhikrItem(
      id: 403,
      arabic: 'سُبْحَانَ اللَّهِ',
      count: 33,
      category: AdhkarCategory.sleep,
      fadl: 'خير لك من خادم',
      source: 'متفق عليه',
    ),
    DhikrItem(
      id: 404,
      arabic: 'الْحَمْدُ لِلَّهِ',
      count: 33,
      category: AdhkarCategory.sleep,
      source: 'متفق عليه',
    ),
    DhikrItem(
      id: 405,
      arabic: 'اللَّهُ أَكْبَرُ',
      count: 34,
      category: AdhkarCategory.sleep,
      source: 'متفق عليه',
    ),
    DhikrItem(
      id: 406,
      arabic:
          'قُلْ هُوَ اللَّهُ أَحَدٌ\nقُلْ أَعُوذُ بِرَبِّ الْفَلَقِ\nقُلْ أَعُوذُ بِرَبِّ النَّاسِ',
      count: 3,
      category: AdhkarCategory.sleep,
      fadl: 'كفتاه من كل شيء',
      source: 'سنن أبي داود',
    ),
  ],

  // ────────────── متنوعة ──────────────
  AdhkarCategory.misc: [
    DhikrItem(
      id: 501,
      arabic: 'لَا إِلَٰهَ إِلَّا اللَّهُ',
      count: 100,
      category: AdhkarCategory.misc,
      fadl: 'من قالها مئة مرة كانت له عِدل عشر رقاب',
      source: 'متفق عليه',
    ),
    DhikrItem(
      id: 502,
      arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، سُبْحَانَ اللَّهِ الْعَظِيمِ',
      count: 1,
      category: AdhkarCategory.misc,
      fadl: 'كلمتان خفيفتان على اللسان، ثقيلتان في الميزان',
      source: 'متفق عليه',
    ),
    DhikrItem(
      id: 503,
      arabic: 'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ',
      count: 10,
      category: AdhkarCategory.misc,
      fadl: 'من صلى علي مرة واحدة صلى الله عليه بها عشراً',
      source: 'صحيح مسلم',
    ),
    DhikrItem(
      id: 504,
      arabic:
          'حَسْبِيَ اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ',
      count: 7,
      category: AdhkarCategory.misc,
      fadl: 'كفاه الله ما أهمه',
      source: 'سنن أبي داود',
    ),
    DhikrItem(
      id: 505,
      arabic: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
      count: 100,
      category: AdhkarCategory.misc,
      fadl: 'كنز من كنوز الجنة',
      source: 'متفق عليه',
    ),
  ],
};

// ═══════════════════════════════════════════════════════════════
//  PROVIDERS
// ═══════════════════════════════════════════════════════════════

// ── حالة تقدم كل تصنيف (index → count) ──
class AdhkarProgressNotifier extends StateNotifier<Map<int, int>> {
  final AdhkarCategory category;

  AdhkarProgressNotifier(this.category) : super({}) {
    _load();
  }

  static const _prefix = 'adhkar_progress_';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefix${category.name}';
    final raw = prefs.getString(key);
    if (raw != null) {
      final map = Map<String, dynamic>.from(jsonDecode(raw));
      state = map.map((k, v) => MapEntry(int.parse(k), v as int));
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefix${category.name}';
    final encoded = jsonEncode(state.map((k, v) => MapEntry(k.toString(), v)));
    await prefs.setString(key, encoded);
  }

  void increment(int index, int maxCount) {
    final current = state[index] ?? 0;
    if (current >= maxCount) return;
    state = {...state, index: current + 1};
    _save();
  }

  void reset() {
    state = {};
    _save();
  }
}

final adhkarProgressProvider =
    StateNotifierProvider.family<
      AdhkarProgressNotifier,
      Map<int, int>,
      AdhkarCategory
    >((ref, cat) => AdhkarProgressNotifier(cat));

// ── إعداد الإشعارات ──
final adhkarNotifEnabledProvider = StateNotifierProvider<_BoolNotifier, bool>(
  (ref) => _BoolNotifier('adhkar_notif_enabled', true),
);

final adhkarMorningTimeProvider =
    StateNotifierProvider<_TimeNotifier, TimeOfDay>(
      (ref) => _TimeNotifier(
        'adhkar_morning_time',
        const TimeOfDay(hour: 6, minute: 30),
      ),
    );

final adhkarEveningTimeProvider =
    StateNotifierProvider<_TimeNotifier, TimeOfDay>(
      (ref) => _TimeNotifier(
        'adhkar_evening_time',
        const TimeOfDay(hour: 17, minute: 0),
      ),
    );

final adhkarAfterFajrProvider = StateNotifierProvider<_BoolNotifier, bool>(
  (ref) => _BoolNotifier('adhkar_after_fajr', true),
);

final adhkarAfterAsrProvider = StateNotifierProvider<_BoolNotifier, bool>(
  (ref) => _BoolNotifier('adhkar_after_asr', true),
);

final adhkarSleepTimeProvider = StateNotifierProvider<_TimeNotifier, TimeOfDay>(
  (ref) =>
      _TimeNotifier('adhkar_sleep_time', const TimeOfDay(hour: 22, minute: 0)),
);

// ── Notifiers helpers ──
class _BoolNotifier extends StateNotifier<bool> {
  final String _key;
  _BoolNotifier(this._key, bool defaultVal) : super(defaultVal) {
    _load(defaultVal);
  }

  Future<void> _load(bool def) async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? def;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, state);
  }

  Future<void> set(bool v) async {
    state = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, v);
  }
}

class _TimeNotifier extends StateNotifier<TimeOfDay> {
  final String _key;
  _TimeNotifier(this._key, TimeOfDay defaultVal) : super(defaultVal) {
    _load(defaultVal);
  }

  Future<void> _load(TimeOfDay def) async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_key);
    if (v != null) {
      final parts = v.split(':');
      state = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
  }

  Future<void> set(TimeOfDay t) async {
    state = t;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      '${t.hour.toString().padLeft(2, "0")}:${t.minute.toString().padLeft(2, "0")}',
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  ADHKAR NOTIFICATION SERVICE
//  إشعارات الأذكار مع زر "قرأت الذكر"
// ═══════════════════════════════════════════════════════════════
class AdhkarNotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  // IDs مخصصة للأذكار (200-range)
  static const _morningId = 310;
  static const _eveningId = 311;
  static const _afterFajrId = 312;
  static const _afterAsrId = 313;
  static const _sleepId = 314;
  static const _dhikrId = 315; // ذكر عشوائي

  // ─── إشعار أذكار الصباح ───
  static Future<void> scheduleMorning(TimeOfDay time) async {
    await _cancelId(_morningId);

    final now = DateTime.now();
    var scheduled = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    final dhikr = _randomDhikr(AdhkarCategory.morning);

    await _plugin.zonedSchedule(
      _morningId,
      '🌅 حان وقت أذكار الصباح',
      dhikr.arabic
          .replaceAll('\n', ' ')
          .substring(0, dhikr.arabic.length > 80 ? 80 : dhikr.arabic.length),
      tz.TZDateTime.from(scheduled, tz.local),
      _buildDetails(
        channelId: 'adhkar_morning',
        channelName: 'أذكار الصباح',
        actions: [
          const AndroidNotificationAction(
            'read_morning',
            'قرأت الأذكار ✓',
            showsUserInterface: false,
            cancelNotification: true,
          ),
          const AndroidNotificationAction(
            'open_morning',
            'فتح الأذكار',
            showsUserInterface: true,
            cancelNotification: false,
          ),
        ],
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'adhkar:morning',
    );
  }

  // ─── إشعار أذكار المساء ───
  static Future<void> scheduleEvening(TimeOfDay time) async {
    await _cancelId(_eveningId);

    final now = DateTime.now();
    var scheduled = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    final dhikr = _randomDhikr(AdhkarCategory.evening);

    await _plugin.zonedSchedule(
      _eveningId,
      '🌆 حان وقت أذكار المساء',
      dhikr.arabic
          .replaceAll('\n', ' ')
          .substring(0, dhikr.arabic.length > 80 ? 80 : dhikr.arabic.length),
      tz.TZDateTime.from(scheduled, tz.local),
      _buildDetails(
        channelId: 'adhkar_evening',
        channelName: 'أذكار المساء',
        actions: [
          const AndroidNotificationAction(
            'read_evening',
            'قرأت الأذكار ✓',
            showsUserInterface: false,
            cancelNotification: true,
          ),
          const AndroidNotificationAction(
            'open_evening',
            'فتح الأذكار',
            showsUserInterface: true,
            cancelNotification: false,
          ),
        ],
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'adhkar:evening',
    );
  }

  // ─── إشعار ذكر يومي عشوائي ───
  static Future<void> scheduleDailyDhikr({
    required TimeOfDay time,
    AdhkarCategory category = AdhkarCategory.misc,
  }) async {
    await _cancelId(_dhikrId);

    final now = DateTime.now();
    var scheduled = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    final dhikr = _randomDhikr(category);
    final arabic = dhikr.arabic.replaceAll('\n', ' ');
    final preview = arabic.length > 100
        ? '${arabic.substring(0, 100)}...'
        : arabic;

    await _plugin.zonedSchedule(
      _dhikrId,
      '📿 ذكر اليوم',
      preview,
      tz.TZDateTime.from(scheduled, tz.local),
      _buildDetails(
        channelId: 'adhkar_daily',
        channelName: 'ذكر اليوم',
        bigText: arabic + (dhikr.fadl != null ? '\n\n✨ ${dhikr.fadl}' : ''),
        actions: [
          AndroidNotificationAction(
            'read_dhikr_${dhikr.id}',
            'قرأت الذكر ✓',
            showsUserInterface: false,
            cancelNotification: true, // ← يُغلق الإشعار فوراً
          ),
          const AndroidNotificationAction(
            'share_dhikr',
            'مشاركة',
            showsUserInterface: false,
            cancelNotification: false,
          ),
        ],
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'dhikr:${dhikr.id}',
    );
  }

  // ─── إشعار فوري لذكر مخصص ───
  static Future<void> showDhikrNow(DhikrItem dhikr) async {
    final arabic = dhikr.arabic.replaceAll('\n', ' ');

    await _plugin.show(
      _dhikrId + dhikr.id,
      '📿 ${_categoryName(dhikr.category)}',
      arabic.length > 80 ? '${arabic.substring(0, 80)}...' : arabic,
      _buildDetails(
        channelId: 'adhkar_instant',
        channelName: 'أذكار فورية',
        bigText:
            arabic +
            (dhikr.fadl != null ? '\n\n✨ الفضل: ${dhikr.fadl}' : '') +
            (dhikr.source != null ? '\n— ${dhikr.source}' : ''),
        actions: [
          AndroidNotificationAction(
            'read_done_${dhikr.id}',
            'قرأت الذكر ✓',
            showsUserInterface: false,
            cancelNotification: true, // ← يُخفي الإشعار
          ),
          AndroidNotificationAction(
            'repeat_${dhikr.id}',
            'أعد لاحقاً 🔁',
            showsUserInterface: false,
            cancelNotification: false,
          ),
        ],
      ),
      payload: 'instant_dhikr:${dhikr.id}',
    );
  }

  // ─── إلغاء الجدولة ───
  static Future<void> cancelAll() async {
    for (final id in [
      _morningId,
      _eveningId,
      _afterFajrId,
      _afterAsrId,
      _sleepId,
      _dhikrId,
    ]) {
      await _plugin.cancel(id);
    }
  }

  static Future<void> _cancelId(int id) => _plugin.cancel(id);

  // ─── بناء تفاصيل الإشعار ───
  static NotificationDetails _buildDetails({
    required String channelId,
    required String channelName,
    String? bigText,
    List<AndroidNotificationAction>? actions,
  }) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: 'أذكار وأدعية من حصن المسلم',
        importance: Importance.high,
        priority: Priority.high,
        color: const Color(0xFFC8A96E),
        styleInformation: bigText != null
            ? BigTextStyleInformation(
                bigText,
                contentTitle: channelName,
                htmlFormatBigText: false,
              )
            : null,
        actions: actions,
        groupKey: 'adhkar_group',
        // لا صوت مزعج للأذكار
        playSound: false,
        enableVibration: false,
      ),
      iOS: const DarwinNotificationDetails(
        categoryIdentifier: 'adhkar_category',
        presentAlert: true,
        presentBadge: false,
        presentSound: false,
        interruptionLevel: InterruptionLevel.passive,
      ),
    );
  }

  // ─── ذكر عشوائي ───
  static DhikrItem _randomDhikr(AdhkarCategory cat) {
    final list = kAdhkarData[cat] ?? kAdhkarData[AdhkarCategory.misc]!;
    final rng = math.Random(DateTime.now().dayOfYear);
    return list[rng.nextInt(list.length)];
  }

  static String _categoryName(AdhkarCategory cat) => switch (cat) {
    AdhkarCategory.morning => 'أذكار الصباح',
    AdhkarCategory.evening => 'أذكار المساء',
    AdhkarCategory.afterPrayer => 'أذكار بعد الصلاة',
    AdhkarCategory.sleep => 'أذكار النوم',
    AdhkarCategory.misc => 'أذكار متنوعة',
  };
}

// Helper extension
extension on DateTime {
  int get dayOfYear {
    final start = DateTime(year, 1, 1);
    return difference(start).inDays + 1;
  }
}

// ═══════════════════════════════════════════════════════════════
//  ADHKAR NOTIF SETTINGS SHEET
//  (تُستدعى من زر 🔔 في الشاشة)
// ═══════════════════════════════════════════════════════════════
class _AdhkarNotifSheet extends ConsumerWidget {
  const _AdhkarNotifSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(adhkarNotifEnabledProvider);
    final morningTime = ref.watch(adhkarMorningTimeProvider);
    final eveningTime = ref.watch(adhkarEveningTimeProvider);
    final afterFajr = ref.watch(adhkarAfterFajrProvider);
    final afterAsr = ref.watch(adhkarAfterAsrProvider);
    final sleepTime = ref.watch(adhkarSleepTimeProvider);

    return Container(
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: context.colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Text(
                  'إشعارات الأذكار',
                  style: GoogleFonts.amiri(
                    fontSize: 18,
                    color: context.colors.gold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: enabled,
                  onChanged: (v) {
                    ref.read(adhkarNotifEnabledProvider.notifier).set(v);
                    if (!v) AdhkarNotificationService.cancelAll();
                  },
                  activeColor: context.colors.gold,
                  activeTrackColor: context.colors.gold.withOpacity(0.3),
                  inactiveTrackColor: context.colors.border,
                  inactiveThumbColor: context.colors.textDim,
                ),
              ],
            ),
          ),

          Divider(color: context.colors.border, height: 20),

          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: enabled
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Row(
                children: [
                  const Text('🔕', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Text(
                    'الإشعارات متوقفة',
                    style: GoogleFonts.notoNaskhArabic(
                      fontSize: 13,
                      color: context.colors.textDim,
                    ),
                  ),
                ],
              ),
            ),
            secondChild: ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              children: [
                // أذكار الصباح
                _NotifRow(
                  icon: '🌅',
                  label: 'أذكار الصباح',
                  time: morningTime,
                  onTimeTap: () async {
                    final t = await _pickTime(context, morningTime);
                    if (t != null) {
                      ref.read(adhkarMorningTimeProvider.notifier).set(t);
                      await AdhkarNotificationService.scheduleMorning(t);
                    }
                  },
                ),
                _NotifRow(
                  icon: '🌆',
                  label: 'أذكار المساء',
                  time: eveningTime,
                  onTimeTap: () async {
                    final t = await _pickTime(context, eveningTime);
                    if (t != null) {
                      ref.read(adhkarEveningTimeProvider.notifier).set(t);
                      await AdhkarNotificationService.scheduleEvening(t);
                    }
                  },
                ),
                _NotifRow(
                  icon: '🌙',
                  label: 'أذكار النوم',
                  time: sleepTime,
                  onTimeTap: () async {
                    final t = await _pickTime(context, sleepTime);
                    if (t != null) {
                      ref.read(adhkarSleepTimeProvider.notifier).set(t);
                    }
                  },
                ),
                const SizedBox(height: 12),
                Container(height: 1, color: context.colors.border),
                const SizedBox(height: 12),
                _ToggleRow(
                  icon: '🌅',
                  label: 'بعد صلاة الفجر',
                  value: afterFajr,
                  onChanged: (v) =>
                      ref.read(adhkarAfterFajrProvider.notifier).set(v),
                ),
                _ToggleRow(
                  icon: '🌇',
                  label: 'بعد صلاة العصر',
                  value: afterAsr,
                  onChanged: (v) =>
                      ref.read(adhkarAfterAsrProvider.notifier).set(v),
                ),

                const SizedBox(height: 14),
                // زر اختبار
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final dhikr = (kAdhkarData[AdhkarCategory.morning]!)[0];
                      await AdhkarNotificationService.showDhikrNow(dhikr);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'تم إرسال إشعار تجريبي ✓',
                            style: GoogleFonts.notoNaskhArabic(fontSize: 13),
                          ),
                          backgroundColor: context.colors.success,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                    icon: const Text('🔔', style: TextStyle(fontSize: 16)),
                    label: Text(
                      'اختبار إشعار ذكر الآن',
                      style: GoogleFonts.notoNaskhArabic(
                        fontSize: 13,
                        color: context.colors.gold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: context.colors.gold.withOpacity(0.3)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<TimeOfDay?> _pickTime(BuildContext context, TimeOfDay current) async {
    return showTimePicker(
      context: context,
      initialTime: current,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.dark(primary: context.colors.gold),
        ),
        child: child!,
      ),
    );
  }
}

class _NotifRow extends StatelessWidget {
  final String icon, label;
  final TimeOfDay time;
  final VoidCallback onTimeTap;

  const _NotifRow({
    required this.icon,
    required this.label,
    required this.time,
    required this.onTimeTap,
  });

  @override
  Widget build(BuildContext context) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.notoNaskhArabic(
                fontSize: 13,
                color: context.colors.textPrimary,
              ),
            ),
          ),
          GestureDetector(
            onTap: onTimeTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: context.colors.goldDim,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: context.colors.gold.withOpacity(0.25)),
              ),
              child: Text(
                '$h:$m',
                style: GoogleFonts.notoNaskhArabic(
                  fontSize: 15,
                  color: context.colors.gold,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String icon, label;
  final bool value;
  final void Function(bool) onChanged;

  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.notoNaskhArabic(
              fontSize: 13,
              color: context.colors.textPrimary,
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: context.colors.teal,
          activeTrackColor: context.colors.teal.withOpacity(0.3),
          inactiveTrackColor: context.colors.border,
          inactiveThumbColor: context.colors.textDim,
        ),
      ],
    ),
  );
}
