import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:sound_mode/sound_mode.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';
import 'dart:async';
import 'package:takwa/core/widgets/primary_button.dart';
import 'package:takwa/features/settings/providers/user_preferences_provider.dart';
import 'package:takwa/core/notifications/adhan_auto_trigger.dart';

// ══════════════════════════════════════════════════════
//  ADHAN OVERLAY SCREEN
// ══════════════════════════════════════════════════════
class AdhanOverlayScreen extends ConsumerStatefulWidget {
  final String prayerName;
  final bool autoPlay;

  const AdhanOverlayScreen({
    super.key,
    required this.prayerName,
    this.autoPlay = true,
  });

  @override
  ConsumerState<AdhanOverlayScreen> createState() => _AdhanOverlayScreenState();
}

class _AdhanOverlayScreenState extends ConsumerState<AdhanOverlayScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final AnimationController _starsCtrl;
  late final AnimationController _entryCtrl;
  StreamSubscription<AccelerometerEvent>? _sensorSub;
  Timer? _vibrationTimer;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(userPreferencesProvider).valueOrNull;
    if (prefs?.wakeScreenEnabled ?? true) {
      WakelockPlus.enable();
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _starsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    if (widget.autoPlay) _initAudio();
    _initSensors();
    _initVibration();
  }

  void _initVibration() {
    final prefs = ref.read(userPreferencesProvider).valueOrNull;
    final mode = prefs?.adhanMode ?? 'sound';

    // Only vibrate if mode is vibrate, or if mode is sound and vibrateWithAdhan is true.
    if (mode == 'vibrate' ||
        (mode == 'sound' && (prefs?.vibrateWithAdhan ?? true))) {
      _vibrationTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
        if (AdhanAudioPlayer.isPlaying || mode == 'vibrate') {
          // Vibrate if playing or if only vibrating
          HapticFeedback.vibrate();
        }
      });
      if (mode == 'vibrate') {
        // Stop vibrating after a duration (e.g., 3 minutes max) since there's no player.playing state if sound is skipped
        Future.delayed(const Duration(minutes: 3), () {
          _vibrationTimer?.cancel();
        });
      }
    }
  }

  void _initSensors() {
    final prefs = ref.read(userPreferencesProvider).valueOrNull;
    if (prefs?.flipToSilenceEnabled ?? true) {
      _sensorSub = accelerometerEventStream().listen((event) {
        // If device is flipped face down (Z axis is significantly negative)
        if (event.z < -8.0) {
          _silenceAdhan();
        }
      });
    }
  }

  void _silenceAdhan() {
    AdhanAudioPlayer.stop();
    _vibrationTimer?.cancel();
  }

  Future<void> _initAudio() async {
    // تأخير قصير للسماح بتهيئة الـ Widget
    await Future.delayed(const Duration(milliseconds: 300));

    // Read user-selected adhan sound from preferences
    final prefsAsync = ref.read(userPreferencesProvider);
    final prefs = prefsAsync.valueOrNull;

    // Respect the adhan mode (sound vs silent/vibrate)
    final mode = prefs?.adhanMode ?? 'sound';
    
    if (mode == 'silent' || mode == 'vibrate') return;

    // Use the user-selected sound file, fall back to Makkah if not set
    final soundFile = prefs?.adhanSound ?? 'Adhan-Makkah.mp3';
    final asset = 'assets/sounds/$soundFile';

    final volume = prefs?.adhanVolumeLevel ?? 1.0;

    if (!AdhanAudioPlayer.isPlaying) {
      await AdhanAudioPlayer.play(asset: asset, volume: volume);
    } else {
      await AdhanAudioPlayer.setVolume(volume);
    }
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _sensorSub?.cancel();
    _vibrationTimer?.cancel();
    _pulseCtrl.dispose();
    _starsCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  void _close() {
    AdhanAudioPlayer.stop();
    _applyAutoSilent();
    Navigator.of(context).pop();
  }

  void _goToPrayer() {
    AdhanAudioPlayer.stop();
    _applyAutoSilent();
    Navigator.of(context).popUntil((r) => r.isFirst);
    Navigator.of(context).pushNamed('/prayer');
  }

  Future<void> _applyAutoSilent() async {
    final prefs = ref.read(userPreferencesProvider).valueOrNull;
    if (prefs?.autoSilentAfterAdhan ?? false) {
      try {
        // Switch to silent or vibrate based on preference (defaulting to silent if autoSilent is on)
        // You might want to add a preference for WHICH mode, but for now we follow the toggle.
        await SoundMode.setSoundMode(RingerModeStatus.silent);
        debugPrint('🔇 Mode: Auto-Silent applied.');
      } catch (e) {
        debugPrint('❌ Error applying auto-silent: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hijri = HijriCalendar.now();
    final hijriStr =
        '${hijri.hDay} ${_hijriMonthAr(hijri.hMonth)} ${hijri.hYear} هـ';

    return WillPopScope(
      onWillPop: () async {
        AdhanAudioPlayer.stop();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // ① Deep Night Gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF02061A),
                    Color(0xFF050D2A),
                    Color(0xFF0A1540),
                    Color(0xFF0E1A50),
                  ],
                ),
              ),
            ),

            // ② Animated Stars
            AnimatedBuilder(
              animation: _starsCtrl,
              builder: (_, _) => CustomPaint(
                painter: _AdhanStarsPainter(progress: _starsCtrl.value),
                size: Size.infinite,
              ),
            ),

            // ③ Mosque Silhouette
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: Tween<double>(begin: 0, end: 1).animate(
                  CurvedAnimation(
                    parent: _entryCtrl,
                    curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
                  ),
                ),
                child: CustomPaint(
                  painter: _MosqueSilhouettePainter(),
                  size: Size(MediaQuery.of(context).size.width, 220),
                ),
              ),
            ),

            // ④ Content
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Radiant pulse circle
                  FadeTransition(
                    opacity: Tween<double>(begin: 0, end: 1).animate(
                      CurvedAnimation(
                        parent: _entryCtrl,
                        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
                      ),
                    ),
                    child: AnimatedBuilder(
                      animation: _pulseCtrl,
                      builder: (_, child) {
                        final pulse = _pulseCtrl.value;
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer glow rings
                            ...List.generate(3, (i) {
                              final delay = i / 3.0;
                              final wrappedPulse = (pulse + delay) % 1.0;
                              return Container(
                                width: 120 + wrappedPulse * 100,
                                height: 120 + wrappedPulse * 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(
                                      0xFFD4AF37,
                                    ).withOpacity(0.3 * (1 - wrappedPulse)),
                                    width: 1.5,
                                  ),
                                ),
                              );
                            }),
                            // Center crescent
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    const Color(0xFFD4AF37).withOpacity(0.3),
                                    Colors.transparent,
                                  ],
                                ),
                                border: Border.all(
                                  color: const Color(0xFFD4AF37),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFD4AF37,
                                    ).withOpacity(0.3 + 0.2 * pulse),
                                    blurRadius: 30 + 15 * pulse,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  '☪',
                                  style: TextStyle(fontSize: 42),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Prayer name
                  SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: _entryCtrl,
                            curve: const Interval(
                              0.2,
                              0.8,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                        ),
                    child: FadeTransition(
                      opacity: Tween<double>(begin: 0, end: 1).animate(
                        CurvedAnimation(
                          parent: _entryCtrl,
                          curve: const Interval(0.2, 0.8),
                        ),
                      ),
                      child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Color(0xFFD4AF37),
                            Color(0xFFF5E070),
                            Color(0xFF2DD4BF),
                          ],
                        ).createShader(bounds),
                        child: Text(
                          'حان وقت ${widget.prayerName}',
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            shadows: [
                              Shadow(color: Color(0xFFD4AF37), blurRadius: 20),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Hijri date
                  FadeTransition(
                    opacity: Tween<double>(begin: 0, end: 1).animate(
                      CurvedAnimation(
                        parent: _entryCtrl,
                        curve: const Interval(0.4, 1.0),
                      ),
                    ),
                    child: Text(
                      hijriStr,
                      style: TextStyle(
                        fontFamily: 'NotoNaskhArabic',
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.6),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Hadith quote
                  FadeTransition(
                    opacity: Tween<double>(begin: 0, end: 1).animate(
                      CurvedAnimation(
                        parent: _entryCtrl,
                        curve: const Interval(0.5, 1.0),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        _prayerHadith(widget.prayerName),
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 16,
                          color: const Color(0xFFD4AF37).withOpacity(0.8),
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Buttons
                  FadeTransition(
                    opacity: Tween<double>(begin: 0, end: 1).animate(
                      CurvedAnimation(
                        parent: _entryCtrl,
                        curve: const Interval(0.6, 1.0),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Row(
                        children: [
                          // Close
                          Expanded(
                            child: PrimaryButton(
                              onTap: () async => _close(),
                              icon: Icons.close_rounded,
                              label: 'إغلاق',
                              isOutline: true,
                              baseColor: Colors.white70,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Go to Prayer
                          Expanded(
                            flex: 2,
                            child: PrimaryButton(
                              onTap: () async => _goToPrayer(),
                              icon: Icons.mosque_rounded,
                              label: 'الذهاب للصلاة',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ── دعاء ما بعد الأذان ──
                  FadeTransition(
                    opacity: Tween<double>(begin: 0, end: 1).animate(
                      CurvedAnimation(
                        parent: _entryCtrl,
                        curve: const Interval(0.7, 1.0),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFD4AF37).withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  '🤲',
                                  style: TextStyle(fontSize: 14),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'دعاء ما بعد الأذان',
                                  style: TextStyle(
                                    fontFamily: 'NotoNaskhArabic',
                                    fontSize: 12,
                                    color: const Color(
                                      0xFFD4AF37,
                                    ).withOpacity(0.7),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'اللَّهُمَّ رَبَّ هَٰذِهِ الدَّعْوَةِ التَّامَّةِ، وَالصَّلَاةِ الْقَائِمَةِ، آتِ مُحَمَّدًا الْوَسِيلَةَ وَالْفَضِيلَةَ',
                              style: TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 15,
                                color: Colors.white,
                                height: 1.8,
                              ),
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _hijriMonthAr(int month) {
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
    return months[(month - 1).clamp(0, 11)];
  }

  /// يُرجع حديثاً أو قولاً مناسباً لكل صلاة
  String _prayerHadith(String prayer) {
    if (prayer.contains('فجر') || prayer.contains('Fajr')) {
      return 'الصلاة خير من النوم';
    } else if (prayer.contains('ظهر') || prayer.contains('Dhuhr')) {
      return 'حافظوا على الصلوات والصلاة الوسطى';
    } else if (prayer.contains('عصر') || prayer.contains('Asr')) {
      return 'من فاتته صلاة العصر فكأنما وُتر أهله وماله';
    } else if (prayer.contains('مغرب') || prayer.contains('Maghrib')) {
      return 'بادروا بالصلاة قبل الفوات';
    } else if (prayer.contains('عشاء') || prayer.contains('Isha')) {
      return 'لو يعلم الناس ما في الصلاة في الظلمة لأتوها ولو حبواً';
    }
    return 'الصلوات الخمس كفارة لما بينهن';
  }
}

// ══════════════════════════════════════════════════════
//  STAR FIELD PAINTER
// ══════════════════════════════════════════════════════
class _AdhanStarsPainter extends CustomPainter {
  final double progress;
  _AdhanStarsPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(99);
    final paint = Paint();

    for (int i = 0; i < 120; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height * 0.75;
      final twinkle = math.sin((progress * math.pi * 2) + i * 0.5);
      final opacity = (0.1 + 0.7 * ((twinkle + 1) / 2)).clamp(0.0, 1.0);
      final radius = 0.6 + rng.nextDouble() * 1.6;
      final isGold = i % 9 == 0;

      paint.color = isGold
          ? const Color(0xFFD4AF37).withOpacity(opacity * 0.8)
          : Colors.white.withOpacity(opacity * 0.7);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_AdhanStarsPainter old) => old.progress != progress;
}

// ══════════════════════════════════════════════════════
//  MOSQUE SILHOUETTE PAINTER
// ══════════════════════════════════════════════════════
class _MosqueSilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.07)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    final path = Path();
    // Ground
    path.moveTo(0, h);
    path.lineTo(w, h);

    // Right minaret
    path.lineTo(w, h * 0.3);
    path.lineTo(w - w * 0.04, h * 0.3);
    path.lineTo(w - w * 0.04, h * 0.1);
    path.lineTo(w - w * 0.06, h * 0.05);
    path.lineTo(w - w * 0.08, h * 0.1);
    path.lineTo(w - w * 0.08, h * 0.3);
    path.lineTo(w - w * 0.12, h * 0.3);
    path.lineTo(w - w * 0.12, h * 0.5);

    // Main dome
    path.lineTo(w * 0.75, h * 0.5);
    path.quadraticBezierTo(w * 0.5, -h * 0.1, w * 0.25, h * 0.5);

    // Left side
    path.lineTo(w * 0.12, h * 0.5);
    path.lineTo(w * 0.12, h * 0.3);
    path.lineTo(w * 0.08, h * 0.3);
    path.lineTo(w * 0.08, h * 0.1);
    path.lineTo(w * 0.06, h * 0.05);
    path.lineTo(w * 0.04, h * 0.1);
    path.lineTo(w * 0.04, h * 0.3);
    path.lineTo(0, h * 0.3);
    path.lineTo(0, h);

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_MosqueSilhouettePainter old) => false;
}
