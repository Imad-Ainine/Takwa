// ═══════════════════════════════════════════════════════════════
//  lib/core/notifications/overlay_background_service.dart
//  تقوى — Overlay Background Service
//  • Shows adhan overlay automatically at prayer times
//  • Shows 60 random adhkar/dua per day (every ~24 min)
// ═══════════════════════════════════════════════════════════════

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adhan/adhan.dart' as adhan;

import 'package:takwa/core/providers/adhkar_providers.dart';
import 'package:takwa/features/duas/presentation/screens/duas_screen.dart';

// ─────────────────────────────────────────
//  CONSTANTS
// ─────────────────────────────────────────
/// Number of adhkar/dua overlays per day.
const _kMaxDailyOverlays = 60;

/// Interval between repeating events: 1 minute in milliseconds.
const _kRepeatIntervalMs = 1 * 60 * 1000;

/// Prayer detection window: ±2 minutes in seconds.
const _kPrayerWindowSecs = 2 * 60;

// ─────────────────────────────────────────
//  SHARED PREFS KEYS
// ─────────────────────────────────────────
const _kDailyCountKey = 'overlay_daily_count';
const _kDailyDateKey = 'overlay_daily_date';
const _kTriggeredPrayersKey =
    'overlay_triggered_prayers'; // "fajr,dhuhr,..." for today
const _kTriggeredPrayersDateKey = 'overlay_triggered_prayers_date';
const _kLastAdhkarTimeKey = 'overlay_last_adhkar_time';
const _kNextAdhkarDelayMsKey = 'overlay_next_adhkar_delay';
const _kLatKey = 'latitude';
const _kLngKey = 'longitude';
const _kMadhabKey = 'madhab';
const _kCalcMethodKey = 'calcMethod';

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
        // Every 1 minute to catch prayer times precisely
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

    await FlutterForegroundTask.startService(
      notificationTitle: 'تطبيق تقوى يعمل بالخلفية',
      notificationText: 'لعرض الأذكار والأذان بشكل تلقائي',
      callback: startCallback,
    );
  }

  static Future<bool> requestPermissions() async {
    try {
      // 1. Notification Permission
      final perm = await FlutterForegroundTask.checkNotificationPermission().timeout(
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
      final isOverlayGranted = await FlutterOverlayWindow.isPermissionGranted().timeout(
        const Duration(seconds: 5),
        onTimeout: () => false,
      );
      if (!isOverlayGranted) {
        await FlutterOverlayWindow.requestPermission().timeout(
          const Duration(seconds: 30), // Overlay often opens settings, give it more time
          onTimeout: () => false,
        );
      }

      final newPerm = await FlutterForegroundTask.checkNotificationPermission().timeout(
        const Duration(seconds: 5),
        onTimeout: () => NotificationPermission.denied,
      );
      final newOverlay = await FlutterOverlayWindow.isPermissionGranted().timeout(
        const Duration(seconds: 5),
        onTimeout: () => false,
      );
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
  final _random = Random();
  List<_PrayerInfo> _todayPrayers = [];
  String _lastPrayerDate = '';

  // ── Lifecycle ──────────────────────────

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    await _refreshPrayerTimes();
  }

  @override
  void onRepeatEvent(DateTime timestamp) async {
    // 1. Check adhan first — prayer time takes priority
    final shownAdhan = await _checkAndShowAdhan();
    if (shownAdhan) return;

    // 2. Check daily adhkar/dua counter and random delay
    final prefs = await SharedPreferences.getInstance();
    final today = _dateKey(DateTime.now());

    // Reset counter if it's a new day
    final savedDate = prefs.getString(_kDailyDateKey) ?? '';
    if (savedDate != today) {
      await prefs.setString(_kDailyDateKey, today);
      await prefs.setInt(_kDailyCountKey, 0);
      await prefs.remove(_kLastAdhkarTimeKey);
      await prefs.remove(_kNextAdhkarDelayMsKey);
    }

    final count = prefs.getInt(_kDailyCountKey) ?? 0;
    if (count >= _kMaxDailyOverlays) return; // Quota reached for today

    // Delay logic
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final lastTime = prefs.getInt(_kLastAdhkarTimeKey) ?? 0;
    // Determine the next delay if not set (between 20 and 40 minutes)
    final nextDelay =
        prefs.getInt(_kNextAdhkarDelayMsKey) ??
        ((20 + _random.nextInt(21)) * 60 * 1000);

    if (nowMs - lastTime < nextDelay) {
      return; // Not enough time has passed yet
    }

    // 3. Pick random adhkar or dua
    final payload = _pickRandomPayload();
    if (payload == null) return;

    // 4. Show overlay
    await _showOverlay(payload, height: 200);

    // 5. Increment counter and set next delay
    await prefs.setInt(_kDailyCountKey, count + 1);
    await prefs.setInt(_kLastAdhkarTimeKey, nowMs);
    // Set next delay between 15 and 45 minutes
    await prefs.setInt(
      _kNextAdhkarDelayMsKey,
      (15 + _random.nextInt(31)) * 60 * 1000,
    );
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {}

  @override
  void onReceiveData(Object data) {}

  @override
  void onNotificationButtonPressed(String id) {}

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

        // ── Fallback: floating overlay card (works even if main isolate is dead) ──
        final payload = jsonEncode({
          'type': 'adhan',
          'arabic': 'حَيَّ عَلَى الصَّلَاةِ ، حَيَّ عَلَى الْفَلَاحِ',
          'label': 'أذان ${prayer.nameAr}',
          'emoji': prayer.emoji,
          'source': '',
        });
        await _showOverlay(payload, height: 450);
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

  // ── Adhkar / Dua Pool ──────────────────

  /// Picks a random item from the unified adhkar + dua pool.
  /// Returns a JSON-encoded payload string, or null if no content available.
  String? _pickRandomPayload() {
    // Build unified pool: all adhkar items + all dua items
    final allAdhkar = kAdhkarData.entries.expand((entry) {
      return entry.value.map(
        (dhikr) => (
          arabic: dhikr.arabic,
          label: _categoryName(entry.key),
          emoji: _categoryIcon(entry.key),
          source: dhikr.source ?? '',
          type: 'adhkar',
        ),
      );
    }).toList();

    final allDuas = kDuasData.entries.expand((entry) {
      return entry.value.map(
        (dua) => (
          arabic: dua.arabic,
          label: 'دعاء — ${dua.occasion}',
          emoji: dua.emoji,
          source: dua.source,
          type: 'dua',
        ),
      );
    }).toList();

    final pool = [...allAdhkar, ...allDuas];
    if (pool.isEmpty) return null;

    // Filter out items with empty arabic text
    final validPool = pool
        .where((item) => item.arabic.trim().isNotEmpty)
        .toList();
    if (validPool.isEmpty) return null;

    final item = validPool[_random.nextInt(validPool.length)];

    return jsonEncode({
      'arabic': item.arabic,
      'label': item.label,
      'emoji': item.emoji,
      'source': item.source,
      'type': item.type,
    });
  }

  // ── Overlay Display ────────────────────

  Future<void> _showOverlay(String payload, {required int height}) async {
    try {
      final bool isActive = await FlutterOverlayWindow.isActive();
      if (isActive) {
        await FlutterOverlayWindow.closeOverlay();
        await Future.delayed(const Duration(milliseconds: 300));
      }

      await FlutterOverlayWindow.showOverlay(
        alignment: OverlayAlignment.centerRight,
        height: height,
        width: WindowSize.matchParent,
        enableDrag: true,
        overlayContent: payload,
        flag: OverlayFlag.defaultFlag,
      );
    } catch (e) {
      print('OverlayService: Failed to show overlay: $e');
    }
  }

  // ── Helpers ────────────────────────────

  String _dateKey(DateTime dt) => '${dt.year}-${dt.month}-${dt.day}';

  String _categoryIcon(AdhkarCategory cat) {
    switch (cat) {
      case AdhkarCategory.morning:
        return '🌅';
      case AdhkarCategory.evening:
        return '🌆';
      case AdhkarCategory.sleep:
        return '🌙';
      case AdhkarCategory.afterPrayer:
        return '🕌';
      case AdhkarCategory.misc:
        return '📿';
    }
  }

  String _categoryName(AdhkarCategory cat) {
    switch (cat) {
      case AdhkarCategory.morning:
        return 'أذكار الصباح';
      case AdhkarCategory.evening:
        return 'أذكار المساء';
      case AdhkarCategory.sleep:
        return 'أذكار النوم';
      case AdhkarCategory.afterPrayer:
        return 'أذكار ما بعد الصلاة';
      case AdhkarCategory.misc:
        return 'أذكار عامة';
    }
  }
}
