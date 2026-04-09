// ═══════════════════════════════════════════════════════════════
//  lib/features/home/presentation/screens/home_screen.dart
//  محاسبة النفس — Home Dashboard (الشاشة الرئيسية)
// ═══════════════════════════════════════════════════════════════

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'package:muhasabah/core/theme/app_theme.dart';
import 'package:muhasabah/core/database/app_database.dart';
import 'package:muhasabah/core/providers/database_providers.dart';

// ─────────────────────────────────────────
//  STATIC DATA
// ─────────────────────────────────────────
const _kPrayers = [
  _PrayerInfo('الفجر', '04:32', 'fajr', '🌅'),
  _PrayerInfo('الشروق', '06:01', 'sunrise', '☀️'),
  _PrayerInfo('الظهر', '12:18', 'dhuhr', '🌤'),
  _PrayerInfo('العصر', '15:44', 'asr', '🌇'),
  _PrayerInfo('المغرب', '18:26', 'maghrib', '🌆'),
  _PrayerInfo('العشاء', '19:58', 'isha', '🌃'),
];

const _kVerses = [
  '﴿ وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا ﴾',
  '﴿ إِنَّ اللَّهَ مَعَ الصَّابِرِينَ ﴾',
  '﴿ فَاذْكُرُونِي أَذْكُرْكُمْ ﴾',
  '﴿ وَبَشِّرِ الصَّابِرِينَ ﴾',
  '﴿ إِنَّ اللَّهَ لَا يُضِيعُ أَجْرَ الْمُحْسِنِينَ ﴾',
];

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
  bool _appBarCollapsed = false;
  static const _sectionCount = 6;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _scrollCtrl.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dailyRecordDaoProvider).getOrCreateToday();
      _staggerCtrl.forward();
    });
  }

  void _initAnimations() {
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    _fadeAnims = List.generate(_sectionCount, (i) {
      final start = i * 0.13;
      final end = (start + 0.38).clamp(0.0, 1.0);
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _staggerCtrl,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });
    _slideAnims = List.generate(_sectionCount, (i) {
      final start = i * 0.13;
      final end = (start + 0.38).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.10),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _staggerCtrl,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ));
    });
  }

  void _onScroll() {
    final collapsed = _scrollCtrl.offset > 80;
    if (collapsed != _appBarCollapsed) {
      setState(() => _appBarCollapsed = collapsed);
    }
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

  static String _hijriMonthName(int m) => const [
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

  @override
  Widget build(BuildContext context) {
    final todayAsync = ref.watch(todayRecordProvider);
    final streakAsync = ref.watch(currentStreakProvider);

    final hijri = HijriCalendar.now();
    final hijriStr =
        '${hijri.hDay} ${_hijriMonthName(hijri.hMonth)} ${hijri.hYear}';
    final miladiStr =
        DateFormat('EEEE، d MMMM yyyy', 'ar').format(DateTime.now());
    final verse = _kVerses[DateTime.now().day % _kVerses.length];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light
          .copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: AppColors.night,
        body: Stack(
          children: [
            // ── خلفية هندسية ──
            const _GeomBg(),

            // ── المحتوى ──
            CustomScrollView(
              controller: _scrollCtrl,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ────────────────── SliverAppBar ──────────────────
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  expandedHeight: 136,
                  collapsedHeight: 62,
                  pinned: true,
                  elevation: 0,
                  surfaceTintColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    background: _anim(
                      0,
                      _DateHeader(hijriStr: hijriStr, miladiStr: miladiStr),
                    ),
                    title: AnimatedOpacity(
                      opacity: _appBarCollapsed ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 180),
                      child: Text(
                        hijriStr,
                        style: GoogleFonts.amiri(
                            fontSize: 14, color: AppColors.gold),
                      ),
                    ),
                    centerTitle: true,
                  ),
                ),

                // ────────────────── Body ──────────────────
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // ① الصلاة القادمة
                      _anim(1, _NextPrayerCard(prayer: _kPrayers[4])),
                      const SizedBox(height: 14),

                      // ② حلقة التقوى
                      _anim(
                        2,
                        todayAsync.when(
                          loading: () => const _Skeleton(height: 108),
                          error: (_, __) => const SizedBox(),
                          data: (r) => _TaqwaSection(
                            record: r,
                            streakAsync: streakAsync,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ③ أوقات الصلاة
                      _anim(3, const _PrayerTimesRow()),
                      const SizedBox(height: 14),

                      // ④ عبادات اليوم
                      _anim(
                        4,
                        todayAsync.when(
                          loading: () => const _Skeleton(height: 180),
                          error: (_, __) => const SizedBox(),
                          data: (r) => _QuickIbadahGrid(record: r),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ⑤ آية اليوم
                      _anim(5, _VerseCard(verse: verse)),
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
}

// ═══════════════════════════════════════════════════════════════
//  BACKGROUND
// ═══════════════════════════════════════════════════════════════
class _GeomBg extends StatelessWidget {
  const _GeomBg();

  @override
  Widget build(BuildContext context) =>
      Positioned.fill(child: CustomPaint(painter: _GeomPainter()));
}

class _GeomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0x09C8A96E)
      ..strokeWidth = 0.7
      ..style = PaintingStyle.stroke;

    for (double x = -size.height; x < size.width + size.height; x += 48) {
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), p);
      canvas.drawLine(Offset(x, 0), Offset(x - size.height, size.height), p);
    }

    canvas.drawCircle(
      Offset(size.width / 2, -60),
      240,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0x1AC8A96E), Colors.transparent],
        ).createShader(
            Rect.fromCircle(center: Offset(size.width / 2, -60), radius: 240)),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}

// ═══════════════════════════════════════════════════════════════
//  DATE HEADER
// ═══════════════════════════════════════════════════════════════
class _DateHeader extends StatelessWidget {
  final String hijriStr;
  final String miladiStr;
  const _DateHeader({required this.hijriStr, required this.miladiStr});

  @override
  Widget build(BuildContext context) {
    final h = DateTime.now().hour;
    final greeting = h < 12
        ? 'صباح الخير 🌅'
        : h < 18
            ? 'مساء الخير 🌤'
            : 'مساء النور 🌙';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 56, 16, 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x24C8A96E), Colors.transparent],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(hijriStr,
                  style: GoogleFonts.amiri(
                      fontSize: 19, color: AppColors.gold, height: 1.2)),
              const SizedBox(height: 2),
              Text(miladiStr,
                  style: GoogleFonts.notoNaskhArabic(
                      fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.goldDim,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.gold.withOpacity(0.22)),
            ),
            child: Text(greeting,
                style: GoogleFonts.notoNaskhArabic(
                    fontSize: 12, color: AppColors.goldLight)),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  NEXT PRAYER CARD
// ═══════════════════════════════════════════════════════════════
class _NextPrayerCard extends StatefulWidget {
  final _PrayerInfo prayer;
  const _NextPrayerCard({required this.prayer});

  @override
  State<_NextPrayerCard> createState() => _NextPrayerCardState();
}

class _NextPrayerCardState extends State<_NextPrayerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  String _countdown = '';

  @override
  void initState() {
    super.initState();
    _pulse =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
    _updateCountdown();
  }

  void _updateCountdown() {
    if (!mounted) return;
    final now = DateTime.now();
    final target = DateTime(now.year, now.month, now.day, 18, 26);
    final diff = target.difference(now);
    if (diff.isNegative) {
      _countdown = 'حان الوقت الآن';
    } else {
      final h = diff.inHours;
      final m = diff.inMinutes % 60;
      _countdown = h > 0 ? 'بعد $hس $mد' : 'بعد $m دقيقة';
    }
    setState(() {});
    Future.delayed(const Duration(seconds: 60), _updateCountdown);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0x22C8A96E), Color(0x0F3AAFA9)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withOpacity(0.22)),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          // أيقونة نابضة
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, __) => Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.goldDim,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color:
                        AppColors.gold.withOpacity(0.08 + 0.14 * _pulse.value),
                    blurRadius: 10 + 10 * _pulse.value,
                  )
                ],
              ),
              child: Center(
                child: Text(widget.prayer.emoji,
                    style: const TextStyle(fontSize: 24)),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // معلومات الصلاة
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('الصلاة القادمة',
                    style: GoogleFonts.notoNaskhArabic(
                        fontSize: 10, color: AppColors.textSecondary)),
                Text('صلاة ${widget.prayer.name}',
                    style: GoogleFonts.amiri(
                        fontSize: 19,
                        color: AppColors.gold,
                        fontWeight: FontWeight.w700)),
                Text(widget.prayer.time,
                    style: GoogleFonts.notoNaskhArabic(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),

          // العد التنازلي
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.gold.withOpacity(0.25)),
            ),
            child: Text(_countdown,
                style: GoogleFonts.notoNaskhArabic(
                    fontSize: 11,
                    color: AppColors.goldLight,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  TAQWA SECTION
// ═══════════════════════════════════════════════════════════════
class _TaqwaSection extends ConsumerWidget {
  final DailyRecord? record;
  final AsyncValue<int> streakAsync;
  const _TaqwaSection({required this.record, required this.streakAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final net = record?.netPoints ?? 0;
    final pct = (net / 100.0).clamp(0.0, 1.0);
    final done = (pct * 10).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card,
      child: Row(
        children: [
          _TaqwaRing(progress: pct, points: net),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _msg(pct),
                  style: GoogleFonts.amiri(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  'أنجزت $done من ١٠ عبادات',
                  style: GoogleFonts.notoNaskhArabic(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                _LevelBadge(label: _level(net)),
                const SizedBox(height: 6),
                streakAsync.when(
                  loading: () => const SizedBox(height: 22),
                  error: (_, __) => const SizedBox(),
                  data: (s) => s > 0 ? _StreakBadge(days: s) : const SizedBox(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _level(int pts) {
    if (pts >= 600) return 'متقي ✨';
    if (pts >= 300) return 'مجاهد ⚔️';
    if (pts >= 100) return 'سالك 🌿';
    return 'مبتدئ 🌱';
  }

  String _msg(double p) {
    if (p >= .9) return 'ما شاء الله! يوم رائع 🌟';
    if (p >= .6) return 'أحسنت، استمر! 💪';
    if (p >= .3) return 'بداية جيدة 🌿';
    return 'بسم الله، ابدأ يومك 🤲';
  }
}

// ── حلقة التقوى ──
class _TaqwaRing extends StatefulWidget {
  final double progress;
  final int points;
  const _TaqwaRing({required this.progress, required this.points});

  @override
  State<_TaqwaRing> createState() => _TaqwaRingState();
}

class _TaqwaRingState extends State<_TaqwaRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    _anim = Tween<double>(begin: 0, end: widget.progress)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(_TaqwaRing old) {
    super.didUpdateWidget(old);
    if (old.progress != widget.progress) {
      _anim = Tween<double>(begin: old.progress, end: widget.progress)
          .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
      _ctrl
        ..reset()
        ..forward();
    }
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
      builder: (_, __) => SizedBox(
        width: 90,
        height: 90,
        child: CustomPaint(
          painter: _RingPainter(progress: _anim.value),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(_anim.value * 100).round()}%',
                  style: GoogleFonts.notoNaskhArabic(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gold,
                      height: 1),
                ),
                Text('اليوم',
                    style: GoogleFonts.notoNaskhArabic(
                        fontSize: 9, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = (size.width - 10) / 2;

    canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = AppColors.border
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7);

    if (progress <= 0) return;

    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..shader = const SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: 3 * math.pi / 2,
          colors: [AppColors.gold, AppColors.teal, AppColors.gold],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );

    // dot at end
    final angle = -math.pi / 2 + 2 * math.pi * progress;
    final dx = c.dx + r * math.cos(angle);
    final dy = c.dy + r * math.sin(angle);
    canvas.drawCircle(
        Offset(dx, dy),
        5,
        Paint()
          ..color = AppColors.goldLight
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    canvas.drawCircle(Offset(dx, dy), 3, Paint()..color = AppColors.goldLight);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// ═══════════════════════════════════════════════════════════════
//  PRAYER TIMES ROW
// ═══════════════════════════════════════════════════════════════
class _PrayerTimesRow extends StatelessWidget {
  const _PrayerTimesRow();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'أوقات الصلاة'),
        const SizedBox(height: 10),
        SizedBox(
          height: 84,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            reverse: true,
            physics: const BouncingScrollPhysics(),
            itemCount: _kPrayers.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => _PrayerChip(
              prayer: _kPrayers[i],
              isActive: _kPrayers[i].key == 'maghrib',
            ),
          ),
        ),
      ],
    );
  }
}

class _PrayerChip extends StatelessWidget {
  final _PrayerInfo prayer;
  final bool isActive;
  const _PrayerChip({required this.prayer, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 66,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        gradient: isActive
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0x28C8A96E), Color(0x143AAFA9)],
              )
            : null,
        color: isActive ? null : AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive ? AppColors.gold.withOpacity(0.35) : AppColors.border,
          width: isActive ? 1.5 : 1,
        ),
        boxShadow: isActive ? AppShadows.goldGlow : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(prayer.emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 4),
          Text(prayer.name,
              style: GoogleFonts.notoNaskhArabic(
                  fontSize: 10,
                  color: isActive ? AppColors.gold : AppColors.textSecondary,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400)),
          const SizedBox(height: 2),
          Text(prayer.time,
              style: GoogleFonts.notoNaskhArabic(
                  fontSize: 10,
                  color: isActive ? AppColors.goldLight : AppColors.textDim)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  QUICK IBADAH GRID
// ═══════════════════════════════════════════════════════════════
class _QuickIbadahGrid extends ConsumerWidget {
  final DailyRecord? record;
  const _QuickIbadahGrid({required this.record});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = _items(record);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('عبادات اليوم',
                style: GoogleFonts.amiri(
                    fontSize: 16, color: AppColors.textPrimary)),
            const SizedBox(width: 8),
            Expanded(child: Container(height: 1, color: AppColors.border)),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {},
              child: Text('عرض الكل ←',
                  style: GoogleFonts.notoNaskhArabic(
                      fontSize: 11, color: AppColors.teal)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.12,
          ),
          itemCount: items.length,
          itemBuilder: (_, i) => _IbadahChip(
            item: items[i],
            onTap: () => HapticFeedback.lightImpact(),
          ),
        ),
      ],
    );
  }

  List<_IbadahItem> _items(DailyRecord? r) => [
        _IbadahItem('🌅', 'الفجر', r?.fajrStatus == PrayerStatus.performed),
        _IbadahItem('📖', 'القرآن', (r?.quranPages ?? 0) > 0),
        _IbadahItem('☀️', 'الظهر', r?.dhuhrStatus == PrayerStatus.performed),
        _IbadahItem('🌤', 'العصر', r?.asrStatus == PrayerStatus.performed),
        _IbadahItem('⭐', 'الأذكار',
            (r?.morningAdhkar ?? false) && (r?.eveningAdhkar ?? false)),
        _IbadahItem('🌌', 'قيام الليل', r?.nightPrayer ?? false),
      ];
}

class _IbadahChip extends StatelessWidget {
  final _IbadahItem item;
  final VoidCallback onTap;
  const _IbadahChip({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        decoration: BoxDecoration(
          color:
              item.done ? AppColors.success.withOpacity(0.1) : AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: item.done
                  ? AppColors.success.withOpacity(0.3)
                  : AppColors.border),
          boxShadow: item.done
              ? [
                  BoxShadow(
                      color: AppColors.success.withOpacity(0.1), blurRadius: 8)
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Text(item.emoji, style: const TextStyle(fontSize: 24)),
                if (item.done)
                  Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.card, width: 1.5),
                    ),
                    child: const Center(
                        child: Text('✓',
                            style:
                                TextStyle(fontSize: 8, color: Colors.white))),
                  ),
              ],
            ),
            const SizedBox(height: 5),
            Text(item.label,
                style: GoogleFonts.notoNaskhArabic(
                    fontSize: 10,
                    color:
                        item.done ? AppColors.success : AppColors.textSecondary,
                    fontWeight: item.done ? FontWeight.w600 : FontWeight.w400)),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  VERSE CARD
// ═══════════════════════════════════════════════════════════════
class _VerseCard extends StatelessWidget {
  final String verse;
  const _VerseCard({required this.verse});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0x1CC8A96E), Color(0x0E3AAFA9)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.gold.withOpacity(0.18)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  width: 28, height: 1, color: AppColors.gold.withOpacity(0.3)),
              const SizedBox(width: 8),
              const Text('❁',
                  style: TextStyle(color: AppColors.gold, fontSize: 14)),
              const SizedBox(width: 8),
              Container(
                  width: 28, height: 1, color: AppColors.gold.withOpacity(0.3)),
            ],
          ),
          const SizedBox(height: 12),
          Text(verse,
              textAlign: TextAlign.center,
              style: GoogleFonts.amiri(
                  fontSize: 18, color: AppColors.goldLight, height: 2.0)),
          const SizedBox(height: 10),
          Text('آية اليوم',
              style: GoogleFonts.notoNaskhArabic(
                  fontSize: 10, color: AppColors.textDim)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title,
            style:
                GoogleFonts.amiri(fontSize: 16, color: AppColors.textPrimary)),
        const SizedBox(width: 8),
        Expanded(child: Container(height: 1, color: AppColors.border)),
      ],
    );
  }
}

class _LevelBadge extends StatelessWidget {
  final String label;
  const _LevelBadge({required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.goldDim,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.gold.withOpacity(0.2)),
        ),
        child: Text(label,
            style: GoogleFonts.notoNaskhArabic(
                fontSize: 11, color: AppColors.gold)),
      );
}

class _StreakBadge extends StatelessWidget {
  final int days;
  const _StreakBadge({required this.days});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.success.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔥', style: TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
            Text('$days يوم متواصل',
                style: GoogleFonts.notoNaskhArabic(
                    fontSize: 11, color: AppColors.success)),
          ],
        ),
      );
}

class _Skeleton extends StatelessWidget {
  final double height;
  const _Skeleton({required this.height});

  @override
  Widget build(BuildContext context) => Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(
          child:
              CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════
//  MODELS
// ═══════════════════════════════════════════════════════════════
class _PrayerInfo {
  final String name, time, key, emoji;
  const _PrayerInfo(this.name, this.time, this.key, this.emoji);
}

class _IbadahItem {
  final String emoji, label;
  final bool done;
  const _IbadahItem(this.emoji, this.label, this.done);
}
