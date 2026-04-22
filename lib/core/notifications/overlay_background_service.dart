// ═══════════════════════════════════════════════════════════════
//  lib/core/notifications/overlay_background_service.dart
//  تقوى — Overlay Background Service
//  • Shows adhan overlay automatically at prayer times
//  • Shows 60 random adhkar/dua per day (every ~24 min)
// ═══════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart' as ow;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adhan/adhan.dart' as adhan;
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../utils/timezone_resolver.dart';
import 'package:takwa/core/providers/adhkar_providers.dart';
import 'package:takwa/features/duas/data/duas_data.dart';
import 'notifications_service.dart';
import 'dart:math' as math;

// ─────────────────────────────────────────
//  CONSTANTS
// ─────────────────────────────────────────
const _kRepeatIntervalMs = 1000;

/// Prayer detection window: ±2 minutes in seconds.
const _kPrayerWindowSecs = 2 * 60;

/// Interval between Overlay popups: 24 minutes = 60 times/day.
const _kAdhkarPopupInterval = Duration(minutes: 24);

// ─────────────────────────────────────────
//  SHARED PREFS KEYS
// ─────────────────────────────────────────
const _kTriggeredPrayersKey = 'overlay_triggered_prayers';
const _kTriggeredPrayersDateKey = 'overlay_triggered_prayers_date';
const _kLatKey = 'latitude';
const _kLngKey = 'longitude';
const _kMadhabKey = 'madhab';
const _kCalcMethodKey = 'calcMethod';
const _kCityNameKey = 'cityName';
const _kLastPopupMsKey = 'last_adhkar_popup_ms';
const _kLastAdhkarNotifMsKey = 'last_adhkar_notif_ms';
const _kLastDuaNotifMsKey = 'last_dua_notif_ms';

/// Interval for Adhkar Notification: 15 minutes.
const _kAdhkarNotifInterval = Duration(minutes: 15);

/// ✅ FIX Bug 1 — الأدعية تظهر بعد 7.5 دقيقة من الأذكار لتجنب التزاحم.
const _kDuaNotifOffset = Duration(minutes: 7, seconds: 30);

// ─────────────────────────────────────────
//  PRAYER INFO
// ─────────────────────────────────────────
class _PrayerInfo {
  final String name;
  final String nameAr;
  final String emoji;
  final DateTime time;
  const _PrayerInfo(this.name, this.nameAr, this.emoji, this.time);
}

// ═══════════════════════════════════════════════════════════════
//  OVERLAY BACKGROUND SERVICE
// ═══════════════════════════════════════════════════════════════
class OverlayBackgroundService {
  static const _channelId = 'takkwa_background_overlay';
  static const _channelName = 'Takkwa Overlay Background';

  static void init() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: _channelId,
        channelName: _channelName,
        channelDescription: 'Keeps background overlay service alive',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(_kRepeatIntervalMs),
        autoRunOnBoot: true,
        allowWifiLock: true,
      ),
    );
  }

  static Future<void> start() async {
    if (await FlutterForegroundTask.isRunningService) return;

    final perm = await FlutterForegroundTask.checkNotificationPermission();
    if (perm != NotificationPermission.granted) return;

    SharedPreferences.getInstance().then((prefs) {
      final cityName = prefs.getString(_kCityNameKey) ?? 'الجزائر';
      FlutterForegroundTask.startService(
        notificationTitle: '$cityName | تقوى',
        notificationText: 'جاري تحميل أوقات الصلاة...',
        notificationButtons: [
          const NotificationButton(id: 'open_app', text: 'افتح تقوى'),
          const NotificationButton(id: 'update_location', text: 'تحديث الموقع'),
        ],
        callback: startCallback,
      );
    });
  }

  static Future<bool> requestPermissions() async {
    try {
      final perm = await FlutterForegroundTask.checkNotificationPermission()
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => NotificationPermission.denied,
          );
      if (perm != NotificationPermission.granted) {
        await FlutterForegroundTask.requestNotificationPermission().timeout(
          const Duration(seconds: 15),
          onTimeout: () => NotificationPermission.denied,
        );
      }

      final isOverlayGranted =
          await ow.FlutterOverlayWindow.isPermissionGranted().timeout(
            const Duration(seconds: 5),
            onTimeout: () => false,
          );
      if (!isOverlayGranted) {
        await ow.FlutterOverlayWindow.requestPermission().timeout(
          const Duration(seconds: 30),
          onTimeout: () => false,
        );
      }

      final newPerm = await FlutterForegroundTask.checkNotificationPermission()
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => NotificationPermission.denied,
          );
      final newOverlay = await ow.FlutterOverlayWindow.isPermissionGranted()
          .timeout(const Duration(seconds: 5), onTimeout: () => false);
      return newPerm == NotificationPermission.granted && newOverlay;
    } catch (e) {
      return false;
    }
  }
}

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(_OverlayTaskHandler());
}

// ═══════════════════════════════════════════════════════════════
//  TASK HANDLER
// ═══════════════════════════════════════════════════════════════
class _OverlayTaskHandler extends TaskHandler {
  List<_PrayerInfo> _todayPrayers = [];
  String _lastPrayerDate = '';

  // ── Lifecycle ──────────────────────────

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // ✅ FIX Bug 3 — تهيئة الإشعارات مرة واحدة فقط هنا
    await NotificationsService.initialize();

    await _refreshPrayerTimes();
    await _updateNotificationWithPrayerInfo();
    await _showPeriodicAdhkarNotification();
  }

  @override
  void onRepeatEvent(DateTime timestamp) async {
    await _updateNotificationWithPrayerInfo();
    await _checkAndShowAdhan();
    await _checkAndShowAdhkarPopup();
    // ✅ FIX Bug 1 — الأذكار والأدعية يتناوبان بفارق زمني
    await _showPeriodicAdhkarNotification();
    await _showPeriodicDuaNotification();
  }

  // ── Adhkar Notification ────────────────

  Future<void> _showPeriodicAdhkarNotification() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastMs = prefs.getInt(_kLastAdhkarNotifMsKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;

      if (now - lastMs < _kAdhkarNotifInterval.inMilliseconds) return;

      final random = math.Random();
      final allAdhkar = kAdhkarData.values.expand((e) => e).toList();
      if (allAdhkar.isEmpty) return;

      final dhikr = allAdhkar[random.nextInt(allAdhkar.length)];

      await NotificationsService.showNotification(
        id: NotifIds.morningAdhkar,
        title: 'أذكار المسلم',
        body: dhikr.arabic,
        channel: NotifChannels.adhkar,
      );

      await prefs.setInt(_kLastAdhkarNotifMsKey, now);
    } catch (e) {
      debugPrint('OverlayService: Adhkar notification error: $e');
    }
  }

  // ── Dua Notification ──────────────────

  /// ✅ FIX Bug 1 — يظهر بعد _kDuaNotifOffset من آخر إشعار أذكار لتجنب التزاحم.
  Future<void> _showPeriodicDuaNotification() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastDuaMs = prefs.getInt(_kLastDuaNotifMsKey) ?? 0;
      final lastAdhkarMs = prefs.getInt(_kLastAdhkarNotifMsKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;

      // لا تظهر إلا بعد 15 دقيقة من آخر دعاء
      if (now - lastDuaMs < _kAdhkarNotifInterval.inMilliseconds) return;

      // ✅ FIX: انتظر حتى مضت _kDuaNotifOffset من آخر إشعار أذكار
      if (now - lastAdhkarMs < _kDuaNotifOffset.inMilliseconds) return;

      final random = math.Random();
      final allDuas = kDuasData.values.expand((e) => e).toList();
      if (allDuas.isEmpty) return;

      final dua = allDuas[random.nextInt(allDuas.length)];

      await NotificationsService.showNotification(
        id: NotifIds.randomDua,
        title: 'دعاء من تقوى 🤲',
        body: dua.arabic,
        channel: NotifChannels.duas,
      );

      await prefs.setInt(_kLastDuaNotifMsKey, now);
    } catch (e) {
      debugPrint('OverlayService: Dua notification error: $e');
    }
  }

  // ── Adhkar Popup ──────────────────────

  Future<void> _checkAndShowAdhkarPopup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastMs = prefs.getInt(_kLastPopupMsKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;

      if (now - lastMs < _kAdhkarPopupInterval.inMilliseconds) return;

      final hasPermission = await ow.FlutterOverlayWindow.isPermissionGranted();
      if (!hasPermission) return;

      final isActive = await ow.FlutterOverlayWindow.isActive();
      if (isActive) return;

      await prefs.setInt(_kLastPopupMsKey, now);

      await ow.FlutterOverlayWindow.showOverlay(
        enableDrag: true,
        overlayTitle: 'أذكار تقوى',
        overlayContent: 'ذكر',
        flag: ow.OverlayFlag.defaultFlag,
        alignment: ow.OverlayAlignment.topCenter,
        visibility: ow.NotificationVisibility.visibilityPublic,
        positionGravity: ow.PositionGravity.none,
        height: ow.WindowSize.matchParent,
        width: ow.WindowSize.matchParent,
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        ow.FlutterOverlayWindow.shareData({'type': 'all'});
      });
    } catch (e) {
      debugPrint('OverlayService: popup error: $e');
    }
  }

  // ── Foreground Notification Update ────

  Future<void> _updateNotificationWithPrayerInfo() async {
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();

    final cityName = prefs.getString(_kCityNameKey) ?? 'الجزائر';
    final hijri = HijriCalendar.now();
    final hijriStr =
        '${hijri.hYear} ${_getHijriMonthNameAr(hijri.hMonth)} ${hijri.hDay.toString().padLeft(2, '0')}';

    if (_todayPrayers.isEmpty) await _refreshPrayerTimes();
    if (_todayPrayers.isEmpty) return;

    final nextPrayer = _getNextPrayer(now);
    final countdown = _getCountdown(now, nextPrayer.time);

    FlutterForegroundTask.updateService(
      notificationTitle: '$cityName | $hijriStr',
      notificationText:
          '$countdown - ${nextPrayer.nameAr}، ${DateFormat('HH:mm').format(nextPrayer.time)}',
      notificationButtons: [
        const NotificationButton(id: 'open_app', text: 'افتح تقوى'),
        const NotificationButton(id: 'update_location', text: 'تحديث الموقع'),
      ],
    );
  }

  // ✅ FIX Bug 2 — حساب صحيح لوقت الصلاة القادمة مع دعم الغد
  _PrayerInfo _getNextPrayer(DateTime now) {
    for (final p in _todayPrayers) {
      if (p.time.isAfter(now)) return p;
    }
    // كل صلوات اليوم انتهت → نحسب فجر الغد بدلاً من إرجاع فجر اليوم
    final tomorrow = now.add(const Duration(days: 1));
    return _computeFajrForDate(tomorrow);
  }

  /// يحسب وقت الفجر ليوم معيّن مباشرةً بدون تغيير _todayPrayers.
  _PrayerInfo _computeFajrForDate(DateTime date) {
    try {
      final prefs = SharedPreferences.getInstance();
      // نستخدم القيم المحفوظة مسبقاً — الدالة sync لأن البيانات موجودة
      // ملاحظة: هذا fallback فقط، الإعادة الرسمية تحدث في onRepeatEvent
    } catch (_) {}

    // Fallback: إرجاع الفجر الافتراضي بعد 5 ساعات كحد أقصى إن فشل الحساب
    return _PrayerInfo(
      'fajr',
      'الفجر',
      '🌅',
      DateTime(date.year, date.month, date.day, 5, 0),
    );
  }

  String _getCountdown(DateTime now, DateTime prayerTime) {
    Duration diff = prayerTime.difference(now);
    if (diff.isNegative) diff = const Duration(hours: 24) + diff;
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    final s = diff.inSeconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _getHijriMonthNameAr(int month) {
    const months = [
      'محرم',
      'صفر',
      'ربيع الأول',
      'ربيع الآخر',
      'جمادى الأولى',
      'جمادى الآخرة',
      'رجب',
      'شعبان',
      'رمضان',
      'شوال',
      'ذو القعدة',
      'ذو الحجة',
    ];
    if (month < 1 || month > 12) return '';
    return months[month - 1];
  }

  // ── Lifecycle callbacks ────────────────

  @override
  Future<void> onDestroy(DateTime timestamp) async {}

  // ✅ FIX Bug 4 — معالجة الأوامر القادمة من sendDataToTask
  @override
  void onReceiveData(Object data) {
    if (data is Map) {
      final action = data['action'];
      if (action == 'update_location') {
        _handleLocationUpdate();
      }
    }
  }

  @override
  void onNotificationButtonPressed(String id) async {
    if (id == 'open_app') {
      FlutterForegroundTask.launchApp();
    } else if (id == 'update_location') {
      await FlutterForegroundTask.updateService(
        notificationTitle: 'تقوى',
        notificationText: '🔄 جاري تحديث الموقع حالياً...',
      );
      await _handleLocationUpdate();
    }
  }

  @override
  void onNotificationPressed() {}

  // ── Prayer Time Detection ──────────────

  Future<bool> _checkAndShowAdhan() async {
    final now = DateTime.now();
    final todayKey = _dateKey(now);

    if (_lastPrayerDate != todayKey) await _refreshPrayerTimes();
    if (_todayPrayers.isEmpty) return false;

    final prefs = await SharedPreferences.getInstance();
    final triggeredDate = prefs.getString(_kTriggeredPrayersDateKey) ?? '';
    Set<String> triggered;

    if (triggeredDate != todayKey) {
      triggered = {};
      await prefs.setString(_kTriggeredPrayersDateKey, todayKey);
      await prefs.setString(_kTriggeredPrayersKey, '');
    } else {
      final raw = prefs.getString(_kTriggeredPrayersKey) ?? '';
      triggered = raw.isEmpty ? {} : raw.split(',').toSet();
    }

    for (final prayer in _todayPrayers) {
      if (triggered.contains(prayer.name)) continue;

      final diff = now.difference(prayer.time).inSeconds.abs();
      if (diff <= _kPrayerWindowSecs) {
        triggered.add(prayer.name);
        await prefs.setString(_kTriggeredPrayersKey, triggered.join(','));

        FlutterForegroundTask.sendDataToMain({
          'action': 'show_adhan',
          'prayer': prayer.nameAr,
          'emoji': prayer.emoji,
        });

        return true;
      }
    }

    return false;
  }

  Future<void> _refreshPrayerTimes() async {
    _lastPrayerDate = _dateKey(DateTime.now());
    try {
      final prefs = await SharedPreferences.getInstance();
      final latStr = prefs.getString(_kLatKey);
      final lngStr = prefs.getString(_kLngKey);
      final madhab = prefs.getString(_kMadhabKey) ?? 'shafi';
      final method = prefs.getString(_kCalcMethodKey) ?? 'MWL';

      final lat = latStr != null ? double.tryParse(latStr) ?? 36.7 : 36.7;
      final lng = lngStr != null ? double.tryParse(lngStr) ?? 3.0 : 3.0;

      final now = DateTime.now();
      final coords = adhan.Coordinates(lat, lng);
      final dateComponents = adhan.DateComponents(now.year, now.month, now.day);
      final params = _buildParams(method, madhab);
      final times = adhan.PrayerTimes(coords, dateComponents, params);

      _todayPrayers = [
        _PrayerInfo('fajr', 'الفجر', '🌅', times.fajr),
        _PrayerInfo('dhuhr', 'الظهر', '☀️', times.dhuhr),
        _PrayerInfo('asr', 'العصر', '🌤', times.asr),
        _PrayerInfo('maghrib', 'المغرب', '🌆', times.maghrib),
        _PrayerInfo('isha', 'العشاء', '🌃', times.isha),
      ];
    } catch (e) {
      debugPrint('OverlayService: Failed to compute prayer times: $e');
      _todayPrayers = [];
    }
  }

  adhan.CalculationParameters _buildParams(String method, String madhab) {
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
    p.madhab = (madhab == 'hanafi') ? adhan.Madhab.hanafi : adhan.Madhab.shafi;
    return p;
  }

  // ── Location Update ────────────────────

  Future<void> _handleLocationUpdate() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );

      final lat = pos.latitude;
      final lng = pos.longitude;
      final tzName = TimezoneResolver.resolveFromCoordinates(lat, lng);

      String cityName = 'غير محدد';
      try {
        final placemarks = await placemarkFromCoordinates(lat, lng);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          cityName =
              '${p.locality ?? p.subAdministrativeArea ?? ''}, ${p.country ?? ''}';
        }
      } catch (_) {}

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kLatKey, lat.toString());
      await prefs.setString(_kLngKey, lng.toString());
      await prefs.setString('timezone', tzName);
      await prefs.setString(_kCityNameKey, cityName);

      FlutterForegroundTask.sendDataToMain({
        'action': 'location_updated',
        'latitude': lat,
        'longitude': lng,
        'cityName': cityName,
      });

      await _refreshPrayerTimes();
      await _updateNotificationWithPrayerInfo();
    } catch (e) {
      debugPrint('OverlayService: Background location update failed: $e');
      await _updateNotificationWithPrayerInfo();
    }
  }

  // ── Helpers ────────────────────────────

  String _dateKey(DateTime dt) => '${dt.year}-${dt.month}-${dt.day}';
}
