import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart' as ow;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adhan/adhan.dart' as adhan;
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:sound_mode/sound_mode.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';

import '../utils/timezone_resolver.dart';
import '../providers/adhkar_providers.dart';
import '../../features/duas/data/duas_data.dart';
import 'notifications_service.dart';
import 'package:takwa/l10n/app_localizations.dart';

// This background isolate (spawned by flutter_foreground_task) doesn't share
// the main isolate's Riverpod/locale state, so chrome strings below use a
// fixed-locale lookup rather than trying to follow the live app locale.
final AppLocalizations _l10n = lookupAppLocalizations(const Locale('ar'));

// ─────────────────────────────────────────
//  SHARED PREFS KEYS
// ─────────────────────────────────────────
const _kTriggeredPrayersKey = 'overlay_triggered_prayers';
const _kTriggeredPrayersDateKey = 'overlay_triggered_prayers_date';
const _kLatKey = 'latitude';
const _kLngKey = 'longitude';
const _kMadhabKey = 'madhab';
const _kCalcMethodKey = 'calc_method';
const _kCityNameKey = 'cityName';
const _kLastPopupMsKey = 'last_adhkar_popup_ms';
const _kLastAdhkarNotifMsKey = 'last_adhkar_notif_ms';
const _kLastDuaNotifMsKey = 'last_dua_notif_ms';
const _kOverlayEnabledKey = 'overlay_popups_enabled';
const _kAdhanSoundEnabledKey = 'adhan_sound_enabled';
const _kPreAdhanNotifEnabledKey = 'pre_adhan_notif_enabled';
const _kPopupIntervalMinsKey = 'popup_interval_minutes';
const _kAdhanScreenTriggeredKey = 'adhan_screen_triggered';
const _kSilentModeEnabledKey = 'silent_mode_enabled';
const _kSilentDurationMinsKey = 'silent_duration_mins';
const _kAutoSilentAfterAdhanKey = 'auto_silent_after_adhan';
const _kSilentModeVibrationKey = 'silent_vibration_enabled';

// ─────────────────────────────────────────
//  TIMINGS
// ─────────────────────────────────────────
/// كل 24 دقيقة = 60 مرة يومياً تقريباً
const _kDefaultPopupIntervalMins = 24;
const _kAdhkarNotifIntervalMins = 15;
const _kDuaNotifOffsetMins = 7;

/// نافذة اكتشاف وقت الصلاة: ±90 ثانية
const _kPrayerWindowSecs = 90;

/// حجب إعادة الأذان لنفس الصلاة لمدة 30 دقيقة
const _kAdhanCooldownMins = 30;

/// مدة عرض الـ overlay قبل إغلاقه تلقائياً (ثانية)
const _kOverlayAutoCloseSecs = 20;

// ─────────────────────────────────────────
//  PRAYER INFO MODEL
// ─────────────────────────────────────────
class _PrayerInfo {
  final String name;
  final String nameAr;
  final String emoji;
  final DateTime time;
  const _PrayerInfo(this.name, this.nameAr, this.emoji, this.time);
}

class OverlayBackgroundService {
  static const _channelId = 'takkwa_background_overlay';
  static const _channelName = 'Takkwa Overlay Background';

  static void init() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: _channelId,
        channelName: _channelName,
        channelDescription: _l10n.overlayServiceChannelDesc,
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        enableVibration: false,
        playSound: false,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(1000), // كل ثانية
        autoRunOnBoot: true,
        allowWifiLock: true,
      ),
    );
  }

  static Future<void> start() async {
    if (await FlutterForegroundTask.isRunningService) return;
    final perm = await FlutterForegroundTask.checkNotificationPermission();
    if (perm != NotificationPermission.granted) return;

    final prefs = await SharedPreferences.getInstance();
    final cityName =
        prefs.getString(_kCityNameKey) ?? _l10n.overlayServiceDefaultCity;

    await FlutterForegroundTask.startService(
      notificationTitle: '$cityName | ${_l10n.appName} 🌙',
      notificationText: _l10n.overlayServiceLoadingPrayerTimes,
      notificationButtons: [
        NotificationButton(
          id: 'open_app',
          text: _l10n.overlayServiceOpenAppButton,
        ),
        NotificationButton(
          id: 'update_location',
          text: _l10n.overlayServiceUpdateLocationButton,
        ),
      ],
      callback: startCallback,
    );
  }

  static Future<void> stop() async {
    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.stopService();
    }
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
    } catch (_) {
      return false;
    }
  }

  /// تحديث إعدادات الـ overlay من التطبيق الرئيسي
  static void updateSettings({
    bool? overlayEnabled,
    bool? adhanSoundEnabled,
    int? popupIntervalMins,
  }) {
    final Map<String, dynamic> data = {};
    if (overlayEnabled != null) data['overlay_popups_enabled'] = overlayEnabled;
    if (adhanSoundEnabled != null) {
      data['adhan_sound_enabled'] = adhanSoundEnabled;
    }
    if (popupIntervalMins != null) {
      data['popup_interval_minutes'] = popupIntervalMins;
    }

    if (data.isNotEmpty) FlutterForegroundTask.sendDataToTask(data);
  }
}

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(_OverlayTaskHandler());
}

class _OverlayTaskHandler extends TaskHandler {
  List<_PrayerInfo> _todayPrayers = [];
  String _lastPrayerDate = '';

  // إعدادات قابلة للتحديث ديناميكياً
  bool _overlayEnabled = true;
  bool _adhanSoundEnabled = true;
  int _popupIntervalMins = _kDefaultPopupIntervalMins;
  bool _silentModeEnabled = false;
  int _silentDurationMins = 20;
  double _adhanVolumeLevel = 1.0;

  final _random = math.Random();

  // ──────────────────────────────────────
  //  LIFECYCLE
  // ──────────────────────────────────────
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    await NotificationsService.initialize();
    await _loadSettings();
    await _refreshPrayerTimes();
    await _updateForegroundNotification();
  }

  @override
  void onRepeatEvent(DateTime timestamp) async {
    await _updateForegroundNotification();
    await _checkAndTriggerAdhan();
    await _checkAndApplySilentMode();
    if (_overlayEnabled) await _checkAndShowAdhkarOverlay();
    await _sendPeriodicAdhkarNotification();
    await _sendPeriodicDuaNotification();
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {}

  @override
  void onReceiveData(Object data) {
    if (data is Map) {
      final action = data['action'];
      if (action == 'update_location') _handleLocationUpdate();
      if (data.containsKey('overlay_popups_enabled')) {
        _overlayEnabled = data['overlay_popups_enabled'] as bool;
      }
      if (data.containsKey('adhan_sound_enabled')) {
        _adhanSoundEnabled = data['adhan_sound_enabled'] as bool;
      }
      if (data.containsKey('adhan_volume_level')) {
        _adhanVolumeLevel = data['adhan_volume_level'] as double;
      }
      if (data.containsKey('popup_interval_minutes')) {
        _popupIntervalMins = data['popup_interval_minutes'] as int;
      }
    }
  }

  @override
  void onNotificationButtonPressed(String id) async {
    if (id == 'open_app') {
      FlutterForegroundTask.launchApp();
    } else if (id == 'update_location') {
      await FlutterForegroundTask.updateService(
        notificationTitle: _l10n.appName,
        notificationText: _l10n.overlayServiceUpdatingLocation,
      );
      await _handleLocationUpdate();
    }
  }

  @override
  void onNotificationPressed() {}

  // ──────────────────────────────────────
  //  SETTINGS LOADER
  // ──────────────────────────────────────
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _overlayEnabled = prefs.getBool(_kOverlayEnabledKey) ?? true;
    _adhanSoundEnabled = prefs.getBool(_kAdhanSoundEnabledKey) ?? true;
    _popupIntervalMins =
        prefs.getInt(_kPopupIntervalMinsKey) ?? _kDefaultPopupIntervalMins;
    _silentModeEnabled = prefs.getBool(_kSilentModeEnabledKey) ?? false;
    _silentDurationMins = prefs.getInt(_kSilentDurationMinsKey) ?? 20;
    _adhanVolumeLevel = prefs.getDouble('adhan_volume_level') ?? 1.0;
  }

  // ──────────────────────────────────────
  //  SILENT MODE WORKER
  // ──────────────────────────────────────
  Future<void> _checkAndApplySilentMode() async {
    if (!_silentModeEnabled) return;

    final now = DateTime.now();
    bool shouldBeSilent = false;

    for (final prayer in _todayPrayers) {
      final start = prayer.time;
      final end = start.add(Duration(minutes: _silentDurationMins));

      if (now.isAfter(start) && now.isBefore(end)) {
        shouldBeSilent = true;
        break;
      }
    }

    try {
      final currentMode = await SoundMode.ringerModeStatus;
      if (shouldBeSilent) {
        if (currentMode != RingerModeStatus.silent &&
            currentMode != RingerModeStatus.vibrate) {
          final prefs = await SharedPreferences.getInstance();
          final vibe = prefs.getBool(_kSilentModeVibrationKey) ?? true;
          await SoundMode.setSoundMode(
            vibe ? RingerModeStatus.vibrate : RingerModeStatus.silent,
          );
          debugPrint('🔇 Silent Mode Applied');
        }
      } else {
        // If we are NOT in a prayer window, and we applied silent mode, we should ideally revert.
        // But we don't want to force "Normal" if the user manually set it to silent.
        // A better way is to track if WE set it to silent.
        // For now, let's just make it silent during the window.
      }
    } catch (e) {
      debugPrint('❌ Error in Silent Worker: $e');
    }
  }

  // ──────────────────────────────────────
  //  FOREGROUND NOTIFICATION UPDATE
  // ──────────────────────────────────────
  Future<void> _updateForegroundNotification() async {
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    final city =
        prefs.getString(_kCityNameKey) ?? _l10n.overlayServiceDefaultCity;
    final hijri = HijriCalendar.now();
    final hStr = '${hijri.hDay} ${_hijriMonthAr(hijri.hMonth)} ${hijri.hYear}';

    if (_todayPrayers.isEmpty || _lastPrayerDate != _dateKey(now)) {
      await _refreshPrayerTimes();
    }
    if (_todayPrayers.isEmpty) return;

    final next = _nextPrayer(now);
    final countdown = _countdown(now, next.time);
    final text =
        '$countdown ${next.emoji} ${next.nameAr}  |  ${DateFormat('HH:mm').format(next.time)}';

    FlutterForegroundTask.updateService(
      notificationTitle: '$city  |  $hStr',
      notificationText: text,
      notificationButtons: [
        NotificationButton(
          id: 'open_app',
          text: _l10n.overlayServiceOpenAppButton,
        ),
        NotificationButton(
          id: 'update_location',
          text: _l10n.overlayServiceUpdateLocationButton,
        ),
      ],
    );
  }

  // ──────────────────────────────────────
  //  ADHAN TRIGGER — يُطلق شاشة الأذان تلقائياً
  // ──────────────────────────────────────
  Future<void> _checkAndTriggerAdhan() async {
    final now = DateTime.now();
    final todayKey = _dateKey(now);
    if (_lastPrayerDate != todayKey) await _refreshPrayerTimes();
    if (_todayPrayers.isEmpty) return;

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

      final diffSecs = now.difference(prayer.time).inSeconds;
      if (diffSecs >= 0 && diffSecs <= 60) {
        triggered.add(prayer.name);
        await prefs.setString(_kTriggeredPrayersKey, triggered.join(','));

        // إرسال إشعار الأذان مع الصوت
        if (_adhanSoundEnabled) {
          await _scheduleAdhanNotification(prayer);
        }

        // فتح الـ Overlay تلقائياً عند وقت الصلاة
        final hasOverlayPerm =
            await ow.FlutterOverlayWindow.isPermissionGranted();
        if (hasOverlayPerm) {
          await ow.FlutterOverlayWindow.showOverlay(
            enableDrag: true,
            overlayTitle: _l10n.overlayServicePrayerTimeOverlayTitle,
            overlayContent: _l10n.overlayServicePrayerTimeOverlayContent(
              prayer.nameAr,
            ),
            flag: ow.OverlayFlag.defaultFlag,
            alignment: ow.OverlayAlignment.center,
            visibility: ow.NotificationVisibility.visibilityPublic,
            height: ow.WindowSize.matchParent,
            width: ow.WindowSize.matchParent,
          );

          // إرسال البيانات للـ Overlay
          await Future.delayed(const Duration(milliseconds: 600));
          ow.FlutterOverlayWindow.shareData({
            'type': 'prayer',
            'prayer': prayer.nameAr,
            'emoji': prayer.emoji,
            'time': DateFormat('HH:mm').format(prayer.time),
            'volume': _adhanVolumeLevel,
            'silentMode': _silentModeEnabled,
            'silentDuration': _silentDurationMins,
          });
        }

        // إرسال أمر لفتح شاشة الأذان في التطبيق (أو تقليله حسب الإعدادات)
        FlutterForegroundTask.sendDataToMain({
          'action': 'show_adhan',
          'prayer': prayer.nameAr,
          'emoji': prayer.emoji,
          'time': DateFormat('HH:mm').format(prayer.time),
          'sound': _adhanSoundEnabled,
        });

        debugPrint('🕌 أُطلق أذان ${prayer.nameAr} مع الـ Overlay');
        return;
      }
    }
  }

  Future<void> _scheduleAdhanNotification(_PrayerInfo prayer) async {
    await NotificationsService.showNotification(
      id: prayer.name == 'fajr'
          ? NotifIds.fajr
          : prayer.name == 'dhuhr'
          ? NotifIds.dhuhr
          : prayer.name == 'asr'
          ? NotifIds.asr
          : prayer.name == 'maghrib'
          ? NotifIds.maghrib
          : NotifIds.isha,
      title: '${prayer.emoji} حان وقت ${prayer.nameAr}',
      body: 'اللهُ أكبر، اللهُ أكبر، حيَّ على الصلاة، حيَّ على الفلاح',
      payload: 'prayer:${prayer.name}',
      channel: NotifChannels.prayerSound,
    );
  }

  // ──────────────────────────────────────
  //  ADHKAR OVERLAY — كل N دقيقة
  // ──────────────────────────────────────
  Future<void> _checkAndShowAdhkarOverlay() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastMs = prefs.getInt(_kLastPopupMsKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      final intervalMs = _popupIntervalMins * 60 * 1000;

      if (now - lastMs < intervalMs) return;

      // لا تُظهر الـ overlay إذا كان وقت الصلاة قريباً (±5 دقائق)
      if (_isNearPrayerTime(5)) return;

      final hasPermission = await ow.FlutterOverlayWindow.isPermissionGranted();
      if (!hasPermission) return;
      final isActive = await ow.FlutterOverlayWindow.isActive();
      if (isActive) return;

      await prefs.setInt(_kLastPopupMsKey, now);

      // اختر نوع المحتوى بشكل متناوب: أذكار أو دعاء
      final showType = _shouldShowDua() ? 'dua' : 'adhkar';

      await ow.FlutterOverlayWindow.showOverlay(
        enableDrag: true,
        overlayTitle: showType == 'dua'
            ? _l10n.overlayServiceDuaOverlayTitle
            : _l10n.overlayServiceAdhkarOverlayTitle,
        overlayContent: showType == 'dua'
            ? _l10n.overlayServiceDuaOverlayContent
            : _l10n.overlayServiceAdhkarOverlayContent,
        flag: ow.OverlayFlag.defaultFlag,
        alignment: ow.OverlayAlignment.topCenter,
        visibility: ow.NotificationVisibility.visibilityPublic,
        positionGravity: ow.PositionGravity.none,
        height: ow.WindowSize.matchParent,
        width: ow.WindowSize.matchParent,
      );

      // أرسل البيانات بعد تهيئة الـ overlay
      await Future.delayed(const Duration(milliseconds: 600));
      ow.FlutterOverlayWindow.shareData({'type': showType});

      debugPrint('📿 Overlay opened: $showType');
    } catch (e) {
      debugPrint('OverlayService: popup error: $e');
    }
  }

  /// تناوب ذكي: دعاء 30% من الوقت، أذكار 70%
  bool _shouldShowDua() {
    final hour = DateTime.now().hour;
    // في الصباح والمساء: أذكار بشكل رئيسي
    if (hour >= 5 && hour <= 8) return false; // وقت أذكار الصباح
    if (hour >= 16 && hour <= 18) return false; // وقت أذكار المساء
    return _random.nextInt(10) < 3; // 30% دعاء
  }

  /// هل نحن قريبون من وقت صلاة؟
  bool _isNearPrayerTime(int marginMins) {
    final now = DateTime.now();
    for (final p in _todayPrayers) {
      final diff = p.time.difference(now).inMinutes.abs();
      if (diff <= marginMins) return true;
    }
    return false;
  }

  // ──────────────────────────────────────
  //  PERIODIC ADHKAR NOTIFICATION
  // ──────────────────────────────────────
  Future<void> _sendPeriodicAdhkarNotification() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastMs = prefs.getInt(_kLastAdhkarNotifMsKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      const intervalMs = _kAdhkarNotifIntervalMins * 60 * 1000;

      if (now - lastMs < intervalMs) return;

      final allAdhkar = kAdhkarData.values.expand((e) => e).toList();
      if (allAdhkar.isEmpty) return;

      // اختر أذكاراً مناسبة للوقت
      final timeBasedAdhkar = _getTimeBasedAdhkar();
      final dhikr = timeBasedAdhkar.isNotEmpty
          ? timeBasedAdhkar[_random.nextInt(timeBasedAdhkar.length)]
          : allAdhkar[_random.nextInt(allAdhkar.length)];

      final arabic = dhikr.arabic.replaceAll('\n', ' ');
      final preview = arabic.length > 100
          ? '${arabic.substring(0, 100)}...'
          : arabic;
      final fadl = dhikr.fadl != null ? '\n✨ ${dhikr.fadl}' : '';

      await NotificationsService.showNotification(
        id: NotifIds.morningAdhkar,
        title: '📿 ${_adhkarCategoryTitle(dhikr.category)}',
        body: preview + fadl,
        payload: 'adhkar:${dhikr.id}',
        channel: NotifChannels.adhkar,
      );

      await prefs.setInt(_kLastAdhkarNotifMsKey, now);
    } catch (e) {
      debugPrint('OverlayService: Adhkar notif error: $e');
    }
  }

  List<DhikrItem> _getTimeBasedAdhkar() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour <= 9) {
      return kAdhkarData[AdhkarCategory.morning] ?? [];
    } else if (hour >= 16 && hour <= 19) {
      return kAdhkarData[AdhkarCategory.evening] ?? [];
    } else if (hour >= 21 || hour <= 4) {
      return kAdhkarData[AdhkarCategory.sleep] ?? [];
    }
    return kAdhkarData[AdhkarCategory.misc] ?? [];
  }

  String _adhkarCategoryTitle(AdhkarCategory cat) => switch (cat) {
    AdhkarCategory.morning => '🌅 أذكار الصباح',
    AdhkarCategory.evening => '🌆 أذكار المساء',
    AdhkarCategory.afterPrayer => '🕌 بعد الصلاة',
    AdhkarCategory.sleep => '🌙 أذكار النوم',
    AdhkarCategory.misc => '📿 متنوعة',
    AdhkarCategory.wakingUp => '📿 الاستيقاظ من النوم',
    AdhkarCategory.food => '📿 الطعام',
  };

  // ──────────────────────────────────────
  //  PERIODIC DUA NOTIFICATION
  // ──────────────────────────────────────
  Future<void> _sendPeriodicDuaNotification() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastDuaMs = prefs.getInt(_kLastDuaNotifMsKey) ?? 0;
      final lastAdhkarMs = prefs.getInt(_kLastAdhkarNotifMsKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      const intervalMs = _kAdhkarNotifIntervalMins * 60 * 1000;
      const offsetMs = _kDuaNotifOffsetMins * 60 * 1000;

      if (now - lastDuaMs < intervalMs) return;
      if (now - lastAdhkarMs < offsetMs) return; // انتظر بعد الأذكار

      final allDuas = kDuasData.values.expand((e) => e).toList();
      if (allDuas.isEmpty) return;

      // اختر دعاءً مناسباً للوقت
      final timeBasedDuas = _getTimeBasedDuas();
      final dua = timeBasedDuas.isNotEmpty
          ? timeBasedDuas[_random.nextInt(timeBasedDuas.length)]
          : allDuas[_random.nextInt(allDuas.length)];

      final arabic = dua.arabic;
      final meaning = '\n💫 ${dua.meaning}';
      final source = dua.source.isNotEmpty ? '\n— ${dua.source}' : '';

      await NotificationsService.showNotification(
        id: NotifIds.randomDua,
        title: '${dua.emoji} دعاء من تقوى',
        body: arabic + meaning + source,
        payload: 'dua:${dua.id}',
        channel: NotifChannels.duas,
      );

      await prefs.setInt(_kLastDuaNotifMsKey, now);
    } catch (e) {
      debugPrint('OverlayService: Dua notif error: $e');
    }
  }

  List<DuaItem> _getTimeBasedDuas() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour <= 9) {
      return kDuasData[DuaCategory.morning] ?? [];
    } else if (hour >= 7 && hour <= 22) {
      // نهاراً: كل أنواع الأدعية
      final all = <DuaItem>[
        ...kDuasData[DuaCategory.guidance] ?? [],
        ...kDuasData[DuaCategory.rizq] ?? [],
        ...kDuasData[DuaCategory.health] ?? [],
        ...kDuasData[DuaCategory.general] ?? [],
      ];
      return all;
    } else {
      return <DuaItem>[
        ...kDuasData[DuaCategory.forgiveness] ?? [],
        ...kDuasData[DuaCategory.general] ?? [],
      ];
    }
  }

  // ──────────────────────────────────────
  //  PRAYER TIMES
  // ──────────────────────────────────────
  _PrayerInfo _nextPrayer(DateTime now) {
    for (final p in _todayPrayers) {
      if (p.time.isAfter(now)) return p;
    }
    // كل الصلوات انتهت → فجر الغد
    final tomorrow = now.add(const Duration(days: 1));
    return _PrayerInfo(
      'fajr',
      'الفجر',
      '🌅',
      DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 5, 0),
    );
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
      final params = _buildAdhanParams(method, madhab);
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
    }
  }

  adhan.CalculationParameters _buildAdhanParams(String method, String madhab) {
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
      case 'MWL':
      default:
        p = adhan.CalculationMethod.muslim_world_league.getParameters();
        p.fajrAngle = 18.0;
        p.ishaAngle = 17.0;
    }
    p.madhab = (madhab == 'hanafi') ? adhan.Madhab.hanafi : adhan.Madhab.shafi;
    return p;
  }

  // ──────────────────────────────────────
  //  LOCATION UPDATE
  // ──────────────────────────────────────
  Future<void> _handleLocationUpdate() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );

      final lat = pos.latitude;
      final lng = pos.longitude;
      final tzName = TimezoneResolver.resolveFromCoordinates(lat, lng);

      String cityName = _l10n.overlayServiceUnknownCity;
      try {
        final placemarks = await placemarkFromCoordinates(lat, lng);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          cityName =
              '${p.locality ?? p.subAdministrativeArea ?? ''}'
              '${p.country != null ? ", ${p.country}" : ""}';
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
      await _updateForegroundNotification();
    } catch (e) {
      debugPrint('OverlayService: Location update failed: $e');
    }
  }

  // ──────────────────────────────────────
  //  HELPERS
  // ──────────────────────────────────────
  String _countdown(DateTime now, DateTime target) {
    Duration diff = target.difference(now);
    if (diff.isNegative) diff = const Duration(hours: 24) + diff;
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    final s = diff.inSeconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _dateKey(DateTime dt) => '${dt.year}-${dt.month}-${dt.day}';

  String _hijriMonthAr(int m) => const [
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
  ][m - 1];
}
