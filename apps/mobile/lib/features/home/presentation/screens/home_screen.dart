// ═══════════════════════════════════════════════════════════════
//  lib/features/home/presentation/screens/home_screen.dart
// تقوى — Home Dashboard (الشاشة الرئيسية المدمجة)
// ═══════════════════════════════════════════════════════════════

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'package:takwa/app/animated_drawer.dart';
import 'package:takwa/core/theme/ramadan_theme.dart';
import 'package:takwa/core/database/app_database.dart';
import 'package:takwa/app/main_shell.dart';
import 'package:takwa/core/notifications/overlay_background_service.dart';
import 'package:takwa/core/providers/database_providers.dart';
import 'package:takwa/core/widgets/custom_pattern_background.dart';
import 'package:takwa/features/prayer/presentation/screens/prayer_screen.dart';

// ═══════════════════════════════════════════════════════════════
//  HOME SCREEN
// ═══════════════════════════════════════════════════════════════
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _staggerCtrl;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;
  final _scrollCtrl = ScrollController();
  bool _headerCollapsed = false;
  static const _sectionCount = 11;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _scrollCtrl.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dailyRecordDaoProvider).getOrCreateToday();
      _staggerCtrl.forward();
      // Auto-start the background overlay service (adhkar + adhan)
      OverlayBackgroundService.start();
    });
  }

  void _initAnimations() {
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnims = List.generate(_sectionCount, (i) {
      final s = i * 0.08, e = (s + 0.3).clamp(0.0, 1.0);
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _staggerCtrl,
          curve: Interval(s, e, curve: Curves.easeOut),
        ),
      );
    });
    _slideAnims = List.generate(_sectionCount, (i) {
      final s = i * 0.08, e = (s + 0.3).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.05),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _staggerCtrl,
          curve: Interval(s, e, curve: Curves.easeOutCubic),
        ),
      );
    });
  }

  void _onScroll() {
    final c = _scrollCtrl.offset > 70;
    if (c != _headerCollapsed) setState(() => _headerCollapsed = c);
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Widget _anim(int i, Widget child) => FadeTransition(
    opacity: _fadeAnims[i],
    child: SlideTransition(position: _slideAnims[i], child: child),
  );

  @override
  Widget build(BuildContext context) {
    final isRamadan = ref.watch(ramadanModeProvider).value ?? false;
    final todayAsync = ref.watch(todayRecordProvider);
    final streakAsync = ref.watch(currentStreakProvider);
    final prayerState = ref.watch(prayerScreenProvider);
    final style = AdaptiveStyle(context, isRamadan);

    final hijri = HijriCalendar.now();
    final hijriStr = '${hijri.hDay} ${_hMonth(hijri.hMonth)} ${hijri.hYear}';
    final miladi = DateFormat('EEEE، d MMMM yyyy', 'ar').format(DateTime.now());

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: style.bg,
        body: Stack(
          children: [
            // ── Dynamic Background ──
            const Positioned.fill(
              child: CustomPatternBackground(pattern: BackgroundPattern.adhkar),
            ),

            CustomScrollView(
              controller: _scrollCtrl,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── SliverAppBar ──
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  expandedHeight: 130,
                  collapsedHeight: 64,
                  pinned: true,
                  elevation: 0,
                  surfaceTintColor: Colors.transparent,
                  leading: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: DrawerMenuButton(),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    background: _anim(
                      0,
                      _HomeHeader(
                        hijriStr: hijriStr,
                        miladiStr: miladi,
                        style: style,
                        isRamadan: isRamadan,
                      ),
                    ),
                    title: AnimatedOpacity(
                      opacity: _headerCollapsed ? 1 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: Text(
                        hijriStr,
                        style: style.amiri(14, color: style.gold),
                      ),
                    ),
                    centerTitle: true,
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 4),

                      // ① Ramadan Banner
                      if (hijri.hMonth == 9 || isRamadan)
                        _anim(
                          0,
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _RamadanBanner(
                              style: style,
                              day: hijri.hDay,
                              isRamadan: isRamadan,
                            ),
                          ),
                        ),

                      // ② Next Prayer Card
                      if (prayerState.next != null)
                        _anim(
                          1,
                          _NextPrayerCardMerged(
                            style: style,
                            prayerState: prayerState,
                          ),
                        ),
                      if (prayerState.next != null) const SizedBox(height: 14),

                      // ③ Prayer Times Mosque Section
                      if (prayerState.prayers.isNotEmpty)
                        _anim(
                          2,
                          _MosquePrayerSection(
                            style: style,
                            prayers: prayerState.prayers,
                            currentKey: prayerState.next?.name ?? '',
                          ),
                        ),
                      if (prayerState.prayers.isNotEmpty)
                        const SizedBox(height: 14),

                      // ④ Taqwa Ring
                      _anim(
                        3,
                        todayAsync.when(
                          loading: () => _Skeleton(style: style, height: 110),
                          error: (_, _) => const SizedBox(),
                          data: (r) => _TaqwaSectionMerged(
                            record: r,
                            streakAsync: streakAsync,
                            style: style,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ⑤ Quick Ibadah Grid
                      _anim(
                        4,
                        todayAsync.when(
                          loading: () => _Skeleton(style: style, height: 180),
                          error: (_, _) => const SizedBox(),
                          data: (r) =>
                              _QuickIbadahGridMerged(record: r, style: style),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ⑥ Features Row
                      _anim(5, _FeatureRow(style: style)),
                      const SizedBox(height: 14),

                      // ⑦ Books Section
                      //     _anim(6, _BooksSection(style: style)),
                      // const SizedBox(height: 14),

                      // ⑧ Verse Card
                      _anim(
                        7,
                        _VerseCardMerged(style: style, isRamadan: isRamadan),
                      ),
                      const SizedBox(height: 14),

                      // ⑨ Ramadan Iftar
                      if (isRamadan)
                        _anim(8, _RamadanIftar(style: style, hijri: hijri)),

                      // ⑩ Daily Dhikr
                      _anim(9, _DailyDhikrCard(style: style)),
                      const SizedBox(height: 100),
                    ]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _hMonth(int m) => const [
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

// ─────────────────────────────────────────
//  HEADER
// ─────────────────────────────────────────
class _HomeHeader extends StatelessWidget {
  final String hijriStr, miladiStr;
  final AdaptiveStyle style;
  final bool isRamadan;
  const _HomeHeader({
    required this.hijriStr,
    required this.miladiStr,
    required this.style,
    required this.isRamadan,
  });

  @override
  Widget build(BuildContext context) {
    final h = DateTime.now().hour;
    final g = h < 12
        ? 'صباح الخير 🌅'
        : h < 17
        ? 'مساء الخير 🌤'
        : 'مساء النور 🌙';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 47, 16, 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            style.gold.withOpacity(isRamadan ? 0.15 : 0.08),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 40), // Space for Drawer button
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(hijriStr, style: style.amiri(19)),
                Text(miladiStr, style: style.naskh(11, color: style.textSec)),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: style.goldDim,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: style.gold.withOpacity(0.2)),
                ),
                child: Text(g, style: style.naskh(11, color: style.goldLight)),
              ),
              const SizedBox(width: 8),
              const RamadanToggle(),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
//  RAMADAN BANNER
// ─────────────────────────────────────────
class _RamadanBanner extends StatefulWidget {
  final AdaptiveStyle style;
  final int day;
  final bool isRamadan;
  const _RamadanBanner({
    required this.style,
    required this.day,
    required this.isRamadan,
  });

  @override
  State<_RamadanBanner> createState() => _RamadanBannerState();
}

class _RamadanBannerState extends State<_RamadanBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.style;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              s.gold.withOpacity(0.15 + 0.05 * _ctrl.value),
              s.success.withOpacity(0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: s.gold.withOpacity(0.25 + 0.15 * _ctrl.value),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: s.gold.withOpacity(0.08 * _ctrl.value),
              blurRadius: 16,
            ),
          ],
        ),
        child: Row(
          children: [
            Text('🌙', style: TextStyle(fontSize: 28, color: s.goldLight)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('رمضان كريم', style: s.amiri(18, color: s.goldLight)),
                  Text(
                    'اليوم ${widget.day} من شهر رمضان المبارك',
                    style: s.naskh(11, color: s.textSec),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Text('${30 - widget.day}', style: s.amiri(22, color: s.gold)),
                Text(
                  'يوم\nمتبقي',
                  style: s.naskh(9, color: s.textSec),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  NEXT PRAYER CARD MERGED
// ─────────────────────────────────────────
class _NextPrayerCardMerged extends StatefulWidget {
  final AdaptiveStyle style;
  final PrayerScreenState prayerState;
  const _NextPrayerCardMerged({required this.style, required this.prayerState});

  @override
  State<_NextPrayerCardMerged> createState() => _NextPrayerCardMergedState();
}

class _NextPrayerCardMergedState extends State<_NextPrayerCardMerged>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  String _getEmoji(String key) {
    switch (key) {
      case 'fajr':
        return '🌙';
      case 'sunrise':
        return '🌅';
      case 'dhuhr':
        return '🌤';
      case 'asr':
        return '🌇';
      case 'maghrib':
        return '🌆';
      case 'isha':
        return '🌃';
      default:
        return '🕌';
    }
  }

  String _getArabicName(String key) {
    switch (key) {
      case 'fajr':
        return 'الفجر';
      case 'sunrise':
        return 'الشروق';
      case 'dhuhr':
        return 'الظهر';
      case 'asr':
        return 'العصر';
      case 'maghrib':
        return 'المغرب';
      case 'isha':
        return 'العشاء';
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.style;
    final next = widget.prayerState.next!;
    final diff = widget.prayerState.remaining ?? const Duration();
    String countdown;
    if (diff.isNegative || diff.inSeconds == 0) {
      countdown = 'حان الوقت الآن';
    } else {
      final h = diff.inHours;
      final m = diff.inMinutes % 60;
      countdown = h > 0 ? 'بعد $hس $mد' : 'بعد $m دقيقة';
    }

    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, _) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              s.gold.withOpacity(0.15 + 0.05 * _pulse.value),
              s.teal.withOpacity(0.07),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: s.gold.withOpacity(0.2 + 0.1 * _pulse.value),
          ),
          boxShadow: [
            BoxShadow(
              color: s.gold.withOpacity(0.06 + 0.06 * _pulse.value),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: s.goldDim,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: s.gold.withOpacity(0.2 + 0.15 * _pulse.value),
                ),
                boxShadow: [
                  BoxShadow(
                    color: s.gold.withOpacity(0.12 * _pulse.value),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _getEmoji(next.name),
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الصلاة القادمة', style: s.naskh(10, color: s.textSec)),
                  Text('صلاة ${_getArabicName(next.name)}', style: s.amiri(19)),
                  Text(
                    DateFormat('HH:mm').format(next.time),
                    style: s.naskh(12, color: s.textSec),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/prayer'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: s.gold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: s.gold.withOpacity(0.25)),
                ),
                child: Text(
                  countdown,
                  style: s.naskh(
                    11,
                    color: widget.prayerState.isIqamaPhase
                        ? Colors.redAccent
                        : s.goldLight,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  MOSQUE PRAYER SECTION (REDESIGNED)
// ─────────────────────────────────────────
class _MosquePrayerSection extends StatelessWidget {
  final List<dynamic> prayers;
  final String currentKey;
  final AdaptiveStyle style;
  const _MosquePrayerSection({
    required this.prayers,
    required this.currentKey,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8, bottom: 8),
          child: Row(
            children: [
              Text('أوقات الصلاة', style: style.amiri(15, color: style.gold)),
              const SizedBox(width: 8),
              Expanded(
                child: Container(height: 1, color: style.gold.withOpacity(0.2)),
              ),
            ],
          ),
        ),
        ClipPath(
          clipper: MosqueClipper(),
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: style.gold.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Background Image
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/SL-020520-27660-18.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
                // Overlay Gradient
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          style.bg.withOpacity(0.4),
                          style.bg.withOpacity(0.85),
                        ],
                      ),
                    ),
                  ),
                ),
                // Pattern Overlay
                const Positioned.fill(
                  child: Opacity(
                    opacity: 0.1,
                    child: CustomPatternBackground(
                      pattern: BackgroundPattern.duas,
                    ),
                  ),
                ),
                // Content
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 110,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        physics: const BouncingScrollPhysics(),
                        itemCount: prayers.length,
                        separatorBuilder: (_, i) => const SizedBox(width: 10),
                        itemBuilder: (_, i) {
                          final prayer = prayers[i];
                          final isActive = prayer.name == currentKey;
                          return _MihrabPrayerChip(
                            prayer: prayer,
                            isActive: isActive,
                            style: style,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MihrabPrayerChip extends StatelessWidget {
  final dynamic prayer;
  final bool isActive;
  final AdaptiveStyle style;
  const _MihrabPrayerChip({
    required this.prayer,
    required this.isActive,
    required this.style,
  });

  String _getEmoji(String key) {
    switch (key) {
      case 'fajr':
        return '🌙';
      case 'sunrise':
        return '🌅';
      case 'dhuhr':
        return '🌤';
      case 'asr':
        return '🌇';
      case 'maghrib':
        return '🌆';
      case 'isha':
        return '🌃';
      default:
        return '🕌';
    }
  }

  String _getArabicName(String key) {
    switch (key) {
      case 'fajr':
        return 'الفجر';
      case 'sunrise':
        return 'الشروق';
      case 'dhuhr':
        return 'الظهر';
      case 'asr':
        return 'العصر';
      case 'maghrib':
        return 'المغرب';
      case 'isha':
        return 'العشاء';
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final emoji = _getEmoji(prayer.name);
    final name = _getArabicName(prayer.name);
    final timeStr = DateFormat('HH:mm').format(prayer.time);

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/prayer'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        width: 70,
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isActive
              ? style.gold.withOpacity(0.15)
              : style.card.withOpacity(0.4),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(35),
            topRight: Radius.circular(35),
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
          border: Border.all(
            color: isActive
                ? style.gold.withOpacity(0.6)
                : style.border.withOpacity(0.3),
            width: isActive ? 1.5 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: style.gold.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            AnimatedScale(
              scale: isActive ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Text(emoji, style: const TextStyle(fontSize: 22)),
            ),
            const Spacer(),
            Text(
              name,
              style: style.naskh(
                11,
                color: isActive ? style.gold : style.textSec,
                weight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              timeStr,
              style: style.amiri(
                13,
                color: isActive
                    ? style.goldLight
                    : style.textSec.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class MosqueClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    path.moveTo(0, h); // Start bottom left
    path.lineTo(0, h * 0.4); // Left wall

    // Left shoulder
    path.quadraticBezierTo(w * 0.05, h * 0.35, w * 0.15, h * 0.35);

    // Left Minaret/Curve
    path.lineTo(w * 0.25, h * 0.35);
    path.quadraticBezierTo(w * 0.3, h * 0.15, w * 0.35, h * 0.15);

    // Main Dome
    path.lineTo(w * 0.4, h * 0.15);
    path.quadraticBezierTo(w * 0.5, 0, w * 0.6, h * 0.15);
    path.lineTo(w * 0.65, h * 0.15);

    // Right Minaret/Curve
    path.quadraticBezierTo(w * 0.7, h * 0.15, w * 0.75, h * 0.35);
    path.lineTo(w * 0.85, h * 0.35);

    // Right shoulder
    path.quadraticBezierTo(w * 0.95, h * 0.35, w, h * 0.4);

    path.lineTo(w, h); // Right wall
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// ─────────────────────────────────────────
//  TAQWA SECTION MERGED
// ─────────────────────────────────────────
class _TaqwaSectionMerged extends StatelessWidget {
  final DailyRecord? record;
  final AsyncValue<int> streakAsync;
  final AdaptiveStyle style;
  const _TaqwaSectionMerged({
    required this.record,
    required this.streakAsync,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final s = style;
    final net = record?.netPoints ?? 0;
    final pct = (net / 100.0).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: s.cardDeco,
      child: Row(
        children: [
          _RingWidget(progress: pct, style: s),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_msg(pct), style: s.amiri(15)),
                const SizedBox(height: 3),
                Text(
                  '${(pct * 10).round()} من ١٠ عبادات',
                  style: s.naskh(11, color: s.textSec),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: s.goldDim,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: s.gold.withOpacity(0.2)),
                      ),
                      child: Text(
                        _level(net),
                        style: s.naskh(11, color: s.gold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () =>
                          Navigator.pushNamed(context, '/achievements'),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: s.gold.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.emoji_events_outlined,
                          size: 16,
                          color: s.gold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                streakAsync.when(
                  loading: () => const SizedBox(height: 22),
                  error: (_, _) => const SizedBox(),
                  data: (n) => n > 0
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: s.success.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: s.success.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🔥', style: TextStyle(fontSize: 12)),
                              const SizedBox(width: 4),
                              Text(
                                '$n يوم متواصل',
                                style: s.naskh(11, color: s.success),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _level(int p) {
    if (p >= 600) return 'متقي ✨';
    if (p >= 300) return 'مجاهد ⚔️';
    if (p >= 100) return 'سالك 🌿';
    return 'مبتدئ 🌱';
  }

  String _msg(double p) {
    if (p >= .9) return 'ما شاء الله! 🌟';
    if (p >= .6) return 'أحسنت، استمر 💪';
    if (p >= .3) return 'بداية جيدة 🌿';
    return 'بسم الله 🤲';
  }
}

class _RingWidget extends StatefulWidget {
  final double progress;
  final AdaptiveStyle style;
  const _RingWidget({required this.progress, required this.style});

  @override
  State<_RingWidget> createState() => _RingWidgetState();
}

class _RingWidgetState extends State<_RingWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _anim = Tween<double>(
      begin: 0,
      end: widget.progress,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, _) => SizedBox(
        width: 88,
        height: 88,
        child: CustomPaint(
          painter: _RingPainterV2(
            progress: _anim.value,
            gold: widget.style.gold,
            teal: widget.style.teal,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(_anim.value * 100).round()}%',
                  style: TextStyle(
                    fontFamily: 'NotoNaskhArabic',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: widget.style.gold,
                    height: 1,
                  ),
                ),
                Text(
                  'اليوم',
                  style: TextStyle(
                    fontFamily: 'NotoNaskhArabic',
                    fontSize: 9,
                    color: widget.style.textSec,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainterV2 extends CustomPainter {
  final double progress;
  final Color gold, teal;
  _RingPainterV2({
    required this.progress,
    required this.gold,
    required this.teal,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = (size.width - 10) / 2;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = gold.withOpacity(0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7,
    );
    if (progress <= 0) return;
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..shader = SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: 3 * math.pi / 2,
          colors: [gold, teal, gold],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );
    final a = -math.pi / 2 + 2 * math.pi * progress;
    final dx = c.dx + r * math.cos(a), dy = c.dy + r * math.sin(a);
    canvas.drawCircle(
      Offset(dx, dy),
      5,
      Paint()
        ..color = gold
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(Offset(dx, dy), 3, Paint()..color = gold);
  }

  @override
  bool shouldRepaint(_RingPainterV2 o) => o.progress != progress;
}

// ─────────────────────────────────────────
//  QUICK IBADAH GRID MERGED
// ─────────────────────────────────────────
class _QuickIbadahGridMerged extends ConsumerWidget {
  final DailyRecord? record;
  final AdaptiveStyle style;
  const _QuickIbadahGridMerged({required this.record, required this.style});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = style;
    final items = [
      ('🌅', 'الفجر', record?.fajrStatus == PrayerStatus.performed),
      ('📖', 'القرآن', (record?.quranPages ?? 0) > 0),
      ('☀️', 'الظهر', record?.dhuhrStatus == PrayerStatus.performed),
      ('🌤', 'العصر', record?.asrStatus == PrayerStatus.performed),
      (
        '⭐',
        'الأذكار',
        (record?.morningAdhkar ?? false) && (record?.eveningAdhkar ?? false),
      ),
      ('🌌', 'قيام الليل', record?.nightPrayer ?? false),
    ];
    return Column(
      children: [
        Row(
          children: [
            Text('عبادات اليوم', style: s.amiri(15)),
            const SizedBox(width: 8),
            Expanded(
              child: Container(height: 1, color: s.border.withOpacity(0.3)),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                Navigator.popUntil(context, (route) => route.isFirst);
                ref.read(currentTabProvider.notifier).state = 2;
              },
              child: Text('عرض الكل ←', style: s.naskh(11, color: s.teal)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.1,
          children: items
              .map(
                (item) => _IbadahChipMerged(
                  emoji: item.$1,
                  label: item.$2,
                  done: item.$3,
                  style: s,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _IbadahChipMerged extends ConsumerWidget {
  final String emoji, label;
  final bool done;
  final AdaptiveStyle style;
  const _IbadahChipMerged({
    required this.emoji,
    required this.label,
    required this.done,
    required this.style,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = style;
    return GestureDetector(
      onTap: () {
        if (label == 'الأذكار') {
          Navigator.pushNamed(context, '/adhkar');
        } else if (label == 'القرآن') {
          Navigator.pushNamed(context, '/quran');
        } else if (label == 'قيام الليل') {
          HapticFeedback.mediumImpact();
          ref.read(currentTabProvider.notifier).state = 1;
        } else {
          HapticFeedback.lightImpact();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          gradient: done
              ? LinearGradient(
                  colors: [
                    s.teal.withOpacity(0.12),
                    s.success.withOpacity(0.08),
                  ],
                )
              : null,
          color: done ? null : s.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: done ? s.success.withOpacity(0.3) : s.border,
          ),
          boxShadow: done
              ? [BoxShadow(color: s.success.withOpacity(0.1), blurRadius: 8)]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 24)),
                if (done)
                  Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      color: style.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: s.card, width: 1.5),
                    ),
                    child: const Center(
                      child: Text(
                        '✓',
                        style: TextStyle(fontSize: 8, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: s.naskh(
                10,
                color: done ? s.success : s.textSec,
                weight: done ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  FEATURE ROW
// ─────────────────────────────────────────
class _FeatureRow extends StatelessWidget {
  final AdaptiveStyle style;
  const _FeatureRow({required this.style});

  static const _features = [
    ('🕌', 'أوقات\nالصلاة', '/prayer'),
    ('📖', 'القرآن', '/quran'),
    ('🧭', 'القبلة', '/qibla'),
    ('📿', 'الأذكار', '/adhkar'),
    ('🤲', 'الأدعية', '/duas'),
    ('✨', 'المسبحة', '/misbaha'),
    ('🕋', 'المساجد', '/mosques'),
    ('📚', 'المكتبة', '/books'),
    ('📊', 'إحصائيات', '/statistics'),
    ('🏆', 'الإنجازات', '/achievements'),
    ('🔔', 'التذكيرات', '/reminders'),
  ];

  @override
  Widget build(BuildContext context) {
    final s = style;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('الميزات', style: s.amiri(15, color: s.gold)),
            const SizedBox(width: 8),
            Expanded(
              child: Container(height: 1, color: s.gold.withOpacity(0.2)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 5,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.85,
          children: _features.map((f) => _FeatureItem(f: f, style: s)).toList(),
        ),
      ],
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final (String, String, String) f;
  final AdaptiveStyle style;
  const _FeatureItem({required this.f, required this.style});

  @override
  Widget build(BuildContext context) {
    final s = style;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.pushNamed(context, f.$3);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [s.gold.withOpacity(0.12), s.teal.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: s.gold.withOpacity(0.25), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: s.gold.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: s.gold.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Text(f.$1, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(height: 8),
            Text(
              f.$2,
              textAlign: TextAlign.center,
              style: s
                  .naskh(9, color: s.text, weight: FontWeight.w600)
                  .copyWith(height: 1.2),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  VERSE CARD MERGED
// ─────────────────────────────────────────
class _VerseCardMerged extends StatelessWidget {
  final AdaptiveStyle style;
  final bool isRamadan;
  static const _verses = [
    ('﴿ وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا ﴾', 'الطلاق: ٢'),
    ('﴿ إِنَّ اللَّهَ مَعَ الصَّابِرِينَ ﴾', 'البقرة: ١٥٣'),
    ('﴿ فَاذْكُرُونِي أَذْكُرْكُمْ ﴾', 'البقرة: ١٥٢'),
    ('﴿ شَهْرُ رَمَضَانَ الَّذِي أُنزِلَ فِيهِ الْقُرْآنُ ﴾', 'البقرة: ١٨٥'),
    ('﴿ إِنَّ اللَّهَ لَا يُضِيعُ أَجْرَ الْمُحْسِنِينَ ﴾', 'التوبة: ١٢٠'),
    ('﴿ وَبَشِّرِ الصَّابِرِينَ ﴾', 'البقرة: ١٥٥'),
  ];

  const _VerseCardMerged({required this.style, required this.isRamadan});

  @override
  Widget build(BuildContext context) {
    final s = style;
    final idx = DateTime.now().day % _verses.length;
    final verse = _verses[isRamadan ? 3 : idx];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            s.gold.withOpacity(isRamadan ? 0.18 : 0.1),
            s.teal.withOpacity(isRamadan ? 0.1 : 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: s.gold.withOpacity(isRamadan ? 0.3 : 0.18)),
        boxShadow: isRamadan
            ? [BoxShadow(color: s.gold.withOpacity(0.08), blurRadius: 16)]
            : null,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 24, height: 1, color: s.gold.withOpacity(0.3)),
              const SizedBox(width: 8),
              Text('❁', style: TextStyle(color: s.gold, fontSize: 14)),
              const SizedBox(width: 8),
              Container(width: 24, height: 1, color: s.gold.withOpacity(0.3)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            verse.$1,
            textAlign: TextAlign.center,
            style: s
                .amiri(
                  isRamadan ? 20 : 18,
                  color: s.goldLight,
                  weight: FontWeight.w400,
                )
                .copyWith(height: 2.0),
          ),
          const SizedBox(height: 8),
          Text(
            isRamadan ? verse.$2 : 'آية اليوم - ${verse.$2}',
            style: s.naskh(10, color: s.textSec),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
//  RAMADAN IFTAR COUNTDOWN
// ─────────────────────────────────────────
class _RamadanIftar extends ConsumerStatefulWidget {
  final AdaptiveStyle style;
  final HijriCalendar hijri;
  const _RamadanIftar({required this.style, required this.hijri});

  @override
  ConsumerState<_RamadanIftar> createState() => _RamadanIftarState();
}

class _RamadanIftarState extends ConsumerState<_RamadanIftar> {
  String _iftarCountdown = '';
  String _suhoorCountdown = '';

  @override
  void initState() {
    super.initState();
    _tick();
  }

  void _tick() {
    if (!mounted) return;
    final now = DateTime.now();
    // In a real app, use actual prayer times
    final iftar = DateTime(now.year, now.month, now.day, 18, 30);
    final suhoor = DateTime(now.year, now.month, now.day + 1, 4, 15);

    _iftarCountdown = _fmt(iftar.difference(now));
    _suhoorCountdown = _fmt(suhoor.difference(now));
    setState(() {});
    Future.delayed(const Duration(seconds: 1), _tick);
  }

  String _fmt(Duration d) {
    if (d.isNegative) return 'مضى ✓';
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.style;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Text('مواقيت رمضان', style: s.amiri(15, color: s.gold)),
              const SizedBox(width: 8),
              Expanded(
                child: Container(height: 1, color: s.gold.withOpacity(0.2)),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _IftarCard(
                label: 'الإفطار',
                countdown: _iftarCountdown,
                icon: '🌙',
                color: s.gold,
                style: s,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _IftarCard(
                label: 'السحور',
                countdown: _suhoorCountdown,
                icon: '🌅',
                color: s.success,
                style: s,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}

class _IftarCard extends StatelessWidget {
  final String label, countdown, icon;
  final Color color;
  final AdaptiveStyle style;
  const _IftarCard({
    required this.label,
    required this.countdown,
    required this.icon,
    required this.color,
    required this.style,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [color.withOpacity(0.12), color.withOpacity(0.05)],
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withOpacity(0.3)),
      boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 8)],
    ),
    child: Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 6),
        Text(label, style: style.naskh(11, color: style.textSec)),
        const SizedBox(height: 4),
        Text(
          countdown,
          style: style.naskh(16, color: color, weight: FontWeight.w700),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────
//  DAILY DHIKR CARD
// ─────────────────────────────────────────
class _DailyDhikrCard extends StatelessWidget {
  final AdaptiveStyle style;
  const _DailyDhikrCard({required this.style});

  static const _dhikrs = [
    'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، سُبْحَانَ اللَّهِ الْعَظِيمِ',
    'لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
    'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ',
    'اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي',
  ];

  @override
  Widget build(BuildContext context) {
    final s = style;
    final idx = DateTime.now().hour % _dhikrs.length;
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/adhkar'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: s.cardDeco,
        child: Row(
          children: [
            const Text('📿', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ذكر اليوم', style: s.naskh(10, color: s.textSec)),
                  const SizedBox(height: 4),
                  Text(
                    _dhikrs[idx],
                    style: s
                        .amiri(14, color: s.text, weight: FontWeight.w400)
                        .copyWith(height: 1.8),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: s.textSec),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  SKELETON
// ─────────────────────────────────────────
class _Skeleton extends StatelessWidget {
  final AdaptiveStyle style;
  final double height;
  const _Skeleton({required this.style, required this.height});

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    decoration: BoxDecoration(
      color: style.card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: style.border),
    ),
    child: Center(
      child: CircularProgressIndicator(color: style.gold, strokeWidth: 2),
    ),
  );
}
