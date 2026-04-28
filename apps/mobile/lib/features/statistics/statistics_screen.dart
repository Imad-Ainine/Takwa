// ═══════════════════════════════════════════════════════════════
//  lib/features/statistics/presentation/screens/statistics_screen.dart
//  تقوى — Statistics Screen (شاشة الإحصائيات)
// ═══════════════════════════════════════════════════════════════

import 'dart:math' as math;
import 'package:drift/drift.dart' show OrderingTerm, Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:takwa/core/database/app_database.dart';
import 'package:takwa/core/database/daos.dart';
import 'package:takwa/core/providers/database_providers.dart';
import 'package:takwa/core/supabase/sync_manager.dart';
import 'package:takwa/core/theme/app_theme.dart';
import 'package:takwa/core/widgets/custom_pattern_background.dart';
import 'package:takwa/core/widgets/guest_mode_guard.dart';
import 'package:takwa/core/widgets/primary_button.dart';
import 'package:takwa/core/widgets/takwa_loading_indicator.dart';
import 'package:takwa/core/widgets/custom_leading_button.dart';

// ═══════════════════════════════════════════════════════════════
//  LOCAL PROVIDERS
// ═══════════════════════════════════════════════════════════════

/// فلتر الفترة الزمنية
enum StatsPeriod { week, month, ramadan }

final _statsPeriodProvider = StateProvider<StatsPeriod>(
  (ref) => StatsPeriod.week,
);

final _unseenAchievementsProvider = StreamProvider<List<Achievement>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.achievements)
        ..where((a) => a.seen.equals(false))
        ..orderBy([(a) => OrderingTerm.desc(a.earnedAt)]))
      .watch();
});

final _allAchievementsProvider = StreamProvider<List<Achievement>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(
    db.achievements,
  )..orderBy([(a) => OrderingTerm.desc(a.earnedAt)])).watch();
});

// ═══════════════════════════════════════════════════════════════
//  STATISTICS SCREEN
// ═══════════════════════════════════════════════════════════════
class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryCtrl;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;
  static const _sectionCount = 6;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnims = List.generate(_sectionCount, (i) {
      final s = i * 0.12, e = (s + 0.40).clamp(0.0, 1.0);
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _entryCtrl,
          curve: Interval(s, e, curve: Curves.easeOut),
        ),
      );
    });
    _slideAnims = List.generate(_sectionCount, (i) {
      final s = i * 0.12, e = (s + 0.40).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.08),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _entryCtrl,
          curve: Interval(s, e, curve: Curves.easeOutCubic),
        ),
      );
    });

    // check and grant achievements on load, then sync from Supabase
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _entryCtrl.forward();
      await ref.read(statsDaoProvider).checkAndGrantAchievements();
      // Pull latest daily records from Supabase so charts are up-to-date
      try {
        await ref.read(syncManagerProvider).fullSync();
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  Widget _anim(int i, Widget child) => FadeTransition(
    opacity: _fadeAnims[i],
    child: SlideTransition(position: _slideAnims[i], child: child),
  );

  /// Compute the (from, to) date range for the selected period.
  static (DateTime, DateTime) _dateRange(StatsPeriod period) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (period) {
      case StatsPeriod.week:
        return (today.subtract(const Duration(days: 6)), today);
      case StatsPeriod.month:
        return (DateTime(now.year, now.month, 1), today);
      case StatsPeriod.ramadan:
        // Use Hijri calendar to find Ramadan 1 of the current year
        final hijri = HijriCalendar.now();
        // Ramadan = month 9; use current Hijri year
        final ramadanStart = HijriCalendar()
          ..hYear = hijri.hYear
          ..hMonth = 9
          ..hDay = 1;
        final ramadanEnd = HijriCalendar()
          ..hYear = hijri.hYear
          ..hMonth = 9
          ..hDay = 30;
        final gStart = ramadanStart.hijriToGregorian(
          ramadanStart.hYear,
          ramadanStart.hMonth,
          ramadanStart.hDay,
        );
        final gEnd = ramadanEnd.hijriToGregorian(
          ramadanEnd.hYear,
          ramadanEnd.hMonth,
          ramadanEnd.hDay,
        );
        return (
          DateTime(gStart.year, gStart.month, gStart.day),
          DateTime(gEnd.year, gEnd.month, gEnd.day),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final period = ref.watch(_statsPeriodProvider);
    final range = _dateRange(period);

    final statsAsync = ref.watch(periodStatsProvider(range));
    final weekAsync = ref.watch(periodChartPointsProvider(range));
    final streakAsync = ref.watch(currentStreakProvider);
    final unseenAsync = ref.watch(_unseenAchievementsProvider);

    final hijri = HijriCalendar.now();

    // Label shown in the bar chart header
    final chartLabel = switch (period) {
      StatsPeriod.week => 'آخر ٧ أيام',
      StatsPeriod.month => 'هذا الشهر',
      StatsPeriod.ramadan => 'رمضان',
    };

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value:
          (Theme.of(context).brightness == Brightness.dark
                  ? SystemUiOverlayStyle.light
                  : SystemUiOverlayStyle.dark)
              .copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: Stack(
          children: [
            const Positioned.fill(
              child: CustomPatternBackground(
                pattern: BackgroundPattern.pattern1,
              ),
            ),
            GuestModeGuard(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ── AppBar ──
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    expandedHeight: 120,
                    leading: const CustomLeadingButton(),
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.pin,
                      background: _StatsTopBar(hijri: hijri),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 8),
                        // ① Period Selector
                        _anim(0, _PeriodSelector()),
                        const SizedBox(height: 16),
                        // ② Taqwa Score Hero Card
                        _anim(
                          1,
                          statsAsync.when(
                            loading: () =>
                                const Center(child: TakwaLoadingIndicator()),
                            error: (_, _) => const SizedBox(),
                            data: (s) => streakAsync.when(
                              loading: () =>
                                  const Center(child: TakwaLoadingIndicator()),
                              error: (_, _) => const SizedBox(),
                              data: (streak) =>
                                  _TaqwaHeroCard(stats: s, streak: streak),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // ③ Bar Chart (period-aware)
                        _anim(
                          2,
                          weekAsync.when(
                            loading: () => const _StatSkeleton(height: 180),
                            error: (_, _) => const SizedBox(),
                            data: (pts) => _WeeklyChart(
                              points: pts,
                              periodLabel: chartLabel,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // ④ Stats Cards Grid
                        _anim(
                          3,
                          statsAsync.when(
                            loading: () => const _StatSkeleton(height: 120),
                            error: (_, _) => const SizedBox(),
                            data: (s) => _StatsCardsGrid(stats: s),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // ⑤ Prayer Attendance (real data)
                        _anim(4, _PrayerAttendanceCard(range: range)),
                        const SizedBox(height: 16),
                        // ⑥ Achievements
                        _anim(5, _AchievementsSection()),
                        const SizedBox(height: 100),
                      ]),
                    ),
                  ),
                ],
              ),
            ),

            // ── Unseen Achievement Overlay ──
            unseenAsync.when(
              loading: () => const SizedBox(),
              error: (_, _) => const SizedBox(),
              data: (list) => list.isNotEmpty
                  ? _AchievementToast(achievement: list.first)
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  TOP BAR
// ═══════════════════════════════════════════════════════════════
class _StatsTopBar extends StatelessWidget {
  final HijriCalendar hijri;
  const _StatsTopBar({required this.hijri});

  @override
  Widget build(BuildContext context) {
    final isRamadan = hijri.hMonth == 9;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 52, 16, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            isRamadan
                ? context.colors.gold.withOpacity(0.15)
                : context.colors.teal.withOpacity(0.1),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isRamadan ? 'تقرير رمضان 🌙' : 'الإحصائيات',
                style: context.typography.displayMedium.copyWith(
                  color: context.colors.gold,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${hijri.hDay} ${_month(hijri.hMonth)} ${hijri.hYear}',
                style: context.typography.bodySmall.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
          if (isRamadan) _RamadanProgress(day: hijri.hDay),
        ],
      ),
    );
  }

  static String _month(int m) => const [
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

class _RamadanProgress extends StatelessWidget {
  final int day;
  const _RamadanProgress({required this.day});

  @override
  Widget build(BuildContext context) {
    final pct = day / 30.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'يوم $day من ٣٠',
          style: context.typography.caption.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 80,
          height: 80,
          child: CustomPaint(
            painter: _SmallRingPainter(
              progress: pct,
              borderColor: context.colors.border,
              goldColor: context.colors.gold,
              tealColor: context.colors.teal,
            ),
            child: Center(
              child: Text(
                '${(pct * 100).round()}%',
                style: context.typography.labelLarge.copyWith(
                  color: context.colors.gold,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  PERIOD SELECTOR
// ═══════════════════════════════════════════════════════════════
class _PeriodSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(_statsPeriodProvider);
    final options = [
      (StatsPeriod.week, 'هذا الأسبوع'),
      (StatsPeriod.month, 'هذا الشهر'),
      (StatsPeriod.ramadan, 'رمضان 🌙'),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        children: options.map((opt) {
          final selected = current == opt.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                ref.read(_statsPeriodProvider.notifier).state = opt.$1;
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  gradient: selected
                      ? LinearGradient(
                          colors: [
                            context.colors.gold,
                            context.colors.goldDark,
                          ],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Center(
                  child: Text(
                    opt.$2,
                    style: context.typography.bodySmall.copyWith(
                      color: selected
                          ? context.colors.background
                          : context.colors.textSecondary,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  TAQWA HERO CARD
// ═══════════════════════════════════════════════════════════════
class _TaqwaHeroCard extends StatelessWidget {
  final MonthStats stats;
  final int streak;
  const _TaqwaHeroCard({required this.stats, required this.streak});

  @override
  Widget build(BuildContext context) {
    final pct = (stats.totalPoints / 3000.0).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            context.colors.gold.withOpacity(0.15),
            context.colors.teal.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.colors.gold.withOpacity(0.2)),
        boxShadow: context.shadows.card,
      ),
      child: Row(
        children: [
          // دائرة التقوى
          _TaqwaScoreRing(
            progress: pct,
            points: stats.totalPoints,
            levelEmoji: _levelEmoji(stats.level),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stats.levelLabel,
                  style: context.typography.headingMedium.copyWith(
                    color: context.colors.gold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${stats.totalPoints} نقطة هذا الشهر',
                  style: context.typography.bodySmall.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),

                // حاجز للمستوى التالي
                _LevelProgressBar(stats: stats),
                const SizedBox(height: 10),

                // Streak
                if (streak > 0) _StreakBadgeLarge(days: streak),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _levelEmoji(TaqwaLevel l) => switch (l) {
    TaqwaLevel.mubtadi => '🌱',
    TaqwaLevel.salik => '🌿',
    TaqwaLevel.mujahid => '⚔️',
    TaqwaLevel.mutaqi => '✨',
  };
}

class _TaqwaScoreRing extends StatefulWidget {
  final double progress;
  final int points;
  final String levelEmoji;
  const _TaqwaScoreRing({
    required this.progress,
    required this.points,
    required this.levelEmoji,
  });

  @override
  State<_TaqwaScoreRing> createState() => _TaqwaScoreRingState();
}

class _TaqwaScoreRingState extends State<_TaqwaScoreRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late Animation<double> _anim;
  late Animation<int> _countAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _anim = Tween<double>(
      begin: 0,
      end: widget.progress,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _countAnim = IntTween(
      begin: 0,
      end: widget.points,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _ctrl,
    builder: (_, _) => SizedBox(
      width: 100,
      height: 100,
      child: CustomPaint(
        painter: _TaqwaRingPainter(
          progress: _anim.value,
          borderColor: context.colors.border,
          goldColor: context.colors.gold,
          goldLightColor: context.colors.goldLight,
          tealColor: context.colors.teal,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.levelEmoji, style: const TextStyle(fontSize: 20)),
              Text(
                '${_countAnim.value}',
                style: context.typography.labelLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.colors.gold,
                  height: 1,
                ),
              ),
              Text(
                'نقطة',
                style: context.typography.caption.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _TaqwaRingPainter extends CustomPainter {
  final double progress;
  final Color borderColor;
  final Color goldColor;
  final Color goldLightColor;
  final Color tealColor;

  _TaqwaRingPainter({
    required this.progress,
    required this.borderColor,
    required this.goldColor,
    required this.goldLightColor,
    required this.tealColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = (size.width - 12) / 2;

    // bg track
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );

    if (progress <= 0) return;

    final rect = Rect.fromCircle(center: c, radius: r);
    // outer glow
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..shader = SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: 3 * math.pi / 2,
          colors: [goldColor, tealColor, goldColor],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // solid arc
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..shader = SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: 3 * math.pi / 2,
          colors: [goldColor, tealColor, goldColor],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );

    // end dot
    final angle = -math.pi / 2 + 2 * math.pi * progress;
    final dx = c.dx + r * math.cos(angle);
    final dy = c.dy + r * math.sin(angle);
    canvas.drawCircle(
      Offset(dx, dy),
      6,
      Paint()
        ..color = goldLightColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(Offset(dx, dy), 3.5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_TaqwaRingPainter old) => old.progress != progress;
}

class _LevelProgressBar extends StatelessWidget {
  final MonthStats stats;
  const _LevelProgressBar({required this.stats});

  @override
  Widget build(BuildContext context) {
    final thresholds = [0, 100, 300, 600, 1000];
    int nextThreshold = 1000;
    int prevThreshold = 0;

    for (int i = 0; i < thresholds.length - 1; i++) {
      if (stats.totalPoints < thresholds[i + 1]) {
        prevThreshold = thresholds[i];
        nextThreshold = thresholds[i + 1];
        break;
      }
    }

    final pct =
        ((stats.totalPoints - prevThreshold) / (nextThreshold - prevThreshold))
            .clamp(0.0, 1.0);
    final remaining = nextThreshold - stats.totalPoints;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'المستوى التالي',
              style: context.typography.caption.copyWith(
                color: context.colors.textDim,
              ),
            ),
            Text(
              remaining > 0 ? '$remaining نقطة متبقية' : 'أقصى مستوى ✨',
              style: context.typography.caption.copyWith(
                color: context.colors.gold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            children: [
              Container(height: 6, color: context.colors.border),
              FractionallySizedBox(
                widthFactor: pct,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [context.colors.gold, context.colors.teal],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StreakBadgeLarge extends StatelessWidget {
  final int days;
  const _StreakBadgeLarge({required this.days});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: context.colors.success.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: context.colors.success.withOpacity(0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('🔥', style: TextStyle(fontSize: 14)),
        const SizedBox(width: 6),
        Text(
          '$days يوم متواصل',
          style: context.typography.bodySmall.copyWith(
            color: context.colors.success,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

// ═══════════════════════════════════════════════════════════════
//  WEEKLY BAR CHART
// ═══════════════════════════════════════════════════════════════
class _WeeklyChart extends StatefulWidget {
  final List<WeeklyPoint> points;
  final String periodLabel;
  const _WeeklyChart({required this.points, required this.periodLabel});

  @override
  State<_WeeklyChart> createState() => _WeeklyChartState();
}

class _WeeklyChartState extends State<_WeeklyChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late Animation<double> _anim;
  int? _hoveredIdx;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.points.isEmpty) return const SizedBox();
    final maxPts = widget.points.map((p) => p.points).fold(0, math.max);
    final isWeekly = widget.points.length <= 7;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: context.decorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'أداء الفترة',
                style: context.typography.headingMedium.copyWith(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                widget.periodLabel,
                style: context.typography.caption.copyWith(
                  color: context.colors.textDim,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Chart area
          AnimatedBuilder(
            animation: _anim,
            builder: (_, _) => SizedBox(
              height: 170,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(widget.points.length, (i) {
                  final pt = widget.points[i];
                  final ratio = maxPts > 0
                      ? (pt.points / maxPts) * _anim.value
                      : 0.0;
                  final isToday = i == widget.points.length - 1;
                  final isHovered = _hoveredIdx == i;

                  return Expanded(
                    child: GestureDetector(
                      onTapDown: (_) => setState(() => _hoveredIdx = i),
                      onTapUp: (_) => setState(() => _hoveredIdx = null),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Tooltip
                            AnimatedOpacity(
                              opacity: isHovered ? 1 : 0,
                              duration: const Duration(milliseconds: 150),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                margin: const EdgeInsets.only(bottom: 4),
                                decoration: BoxDecoration(
                                  color: context.colors.card2,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: context.colors.border,
                                  ),
                                ),
                                child: Text(
                                  '${pt.points}',
                                  style: context.typography.caption.copyWith(
                                    color: context.colors.gold,
                                  ),
                                ),
                              ),
                            ),

                            // Bar
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              height: (100 * ratio).clamp(4.0, 100.0),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: isToday
                                      ? [
                                          context.colors.gold,
                                          context.colors.goldLight,
                                        ]
                                      : isHovered
                                      ? [
                                          context.colors.teal,
                                          context.colors.teal.withOpacity(0.6),
                                        ]
                                      : [
                                          context.colors.border,
                                          context.colors.card2,
                                        ],
                                ),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6),
                                ),
                                boxShadow: isToday
                                    ? [
                                        BoxShadow(
                                          color: context.colors.gold
                                              .withOpacity(0.3),
                                          blurRadius: 8,
                                        ),
                                      ]
                                    : null,
                              ),
                            ),

                            const SizedBox(height: 6),
                            Text(
                              isWeekly ? pt.fullDayName : pt.shortDayName,
                              style: context.typography.caption.copyWith(
                                color: isToday
                                    ? context.colors.gold
                                    : context.colors.textDim,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 30),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ChartLegend(color: context.colors.gold, label: 'اليوم'),
              const SizedBox(width: 16),
              _ChartLegend(color: context.colors.border, label: 'أيام سابقة'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  final Color color;
  final String label;
  const _ChartLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 5),
      Text(
        label,
        style: context.typography.caption.copyWith(
          color: context.colors.textSecondary,
        ),
      ),
    ],
  );
}

// ═══════════════════════════════════════════════════════════════
//  STATS CARDS GRID
// ═══════════════════════════════════════════════════════════════
class _StatsCardsGrid extends StatelessWidget {
  final MonthStats stats;
  const _StatsCardsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _StatCardData(
        '📖',
        'صفحات القرآن',
        '${stats.quranPages}',
        context.colors.teal,
      ),
      _StatCardData(
        '🕌',
        'حضور الصلوات',
        '${stats.prayerPercent}%',
        context.colors.gold,
      ),
      _StatCardData(
        '🔥',
        'أطول سلسلة',
        '${stats.longestStreak} يوم',
        context.colors.success,
      ),
      _StatCardData(
        '🌟',
        'نقاط التقوى',
        '${stats.totalPoints}',
        context.colors.gold,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.55,
      children: cards.map((c) => _StatCard(data: c)).toList(),
    );
  }
}

class _StatCardData {
  final String emoji, label, value;
  final Color color;
  const _StatCardData(this.emoji, this.label, this.value, this.color);
}

class _StatCard extends StatefulWidget {
  final _StatCardData data;
  const _StatCard({required this.data});

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scale = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(widget.data.emoji, style: const TextStyle(fontSize: 18)),
                const Spacer(),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: widget.data.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.data.value,
                  style: context.typography.headingMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: widget.data.color,
                  ),
                ),
                Text(
                  widget.data.label,
                  style: context.typography.caption.copyWith(
                    color: context.colors.textSecondary,
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
//  PRAYER ATTENDANCE CARD (real per-prayer rates from DB)
// ═══════════════════════════════════════════════════════════════
class _PrayerAttendanceCard extends ConsumerWidget {
  final (DateTime, DateTime) range;
  const _PrayerAttendanceCard({required this.range});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratesAsync = ref.watch(periodPrayerRatesProvider(range));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: context.decorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'حضور الصلوات',
            style: context.typography.headingMedium.copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          ratesAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: TakwaLoadingIndicator(strokeWidth: 2),
              ),
            ),
            error: (_, _) => const SizedBox(),
            data: (rates) => Column(
              children: rates
                  .map(
                    (p) => _PrayerRateRow(
                      name: p.name,
                      rate: p.rate,
                      emoji: p.emoji,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrayerRateRow extends StatefulWidget {
  final String name, emoji;
  final double rate;
  const _PrayerRateRow({
    required this.name,
    required this.rate,
    required this.emoji,
  });

  @override
  State<_PrayerRateRow> createState() => _PrayerRateRowState();
}

class _PrayerRateRowState extends State<_PrayerRateRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _anim = Tween<double>(
      begin: 0,
      end: widget.rate,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color _color(BuildContext context) {
    if (widget.rate >= 0.9) return context.colors.success;
    if (widget.rate >= 0.7) return context.colors.gold;
    return context.colors.danger;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(widget.emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          SizedBox(
            width: 44,
            child: Text(
              widget.name,
              style: context.typography.bodySmall.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AnimatedBuilder(
              animation: _anim,
              builder: (_, _) => ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Stack(
                  children: [
                    Container(height: 8, color: context.colors.border),
                    FractionallySizedBox(
                      widthFactor: _anim.value,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _color(context),
                              _color(context).withOpacity(0.6),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: _color(context).withOpacity(0.3),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 34,
            child: AnimatedBuilder(
              animation: _anim,
              builder: (_, _) => Text(
                '${(_anim.value * 100).round()}%',
                style: context.typography.bodySmall.copyWith(
                  color: _color(context),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.end,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  ACHIEVEMENTS SECTION
// ═══════════════════════════════════════════════════════════════
class _AchievementsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allAsync = ref.watch(_allAchievementsProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: context.decorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'الإنجازات والشارات',
                style: context.typography.headingMedium.copyWith(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              allAsync.when(
                loading: () => const SizedBox(),
                error: (_, _) => const SizedBox(),
                data: (list) => Text(
                  '${list.length} إنجاز',
                  style: context.typography.bodySmall.copyWith(
                    color: context.colors.textDim,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          allAsync.when(
            loading: () => Center(
              child: TakwaLoadingIndicator(
                color: context.colors.gold,
                strokeWidth: 2,
              ),
            ),
            error: (_, _) => const SizedBox(),
            data: (list) => list.isEmpty
                ? _EmptyAchievements()
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: list
                        .map((a) => _AchievementBadge(achievement: a))
                        .toList(),
                  ),
          ),

          const SizedBox(height: 14),
          _LockedAchievementsRow(),
        ],
      ),
    );
  }
}

class _AchievementBadge extends ConsumerWidget {
  final Achievement achievement;
  const _AchievementBadge({required this.achievement});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showDetail(context, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [context.colors.gold.withOpacity(0.12), Colors.transparent],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.colors.gold.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(achievement.emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  achievement.titleAr,
                  style: context.typography.bodySmall.copyWith(
                    color: context.colors.gold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '+${achievement.pointsReward} نقطة',
                  style: context.typography.caption.copyWith(
                    color: context.colors.textDim,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, WidgetRef ref) {
    // Mark as seen
    ref
        .read(appDatabaseProvider)
        .update(ref.read(appDatabaseProvider).achievements)
      ..where((a) => a.id.equals(achievement.id))
      ..write(const AchievementsCompanion(seen: Value(true)));

    showDialog(
      context: context,
      builder: (_) => _AchievementDialog(achievement: achievement),
    );
  }
}

class _AchievementDialog extends StatelessWidget {
  final Achievement achievement;
  const _AchievementDialog({required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.colors.card,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: context.colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(achievement.emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              achievement.titleAr,
              style: context.typography.headingMedium.copyWith(
                fontSize: 20,
                color: context.colors.gold,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              achievement.descAr,
              textAlign: TextAlign.center,
              style: context.typography.bodyMedium.copyWith(
                color: context.colors.textSecondary,
                height: 1.7,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: context.colors.gold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: context.colors.gold.withOpacity(0.2)),
              ),
              child: Text(
                '+${achievement.pointsReward} نقطة مكافأة 🌟',
                style: context.typography.caption.copyWith(
                  color: context.colors.gold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              onTap: () async => Navigator.pop(context),
              label: 'شكراً لله 🤲',
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyAchievements extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Column(
      children: [
        const Text('🏆', style: TextStyle(fontSize: 32)),
        const SizedBox(height: 8),
        Text(
          'لا إنجازات بعد',
          style: context.typography.bodyMedium.copyWith(
            color: context.colors.textDim,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'حافظ على العبادات لتحصل على أول إنجاز',
          style: context.typography.caption.copyWith(
            color: context.colors.textDim,
          ),
        ),
      ],
    ),
  );
}

// إنجازات مقفلة
class _LockedAchievementsRow extends StatelessWidget {
  static const _locked = [
    ('streak_30', '🌙', 'شهر المجاهد', '٣٠ يوم متواصل'),
    ('quran_khatma', '📖', 'ختمة كاملة', 'إتمام القرآن'),
    ('full_week', '⭐', 'أسبوع مثالي', '٧ أيام مكتملة'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Container(width: 24, height: 1, color: context.colors.border),
              const SizedBox(width: 8),
              Text(
                'قادم قريباً 🔒',
                style: context.typography.caption.copyWith(
                  color: context.colors.textDim,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(height: 1, color: context.colors.border),
              ),
            ],
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _locked
              .map(
                (l) => Opacity(
                  opacity: 0.4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.card2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.colors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔒', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l.$3,
                              style: context.typography.bodySmall.copyWith(
                                color: context.colors.textSecondary,
                              ),
                            ),
                            Text(
                              l.$4,
                              style: context.typography.caption.copyWith(
                                color: context.colors.textDim,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  ACHIEVEMENT TOAST (overlay for new achievements)
// ═══════════════════════════════════════════════════════════════
class _AchievementToast extends ConsumerStatefulWidget {
  final Achievement achievement;
  const _AchievementToast({required this.achievement});

  @override
  ConsumerState<_AchievementToast> createState() => _AchievementToastState();
}

class _AchievementToastState extends ConsumerState<_AchievementToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);

    _ctrl.forward();
    // Auto dismiss after 4 sec
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _ctrl.reverse().then((_) {
          // Mark as seen
          ref
              .read(appDatabaseProvider)
              .update(ref.read(appDatabaseProvider).achievements)
            ..where((a) => a.id.equals(widget.achievement.id))
            ..write(const AchievementsCompanion(seen: Value(true)));
        });
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 120,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [context.colors.goldDim, context.colors.gold],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.colors.gold.withOpacity(0.4)),
              boxShadow: [
                BoxShadow(
                  color: context.colors.gold.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Text(
                  widget.achievement.emoji,
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إنجاز جديد! 🎉',
                        style: context.typography.caption.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                      Text(
                        widget.achievement.titleAr,
                        style: context.typography.headingMedium.copyWith(
                          color: context
                              .colors
                              .background, // Contrast against gold gradient
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        widget.achievement.descAr,
                        style: context.typography.bodySmall.copyWith(
                          color: context.colors.background.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.goldDim,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+${widget.achievement.pointsReward}',
                    style: TextStyle(
                      fontFamily: 'NotoNaskhArabic',
                      fontSize: 12,
                      color: context.colors.gold,
                      fontWeight: FontWeight.w700,
                    ),
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

// ═══════════════════════════════════════════════════════════════
//  HELPERS
// ═══════════════════════════════════════════════════════════════
class _SmallRingPainter extends CustomPainter {
  final double progress;
  final Color borderColor;
  final Color goldColor;
  final Color tealColor;

  _SmallRingPainter({
    required this.progress,
    required this.borderColor,
    required this.goldColor,
    required this.tealColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = (size.width - 10) / 2;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
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
          colors: [goldColor, tealColor, goldColor],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_SmallRingPainter o) => o.progress != progress;
}

class _StatSkeleton extends StatelessWidget {
  final double height;
  const _StatSkeleton({required this.height});

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    decoration: BoxDecoration(
      color: context.colors.card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: context.colors.border),
    ),
    child: Center(
      child: TakwaLoadingIndicator(color: context.colors.gold, strokeWidth: 2),
    ),
  );
}
