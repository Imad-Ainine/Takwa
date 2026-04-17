// ═══════════════════════════════════════════════════════════════
//  lib/core/notifications/notifications_service.dart
// تقوى — Local Notifications + Prayer Times
// ═══════════════════════════════════════════════════════════════

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:adhan/adhan.dart' as adhan;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:permission_handler/permission_handler.dart';

import 'package:takwa/core/providers/database_providers.dart';
import 'package:takwa/core/routes/app_routes.dart';

// ─────────────────────────────────────────
//  NOTIFICATION IDs  (ثابتة لا تتغير)
// ─────────────────────────────────────────
class NotifIds {
  // صلوات
  static const fajr = 100;
  static const dhuhr = 101;
  static const asr = 102;
  static const maghrib = 103;
  static const isha = 104;
  static const fajrWakeUp = 105; // تنبيه قبل الفجر بـ 15 دقيقة (قديم)

  // تنبيهات جديدة قبل الأذان بـ 15 دقيقة
  static const preFajr = 110;
  static const preDhuhr = 111;
  static const preAsr = 112;
  static const preMaghrib = 113;
  static const preIsha = 114;

  // تنبيهات الإقامة (بعد الأذان)
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

  // تحدي رمضان يومي
  static const ramadanDaily = 400;

  // إنجاز جديد
  static const achievement = 500;
}

// ─────────────────────────────────────────
//  NOTIFICATION CHANNELS (Android)
// ─────────────────────────────────────────
class NotifChannels {
  static const AndroidNotificationChannel prayer = AndroidNotificationChannel(
    'prayer_times',
    'أوقات الصلاة',
    description: 'تذكيرات أوقات الصلوات الخمس',
    importance: Importance.high,
    sound: RawResourceAndroidNotificationSound('adhan'),
    playSound: true,
    enableVibration: true,
  );

  static const AndroidNotificationChannel alert = AndroidNotificationChannel(
    'prayer_alerts',
    'تنبيهات الصلاة',
    description: 'تنبيهات قبل الأذان وبوقت الإقامة',
    importance: Importance.high,
    sound: RawResourceAndroidNotificationSound('notification'),
    playSound: true,
    enableVibration: true,
  );

  static const AndroidNotificationChannel muhasaba = AndroidNotificationChannel(
    'muhasaba',
    'محاسبة النفس',
    description: 'تذكيرات المحاسبة المسائية',
    importance: Importance.defaultImportance,
  );

  static const AndroidNotificationChannel adhkar = AndroidNotificationChannel(
    'adhkar',
    'الأذكار',
    description: 'تذكيرات أذكار الصباح والمساء',
    importance: Importance.defaultImportance,
  );

  static const AndroidNotificationChannel achievement =
      AndroidNotificationChannel(
        'achievement',
        'الإنجازات',
        description: 'إشعارات الإنجازات الجديدة',
        importance: Importance.high,
      );
}

// ─────────────────────────────────────────
//  PRAYER INFO MODEL
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

// ─────────────────────────────────────────
//  NOTIFICATIONS SERVICE
// ─────────────────────────────────────────
class NotificationsService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  // ── تهيئة الخدمة ──
  static Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    // Android settings
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(android: android, iOS: ios);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotifTap,
      onDidReceiveBackgroundNotificationResponse: _onNotifTap,
    );

    // إنشاء القنوات (Android)
    if (Platform.isAndroid) {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidPlugin?.createNotificationChannel(NotifChannels.prayer);
      await androidPlugin?.createNotificationChannel(NotifChannels.alert);
      await androidPlugin?.createNotificationChannel(NotifChannels.muhasaba);
      await androidPlugin?.createNotificationChannel(NotifChannels.adhkar);
      await androidPlugin?.createNotificationChannel(NotifChannels.achievement);
    }

    _initialized = true;
  }

  // ── طلب الإذن ──
  static Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      if (!status.isGranted) return false;

      // Android 12+ exact alarm
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

  // ── جدولة إشعارات الصلاة (ليوم واحد) ──
  static Future<void> schedulePrayerNotifications({
    required List<PrayerTimeInfo> prayers,
    required bool wakeUpBeforeFajr,
  }) async {
    // إلغاء القديمة
    final idsToCancel = [
      100,
      101,
      102,
      103,
      104,
      105,
      110,
      111,
      112,
      113,
      114,
      120,
      121,
      122,
      123,
      124,
    ];
    for (final id in idsToCancel) {
      await _plugin.cancel(id);
    }

    final iqamaOffsets = {
      'fajr': 20,
      'dhuhr': 15,
      'asr': 15,
      'maghrib': 5,
      'isha': 15,
    };

    for (int i = 0; i < prayers.length; i++) {
      final prayer = prayers[i];
      final now = DateTime.now();

      // 1. التنبيه قبل الأذان بـ 15 دقيقة
      final preTime = prayer.time.subtract(const Duration(minutes: 15));
      if (preTime.isAfter(now)) {
        await _scheduleExact(
          id: 110 + i,
          title: 'اقترب وقت ${prayer.nameAr} ⏳',
          body: '١٥ دقيقة ويؤذن لـ ${prayer.nameAr}، استعد للصلاة',
          scheduledTime: preTime,
          channelId: NotifChannels.alert.id,
          sound: 'notification',
          payload: 'pre_prayer:${prayer.name}',
        );
      }

      // 2. الأذان الفعلي
      if (prayer.time.isAfter(now)) {
        await _scheduleExact(
          id: prayer.notifId,
          title: 'حان وقت ${prayer.nameAr} ${prayer.emoji}',
          body: 'الله أكبر، الله أكبر، حي على الصلاة',
          scheduledTime: prayer.time,
          channelId: NotifChannels.prayer.id,
          sound: 'adhan',
          payload: 'prayer:${prayer.name}',
        );
      }

      // 3. تنبيه الإقامة
      final offset = iqamaOffsets[prayer.name] ?? 15;
      final iqamaTime = prayer.time.add(Duration(minutes: offset));
      if (iqamaTime.isAfter(now)) {
        await _scheduleExact(
          id: 120 + i,
          title: 'وقت الإقامة — ${prayer.nameAr} 🤲',
          body: 'حان الآن وقت إقامة صلاة ${prayer.nameAr}',
          scheduledTime: iqamaTime,
          channelId: NotifChannels.alert.id,
          sound: 'notification',
          payload: 'iqama:${prayer.name}',
        );
      }
    }
  }

  // ── جدولة المحاسبة المسائية (يومياً) ──
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

    // يومي بالتكرار
    await _plugin.zonedSchedule(
      NotifIds.eveningMuhasaba,
      'وقت محاسبة النفس 📝',
      _eveningMessages[DateTime.now().weekday % _eveningMessages.length],
      tz.TZDateTime.from(scheduled, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          NotifChannels.muhasaba.id,
          NotifChannels.muhasaba.name,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          styleInformation: BigTextStyleInformation(
            _eveningMessages[DateTime.now().weekday % _eveningMessages.length],
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'muhasaba:evening',
    );
  }

  // ── جدولة أذكار الصباح والمساء ──
  static Future<void> scheduleAdhkarReminders({
    required TimeOfDay morningTime,
    required TimeOfDay eveningTime,
  }) async {
    await _plugin.cancel(NotifIds.morningAdhkar);
    await _plugin.cancel(NotifIds.eveningAdhkar);

    await _scheduleDailyAt(
      id: NotifIds.morningAdhkar,
      title: 'أذكار الصباح ☀️',
      body:
          'لا تنس أذكار الصباح — "وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا"',
      time: morningTime,
      channelId: NotifChannels.adhkar.id,
      payload: 'adhkar:morning',
    );

    await _scheduleDailyAt(
      id: NotifIds.eveningAdhkar,
      title: 'أذكار المساء 🌆',
      body: 'اللهم بك أمسينا وبك أصبحنا وبك نحيا وبك نموت',
      time: eveningTime,
      channelId: NotifChannels.adhkar.id,
      payload: 'adhkar:evening',
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
      '$body — +$points نقطة 🌟',
      NotificationDetails(
        android: AndroidNotificationDetails(
          NotifChannels.achievement.id,
          NotifChannels.achievement.name,
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation('$body — +$points نقطة 🌟'),
          color: const Color(0xFFC8A96E),
          // largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'achievement:new',
    );
  }

  // ── إلغاء كل الإشعارات ──
  static Future<void> cancelAll() => _plugin.cancelAll();

  // ── إلغاء إشعار محدد ──
  static Future<void> cancel(int id) => _plugin.cancel(id);

  // ── الإشعارات المجدولة ──
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
  }) async {
    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId,
          importance: Importance.high,
          priority: Priority.high,
          sound: sound != null
              ? RawResourceAndroidNotificationSound(sound)
              : null,
          playSound: sound != null,
          enableVibration: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
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
          importance: Importance.defaultImportance,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: false,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  static void _onNotifTap(NotificationResponse response) {
    // يُعالج في main.dart عبر navigatorKey
    NotificationRouter.route(response.payload ?? '');
  }

  // رسائل المحاسبة المسائية المتنوعة
  static const _eveningMessages = [
    'كيف كان يومك مع الله؟ حاسب نفسك قبل أن تنام 🌙',
    '"حَاسِبُوا أَنفُسَكُمْ قَبْلَ أَنْ تُحَاسَبُوا" — عمر بن الخطاب',
    'ماذا قدّمت اليوم؟ سجّل عباداتك الآن 📝',
    'الليل ينادي: أيها المؤمن، ماذا فعلت اليوم؟ 🌟',
    'لا تنم قبل أن تحاسب نفسك على يومك 💫',
    'ثلاث دقائق لمحاسبة النفس خير من ساعات الندم 🤲',
    'أنجزت شيئاً جيداً اليوم؟ دوّنه واشكر الله 🙏',
  ];
}

// ═══════════════════════════════════════════════════════════════
//  PRAYER TIMES SERVICE
// ═══════════════════════════════════════════════════════════════
class PrayerTimesService {
  // ── حساب أوقات الصلاة ──
  static Future<List<PrayerTimeInfo>> calculate({
    required double latitude,
    required double longitude,
    required String madhab, // 'hanafi' | 'shafi'
    required String method, // 'MWL' | 'Egypt' | 'Karachi' | 'UmmAlQura'
    DateTime? date,
  }) async {
    final d = date ?? DateTime.now();
    final coords = adhan.Coordinates(latitude, longitude);
    final params = _calcParams(method, madhab);
    final dateComponents = adhan.DateComponents(d.year, d.month, d.day);
    final times = adhan.PrayerTimes(coords, dateComponents, params);

    return [
      PrayerTimeInfo(
        name: 'fajr',
        nameAr: 'الفجر',
        emoji: '🌅',
        time: times.fajr,
        notifId: NotifIds.fajr,
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

  // ── جلب الموقع الجغرافي ──
  static Future<Position?> getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );
  }

  // ── الصلاة الحالية / القادمة ──
  static adhan.Prayer currentPrayer(List<PrayerTimeInfo> prayers) {
    final now = DateTime.now();
    for (int i = prayers.length - 1; i >= 0; i--) {
      if (now.isAfter(prayers[i].time)) {
        return adhan.Prayer.values[i];
      }
    }
    return adhan.Prayer.none;
  }

  static PrayerTimeInfo? nextPrayer(List<PrayerTimeInfo> prayers) {
    final now = DateTime.now();
    for (final p in prayers) {
      if (p.time.isAfter(now)) return p;
    }
    // الفجر الغد
    return null;
  }

  static Duration? timeUntilNext(List<PrayerTimeInfo> prayers) {
    final next = nextPrayer(prayers);
    if (next == null) return null;
    return next.time.difference(DateTime.now());
  }

  // ── تنسيق الوقت ──
  static String formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour < 12 ? 'ص' : 'م';
    return '$h:$m $ampm';
  }

  static String formatDuration(Duration d) {
    if (d.inHours > 0) return '${d.inHours}س ${d.inMinutes % 60}د';
    return '${d.inMinutes} دقيقة';
  }

  // ── معامل الحساب ──
  static adhan.CalculationParameters _calcParams(String method, String madhab) {
    adhan.CalculationParameters p;
    switch (method) {
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
    if (madhab == 'hanafi') {
      p.madhab = adhan.Madhab.hanafi;
    } else {
      p.madhab = adhan.Madhab.shafi;
    }
    return p;
  }
}

// ═══════════════════════════════════════════════════════════════
//  NOTIFICATION ROUTER  (معالجة النقر على الإشعار)
// ═══════════════════════════════════════════════════════════════
class NotificationRouter {
  static final _navigatorKey = GlobalKey<NavigatorState>();
  static GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  static void route(String payload) {
    if (payload.isEmpty) return;
    final parts = payload.split(':');
    final type = parts.isNotEmpty ? parts[0] : '';

    final ctx = _navigatorKey.currentContext;
    if (ctx == null) return;

    switch (type) {
      case 'prayer':
      case 'wakeup':
        // انتقل لشاشة المحاسبة
        Navigator.pushNamed(ctx, Routes.checklist);
        break;
      case 'muhasaba':
        Navigator.pushNamed(ctx, Routes.checklist);
        break;
      case 'adhkar':
        // انتقل لشاشة الأذكار
        Navigator.pushNamed(ctx, Routes.adhkar);
        break;
      case 'achievement':
        Navigator.pushNamed(ctx, Routes.statistics);
        break;
    }
  }
}

// ═══════════════════════════════════════════════════════════════
//  PRAYER TIMES PROVIDER (Riverpod)
// ═══════════════════════════════════════════════════════════════
final prayerTimesProvider = FutureProvider<List<PrayerTimeInfo>>((ref) async {
  final settings = ref.watch(settingsDaoProvider);
  final madhab = await settings.get('madhab') ?? 'shafi';
  final method = await settings.get('calcMethod') ?? 'MWL';

  // جرّب الموقع المحفوظ أولاً
  final savedLat = await settings.get('latitude');
  final savedLng = await settings.get('longitude');

  double lat, lng;
  if (savedLat != null && savedLng != null) {
    lat = double.tryParse(savedLat) ?? 36.7;
    lng = double.tryParse(savedLng) ?? 3.0;
  } else {
    final pos = await PrayerTimesService.getLocation();
    lat = pos?.latitude ?? 36.7; // الجزائر العاصمة default
    lng = pos?.longitude ?? 3.0;
    if (pos != null) {
      await settings.set('latitude', lat.toString());
      await settings.set('longitude', lng.toString());
    }
  }

  return PrayerTimesService.calculate(
    latitude: lat,
    longitude: lng,
    madhab: madhab,
    method: method,
  );
});

final nextPrayerProvider = Provider<AsyncValue<PrayerTimeInfo?>>((ref) {
  return ref
      .watch(prayerTimesProvider)
      .whenData((prayers) => PrayerTimesService.nextPrayer(prayers));
});

// ═══════════════════════════════════════════════════════════════
//  NOTIFICATIONS MANAGER  (جدولة شاملة)
// ═══════════════════════════════════════════════════════════════
class NotificationsManager {
  static Future<void> scheduleAll(WidgetRef ref) async {
    final granted = await NotificationsService.requestPermissions();
    if (!granted) return;

    final settings = ref.read(settingsDaoProvider);
    final prayerReminder = await settings.getBool(
      'prayerReminder',
      defaultVal: true,
    );
    final muhasabaReminder = await settings.getBool(
      'eveningMuhasabaReminder',
      defaultVal: true,
    );
    final morningAdhkarOn = await settings.getBool(
      'morningAdhkarReminder',
      defaultVal: true,
    );
    final eveningAdhkarOn = await settings.getBool(
      'eveningAdhkarReminder',
      defaultVal: true,
    );
    final wakeUpFajr = await settings.getBool(
      'wakeUpBeforeFajr',
      defaultVal: false,
    );

    // ── أوقات الصلاة ──
    if (prayerReminder) {
      final prayers = await ref.read(prayerTimesProvider.future);
      await NotificationsService.schedulePrayerNotifications(
        prayers: prayers,
        wakeUpBeforeFajr: wakeUpFajr,
      );
    }

    // ── المحاسبة المسائية ──
    if (muhasabaReminder) {
      final timeStr = await settings.get('eveningReminderTime') ?? '21:00';
      final parts = timeStr.split(':');
      final time = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
      await NotificationsService.scheduleEveningMuhasaba(time: time);
    }

    // ── الأذكار ──
    if (morningAdhkarOn || eveningAdhkarOn) {
      await NotificationsService.scheduleAdhkarReminders(
        morningTime: const TimeOfDay(hour: 6, minute: 30),
        eveningTime: const TimeOfDay(hour: 17, minute: 0),
      );
    }
  }

  // إعادة الجدولة عند تغيير الإعدادات
  static Future<void> reschedule(WidgetRef ref) async {
    await NotificationsService.cancelAll();
    await scheduleAll(ref);
  }
}
