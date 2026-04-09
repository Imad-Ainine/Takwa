// ═══════════════════════════════════════════════════════════════
//  lib/statistics_screen.dart — شاشة الإحصائيات
// ═══════════════════════════════════════════════════════════════

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:muhasabah/core/theme/app_theme.dart';
import 'package:muhasabah/core/database/daos.dart';
import 'package:muhasabah/core/providers/database_providers.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entryCtrl;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final streakAsync = ref.watch(currentStreakProvider);
    final weeklyAsync = ref.watch(weeklyPointsProvider);
    final monthAsync = ref.watch(monthStatsProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light
          .copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: AppColors.night,
        body: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _StatsBgPainter())),
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── App Bar ──
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  surfaceTintColor: Colors.transparent,
                  pinned: true,
                  expandedHeight: 100,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      padding: const EdgeInsets.fromLTRB(20, 56, 20, 12),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x20C8A96E), Colors.transparent],
                        ),
                      ),
                      child: Row(
                        children: [
                          const Text('📊', style: TextStyle(fontSize: 28)),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'إحصائياتك',
                                style: GoogleFonts.amiri(
                                    fontSize: 22, color: AppColors.gold),
                              ),
                              Text(
                                'مراجعة النتائج',
                                style: GoogleFonts.notoNaskhArabic(
                                    fontSize: 12,
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // ① Streak + Score cards
                      streakAsync.when(
                        loading: () => const _Skeleton(height: 100),
                        error: (_, __) => const SizedBox(),
                        data: (streak) => _FadeIn(
                          ctrl: _entryCtrl,
                          delay: 0.0,
                          child: _TopStatsRow(streak: streak),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ② Weekly Chart
                      weeklyAsync.when(
                        loading: () => const _Skeleton(height: 200),
                        error: (_, __) => const SizedBox(),
                        data: (weekly) => _FadeIn(
                          ctrl: _entryCtrl,
                          delay: 0.15,
                          child: _WeeklyChart(data: weekly),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ③ Month Summary
                      monthAsync.when(
                        loading: () => const _Skeleton(height: 160),
                        error: (_, __) => const SizedBox(),
                        data: (month) => _FadeIn(
                          ctrl: _entryCtrl,
                          delay: 0.3,
                          child: _MonthSummary(stats: month),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ④ Taqwa meter
                      monthAsync.when(
                        loading: () => const _Skeleton(height: 140),
                        error: (_, __) => const SizedBox(),
                        data: (month) => _FadeIn(
                          ctrl: _entryCtrl,
                          delay: 0.45,
                          child: _TaqwaMeter(totalPoints: month.totalPoints),
                        ),
                      ),
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
//  TOP STATS ROW
// ═══════════════════════════════════════════════════════════════
class _TopStatsRow extends StatelessWidget {
  final int streak;
  const _TopStatsRow({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            emoji: '🔥',
            value: '$streak',
            label: 'أيام متتالية',
            color: const Color(0xFFFF6B35),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            emoji: '⭐',
            value: '${streak * 15}',
            label: 'نقطة تقوى',
            color: AppColors.gold,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            emoji: '🌟',
            value: streak >= 30
                ? 'متقي'
                : streak >= 14
                    ? 'مجاهد'
                    : streak >= 7
                        ? 'سالك'
                        : 'مبتدئ',
            label: 'مستواك',
            color: AppColors.teal,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.emoji,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.22)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.amiri(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.notoNaskhArabic(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  WEEKLY CHART  (bar chart — no fl_chart needed)
// ═══════════════════════════════════════════════════════════════
class _WeeklyChart extends StatelessWidget {
  final List<WeeklyPoint> data;
  const _WeeklyChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final days = [
      'الأحد',
      'الاثن',
      'الثلا',
      'الأربع',
      'الخمي',
      'الجمع',
      'السبت'
    ];
    final values = data.isNotEmpty
        ? data.map((d) => d.points.toDouble()).toList()
        : List.filled(7, 0.0);
    final maxVal = values.isEmpty
        ? 1.0
        : (values.reduce(math.max)).clamp(1.0, double.infinity);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.gold.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📈', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'نقاط الأسبوع',
                style: GoogleFonts.amiri(fontSize: 18, color: AppColors.gold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 130,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (i) {
                final val = i < values.length ? values[i] : 0.0;
                final pct = val / maxVal;
                final isToday = i == DateTime.now().weekday % 7;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      val.toInt().toString(),
                      style: GoogleFonts.notoNaskhArabic(
                        fontSize: 9,
                        color: isToday ? AppColors.gold : AppColors.textDim,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      width: 28,
                      height: (pct * 100).clamp(4.0, 100.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: isToday
                              ? [AppColors.gold, AppColors.teal]
                              : [AppColors.border, AppColors.border],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      i < days.length ? days[i] : '',
                      style: GoogleFonts.notoNaskhArabic(
                        fontSize: 9,
                        color: isToday ? AppColors.gold : AppColors.textDim,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  MONTH SUMMARY
// ═══════════════════════════════════════════════════════════════
class _MonthSummary extends StatelessWidget {
  final MonthStats stats;
  const _MonthSummary({required this.stats});

  @override
  Widget build(BuildContext context) {
    const daysCount = 0; // days tracked this month
    const fullDays = 0;
    final avgPoints =
        stats.totalPoints > 0 ? stats.totalPoints.toDouble() / 30 : 0.0;
    final totalPages = stats.quranPages;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.teal.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🗓️', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'ملخّص الشهر',
                style: GoogleFonts.amiri(fontSize: 18, color: AppColors.teal),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              const _MonthStat('📅', '$daysCount', 'يوم مسجّل'),
              const _MonthStat('✅', '$fullDays', 'يوم مكتمل'),
              _MonthStat('⭐', avgPoints.toStringAsFixed(0), 'متوسط النقاط'),
              _MonthStat('📖', '$totalPages', 'صفحة قرآن'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MonthStat extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  const _MonthStat(this.emoji, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width - 80) / 2,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.night,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.amiri(
                  fontSize: 18,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.notoNaskhArabic(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  TAQWA METER
// ═══════════════════════════════════════════════════════════════
class _TaqwaMeter extends StatelessWidget {
  final int totalPoints;
  const _TaqwaMeter({required this.totalPoints});

  static const _levels = [
    (0, 100, 'مبتدئ 🌱', AppColors.textDim),
    (100, 300, 'سالك 🌿', AppColors.teal),
    (300, 600, 'مجاهد ⚔️', AppColors.gold),
    (600, 1000, 'متقي ✨', Color(0xFF7D5FFF)),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.gold.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🏆', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text('مقياس التقوى',
                  style:
                      GoogleFonts.amiri(fontSize: 18, color: AppColors.gold)),
            ],
          ),
          const SizedBox(height: 16),
          ..._levels.map((lvl) {
            final pct =
                ((totalPoints - lvl.$1) / (lvl.$2 - lvl.$1)).clamp(0.0, 1.0);
            final reached = totalPoints >= lvl.$1;

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(lvl.$3,
                          style: GoogleFonts.notoNaskhArabic(
                            fontSize: 13,
                            color: reached ? lvl.$4 : AppColors.textDim,
                          )),
                      Text(
                        reached ? '${lvl.$1}–${lvl.$2}' : 'محجوب',
                        style: GoogleFonts.notoNaskhArabic(
                          fontSize: 11,
                          color: AppColors.textDim,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: reached ? pct : 0,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation(
                          reached ? lvl.$4 : AppColors.border),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  HELPERS
// ═══════════════════════════════════════════════════════════════
class _FadeIn extends StatelessWidget {
  final AnimationController ctrl;
  final double delay;
  final Widget child;

  const _FadeIn({
    required this.ctrl,
    required this.delay,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final end = (delay + 0.4).clamp(0.0, 1.0);
    final fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: ctrl, curve: Interval(delay, end, curve: Curves.easeOut)),
    );
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: ctrl, curve: Interval(delay, end)));

    return FadeTransition(
        opacity: fade, child: SlideTransition(position: slide, child: child));
  }
}

class _Skeleton extends StatelessWidget {
  final double height;
  const _Skeleton({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }
}

// ── Background Painter ─────────────────────────────────────────
class _StatsBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
      Offset(0, size.height * 0.15),
      200,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0x0A7D5FFF), Colors.transparent],
        ).createShader(Rect.fromCircle(
            center: Offset(0, size.height * 0.15), radius: 200)),
    );
    canvas.drawCircle(
      Offset(size.width, size.height * 0.65),
      180,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0x0AC8A96E), Colors.transparent],
        ).createShader(Rect.fromCircle(
            center: Offset(size.width, size.height * 0.65), radius: 180)),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}
