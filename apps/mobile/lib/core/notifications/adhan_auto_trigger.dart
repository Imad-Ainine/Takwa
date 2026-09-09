import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../routes/app_routes.dart';
import 'notifications_service.dart';
import '../../features/settings/providers/user_preferences_provider.dart';
import '../../features/settings/data/user_preferences.dart';

class AdhanAudioPlayer {
  static AudioPlayer? _player;
  static bool _isPlaying = false;

  static Future<void> play({
    String asset = 'assets/sounds/Adhan-Makkah.mp3',
    double volume = 1.0,
  }) async {
    try {
      await stop();
      _player = AudioPlayer();
      await _player!.setVolume(volume);
      await _player!.setAsset(asset);
      _player!.playerStateStream.listen((state) {
        _isPlaying = state.playing;
      });
      await _player!.play();
      _isPlaying = true;
    } catch (e) {
      debugPrint('AdhanAudio: play error: $e');
    }
  }

  static Future<void> setVolume(double volume) async {
    if (_player != null) {
      await _player!.setVolume(volume);
    }
  }

  static Future<void> stop() async {
    try {
      if (_player != null) {
        await _player!.stop();
        await _player!.dispose();
        _player = null;
        _isPlaying = false;
      }
    } catch (e) {
      debugPrint('AdhanAudio: stop error: $e');
    }
  }

  static bool get isPlaying => _isPlaying;
}

class AdhanAutoTrigger {
  static Timer? _checkTimer;
  // Key is '<prayerName>_<dayOfYear>' — unique per prayer per day.
  static String? _lastTriggeredPrayer;
  // Guards concurrent executions: avoids stacking multiple async _check
  // calls when the provider is slow to resolve on the first tick.
  static bool _checking = false;

  /// يبدأ مراقبة أوقات الصلاة كل ثانية بدقة عالية
  static void start(WidgetRef ref, GlobalKey<NavigatorState> navigatorKey) {
    _checkTimer?.cancel();
    _checkTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _check(ref, navigatorKey);
    });
  }

  static void stop() {
    _checkTimer?.cancel();
    _checkTimer = null;
    AdhanAudioPlayer.stop();
  }

  static Future<void> _check(
    WidgetRef ref,
    GlobalKey<NavigatorState> navigatorKey,
  ) async {
    if (_checking) return; // prevent overlapping async calls
    _checking = true;
    try {
      final prayers = ref.read(prayerTimesProvider).value;
      if (prayers == null) return;

      // Read preferences synchronously from the cached value to avoid a
      // per-second async database hit. Fall back to the future only if the
      // value has not loaded yet (first launch).
      final UserPreferences prefs =
          ref.read(userPreferencesProvider).valueOrNull ??
          await ref.read(userPreferencesProvider.future);

      final adhanMode = prefs.adhanMode;
      final playSound = adhanMode == 'sound';
      final adhanVolumeLevel = prefs.adhanVolumeLevel;
      final adhanScreen = prefs.adhanScreenEnabled;
      final adhanSoundFile = prefs.adhanSound;

      final now = DateTime.now();
      for (final prayer in prayers) {
        final diffSecs = now.difference(prayer.time).inSeconds;
        // Trigger window: from prayer time up to 3 minutes after, to
        // survive the app being momentarily backgrounded at the exact second.
        if (diffSecs < 0 || diffSecs > 180) continue;

        // Unique key per prayer per calendar day — the only deduplication
        // guard needed. The old 30-minute cross-prayer wall was removed
        // because it blocked a prayer that falls within 30 min of the
        // previous one (e.g., Dhuhr at 13:00 and Asr at 13:20 in summer).
        final key =
            '${prayer.name}_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
        if (_lastTriggeredPrayer == key) continue;

        // Guard: don't push the Adhan screen if it's already on top.
        final nav = navigatorKey.currentState;
        bool adhanAlreadyVisible = false;
        if (nav != null) {
          nav.popUntil((route) {
            if (route.settings.name == Routes.adhan) {
              adhanAlreadyVisible = true;
            }
            return true; // never actually pop anything
          });
        }

        _lastTriggeredPrayer = key;

        debugPrint('🕌 Auto-trigger adhan: ${prayer.nameAr}');

        // تشغيل صوت الأذان المختار من الإعدادات
        if (playSound && !AdhanAudioPlayer.isPlaying) {
          await AdhanAudioPlayer.play(
            asset: 'assets/sounds/$adhanSoundFile',
            volume: adhanVolumeLevel,
          );
        }

        // فتح شاشة الأذان
        if (adhanScreen && !adhanAlreadyVisible) {
          FlutterForegroundTask.wakeUpScreen();
          final ctx = navigatorKey.currentContext;
          if (ctx != null) {
            await Future.delayed(const Duration(milliseconds: 300));
            navigatorKey.currentState?.pushNamed(
              Routes.adhan,
              arguments: prayer.nameAr,
            );
          }
        }

        break;
      }
    } catch (e) {
      debugPrint('AdhanAutoTrigger: error: $e');
    } finally {
      _checking = false;
    }
  }

  /// يُستدعى من foreground task عند استلام بيانات الأذان
  static Future<void> handleForegroundData(
    Map data,
    GlobalKey<NavigatorState> navigatorKey,
    WidgetRef ref,
  ) async {
    final action = data['action'];
    if (action != 'show_adhan') return;

    final prayerName = (data['prayer'] as String?) ?? 'الصلاة';
    // The background service now sends 'adhanMode' (the canonical string);
    // fall back to interpreting the legacy bool 'sound' field so older
    // background isolates still work correctly.
    final String adhanModeFromBg =
        (data['adhanMode'] as String?) ??
        ((data['sound'] as bool?) == true ? 'sound' : 'silent');

    // Prefer the live Riverpod value (already cached); only await if loading.
    final UserPreferences prefs =
        ref.read(userPreferencesProvider).valueOrNull ??
        await ref.read(userPreferencesProvider.future);

    final adhanMode = prefs.adhanMode;
    final playSoundPref = adhanMode == 'sound';
    // Only play if both the user setting AND the background signal agree.
    final shouldPlaySound = playSoundPref && adhanModeFromBg == 'sound';

    final adhanVolumeLevel = prefs.adhanVolumeLevel;
    final adhanScreen = prefs.adhanScreenEnabled;

    if (shouldPlaySound && !AdhanAudioPlayer.isPlaying) {
      final adhanSoundFile = prefs.adhanSound;
      await AdhanAudioPlayer.play(
        asset: 'assets/sounds/$adhanSoundFile',
        volume: adhanVolumeLevel,
      );
    }

    if (adhanScreen) {
      // Guard: don't push on top of an already-visible Adhan screen.
      bool adhanAlreadyVisible = false;
      navigatorKey.currentState?.popUntil((route) {
        if (route.settings.name == Routes.adhan) adhanAlreadyVisible = true;
        return true;
      });

      if (!adhanAlreadyVisible) {
        await Future.delayed(const Duration(milliseconds: 300));
        navigatorKey.currentState?.pushNamed(
          Routes.adhan,
          arguments: prayerName,
        );
      }
    }
  }
}

class AdhanScreenController {
  static final _instance = AdhanScreenController._();
  AdhanScreenController._();
  static AdhanScreenController get instance => _instance;

  final ValueNotifier<bool> isAdhanPlaying = ValueNotifier(false);
  final ValueNotifier<String?> currentPrayerName = ValueNotifier(null);

  Future<void> onAdhanScreenOpened(String prayerName) async {
    currentPrayerName.value = prayerName;
    isAdhanPlaying.value = true;
    if (!AdhanAudioPlayer.isPlaying) {
      await AdhanAudioPlayer.play();
    }
  }

  Future<void> onAdhanScreenClosed() async {
    currentPrayerName.value = null;
    isAdhanPlaying.value = false;
    await AdhanAudioPlayer.stop();
  }

  Future<void> stopAdhan() async {
    isAdhanPlaying.value = false;
    await AdhanAudioPlayer.stop();
  }
}

mixin AdhanAutoMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  void initAdhanAuto(GlobalKey<NavigatorState> navigatorKey) {
    AdhanAutoTrigger.start(ref, navigatorKey);
  }

  @override
  void dispose() {
    AdhanAutoTrigger.stop();
    super.dispose();
  }

  /// استدعِ هذا من _onAdhanData في TakwaApp
  Future<void> handleAdhanData(
    Map data,
    GlobalKey<NavigatorState> navigatorKey,
  ) async {
    await AdhanAutoTrigger.handleForegroundData(data, navigatorKey, ref);
  }
}
