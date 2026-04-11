// ═══════════════════════════════════════════════════════════════
//  lib/features/prayer/presentation/screens/prayer_screen.dart
//  محاسبة النفس — شاشة الأذان والصلاة القادمة
// ═══════════════════════════════════════════════════════════════


import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:muhasabah/core/providers/database_providers.dart';
import 'package:muhasabah/core/theme/app_theme.dart';
import 'package:muhasabah/core/notifications/notifications_service.dart';
import 'package:muhasabah/core/notifications/location_prayer_update.dart';

// ─────────────────────────────────────────
//  IQAMA OFFSETS (minutes after adhan)
// ─────────────────────────────────────────
const Map<String, int> _kIqamaOffsets = {
  'fajr': 20,
  'dhuhr': 15,
  'asr': 15,
  'maghrib': 5,
  'isha': 15,
};

// ─────────────────────────────────────────
//  PRAYER VISUAL DATA
// ─────────────────────────────────────────
class _PrayerVisual {
  final String key, nameAr, emoji;
  final Color primaryColor, secondaryColor;
  final String skyPhase; // dawn/morning/noon/afternoon/sunset/night
  const _PrayerVisual({
    required this.key,
    required this.nameAr,
    required this.emoji,
    required this.primaryColor,
    required this.secondaryColor,
    required this.skyPhase,
  });
}

const _kPrayerVisuals = {
  'fajr': _PrayerVisual(
    key: 'fajr',
    nameAr: 'الفجر',
    emoji: '🌅',
    primaryColor: Color(0xFF4A5568),
    secondaryColor: Color(0xFF7B8FA6),
    skyPhase: 'dawn',
  ),
  'dhuhr': _PrayerVisual(
    key: 'dhuhr',
    nameAr: 'الظهر',
    emoji: '☀️',
    primaryColor: Color(0xFF1A6B8A),
    secondaryColor: Color(0xFF2E9CC4),
    skyPhase: 'noon',
  ),
  'asr': _PrayerVisual(
    key: 'asr',
    nameAr: 'العصر',
    emoji: '🌤',
    primaryColor: Color(0xFF8B5E3C),
    secondaryColor: Color(0xFFE8945A),
    skyPhase: 'afternoon',
  ),
  'maghrib': _PrayerVisual(
    key: 'maghrib',
    nameAr: 'المغرب',
    emoji: '🌆',
    primaryColor: Color(0xFF7B3F6E),
    secondaryColor: Color(0xFFE87B5A),
    skyPhase: 'sunset',
  ),
  'isha': _PrayerVisual(
    key: 'isha',
    nameAr: 'العشاء',
    emoji: '🌃',
    primaryColor: Color(0xFF0D1117),
    secondaryColor: Color(0xFF1A2332),
    skyPhase: 'night',
  ),
};

// ─────────────────────────────────────────
//  STATE MODEL
// ─────────────────────────────────────────
class PrayerScreenState {
  final List<PrayerTimeInfo> prayers;
  final PrayerTimeInfo? next;
  final Duration? remaining;
  final DateTime? iqamaTime;
  final Duration? remainingIqama;
  final bool isIqamaPhase;
  final String cityName;
  final bool loading;
  final String? error;

  const PrayerScreenState({
    this.prayers = const [],
    this.next,
    this.remaining,
    this.iqamaTime,
    this.remainingIqama,
    this.isIqamaPhase = false,
    this.cityName = '',
    this.loading = true,
    this.error,
  });

  PrayerScreenState copyWith({
    List<PrayerTimeInfo>? prayers,
    PrayerTimeInfo? next,
    Duration? remaining,
    DateTime? iqamaTime,
    Duration? remainingIqama,
    bool? isIqamaPhase,
    String? cityName,
    bool? loading,
    String? error,
  }) => PrayerScreenState(
    prayers: prayers ?? this.prayers,
    next: next ?? this.next,
    remaining: remaining ?? this.remaining,
    iqamaTime: iqamaTime ?? this.iqamaTime,
    remainingIqama: remainingIqama ?? this.remainingIqama,
    isIqamaPhase: isIqamaPhase ?? this.isIqamaPhase,
    cityName: cityName ?? this.cityName,
    loading: loading ?? this.loading,
    error: error,
  );
}

// ─────────────────────────────────────────
//  NOTIFIER
// ─────────────────────────────────────────
class PrayerNotifier extends StateNotifier<PrayerScreenState> {
  PrayerNotifier(this._ref) : super(const PrayerScreenState()) {
    _init();
  }

  final Ref _ref;
  Timer? _ticker;

  Future<void> _init() async {
    state = state.copyWith(loading: true);
    try {
      final settings = _ref.read(settingsDaoProvider);

      // جلب الموقع المحفوظ أو تحديثه
      final savedLat = await settings.get('latitude');
      final savedLng = await settings.get('longitude');
      String city = await settings.get('cityName') ?? 'غير محدد';

      if (savedLat == null || savedLng == null || city == 'غير محدد') {
        final result = await LocationPrayerManager.refreshLocation(_ref);
        if (result == LocationResult.success) {
          city = await settings.get('cityName') ?? city;
        }
      }

      // حساب أوقات الصلاة باستخدام الـ provider لإبقاء البيانات متزامنة
      final prayers = await _ref.read(prayerTimesProvider.future);

      state = state.copyWith(
        prayers: prayers,
        cityName: city,
        loading: false,
      );

      _startTicker();
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(loading: true);
    await LocationPrayerManager.refreshLocation(_ref);
    await _init();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    _tick();
  }

  void _tick() {
    if (state.prayers.isEmpty) return;
    final now = DateTime.now();
    final next = PrayerTimesService.nextPrayer(state.prayers);
    if (next == null) return;

    final iqamaOffset = _kIqamaOffsets[next.name] ?? 15;
    final iqamaTime = next.time.add(Duration(minutes: iqamaOffset));
    final isIqamaPhase = now.isAfter(next.time) && now.isBefore(iqamaTime);

    final remaining = isIqamaPhase
        ? iqamaTime.difference(now)
        : next.time.difference(now);

    state = state.copyWith(
      next: next,
      remaining: remaining,
      iqamaTime: iqamaTime,
      remainingIqama: iqamaTime.difference(now),
      isIqamaPhase: isIqamaPhase,
    );
  }


  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

final prayerScreenProvider =
    StateNotifierProvider<PrayerNotifier, PrayerScreenState>(
      (ref) => PrayerNotifier(ref),
    );

// ═══════════════════════════════════════════════════════════════
//  PRAYER SCREEN
// ═══════════════════════════════════════════════════════════════
class PrayerScreen extends ConsumerStatefulWidget {
  const PrayerScreen({super.key});

  @override
  ConsumerState<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends ConsumerState<PrayerScreen>
    with TickerProviderStateMixin {
  late final AnimationController _skyCtrl; // تغيير لون السماء
  late final AnimationController _pulseCtrl; // نبض الدائرة
  late final AnimationController _starsCtrl; // النجوم ليلاً
  late final AnimationController _entryCtrl; // دخول العناصر

  late Animation<double> _pulse;
  late Animation<double> _stars;

  String _lastPrayerKey = '';

  @override
  void initState() {
    super.initState();

    _skyCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulse = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _starsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _stars = CurvedAnimation(parent: _starsCtrl, curve: Curves.easeInOut);

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _skyCtrl.dispose();
    _pulseCtrl.dispose();
    _starsCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  void _animateSkyIfNeeded(String prayerKey) {
    if (prayerKey != _lastPrayerKey) {
      _lastPrayerKey = prayerKey;
      _skyCtrl.forward(from: 0);
      _entryCtrl.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(prayerScreenProvider);

    final prayerKey = state.next?.name ?? 'isha';
    final visual = _kPrayerVisuals[prayerKey]!;
    _animateSkyIfNeeded(prayerKey);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: context.colors.night,
        body: Stack(
          children: [
            // ── خلفية السماء الديناميكية ──
            Positioned.fill(
              child: _SkyBackground(
                visual: visual,
                skyCtrl: _skyCtrl,
                starsAnim: _stars,
              ),
            ),

            // ── جسيمات عائمة ──
            Positioned.fill(child: _FloatingParticles(visual: visual)),

            // ── المحتوى ──
            state.loading
                ? const _LoadingOverlay()
                : state.error != null
                ? _ErrorView(
                    onRetry: () =>
                        ref.read(prayerScreenProvider.notifier).refresh(),
                  )
                : _buildContent(context, state, visual),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    PrayerScreenState state,
    _PrayerVisual visual,
  ) {
    return SafeArea(
      child: Column(
        children: [
          // ── شريط علوي ──
          _TopBar(
            cityName: state.cityName,
            onRefresh: () => ref.read(prayerScreenProvider.notifier).refresh(),
            entryCtrl: _entryCtrl,
          ),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  // ── البطاقة الرئيسية ──
                  _MainPrayerCard(
                    state: state,
                    visual: visual,
                    pulseAnim: _pulse,
                    entryCtrl: _entryCtrl,
                  ),
                  const SizedBox(height: 20),

                  // ── جدول الصلوات اليومي ──
                  _DailyPrayersTable(
                    prayers: state.prayers,
                    currentKey: state.next?.name ?? '',
                    iqamaOffsets: _kIqamaOffsets,
                    entryCtrl: _entryCtrl,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  SKY BACKGROUND
// ═══════════════════════════════════════════════════════════════
class _SkyBackground extends StatelessWidget {
  final _PrayerVisual visual;
  final AnimationController skyCtrl;
  final Animation<double> starsAnim;

  const _SkyBackground({
    required this.visual,
    required this.skyCtrl,
    required this.starsAnim,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: skyCtrl,
      builder: (_, __) => CustomPaint(
        painter: _SkyPainter(
          primary: visual.primaryColor,
          secondary: visual.secondaryColor,
          phase: visual.skyPhase,
          t: skyCtrl.value,
          starsT: starsAnim.value,
        ),
      ),
    );
  }
}

class _SkyPainter extends CustomPainter {
  final Color primary, secondary;
  final String phase;
  final double t, starsT;

  _SkyPainter({
    required this.primary,
    required this.secondary,
    required this.phase,
    required this.t,
    required this.starsT,
  });

  static final _rng = math.Random(42);
  static List<Offset>? _starPositions;

  @override
  void paint(Canvas canvas, Size size) {
    // ── Gradient sky ──
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: _skyColors(),
        stops: const [0.0, 0.4, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // ── نجوم (ليل/فجر) ──
    if (phase == 'night' || phase == 'dawn') {
      _drawStars(canvas, size);
    }

    // ── هلال (ليل) ──
    if (phase == 'night') {
      _drawCrescent(canvas, size);
    }

    // ── شمس (ظهر) ──
    if (phase == 'noon') {
      _drawSun(canvas, size);
    }

    // ── طبقة الغلاف الجوي السفلية ──
    _drawHorizonGlow(canvas, size);

    // ── نمط هندسي إسلامي شفاف ──
    _drawGeometricPattern(canvas, size);
  }

  List<Color> _skyColors() {
    switch (phase) {
      case 'dawn':
        return [
          const Color(0xFF1A1A2E),
          const Color(0xFF2D3561),
          const Color(0xFF6B3FA0).withOpacity(0.7),
          const Color(0xFFE8945A).withOpacity(0.5),
        ];
      case 'noon':
        return [
          const Color(0xFF0A3D62),
          const Color(0xFF1565C0),
          const Color(0xFF1E88E5),
          const Color(0xFF42A5F5),
        ];
      case 'afternoon':
        return [
          const Color(0xFF0D3349),
          const Color(0xFF1A5276),
          const Color(0xFFE8945A).withOpacity(0.6),
          const Color(0xFFFFB74D).withOpacity(0.4),
        ];
      case 'sunset':
        return [
          const Color(0xFF1A0033),
          const Color(0xFF7B1FA2),
          const Color(0xFFE64A19),
          const Color(0xFFFF8F00),
        ];
      case 'night':
        return [
          const Color(0xFF020408),
          const Color(0xFF0A0F1A),
          const Color(0xFF0D1117),
          const Color(0xFF111827),
        ];
      default:
        return [
          const Color(0xFF0D1117),
          const Color(0xFF111827),
          const Color(0xFF1A2332),
          const Color(0xFF1E2D40),
        ];
    }
  }

  void _drawStars(Canvas canvas, Size size) {
    _starPositions ??= List.generate(
      80,
      (_) => Offset(
        _rng.nextDouble() * size.width,
        _rng.nextDouble() * size.height * 0.65,
      ),
    );

    final starPaint = Paint()..color = Colors.white;
    for (int i = 0; i < _starPositions!.length; i++) {
      final opacity =
          0.3 + 0.7 * ((math.sin(starsT * math.pi * 2 + i * 0.3) + 1) / 2);
      final radius = 0.5 + _rng.nextDouble() * 1.5;
      starPaint.color = Colors.white.withOpacity(
        opacity * (phase == 'dawn' ? 0.5 : 1.0),
      );
      canvas.drawCircle(_starPositions![i], radius, starPaint);
    }
  }

  void _drawCrescent(Canvas canvas, Size size) {
    final cx = size.width * 0.78, cy = size.height * 0.12;
    const r = 22.0;
    final moonPaint = Paint()
      ..color = const Color(0xFFFFF9C4)
      ..style = PaintingStyle.fill;

    // Outer circle
    canvas.drawCircle(Offset(cx, cy), r, moonPaint);
    // Cut with darker circle to make crescent
    final cutPaint = Paint()
      ..color = _skyColors()[0]
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx + r * 0.5, cy - r * 0.1), r * 0.88, cutPaint);

    // Glow
    canvas.drawCircle(
      Offset(cx, cy),
      r + 6,
      Paint()
        ..color = const Color(0x22FFF9C4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
  }

  void _drawSun(Canvas canvas, Size size) {
    final cx = size.width * 0.5, cy = size.height * 0.08;
    // Glow rings
    for (int i = 3; i >= 0; i--) {
      canvas.drawCircle(
        Offset(cx, cy),
        20.0 + i * 14,
        Paint()
          ..color = const Color(0xFFFFD700).withOpacity(0.04 + i * 0.02)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );
    }
    canvas.drawCircle(
      Offset(cx, cy),
      22,
      Paint()..color = const Color(0xFFFFF176),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      18,
      Paint()..color = const Color(0xFFFFFFFF),
    );
  }

  void _drawHorizonGlow(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              primary.withOpacity(0.3),
              secondary.withOpacity(0.15),
            ],
          ).createShader(
            Rect.fromLTWH(0, size.height * 0.5, size.width, size.height * 0.5),
          );
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.5, size.width, size.height * 0.5),
      paint,
    );
  }

  void _drawGeometricPattern(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 0.7
      ..style = PaintingStyle.stroke;

    const spacing = 44.0;
    for (double x = -size.height; x < size.width + size.height; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), p);
      canvas.drawLine(Offset(x, 0), Offset(x - size.height, size.height), p);
    }
  }

  @override
  bool shouldRepaint(_SkyPainter old) =>
      old.phase != phase || old.t != t || old.starsT != starsT;
}

// ═══════════════════════════════════════════════════════════════
//  FLOATING PARTICLES
// ═══════════════════════════════════════════════════════════════
class _FloatingParticles extends StatefulWidget {
  final _PrayerVisual visual;
  const _FloatingParticles({required this.visual});

  @override
  State<_FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<_FloatingParticles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  static final _rng = math.Random(99);
  static final _particles = List.generate(
    18,
    (i) => _Particle(
      x: _rng.nextDouble(),
      y: _rng.nextDouble(),
      size: 1.0 + _rng.nextDouble() * 2.5,
      speed: 0.0002 + _rng.nextDouble() * 0.0004,
      phase: _rng.nextDouble() * 2 * math.pi,
    ),
  );

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        painter: _ParticlePainter(
          particles: _particles,
          t: _ctrl.value,
          color: widget.visual.secondaryColor,
        ),
        // We remove size: Size.infinite because it causes offsets to be Infinity.
        // Being inside a Positioned.fill already provides the correct layout constraints.
        size: Size.copy(MediaQuery.sizeOf(context)),
      ),
    );
  }
}

class _Particle {
  final double x, y, size, speed, phase;
  const _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.phase,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double t;
  final Color color;

  _ParticlePainter({
    required this.particles,
    required this.t,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    for (final p in particles) {
      final dx = math.sin(t * 2 * math.pi + p.phase) * 20;
      final dy = -(t * size.height * 0.3 + p.y * size.height) % size.height;
      final opacity = (0.1 + 0.15 * math.sin(t * 2 * math.pi + p.phase + 1))
          .clamp(0.0, 1.0);

      canvas.drawCircle(
        Offset(p.x * size.width + dx, dy),
        p.size,
        Paint()
          ..color = color.withOpacity(opacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.t != t;
}

// ═══════════════════════════════════════════════════════════════
//  TOP BAR
// ═══════════════════════════════════════════════════════════════
class _TopBar extends StatelessWidget {
  final String cityName;
  final VoidCallback onRefresh;
  final AnimationController entryCtrl;

  const _TopBar({
    required this.cityName,
    required this.onRefresh,
    required this.entryCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: entryCtrl,
        curve: const Interval(0, 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'أوقات الصلاة',
                    style: GoogleFonts.amiri(
                      fontSize: 22,
                      color: context.colors.gold,
                      fontWeight: FontWeight.w700,
                      shadows: [
                        Shadow(
                          color: context.colors.gold.withOpacity(0.4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 12,
                        color: context.colors.textSecondary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        cityName,
                        style: GoogleFonts.notoNaskhArabic(
                          fontSize: 12,
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onRefresh,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                ),
                child: Icon(
                  Icons.my_location_rounded,
                  size: 18,
                  color: context.colors.gold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  MAIN PRAYER CARD
// ═══════════════════════════════════════════════════════════════
class _MainPrayerCard extends StatelessWidget {
  final PrayerScreenState state;
  final _PrayerVisual visual;
  final Animation<double> pulseAnim;
  final AnimationController entryCtrl;

  const _MainPrayerCard({
    required this.state,
    required this.visual,
    required this.pulseAnim,
    required this.entryCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final next = state.next;
    if (next == null) return const SizedBox();

    final remaining = state.remaining ?? Duration.zero;
    final iqamaTime = state.iqamaTime;
    final isIqama = state.isIqamaPhase;

    return FadeTransition(
      opacity: CurvedAnimation(
        parent: entryCtrl,
        curve: const Interval(0.1, 0.7),
      ),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: entryCtrl,
                curve: const Interval(0.1, 0.7, curve: Curves.easeOutCubic),
              ),
            ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // ── اسم الصلاة + الأيقونة ──
              _PrayerNameBadge(visual: visual, isIqama: isIqama),
              const SizedBox(height: 20),

              // ── الساعة الرئيسية (العداد) ──
              _CountdownRing(
                remaining: remaining,
                visual: visual,
                isIqama: isIqama,
                pulseAnim: pulseAnim,
              ),
              const SizedBox(height: 24),

              // ── صف وقت الأذان و الإقامة ──
              _AdhanIqamaRow(
                adhanTime: next.time,
                iqamaTime: iqamaTime,
                iqamaOffset: _kIqamaOffsets[next.name] ?? 15,
                isIqamaPhase: isIqama,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── شارة اسم الصلاة ──
class _PrayerNameBadge extends StatelessWidget {
  final _PrayerVisual visual;
  final bool isIqama;

  const _PrayerNameBadge({required this.visual, required this.isIqama});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // الأيقونة
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                visual.secondaryColor.withOpacity(0.3),
                Colors.transparent,
              ],
            ),
            border: Border.all(
              color: visual.secondaryColor.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: visual.secondaryColor.withOpacity(0.2),
                blurRadius: 20,
              ),
            ],
          ),
          child: Center(
            child: Text(visual.emoji, style: const TextStyle(fontSize: 26)),
          ),
        ),
        const SizedBox(height: 10),

        // الاسم
        Text(
          isIqama ? 'وقت الإقامة — ${visual.nameAr}' : 'صلاة ${visual.nameAr}',
          style: GoogleFonts.amiri(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.w700,
            shadows: [
              Shadow(
                color: visual.secondaryColor.withOpacity(0.6),
                blurRadius: 16,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isIqama ? 'أقم الصلاة' : 'الصلاة القادمة',
          style: GoogleFonts.notoNaskhArabic(
            fontSize: 12,
            color: Colors.white.withOpacity(0.55),
          ),
        ),
      ],
    );
  }
}

// ── دائرة العداد المتناقص ──
class _CountdownRing extends StatelessWidget {
  final Duration remaining;
  final _PrayerVisual visual;
  final bool isIqama;
  final Animation<double> pulseAnim;

  const _CountdownRing({
    required this.remaining,
    required this.visual,
    required this.isIqama,
    required this.pulseAnim,
  });

  String get _timeStr {
    if (remaining.isNegative) return '٠٠:٠٠:٠٠';
    final h = remaining.inHours;
    final m = (remaining.inMinutes % 60).toString().padLeft(2, '0');
    final s = (remaining.inSeconds % 60).toString().padLeft(2, '0');
    if (h > 0) return '$h:$m:$s';
    return '$m:$s';
  }

  double get _progress {
    // نسبة الوقت المتبقي من الوقت الكامل بين صلاتين (~4-6 ساعات)
    final maxSecs = isIqama ? 1200.0 : 21600.0; // 20 دقيقة أو 6 ساعات
    return (remaining.inSeconds / maxSecs).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: pulseAnim,
      child: SizedBox(
        width: 220,
        height: 220,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // حلقات خارجية (halo)
            ...List.generate(
              3,
              (i) => Container(
                width: 220 - i * 28.0,
                height: 220 - i * 28.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: visual.secondaryColor.withOpacity(0.06 + i * 0.04),
                    width: 1,
                  ),
                ),
              ),
            ),

            // الحلقة الرئيسية
            CustomPaint(
              size: const Size(200, 200),
              painter: _CountdownArcPainter(
                progress: _progress,
                primaryColor: visual.secondaryColor,
                successColor: context.colors.success,
                tealColor: context.colors.teal,
                isIqama: isIqama,
              ),
            ),

            // المحتوى الداخلي
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    visual.primaryColor.withOpacity(0.8),
                    visual.primaryColor.withOpacity(0.4),
                  ],
                ),
                border: Border.all(
                  color: visual.secondaryColor.withOpacity(0.2),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isIqama ? 'الإقامة بعد' : 'الأذان بعد',
                    style: GoogleFonts.notoNaskhArabic(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.55),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _timeStr,
                    style: GoogleFonts.notoNaskhArabic(
                      fontSize: remaining.inHours > 0 ? 26 : 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: visual.secondaryColor.withOpacity(0.5),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.12)),
                    ),
                    child: Text(
                      isIqama ? '🕌 أقم الصلاة' : '🔔 استعد',
                      style: GoogleFonts.notoNaskhArabic(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountdownArcPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color successColor;
  final Color tealColor;
  final bool isIqama;

  _CountdownArcPainter({
    required this.progress,
    required this.primaryColor,
    required this.successColor,
    required this.tealColor,
    required this.isIqama,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = (size.width - 14) / 2;
    final rect = Rect.fromCircle(center: c, radius: r);

    // Track
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = Colors.white.withOpacity(0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10,
    );

    if (progress <= 0) return;

    // Outer glow
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..shader = SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: 3 * math.pi / 2,
          colors: isIqama
              ? [
                  successColor,
                  tealColor,
                  successColor,
                ]
              : [primaryColor, Colors.white.withOpacity(0.9), primaryColor],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Solid arc
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..shader = SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: 3 * math.pi / 2,
          colors: isIqama
              ? [
                  successColor,
                  tealColor,
                  successColor,
                ]
              : [primaryColor, Colors.white, primaryColor],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );

    // End dot
    final angle = -math.pi / 2 + 2 * math.pi * progress;
    final dx = c.dx + r * math.cos(angle);
    final dy = c.dy + r * math.sin(angle);
    canvas.drawCircle(
      Offset(dx, dy),
      8,
      Paint()
        ..color = Colors.white
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(
      Offset(dx, dy),
      5,
      Paint()..color = isIqama ? successColor : primaryColor,
    );
  }

  @override
  bool shouldRepaint(_CountdownArcPainter old) =>
      old.progress != progress || old.isIqama != isIqama;
}

// ── صف الأذان والإقامة ──
class _AdhanIqamaRow extends StatelessWidget {
  final DateTime adhanTime;
  final DateTime? iqamaTime;
  final int iqamaOffset;
  final bool isIqamaPhase;

  const _AdhanIqamaRow({
    required this.adhanTime,
    required this.iqamaTime,
    required this.iqamaOffset,
    required this.isIqamaPhase,
  });

  String _fmt(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour < 12 ? 'ص' : 'م';
    return '$h:$m $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TimeCard(
            label: 'وقت الأذان',
            time: _fmt(adhanTime),
            icon: '📢',
            color: context.colors.gold,
            isActive: !isIqamaPhase,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TimeCard(
            label: 'وقت الإقامة',
            time: iqamaTime != null ? _fmt(iqamaTime!) : '+$iqamaOffsetد',
            icon: '🕌',
            color: context.colors.success,
            isActive: isIqamaPhase,
            subtitle: 'بعد $iqamaOffset دقيقة',
          ),
        ),
      ],
    );
  }
}

class _TimeCard extends StatelessWidget {
  final String label, time, icon;
  final Color color;
  final bool isActive;
  final String? subtitle;

  const _TimeCard({
    required this.label,
    required this.time,
    required this.icon,
    required this.color,
    required this.isActive,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: isActive
            ? color.withOpacity(0.15)
            : Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? color.withOpacity(0.4)
              : Colors.white.withOpacity(0.1),
          width: isActive ? 1.5 : 1,
        ),
        boxShadow: isActive
            ? [BoxShadow(color: color.withOpacity(0.2), blurRadius: 12)]
            : null,
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.notoNaskhArabic(
              fontSize: 10,
              color: Colors.white.withOpacity(0.55),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: GoogleFonts.notoNaskhArabic(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isActive ? color : Colors.white,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: GoogleFonts.notoNaskhArabic(
                fontSize: 9,
                color: color.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  DAILY PRAYERS TABLE
// ═══════════════════════════════════════════════════════════════
class _DailyPrayersTable extends StatelessWidget {
  final List<PrayerTimeInfo> prayers;
  final String currentKey;
  final Map<String, int> iqamaOffsets;
  final AnimationController entryCtrl;

  const _DailyPrayersTable({
    required this.prayers,
    required this.currentKey,
    required this.iqamaOffsets,
    required this.entryCtrl,
  });

  String _fmt(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour < 12 ? 'ص' : 'م';
    return '$h:$m $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: entryCtrl,
        curve: const Interval(0.4, 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'جدول الصلوات اليوم',
                      style: GoogleFonts.amiri(
                        fontSize: 15,
                        color: context.colors.gold,
                      ),
                    ),
                    Text(
                      DateFormat('EEEE d MMMM', 'ar').format(DateTime.now()),
                      style: GoogleFonts.notoNaskhArabic(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ),
              Container(height: 1, color: Colors.white.withOpacity(0.06)),

              ...prayers.asMap().entries.map((e) {
                final i = e.key;
                final p = e.value;
                final isNext = p.name == currentKey;
                final isPast = DateTime.now().isAfter(p.time);
                final iqama = p.time.add(
                  Duration(minutes: iqamaOffsets[p.name] ?? 15),
                );

                return _PrayerTableRow(
                  prayer: p,
                  iqamaTime: iqama,
                  isNext: isNext,
                  isPast: isPast,
                  isLast: i == prayers.length - 1,
                  formatTime: _fmt,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrayerTableRow extends StatelessWidget {
  final PrayerTimeInfo prayer;
  final DateTime iqamaTime;
  final bool isNext, isPast, isLast;
  final String Function(DateTime) formatTime;

  const _PrayerTableRow({
    required this.prayer,
    required this.iqamaTime,
    required this.isNext,
    required this.isPast,
    required this.isLast,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    final visual = _kPrayerVisuals[prayer.name]!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: isNext
            ? visual.secondaryColor.withOpacity(0.12)
            : Colors.transparent,
        borderRadius: isLast
            ? const BorderRadius.vertical(bottom: Radius.circular(20))
            : null,
        border: isNext
            ? Border(right: BorderSide(color: visual.secondaryColor, width: 3))
            : null,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                // أيقونة + اسم
                Text(prayer.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prayer.nameAr,
                        style: GoogleFonts.notoNaskhArabic(
                          fontSize: 13,
                          color: isNext
                              ? Colors.white
                              : isPast
                              ? Colors.white.withOpacity(0.35)
                              : Colors.white.withOpacity(0.75),
                          fontWeight: isNext
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                      if (isNext)
                        Text(
                          'الأذان الآن',
                          style: GoogleFonts.notoNaskhArabic(
                            fontSize: 9,
                            color: visual.secondaryColor,
                          ),
                        ),
                    ],
                  ),
                ),

                // وقت الأذان
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      formatTime(prayer.time),
                      style: GoogleFonts.notoNaskhArabic(
                        fontSize: 14,
                        color: isNext
                            ? Colors.white
                            : isPast
                            ? Colors.white.withOpacity(0.3)
                            : Colors.white.withOpacity(0.65),
                        fontWeight: isNext ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                    Text(
                      'أذان',
                      style: GoogleFonts.notoNaskhArabic(
                        fontSize: 8,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),

                Container(
                  width: 1,
                  height: 28,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  color: Colors.white.withOpacity(0.08),
                ),

                // وقت الإقامة
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      formatTime(iqamaTime),
                      style: GoogleFonts.notoNaskhArabic(
                        fontSize: 14,
                        color: isNext
                            ? context.colors.success
                            : isPast
                            ? Colors.white.withOpacity(0.25)
                            : Colors.white.withOpacity(0.5),
                        fontWeight: isNext ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                    Text(
                      'إقامة',
                      style: GoogleFonts.notoNaskhArabic(
                        fontSize: 8,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),

                // علامة ✓ للماضي
                if (isPast && !isNext) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: context.colors.success.withOpacity(0.4),
                  ),
                ],
              ],
            ),
          ),
          if (!isLast)
            Container(height: 1, color: Colors.white.withOpacity(0.04)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  OVERLAYS
// ═══════════════════════════════════════════════════════════════
class _LoadingOverlay extends StatefulWidget {
  const _LoadingOverlay();

  @override
  State<_LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<_LoadingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => Transform.rotate(
              angle: _ctrl.value * 2 * math.pi,
              child: SizedBox(
                width: 60,
                height: 60,
                child: CustomPaint(painter: _LoadingRingPainter(_ctrl.value, context.colors.gold)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'جارٍ تحديد موقعك...',
            style: GoogleFonts.notoNaskhArabic(
              fontSize: 13,
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'لحساب أوقات الصلاة',
            style: GoogleFonts.notoNaskhArabic(
              fontSize: 11,
              color: context.colors.textDim,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingRingPainter extends CustomPainter {
  final double t;
  final Color color;
  _LoadingRingPainter(this.t, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 4;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      0,
      math.pi * 1.5,
      false,
      Paint()
        ..shader = SweepGradient(
          colors: [color, Colors.transparent],
        ).createShader(Rect.fromCircle(center: c, radius: r))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_LoadingRingPainter old) => old.t != t;
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('📍', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            'تعذّر تحديد الموقع',
            style: GoogleFonts.amiri(
              fontSize: 18,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'تأكد من تفعيل GPS',
            style: GoogleFonts.notoNaskhArabic(
              fontSize: 12,
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.gold,
              foregroundColor: context.colors.night,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'إعادة المحاولة',
              style: GoogleFonts.notoNaskhArabic(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
