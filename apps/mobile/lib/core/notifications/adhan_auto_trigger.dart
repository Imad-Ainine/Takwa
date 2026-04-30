import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../routes/app_routes.dart';
import 'notifications_service.dart';
import '../../features/settings/providers/user_preferences_provider.dart';

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
  static String? _lastTriggeredPrayer;
  static DateTime? _lastTriggeredTime;

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
    try {
      final prayers = ref.read(prayerTimesProvider).value;
      if (prayers == null) return;

      final prefs = await ref.read(userPreferencesProvider.future);

      final adhanMode = prefs.adhanMode;
      final playSound = adhanMode == 'sound';
      final adhanVolumeLevel = prefs.adhanVolumeLevel;

      final adhanScreen = prefs.adhanScreenEnabled;

      // Read the user-selected adhan sound
      final adhanSoundFile = prefs.adhanSound;

      final now = DateTime.now();
      for (final prayer in prayers) {
        final diffSecs = now.difference(prayer.time).inSeconds;
        // نُطلق الشاشة فقط عند وقت الصلاة تماماً (0-180 ثانية)
        if (diffSecs < 0 || diffSecs > 180) {
          continue;
        }

        final key = '${prayer.name}_${prayer.time.day}';
        if (_lastTriggeredPrayer == key) continue;

        // تجنب إعادة التشغيل في نفس الفترة (30 دقيقة)
        if (_lastTriggeredTime != null &&
            now.difference(_lastTriggeredTime!).inMinutes < 30) {
          continue;
        }

        _lastTriggeredPrayer = key;
        _lastTriggeredTime = now;

        debugPrint('🕌 Auto-trigger adhan: ${prayer.nameAr}');

        // تشغيل صوت الأذان المختار من الإعدادات
        if (playSound) {
          await AdhanAudioPlayer.play(
            asset: 'assets/sounds/$adhanSoundFile',
            volume: adhanVolumeLevel,
          );
        }

        // فتح شاشة الأذان
        if (adhanScreen) {
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
    final requestPlaySound = (data['sound'] as bool?) ?? true;

    final prefs = await ref.read(userPreferencesProvider.future);
    final adhanMode = prefs.adhanMode;
    final playSoundPref = adhanMode == 'sound';
    final adhanVolumeLevel = prefs.adhanVolumeLevel;

    final adhanScreen = prefs.adhanScreenEnabled;

    if (playSoundPref && requestPlaySound) {
      // Read the user-selected adhan sound file
      final adhanSoundFile = prefs.adhanSound;
      await AdhanAudioPlayer.play(
        asset: 'assets/sounds/$adhanSoundFile',
        volume: adhanVolumeLevel,
      );
    }

    if (adhanScreen) {
      await Future.delayed(const Duration(milliseconds: 300));
      navigatorKey.currentState?.pushNamed(Routes.adhan, arguments: prayerName);
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
