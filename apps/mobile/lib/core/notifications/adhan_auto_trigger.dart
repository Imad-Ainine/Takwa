// ═══════════════════════════════════════════════════════════════
//  lib/core/notifications/adhan_auto_trigger.dart
//  تقوى — Adhan Auto Trigger Service
//  يُطلق شاشة الأذان تلقائياً مع صوت الأذان
// ═══════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../routes/app_routes.dart';
import 'notifications_service.dart';
import '../providers/database_providers.dart';

// ═══════════════════════════════════════════════════════════════
//  ADHAN AUDIO PLAYER
// ═══════════════════════════════════════════════════════════════
class AdhanAudioPlayer {
  static AudioPlayer? _player;
  static bool _isPlaying = false;

  static Future<void> play({String asset = 'assets/sounds/Adhan-Makkah.mp3', double volume = 1.0}) async {
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

// ═══════════════════════════════════════════════════════════════
//  ADHAN AUTO TRIGGER — يُشغَّل من main.dart عبر listener
// ═══════════════════════════════════════════════════════════════
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

      final settings = ref.read(settingsDaoProvider);
      
      final adhanMode = await settings.get('adhan_mode') ?? 'sound';
      final playSound = adhanMode == 'sound';
      final adhanVolumeLevel = double.tryParse((await settings.get('adhan_volume_level')) ?? '1.0') ?? 1.0;
      
      final adhanScreen = await settings.getBool(
        'adhan_screen_enabled',
        defaultVal: true,
      );

      // Read the user-selected adhan sound
      final adhanSoundFile =
          await settings.get('adhan_sound') ?? 'Adhan-Makkah.mp3';

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

    final settings = ref.read(settingsDaoProvider);
    final adhanMode = await settings.get('adhan_mode') ?? 'sound';
    final playSoundPref = adhanMode == 'sound';
    final adhanVolumeLevel = double.tryParse((await settings.get('adhan_volume_level')) ?? '1.0') ?? 1.0;

    final adhanScreen = await settings.getBool(
      'adhan_screen_enabled',
      defaultVal: true,
    );

    if (playSoundPref && requestPlaySound) {
      // Read the user-selected adhan sound file
      final adhanSoundFile =
          await settings.get('adhan_sound') ?? 'Adhan-Makkah.mp3';
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

// ═══════════════════════════════════════════════════════════════
//  ADHAN OVERLAY SCREEN (شاشة الأذان الكاملة)
//  الشاشة الفعلية موجودة في features/prayer/presentation/screens/adhan_overlay_screen.dart
//  هذا فقط controller لتشغيل الصوت ومزامنته مع الشاشة
// ═══════════════════════════════════════════════════════════════
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

// ═══════════════════════════════════════════════════════════════
//  MAIN APP INTEGRATION MIXIN
//  يُضاف لـ _TakwaAppState في main.dart
// ═══════════════════════════════════════════════════════════════
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
