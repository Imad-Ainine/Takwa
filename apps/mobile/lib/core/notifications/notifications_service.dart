// ═══════════════════════════════════════════════════════════════
//  lib/core/notifications/notifications_service.dart
//  تقوى — Complete Notifications Service (IMPROVED)
//  • إشعارات الصلاة مع صوت الأذان
//  • تنبيهات قبل الأذان بـ 15 دقيقة
//  • إشعارات الإقامة بعد الأذان
//  • أذكار الصباح والمساء يومياً
//  • دعاء الصباح ودعاء المساء
//  • إشعارات الجمعة والأيام البيض
//  • إشعارات الإنجازات
// ═══════════════════════════════════════════════════════════════

import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:adhan/adhan.dart' as adhan;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:permission_handler/permission_handler.dart';
import 'package:hijri/hijri_calendar.dart';

import 'package:takwa/features/duas/data/duas_data.dart';
import 'package:takwa/core/providers/database_providers.dart';
import 'package:takwa/core/routes/app_routes.dart';
import 'package:takwa/core/providers/adhkar_providers.dart';
import 'package:takwa/features/settings/providers/user_preferences_provider.dart';

// ─────────────────────────────────────────
//  NOTIFICATION IDs
// ─────────────────────────────────────────
class NotifIds {
  // الصلوات الخمس
  static const fajr = 100;
  static const dhuhr = 101;
  static const asr = 102;
  static const maghrib = 103;
  static const isha = 104;

  // تنبيهات قبل الأذان بـ 15 دقيقة
  static const preFajr = 110;
  static const preDhuhr = 111;
  static const preAsr = 112;
  static const preMaghrib = 113;
  static const preIsha = 114;

  // تنبيهات الإقامة
  static const iqamaFajr = 120;
  static const iqamaDhuhr = 121;
  static const iqamaAsr = 122;
  static const iqamaMaghrib = 123;
  static const iqamaIsha = 124;

  // محاسبة مسائية
  static const eveningMuhasaba = 200;

  // أذكار
  static const morningAdhkar = 300;
  static const eveningAdhkar = 301;
  static const afterPrayerAdhkar = 302;
  static const sleepAdhkar = 303;
  static const randomAdhkar = 304;

  // أدعية
  static const randomDua = 400;
  static const dailyDuaMorning = 401;
  static const dailyDuaEvening = 402;
  static const distressDua = 403;

  // تذكيرات خاصة
  static const fridayKahf = 500;
  static const fridaySalawat = 501;
  static const fastingMonday = 502;
  static const fastingThursday = 503;
  static const fastingWhiteDays = 504;

  // إنجازات
  static const achievement = 600;

  // رمضان
  static const ramadanSuhoor = 700;
  static const ramadanIftar = 701;

  // تنبيهات الاستيقاظ
  static const wakeUpAlarm = 105;
}

// ─────────────────────────────────────────
//  NOTIFICATION CHANNELS (Android)
// ─────────────────────────────────────────
class NotifChannels {
  /// قناة الأذان — أعلى أولوية مع صوت الأذان
  static const AndroidNotificationChannel prayer = AndroidNotificationChannel(
    'prayer_adhan',
    'أذان الصلاة',
    description: 'إشعار وقت الأذان مع صوت الأذان',
    importance: Importance.max,
    sound: RawResourceAndroidNotificationSound('adhan'),
    playSound: true,
    enableVibration: true,
    enableLights: true,
    ledColor: Color(0xFFC8A96E),
  );

  /// تنبيهات قبل الأذان والإقامة
  static const AndroidNotificationChannel alert = AndroidNotificationChannel(
    'prayer_alerts',
    'تنبيهات الصلاة',
    description: 'تنبيهات قبل الأذان وبعد الإقامة',
    importance: Importance.high,
    sound: RawResourceAndroidNotificationSound('notification'),
    playSound: true,
    enableVibration: true,
  );

  /// قناة المحاسبة
  static const AndroidNotificationChannel muhasaba = AndroidNotificationChannel(
    'muhasaba',
    'محاسبة النفس',
    description: 'تذكير محاسبة النفس المسائية',
    importance: Importance.defaultImportance,
    enableVibration: false,
  );

  /// قناة الأذكار
  static const AndroidNotificationChannel adhkar = AndroidNotificationChannel(
    'adhkar_channel',
    'الأذكار اليومية',
    description: 'أذكار الصباح والمساء وبعد الصلاة',
    importance: Importance.defaultImportance,
    playSound: false,
    enableVibration: false,
  );

  /// قناة الأدعية
  static const AndroidNotificationChannel duas = AndroidNotificationChannel(
    'duas_channel',
    'الأدعية',
    description: 'نفحات من الأدعية النبوية والقرآنية',
    importance: Importance.defaultImportance,
    playSound: false,
    enableVibration: false,
  );

  /// قناة الإنجازات
  static const AndroidNotificationChannel achievement =
      AndroidNotificationChannel(
        'achievement_channel',
        'الإنجازات',
        description: 'إشعارات الإنجازات الجديدة',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

  /// قناة التذكيرات الخاصة
  static const AndroidNotificationChannel reminders =
      AndroidNotificationChannel(
        'special_reminders',
        'تذكيرات إيمانية',
        description: 'تذكيرات بسنن الجمعة والصيام والأيام البيض',
        importance: Importance.defaultImportance,
        enableVibration: false,
      );

  /// قناة رمضان
  static const AndroidNotificationChannel ramadan = AndroidNotificationChannel(
    'ramadan_channel',
    'رمضان المبارك',
    description: 'تنبيهات السحور والإفطار',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  /// قناة منبه الاستيقاظ
  static const AndroidNotificationChannel wakeUpAlarm =
      AndroidNotificationChannel(
        'wakeup_alarm_channel',
        'منبه الاستيقاظ',
        description: 'منبه مخصص للاستيقاظ لصلاة الفجر',
        importance: Importance.max,
        sound: RawResourceAndroidNotificationSound('adhan'),
        playSound: true,
        enableVibration: true,
        enableLights: true,
        ledColor: Color(0xFFC8A96E),
      );

  static List<AndroidNotificationChannel> get all => [
    prayer,
    alert,
    muhasaba,
    adhkar,
    duas,
    achievement,
    reminders,
    ramadan,
    wakeUpAlarm,
  ];
}

// ─────────────────────────────────────────
//  PRAYER TIME INFO MODEL
// ─────────────────────────────────────────
class PrayerTimeInfo {
  final String name;
  final String nameAr;
  final String emoji;
  final DateTime time;
  final int notifId;
  const PrayerTimeInfo({
    required this.name,
    required this.nameAr,
    required this.emoji,
    required this.time,
    required this.notifId,
  });
}

// ═══════════════════════════════════════════════════════════════
//  NOTIFICATIONS SERVICE
// ═══════════════════════════════════════════════════════════════
class NotificationsService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  // ── تهيئة الخدمة ──
  static Future<void> initialize() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onNotifTap,
      onDidReceiveBackgroundNotificationResponse: _onNotifTap,
    );

    // إنشاء القنوات على Android
    if (Platform.isAndroid) {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      for (final channel in NotifChannels.all) {
        await androidPlugin?.createNotificationChannel(channel);
      }
    }

    _initialized = true;
  }

  // ── طلب الأذون ──
  static Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      if (!status.isGranted) return false;
      // Android 12+ يحتاج إذن التنبيه الدقيق
      final exact = await Permission.scheduleExactAlarm.request();
      return exact.isGranted;
    }
    if (Platform.isIOS) {
      final result = await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return result ?? false;
    }
    return true;
  }

  static Future<bool> checkPermissions() async {
    if (Platform.isAndroid) {
      return await Permission.notification.isGranted &&
          await Permission.scheduleExactAlarm.isGranted;
    }
    return await Permission.notification.isGranted;
  }

  static Future<bool> requestBackgroundPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.ignoreBatteryOptimizations
          .request()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => PermissionStatus.denied,
          );
      return status.isGranted;
    }
    return true;
  }

  // ── جدولة إشعارات الصلاة الكاملة ──
  static Future<void> schedulePrayerNotifications({
    required List<PrayerTimeInfo> prayers,
    bool preAdhanEnabled = true,
    bool iqamaEnabled = true,
  }) async {
    // إلغاء القديمة
    final ids = [
      ...List.generate(5, (i) => 100 + i), // أذان
      ...List.generate(5, (i) => 110 + i), // قبل الأذان
      ...List.generate(5, (i) => 120 + i), // إقامة
    ];
    for (final id in ids) {
      await _plugin.cancel(id);
    }

    final iqamaOffsets = {
      'fajr': 20,
      'dhuhr': 15,
      'asr': 15,
      'maghrib': 5,
      'isha': 15,
    };

    final now = DateTime.now();

    for (int i = 0; i < prayers.length; i++) {
      final prayer = prayers[i];

      // 1. تنبيه قبل الأذان بـ 15 دقيقة
      if (preAdhanEnabled) {
        final preTime = prayer.time.subtract(const Duration(minutes: 15));
        if (preTime.isAfter(now)) {
          await _scheduleExact(
            id: 110 + i,
            title: '⏳ اقترب وقت ${prayer.nameAr}',
            body: '15 دقيقة على أذان ${prayer.nameAr}، استعدَّ للصلاة',
            scheduledTime: preTime,
            channelId: NotifChannels.alert.id,
            payload: 'pre_prayer:${prayer.name}',
          );
        }
      }

      // 2. إشعار الأذان مع الصوت
      if (prayer.time.isAfter(now)) {
        await _scheduleExact(
          id: prayer.notifId,
          title: '${prayer.emoji} حان وقت ${prayer.nameAr}',
          body: 'اللهُ أكبر، اللهُ أكبر — حيَّ على الصلاة، حيَّ على الفلاح',
          scheduledTime: prayer.time,
          channelId: NotifChannels.prayer.id,
          sound: 'adhan',
          payload: 'prayer:${prayer.name}',
          fullScreenIntent: true,
        );
      }

      // 3. تنبيه الإقامة
      if (iqamaEnabled) {
        final offset = iqamaOffsets[prayer.name] ?? 15;
        final iqamaTime = prayer.time.add(Duration(minutes: offset));
        if (iqamaTime.isAfter(now)) {
          await _scheduleExact(
            id: 120 + i,
            title: '🤲 وقت الإقامة — ${prayer.nameAr}',
            body: 'حان وقت إقامة صلاة ${prayer.nameAr}، الله أكبر الله أكبر',
            scheduledTime: iqamaTime,
            channelId: NotifChannels.alert.id,
            payload: 'iqama:${prayer.name}',
          );
        }
      }
    }
  }

  // ── جدولة محاسبة مسائية يومية ──
  static Future<void> scheduleEveningMuhasaba({required TimeOfDay time}) async {
    await _plugin.cancel(NotifIds.eveningMuhasaba);

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

    final msg = _eveningMessages[now.weekday % _eveningMessages.length];

    await _plugin.zonedSchedule(
      NotifIds.eveningMuhasaba,
      '📝 وقت محاسبة النفس',
      msg,
      tz.TZDateTime.from(scheduled, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          NotifChannels.muhasaba.id,
          NotifChannels.muhasaba.name,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          styleInformation: BigTextStyleInformation(msg),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: false,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'muhasaba:evening',
    );
  }

  // ── جدولة أذكار الصباح والمساء يومياً ──
  static Future<void> scheduleAdhkarReminders({
    required TimeOfDay morningTime,
    required TimeOfDay eveningTime,
  }) async {
    await _plugin.cancel(NotifIds.morningAdhkar);
    await _plugin.cancel(NotifIds.eveningAdhkar);

    // أذكار الصباح
    final morningDhikr = _randomFromCategory(AdhkarCategory.morning);
    await _scheduleDailyAt(
      id: NotifIds.morningAdhkar,
      title: '🌅 أذكار الصباح',
      body: morningDhikr != null
          ? _truncate(morningDhikr.arabic, 120)
          : 'لا تنس أذكار الصباح — حصنك اليومي',
      time: morningTime,
      channelId: NotifChannels.adhkar.id,
      payload: 'adhkar:morning',
    );

    // أذكار المساء
    final eveningDhikr = _randomFromCategory(AdhkarCategory.evening);
    await _scheduleDailyAt(
      id: NotifIds.eveningAdhkar,
      title: '🌆 أذكار المساء',
      body: eveningDhikr != null
          ? _truncate(eveningDhikr.arabic, 120)
          : 'اللهم بك أمسينا وبك أصبحنا وبك نحيا وبك نموت',
      time: eveningTime,
      channelId: NotifChannels.adhkar.id,
      payload: 'adhkar:evening',
    );

    // أذكار النوم
    await _scheduleDailyAt(
      id: NotifIds.sleepAdhkar,
      title: '🌙 أذكار النوم',
      body: 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا — حان وقت أذكار النوم',
      time: const TimeOfDay(hour: 22, minute: 0),
      channelId: NotifChannels.adhkar.id,
      payload: 'adhkar:sleep',
    );
  }

  // ── جدولة أدعية يومية ──
  static Future<void> scheduleDailyDuas() async {
    // دعاء الصباح (9:00)
    final morningDua = _getTimedDua(DuaCategory.morning);
    if (morningDua != null) {
      await _scheduleDailyAt(
        id: NotifIds.dailyDuaMorning,
        title: '${morningDua.emoji} دعاء الصباح',
        body: _truncate(morningDua.arabic, 150),
        time: const TimeOfDay(hour: 9, minute: 0),
        channelId: NotifChannels.duas.id,
        payload: 'dua:${morningDua.id}',
      );
    }

    // دعاء المساء (9:00 م)
    final eveningDua = _getRandomDua([
      DuaCategory.forgiveness,
      DuaCategory.guidance,
      DuaCategory.general,
    ]);
    if (eveningDua != null) {
      await _scheduleDailyAt(
        id: NotifIds.dailyDuaEvening,
        title: '${eveningDua.emoji} دعاء المساء',
        body: _truncate(eveningDua.arabic, 150),
        time: const TimeOfDay(hour: 21, minute: 0),
        channelId: NotifChannels.duas.id,
        payload: 'dua:${eveningDua.id}',
      );
    }

    // دعاء الكرب (12:00) — وسط النهار
    final distressDua = _getTimedDua(DuaCategory.distress);
    if (distressDua != null) {
      await _scheduleDailyAt(
        id: NotifIds.distressDua,
        title: '${distressDua.emoji} دعاء اليوم',
        body: _truncate(distressDua.arabic, 150),
        time: const TimeOfDay(hour: 12, minute: 0),
        channelId: NotifChannels.duas.id,
        payload: 'dua:${distressDua.id}',
      );
    }
  }

  // ── جدولة تذكيرات الجمعة والصيام ──
  static Future<void> scheduleSpecialReminders({
    required bool fridayReminders,
    required bool fastingReminders,
  }) async {
    final ids = [
      NotifIds.fridayKahf,
      NotifIds.fridaySalawat,
      NotifIds.fastingMonday,
      NotifIds.fastingThursday,
    ];
    for (final id in ids) {
      await _plugin.cancel(id);
    }

    if (fridayReminders) {
      await _scheduleWeekly(
        id: NotifIds.fridayKahf,
        title: '📖 سورة الكهف',
        body: 'لا تنس قراءة سورة الكهف اليوم — نور ما بين الجمعتين',
        day: DateTime.friday,
        hour: 9,
        minute: 0,
        payload: 'reminder:kahf',
      );
      await _scheduleWeekly(
        id: NotifIds.fridaySalawat,
        title: '💛 الصلاة على النبي ﷺ',
        body: 'اللهم صلِّ وسلِّم على سيدنا محمد — أكثِر من الصلاة يوم الجمعة',
        day: DateTime.friday,
        hour: 13,
        minute: 0,
        payload: 'reminder:salawat',
      );
    }

    if (fastingReminders) {
      await _scheduleWeekly(
        id: NotifIds.fastingMonday,
        title: '🥘 تذكير بصيام الاثنين',
        body: 'غداً الاثنين — تُعرض فيه الأعمال، فليكن عملك وأنت صائم',
        day: DateTime.sunday,
        hour: 21,
        minute: 0,
        payload: 'reminder:fasting_monday',
      );
      await _scheduleWeekly(
        id: NotifIds.fastingThursday,
        title: '🥘 تذكير بصيام الخميس',
        body: 'غداً الخميس — تُرفع فيه الأعمال، هنيئاً لمن صام',
        day: DateTime.wednesday,
        hour: 21,
        minute: 0,
        payload: 'reminder:fasting_thursday',
      );

      // الأيام البيض
      await _scheduleWhiteDays();
    }
  }

  // ── جدولة رمضان (السحور والإفطار) ──
  static Future<void> scheduleRamadanNotifications({
    required DateTime suhoorTime,
    required DateTime iftarTime,
  }) async {
    await _plugin.cancel(NotifIds.ramadanSuhoor);
    await _plugin.cancel(NotifIds.ramadanIftar);

    final now = DateTime.now();
    final suhoorAlert = suhoorTime.subtract(const Duration(minutes: 30));
    if (suhoorAlert.isAfter(now)) {
      await _scheduleExact(
        id: NotifIds.ramadanSuhoor,
        title: '🌙 تنبيه السحور',
        body: 'بقي 30 دقيقة على الإمساك — استيقظ للسحور وبارك الله لك',
        scheduledTime: suhoorAlert,
        channelId: NotifChannels.ramadan.id,
        payload: 'ramadan:suhoor',
      );
    }
    if (iftarTime.isAfter(now)) {
      await _scheduleExact(
        id: NotifIds.ramadanIftar,
        title: '🌅 حان وقت الإفطار',
        body: 'اللهم لك صمت وعلى رزقك أفطرت — رمضان مبارك',
        scheduledTime: iftarTime,
        channelId: NotifChannels.ramadan.id,
        sound: 'adhan',
        payload: 'ramadan:iftar',
      );
    }
  }

  // ── المنبه / الاستيقاظ ──
  static Future<void> scheduleWakeUpAlarm({required TimeOfDay time}) async {
    await _scheduleDailyAt(
      id: NotifIds.wakeUpAlarm,
      title: '🌙 حان وقت الاستيقاظ',
      body: 'الصلاة خير من النوم — استيقظ لصلاة الفجر',
      time: time,
      channelId: NotifChannels.wakeUpAlarm.id,
      sound: 'adhan',
      payload: 'wakeup:fajr',
      fullScreenIntent: true,
    );
  }

  static Future<void> scheduleSnooze({required int minutes}) async {
    final snoozeTime = DateTime.now().add(Duration(minutes: minutes));
    await _scheduleExact(
      id: NotifIds.wakeUpAlarm,
      title: '🌙 حان وقت الاستيقاظ (غفوة)',
      body: 'الصلاة خير من النوم — استيقظ لصلاة الفجر',
      scheduledTime: snoozeTime,
      channelId: NotifChannels.wakeUpAlarm.id,
      sound: 'adhan',
      payload: 'wakeup:fajr',
      fullScreenIntent: true,
    );
  }

  // ── إشعار إنجاز فوري ──
  static Future<void> showAchievementNotif({
    required String title,
    required String body,
    required String emoji,
    required int points,
  }) async {
    await _plugin.show(
      NotifIds.achievement,
      '$emoji إنجاز جديد: $title',
      '$body — +$points نقطة تقوى 🌟',
      NotificationDetails(
        android: AndroidNotificationDetails(
          NotifChannels.achievement.id,
          NotifChannels.achievement.name,
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(
            '$body\n✨ +$points نقطة تقوى',
          ),
          color: const Color(0xFFC8A96E),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
        ),
      ),
      payload: 'achievement:new',
    );
  }

  // ── عرض إشعار فوري ──
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    required AndroidNotificationChannel channel,
    String? bigText,
  }) async {
    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: channel.importance,
          priority: Priority.defaultPriority,
          styleInformation: BigTextStyleInformation(bigText ?? body),
          color: const Color(0xFFC8A96E),
        ),
        iOS: const DarwinNotificationDetails(presentAlert: true),
      ),
      payload: payload,
    );
  }

  // ── إلغاء الإشعارات ──
  static Future<void> cancel(int id) => _plugin.cancel(id);
  static Future<void> cancelAll() => _plugin.cancelAll();
  static Future<List<PendingNotificationRequest>> getPending() =>
      _plugin.pendingNotificationRequests();

  // ─────────────────── PRIVATE ───────────────────

  static Future<void> _scheduleExact({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String channelId,
    String? sound,
    String? payload,
    bool fullScreenIntent = false,
  }) async {
    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);
    if (tzTime.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId,
          importance: Importance.max,
          priority: Priority.high,
          sound: sound != null
              ? RawResourceAndroidNotificationSound(sound)
              : null,
          playSound: sound != null,
          enableVibration: true,
          fullScreenIntent: fullScreenIntent,
          category: fullScreenIntent ? AndroidNotificationCategory.alarm : null,
          audioAttributesUsage: fullScreenIntent
              ? AudioAttributesUsage.alarm
              : AudioAttributesUsage.notification,
          visibility: NotificationVisibility.public,
          styleInformation: BigTextStyleInformation(body),
          color: const Color(0xFFC8A96E),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: sound != null,
          sound: sound != null ? 'adhan.aiff' : null,
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  static Future<void> _scheduleDailyAt({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    required String channelId,
    String? payload,
    String? sound,
    bool fullScreenIntent = false,
  }) async {
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

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduled, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId,
          importance: sound != null
              ? Importance.max
              : Importance.defaultImportance,
          priority: sound != null ? Priority.high : Priority.defaultPriority,
          sound: sound != null
              ? RawResourceAndroidNotificationSound(sound)
              : null,
          playSound: sound != null,
          enableVibration: true,
          fullScreenIntent: fullScreenIntent,
          category: fullScreenIntent ? AndroidNotificationCategory.alarm : null,
          audioAttributesUsage: fullScreenIntent
              ? AudioAttributesUsage.alarm
              : AudioAttributesUsage.notification,
          visibility: NotificationVisibility.public,
          styleInformation: BigTextStyleInformation(body),
          color: const Color(0xFFC8A96E),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: sound != null,
          sound: sound != null ? 'adhan.aiff' : null,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  static Future<void> _scheduleWeekly({
    required int id,
    required String title,
    required String body,
    required int day,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var date = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    while (date.weekday != day || date.isBefore(now)) {
      date = date.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      date,
      NotificationDetails(
        android: AndroidNotificationDetails(
          NotifChannels.reminders.id,
          NotifChannels.reminders.name,
          importance: Importance.defaultImportance,
          styleInformation: BigTextStyleInformation(body),
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: payload,
    );
  }

  static Future<void> _scheduleWhiteDays() async {
    for (int monthOffset = 0; monthOffset <= 1; monthOffset++) {
      final h = HijriCalendar.now();
      if (monthOffset > 0) {
        h.hMonth++;
        if (h.hMonth > 12) {
          h.hMonth = 1;
          h.hYear++;
        }
      }
      for (int day in [12, 13, 14]) {
        h.hDay = day;
        final solar = h.hijriToGregorian(h.hYear, h.hMonth, h.hDay);
        final notify = DateTime(solar.year, solar.month, solar.day, 20, 30);
        if (notify.isAfter(DateTime.now())) {
          await _scheduleExact(
            id: NotifIds.fastingWhiteDays + (monthOffset * 3) + (day - 12),
            title: '⚪ غداً من الأيام البيض',
            body:
                'غداً يوم ${day + 1} من ${h.getLongMonthName()} الهجري — صيام الأيام البيض سنّة مؤكدة',
            scheduledTime: notify,
            channelId: NotifChannels.reminders.id,
            payload: 'reminder:white_days',
          );
        }
      }
    }
  }

  // ── helpers ──
  static DhikrItem? _randomFromCategory(AdhkarCategory cat) {
    final list = kAdhkarData[cat];
    if (list == null || list.isEmpty) return null;
    return list[Random(DateTime.now().dayOfYear).nextInt(list.length)];
  }

  static DuaItem? _getTimedDua(DuaCategory cat) {
    final list = kDuasData[cat];
    if (list == null || list.isEmpty) return null;
    return list[Random(DateTime.now().dayOfYear).nextInt(list.length)];
  }

  static DuaItem? _getRandomDua(List<DuaCategory> cats) {
    final pool = cats.expand((c) => kDuasData[c] ?? []).toList();
    if (pool.isEmpty) return null;
    return pool[Random(DateTime.now().dayOfYear).nextInt(pool.length)];
  }

  static String _truncate(String text, int maxLen) {
    final clean = text.replaceAll('\n', ' ');
    return clean.length > maxLen ? '${clean.substring(0, maxLen)}...' : clean;
  }

  static String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ap = dt.hour < 12 ? 'ص' : 'م';
    return '$h:$m $ap';
  }

  static void _onNotifTap(NotificationResponse response) {
    NotificationRouter.route(response.payload ?? '');
  }

  static const _eveningMessages = [
    'كيف كان يومك مع الله؟ حاسب نفسك قبل أن تنام 🌙',
    '"حَاسِبُوا أَنفُسَكُمْ قَبْلَ أَنْ تُحَاسَبُوا" — عمر بن الخطاب',
    'ماذا قدَّمتَ اليوم؟ سجِّل عباداتك الآن 📝',
    'الليل ينادي: أيها المؤمن، ماذا عملتَ اليوم؟ 🌟',
    'لا تنم قبل أن تحاسب نفسك على يومك 💫',
    'ثلاث دقائق لمحاسبة النفس خير من ساعات الندم 🤲',
    'أنجزتَ شيئاً جيداً اليوم؟ دوِّنه واشكر الله 🙏',
  ];
}

// ═══════════════════════════════════════════════════════════════
//  PRAYER TIMES SERVICE
// ═══════════════════════════════════════════════════════════════
class PrayerTimesService {
  static Future<List<PrayerTimeInfo>> calculate({
    required double latitude,
    required double longitude,
    required String madhab,
    required String method,
    DateTime? date,
  }) async {
    final d = date ?? DateTime.now();
    final coords = adhan.Coordinates(latitude, longitude);
    final params = _calcParams(method, madhab);
    final dc = adhan.DateComponents(d.year, d.month, d.day);
    final times = adhan.PrayerTimes(coords, dc, params);

    return [
      PrayerTimeInfo(
        name: 'fajr',
        nameAr: 'الفجر',
        emoji: '🌙',
        time: times.fajr,
        notifId: NotifIds.fajr,
      ),
      PrayerTimeInfo(
        name: 'sunrise',
        nameAr: 'الشروق',
        emoji: '🌅',
        time: times.sunrise,
        notifId: -1, // لا يوجد إشعار للشروق حالياً
      ),
      PrayerTimeInfo(
        name: 'dhuhr',
        nameAr: 'الظهر',
        emoji: '☀️',
        time: times.dhuhr,
        notifId: NotifIds.dhuhr,
      ),
      PrayerTimeInfo(
        name: 'asr',
        nameAr: 'العصر',
        emoji: '🌤',
        time: times.asr,
        notifId: NotifIds.asr,
      ),
      PrayerTimeInfo(
        name: 'maghrib',
        nameAr: 'المغرب',
        emoji: '🌆',
        time: times.maghrib,
        notifId: NotifIds.maghrib,
      ),
      PrayerTimeInfo(
        name: 'isha',
        nameAr: 'العشاء',
        emoji: '🌃',
        time: times.isha,
        notifId: NotifIds.isha,
      ),
    ];
  }

  static Future<Position?> getLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) return null;
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) return null;
    }
    if (perm == LocationPermission.deniedForever) return null;
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );
  }

  static PrayerTimeInfo? nextPrayer(List<PrayerTimeInfo> prayers) {
    final now = DateTime.now();
    for (final p in prayers) {
      if (p.time.isAfter(now)) return p;
    }
    return null;
  }

  static Duration? timeUntilNext(List<PrayerTimeInfo> prayers) =>
      nextPrayer(prayers)?.time.difference(DateTime.now());

  static String formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ap = dt.hour < 12 ? 'ص' : 'م';
    return '$h:$m $ap';
  }

  static String formatDuration(Duration d) {
    if (d.inHours > 0) return '${d.inHours}س ${d.inMinutes % 60}د';
    return '${d.inMinutes} دقيقة';
  }

  static adhan.CalculationParameters _calcParams(String method, String madhab) {
    adhan.CalculationParameters p;
    switch (method) {
      case 'Algeria':
        // وزارة الشؤون الدينية والأوقاف - الجزائر
        // تعتمد زوايا قريبة من المصري (19.5/17.5) مع تعديلات طفيفة
        p = adhan.CalculationMethod.egyptian.getParameters();
        p.fajrAngle = 18.0;
        p.ishaAngle = 17.0;
        // تعديلات دقيقة لتطابق تطبيق صلاتك والرزنامة الرسمية
        p.methodAdjustments.fajr = 0;
        p.methodAdjustments.dhuhr = 0;
        p.methodAdjustments.asr = 1;
        p.methodAdjustments.maghrib = 5;
        p.methodAdjustments.isha = 0;
        break;
      case 'Egypt':
        p = adhan.CalculationMethod.egyptian.getParameters();
        break;
      case 'Karachi':
        p = adhan.CalculationMethod.karachi.getParameters();
        break;
      case 'UmmAlQura':
        p = adhan.CalculationMethod.umm_al_qura.getParameters();
        break;
      case 'ISNA':
        p = adhan.CalculationMethod.north_america.getParameters();
        break;
      default:
        p = adhan.CalculationMethod.muslim_world_league.getParameters();
    }
    p.madhab = madhab == 'hanafi' ? adhan.Madhab.hanafi : adhan.Madhab.shafi;
    return p;
  }
}

// ═══════════════════════════════════════════════════════════════
//  NOTIFICATION ROUTER
// ═══════════════════════════════════════════════════════════════
class NotificationRouter {
  static final _navigatorKey = GlobalKey<NavigatorState>();
  static GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  static void route(String payload) {
    if (payload.isEmpty) return;
    final parts = payload.split(':');
    final type = parts.isNotEmpty ? parts[0] : '';
    final param = parts.length > 1 ? parts[1] : '';
    final ctx = _navigatorKey.currentContext;
    if (ctx == null) return;

    switch (type) {
      case 'prayer':
        Navigator.pushNamed(ctx, Routes.adhan, arguments: _prayerNameAr(param));
        break;
      case 'wakeup':
        Navigator.pushNamed(ctx, Routes.wakeUpOverlay);
        break;
      case 'pre_prayer':
      case 'iqama':
        Navigator.pushNamed(ctx, Routes.prayer);
        break;
      case 'muhasaba':
        Navigator.pushNamed(ctx, Routes.checklist);
        break;
      case 'adhkar':
        Navigator.pushNamed(ctx, Routes.adhkar);
        break;
      case 'dua':
        Navigator.pushNamed(ctx, Routes.duas);
        break;
      case 'achievement':
        Navigator.pushNamed(ctx, Routes.statistics);
        break;
      case 'reminder':
        Navigator.pushNamed(ctx, Routes.home);
        break;
      case 'ramadan':
        Navigator.pushNamed(ctx, Routes.prayer);
        break;
    }
  }

  static String _prayerNameAr(String key) => switch (key) {
    'fajr' => 'الفجر',
    'dhuhr' => 'الظهر',
    'asr' => 'العصر',
    'maghrib' => 'المغرب',
    'isha' => 'العشاء',
    _ => key.isNotEmpty ? key : 'الصلاة',
  };
}

// ═══════════════════════════════════════════════════════════════
//  PRAYER TIMES PROVIDER
// ═══════════════════════════════════════════════════════════════
final prayerTimesProvider = FutureProvider<List<PrayerTimeInfo>>((ref) async {
  final prefs = await ref.watch(userPreferencesProvider.future);
  final settings = ref.watch(settingsDaoProvider);

  final savedLat = await settings.get('latitude');
  final savedLng = await settings.get('longitude');

  double lat, lng;
  if (savedLat != null && savedLng != null) {
    lat = double.tryParse(savedLat) ?? 36.7;
    lng = double.tryParse(savedLng) ?? 3.0;
  } else {
    final pos = await PrayerTimesService.getLocation();
    lat = pos?.latitude ?? 36.7;
    lng = pos?.longitude ?? 3.0;
    if (pos != null) {
      await settings.set('latitude', lat.toString());
      await settings.set('longitude', lng.toString());
    }
  }

  return PrayerTimesService.calculate(
    latitude: lat,
    longitude: lng,
    madhab: prefs.madhab,
    method: prefs.calcMethod,
  );
});

final nextPrayerProvider = Provider<AsyncValue<PrayerTimeInfo?>>(
  (ref) => ref
      .watch(prayerTimesProvider)
      .whenData((p) => PrayerTimesService.nextPrayer(p)),
);

// ═══════════════════════════════════════════════════════════════
//  NOTIFICATIONS MANAGER
// ═══════════════════════════════════════════════════════════════
final notificationsManagerProvider = Provider<NotificationsManager>((ref) {
  return NotificationsManager(ref);
});

class NotificationsManager {
  final Ref _ref;
  NotificationsManager(this._ref);

  Future<void> scheduleAll() async {
    if (!await NotificationsService.checkPermissions()) return;

    final prefs = await _ref.read(userPreferencesProvider.future);

    // أوقات الصلاة
    if (prefs.prayerReminder) {
      final prayers = await _ref.read(prayerTimesProvider.future);
      await NotificationsService.schedulePrayerNotifications(
        prayers: prayers,
        preAdhanEnabled: prefs.preAdhanNotif,
        iqamaEnabled: prefs.iqamaNotif,
      );
    }

    // تنبيه اليقظة قبل الفجر
    if (prefs.wakeUpBeforeFajr) {
      await NotificationsService.scheduleWakeUpAlarm(time: prefs.wakeUpTime);
    } else {
      await NotificationsService.cancel(NotifIds.wakeUpAlarm);
    }

    // المحاسبة
    if (prefs.muhasabaReminder) {
      await NotificationsService.scheduleEveningMuhasaba(
        time: prefs.muhasabaTime,
      );
    }

    // الأذكار
    await AdhkarNotificationService.rescheduleAll(prefs);

    // الأدعية
    if (prefs.dailyDuasOn) await NotificationsService.scheduleDailyDuas();

    // التذكيرات الخاصة
    await NotificationsService.scheduleSpecialReminders(
      fridayReminders: prefs.specialRemindersOn,
      fastingReminders: prefs.fastingRemindersOn,
    );
  }

  Future<void> reschedule() async {
    await NotificationsService.cancelAll();
    await scheduleAll();
  }
}

// Helper extension
extension on DateTime {
  int get dayOfYear {
    final start = DateTime(year, 1, 1);
    return difference(start).inDays + 1;
  }
}
