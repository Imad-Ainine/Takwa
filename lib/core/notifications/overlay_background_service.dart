// ═══════════════════════════════════════════════════════════════
//  lib/core/notifications/overlay_background_service.dart
//  تقوى — Overlay Background Service
//  • Shows adhan overlay automatically at prayer times
//  • Shows 60 random adhkar/dua per day (every ~24 min)
// ═══════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart' as ow;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adhan/adhan.dart' as adhan;
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../utils/timezone_resolver.dart';

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
const _kTriggeredPrayersKey =
    'overlay_triggered_prayers'; // "fajr,dhuhr,..." for today
const _kTriggeredPrayersDateKey = 'overlay_triggered_prayers_date';
const _kLatKey = 'latitude';
const _kLngKey = 'longitude';
const _kMadhabKey = 'madhab';
const _kCalcMethodKey = 'calcMethod';
const _kCityNameKey = 'cityName';
const _kLastPopupMsKey = 'last_adhkar_popup_ms';

// ─────────────────────────────────────────
//  PRAYER INFO  (lightweight, no adhan pkg types exposed)
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
        // Every 1 second to catch prayer times and update countdown precisely
        eventAction: ForegroundTaskEventAction.repeat(_kRepeatIntervalMs),
        autoRunOnBoot: true,
        allowWifiLock: true,
      ),
    );
  }

  static Future<void> start() async {
    if (await FlutterForegroundTask.isRunningService) {
      return;
    }

    // Only start if permissions are already granted (don't request here)
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
      // 1. Notification Permission
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

      // 2. Overlay Permission
      final isOverlayGranted =
          await ow.FlutterOverlayWindow.isPermissionGranted().timeout(
            const Duration(seconds: 5),
            onTimeout: () => false,
          );
      if (!isOverlayGranted) {
        await ow.FlutterOverlayWindow.requestPermission().timeout(
          const Duration(
            seconds: 30,
          ), // Overlay often opens settings, give it more time
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
    await _refreshPrayerTimes();
    await _updateNotificationWithPrayerInfo();
  }

  @override
  void onRepeatEvent(DateTime timestamp) async {
    // 1. تحديث إشعار الخدمة
    await _updateNotificationWithPrayerInfo();

    // 2. التحقق من وقت الأذان
    await _checkAndShowAdhan();

    // 3. عرض popup الأذكار/الأدعية كل 24 دقيقة
    await _checkAndShowAdhkarPopup();
  }

  /// يطلق Overlay popup اذا مضى اكثر من 24 دقيقة منذ آخر popup.
  Future<void> _checkAndShowAdhkarPopup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastMs = prefs.getInt(_kLastPopupMsKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;

      if (now - lastMs < _kAdhkarPopupInterval.inMilliseconds) return;

      // تحقق من صلاحية overlay permission
      final hasPermission = await ow.FlutterOverlayWindow.isPermissionGranted();
      if (!hasPermission) return;

      // لا تظهر popup اذا كان الـ overlay نشطاً
      final isActive = await ow.FlutterOverlayWindow.isActive();
      if (isActive) return;

      // حفظ وقت آخر popup
      await prefs.setInt(_kLastPopupMsKey, now);

      // اظهار الـ overlay (يستدعي UnifiedOverlayWindow عبر overlayMain)
      await ow.FlutterOverlayWindow.showOverlay(
        enableDrag: true,
        overlayTitle: 'أذكار تقوى',
        overlayContent: 'ذكر/دعاء متجدد',
        flag: ow.OverlayFlag.defaultFlag,
        alignment: ow.OverlayAlignment.center,
        visibility: ow.NotificationVisibility.visibilityPublic,
        positionGravity: ow.PositionGravity.none,
        height: 420,
        width: 320,
      );

      // نرسل نوع البيانات للمصفي (هنا نتركها عامة لتشمل الإثنين أو نحدد أذكار)
      Future.delayed(const Duration(milliseconds: 500), () {
        ow.FlutterOverlayWindow.shareData({'type': 'all'});
      });
    } catch (e) {
      print('OverlayService: popup error: $e');
    }
  }

  Future<void> _updateNotificationWithPrayerInfo() async {
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();

    // 1. Get Location/City Info
    final cityName = prefs.getString(_kCityNameKey) ?? 'الجزائر';

    // 2. Get Hijri Date
    final hijri = HijriCalendar.now();
    final hijriStr =
        '${hijri.hYear} ${_getHijriMonthNameAr(hijri.hMonth)} ${hijri.hDay.toString().padLeft(2, '0')}';

    // 3. Get Prayer Info
    if (_todayPrayers.isEmpty) await _refreshPrayerTimes();
    if (_todayPrayers.isEmpty) return;

    final nextPrayer = _getNextPrayer(now);
    final countdown = _getCountdown(now, nextPrayer.time);

    final title = '$cityName | $hijriStr';
    final text =
        '$countdown - ${nextPrayer.nameAr}، ${DateFormat('HH:mm').format(nextPrayer.time)}';

    FlutterForegroundTask.updateService(
      notificationTitle: title,
      notificationText: text,
      notificationButtons: [
        const NotificationButton(id: 'open_app', text: 'افتح تقوى'),
        const NotificationButton(id: 'update_location', text: 'تحديث الموقع'),
      ],
    );
  }

  _PrayerInfo _getNextPrayer(DateTime now) {
    for (final p in _todayPrayers) {
      if (p.time.isAfter(now)) return p;
    }
    // If all prayers passed, return first prayer of tomorrow (Fajr)
    return _todayPrayers
        .first; // Simplified: actually should be tomorrow's Fajr
  }

  String _getCountdown(DateTime now, DateTime prayerTime) {
    Duration diff = prayerTime.difference(now);
    if (diff.isNegative) {
      // It's for tomorrow
      diff = const Duration(hours: 24) + diff;
    }
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

  @override
  Future<void> onDestroy(DateTime timestamp) async {}

  @override
  void onReceiveData(Object data) {}

  @override
  void onNotificationButtonPressed(String id) async {
    if (id == 'open_app') {
      // 1. جلب شريط الإشعارات للأعلى (إغلاقه)
      FlutterForegroundTask.minimizeApp(); // سيعيد التطبيق للخلفية ويغلق الدرج في بعض الحالات
      // أو الحل الأفضل لإغلاق اللوحة مباشرة:
      FlutterForegroundTask.launchApp(); // جلب التطبيق للواجهة يغلق اللوحة تلقائياً في معظم الأنظمة
    } else if (id == 'update_location') {
      // 1. Display Loading State
      await FlutterForegroundTask.updateService(
        notificationTitle: 'تقوى',
        notificationText: '🔄 جاري تحديث الموقع حالياً...',
      );

      // 2. Execute the logic
      await _handleLocationUpdate();
    }
  }

  Future<void> _handleLocationUpdate() async {
    try {
      // 1. Get position
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );

      final lat = pos.latitude;
      final lng = pos.longitude;

      // 2. Resolve Timezone
      final tzName = TimezoneResolver.resolveFromCoordinates(lat, lng);

      // 3. Resolve City Name
      String cityName = 'غير محدد';
      try {
        final placemarks = await placemarkFromCoordinates(lat, lng);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          cityName =
              '${p.locality ?? p.subAdministrativeArea ?? ''}, ${p.country ?? ''}';
        }
      } catch (_) {}

      // 4. Save to SharedPreferences (Source of truth for this isolate)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kLatKey, lat.toString());
      await prefs.setString(_kLngKey, lng.toString());
      await prefs.setString('timezone', tzName);
      await prefs.setString(_kCityNameKey, cityName);

      // 5. Notify main isolate to sync if it's alive
      FlutterForegroundTask.sendDataToMain({
        'action': 'location_updated',
        'latitude': lat,
        'longitude': lng,
        'cityName': cityName,
      });

      // 6. Refresh local state and UI
      await _refreshPrayerTimes();
      await _updateNotificationWithPrayerInfo();
    } catch (e) {
      print('OverlayService: Background location update failed: $e');
      await _updateNotificationWithPrayerInfo();
    }
  }

  @override
  void onNotificationPressed() {}

  // ── Prayer Time Detection ──────────────

  /// Returns true if an adhan overlay was shown.
  Future<bool> _checkAndShowAdhan() async {
    final now = DateTime.now();

    // Refresh prayer times if the date has changed
    final todayKey = _dateKey(now);
    if (_lastPrayerDate != todayKey) {
      await _refreshPrayerTimes();
    }

    if (_todayPrayers.isEmpty) return false;

    final prefs = await SharedPreferences.getInstance();

    // Reset triggered set if it's a new day
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
        // Mark as triggered immediately to prevent duplicates
        triggered.add(prayer.name);
        await prefs.setString(_kTriggeredPrayersKey, triggered.join(','));

        // ── Primary: wake the main app isolate → shows full AdhanOverlayScreen ──
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

  /// Computes prayer times for today from SharedPreferences settings.
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
      print('OverlayService: Failed to compute prayer times: $e');
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

  // ── Helpers ────────────────────────────

  String _dateKey(DateTime dt) => '${dt.year}-${dt.month}-${dt.day}';
}
