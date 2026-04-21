// ═══════════════════════════════════════════════════════════════
//  lib/features/checklist/checklist_screen.dart
//  تقوى — Daily Checklist (قائمة المحاسبة اليومية)
// ═══════════════════════════════════════════════════════════════

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hijri/hijri_calendar.dart';

import 'package:takwa/core/theme/app_theme.dart';
import 'package:takwa/core/widgets/custom_pattern_background.dart';
import 'package:takwa/core/database/app_database.dart';
import 'package:takwa/core/providers/database_providers.dart';
import 'package:takwa/core/widgets/primary_button.dart';
import 'package:takwa/core/widgets/custom_leading_button.dart';
import 'package:takwa/core/widgets/guest_mode_guard.dart';
import 'package:takwa/core/supabase/sync_manager.dart';
import 'package:takwa/features/checklist/widgets/custom_ibadah_group.dart';

// ═══════════════════════════════════════════════════════════════
//  CHECKLIST SCREEN
// ═══════════════════════════════════════════════════════════════
class ChecklistScreen extends ConsumerStatefulWidget {
  const ChecklistScreen({super.key});

  @override
  ConsumerState<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends ConsumerState<ChecklistScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryCtrl;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;

  final _quranCtrl = TextEditingController();
  static const _groupCount = 5;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _fadeAnims = List.generate(_groupCount, (i) {
      final s = i * 0.15, e = (s + 0.45).clamp(0.0, 1.0);
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _entryCtrl,
          curve: Interval(s, e, curve: Curves.easeOut),
        ),
      );
    });
    _slideAnims = List.generate(_groupCount, (i) {
      final s = i * 0.15, e = (s + 0.45).clamp(0.0, 1.0);
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dailyRecordDaoProvider).getOrCreateToday();
      _entryCtrl.forward();
    });
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _quranCtrl.dispose();
    super.dispose();
  }

  Widget _anim(int i, Widget child) => FadeTransition(
    opacity: _fadeAnims[i],
    child: SlideTransition(position: _slideAnims[i], child: child),
  );

  @override
  Widget build(BuildContext context) {
    final todayAsync = ref.watch(todayRecordProvider);

    final hijri = HijriCalendar.now();
    final hijriStr =
        '${hijri.hDay} ${_hijriMonth(hijri.hMonth)} ${hijri.hYear}';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: Stack(
          children: [
            const Positioned.fill(
              child: CustomPatternBackground(
                pattern: BackgroundPattern.arrowKite,
              ),
            ),
            todayAsync.when(
              loading: () => Center(
                child: CircularProgressIndicator(
                  color: context.colors.gold,
                  strokeWidth: 2,
                ),
              ),
              error: (e, _) => Center(
                child: Text(
                  'خطأ: $e',
                  style: context.typography.bodyMedium.copyWith(
                    color: context.colors.danger,
                  ),
                ),
              ),
              data: (record) =>
                  GuestModeGuard(child: _buildBody(context, record, hijriStr)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    DailyRecord? record,
    String hijriStr,
  ) {
    final net = record?.netPoints ?? 0;
    final gross = record?.taqwaPoints ?? 0;
    final deducted = record?.deductedPoints ?? 0;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.transparent,
          expandedHeight: 110,
          pinned: true,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.pin,
            background: _TopBar(
              hijriStr: hijriStr,
              netPoints: net,
              grossPoints: gross,
              deducted: deducted,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 8),

              // ① مؤشر التقدم
              _anim(0, _DayProgressBar(record: record)),
              const SizedBox(height: 16),

              // ② الصلوات الخمس
              _anim(1, _PrayersGroup(record: record)),
              const SizedBox(height: 12),

              // ③ القرآن + الأذكار + الصيام + الصدقة
              _anim(2, _IbadahGroup(record: record, quranCtrl: _quranCtrl)),
              const SizedBox(height: 12),

              // ④ المحظورات
              _anim(3, _ProhibitionsGroup(record: record)),
              const SizedBox(height: 12),

              // ⑤ عاداتي وإضافاتي (Custom Ibadaat)
              _anim(4, CustomIbadahGroup(record: record)),
              const SizedBox(height: 12),

              // ⑥ ملاحظة اليوم
              _DayNoteField(record: record),
              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }

  static String _hijriMonth(int m) => const [
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

// ═══════════════════════════════════════════════════════════════
//  TOP BAR
// ═══════════════════════════════════════════════════════════════
class _TopBar extends StatelessWidget {
  final String hijriStr;
  final int netPoints, grossPoints, deducted;
  const _TopBar({
    required this.hijriStr,
    required this.netPoints,
    required this.grossPoints,
    required this.deducted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 52, 16, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [context.colors.gold.withOpacity(0.12), Colors.transparent],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomLeadingButton(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'محاسبة اليوم',
                  style: context.typography.headingMedium.copyWith(
                    fontSize: 22,
                    color: context.colors.gold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  hijriStr,
                  style: context.typography.caption.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              _PointsPill(
                label: 'الصافي',
                value: netPoints,
                color: netPoints >= 0
                    ? context.colors.gold
                    : context.colors.danger,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  _PointsPill(
                    label: '+',
                    value: grossPoints,
                    color: context.colors.success,
                    small: true,
                  ),
                  const SizedBox(width: 4),
                  _PointsPill(
                    label: '-',
                    value: deducted,
                    color: context.colors.danger,
                    small: true,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PointsPill extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final bool small;
  const _PointsPill({
    required this.label,
    required this.value,
    required this.color,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 12,
        vertical: small ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        '$label$value نقطة',
        style: context.typography.bodySmall.copyWith(
          fontSize: small ? 10 : 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  DAY PROGRESS BAR
// ═══════════════════════════════════════════════════════════════
class _DayProgressBar extends ConsumerWidget {
  final DailyRecord? record;
  const _DayProgressBar({required this.record});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const totalIbadah = 10;
    int done = 0;
    if (record != null) {
      if (record!.fajrStatus == PrayerStatus.performed) done++;
      if (record!.dhuhrStatus == PrayerStatus.performed) done++;
      if (record!.asrStatus == PrayerStatus.performed) done++;
      if (record!.maghribStatus == PrayerStatus.performed) done++;
      if (record!.ishaStatus == PrayerStatus.performed) done++;
      if (record!.morningAdhkar) done++;
      if (record!.eveningAdhkar) done++;
      if (record!.quranPages > 0) done++;
      if (record!.fastingType != FastingType.none) done++;
      if (record!.nightPrayer) done++;
    }
    final pct = done / totalIbadah;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'إنجاز اليوم',
                style: context.typography.bodySmall.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              Text(
                '$done / $totalIbadah',
                style: context.typography.bodySmall.copyWith(
                  color: context.colors.gold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _AnimatedProgressBar(progress: pct),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _motivate(pct),
                style: context.typography.caption.copyWith(
                  color: context.colors.textDim,
                ),
              ),
              Text(
                '${(pct * 100).round()}%',
                style: context.typography.caption.copyWith(
                  color: pct >= 0.8
                      ? context.colors.success
                      : context.colors.textDim,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _motivate(double p) {
    if (p >= 1.0) return 'يوم مكتمل الحمد لله ✨';
    if (p >= 0.7) return 'رائع، أنت على الطريق 💪';
    if (p >= 0.4) return 'استمر، لا تتوقف 🌿';
    return 'البداية الآن 🤲';
  }
}

class _AnimatedProgressBar extends StatefulWidget {
  final double progress;
  const _AnimatedProgressBar({required this.progress});

  @override
  State<_AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<_AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _anim = Tween<double>(
      begin: 0,
      end: widget.progress,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(_AnimatedProgressBar old) {
    super.didUpdateWidget(old);
    if (old.progress != widget.progress) {
      _anim = Tween<double>(
        begin: old.progress,
        end: widget.progress,
      ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
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
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _anim,
    builder: (_, _) => ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Stack(
        children: [
          Container(height: 10, color: context.colors.border),
          FractionallySizedBox(
            widthFactor: _anim.value.clamp(0.0, 1.0),
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.colors.gold,
                    _anim.value >= 0.8
                        ? context.colors.success
                        : context.colors.teal,
                  ],
                ),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: context.colors.gold.withOpacity(0.3),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════
//  PRAYERS GROUP
// ═══════════════════════════════════════════════════════════════
class _PrayersGroup extends ConsumerWidget {
  final DailyRecord? record;
  const _PrayersGroup({required this.record});

  static const _prayers = [
    ('الفجر', '🌅', 'fajr'),
    ('الظهر', '☀️', 'dhuhr'),
    ('العصر', '🌤', 'asr'),
    ('المغرب', '🌆', 'maghrib'),
    ('العشاء', '🌃', 'isha'),
  ];

  PrayerStatus _statusOf(String key) {
    if (record == null) return PrayerStatus.pending;
    return switch (key) {
      'fajr' => record!.fajrStatus,
      'dhuhr' => record!.dhuhrStatus,
      'asr' => record!.asrStatus,
      'maghrib' => record!.maghribStatus,
      'isha' => record!.ishaStatus,
      _ => PrayerStatus.pending,
    };
  }

  int get _countPerformed =>
      _prayers.where((p) => _statusOf(p.$3) == PrayerStatus.performed).length;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _GroupCard(
      icon: '🕌',
      title: 'الصلوات الخمس',
      trailing: '$_countPerformed / ٥',
      trailingColor: context.colors.gold,
      children: _prayers.map((p) {
        final status = _statusOf(p.$3);
        return _PrayerRow(
          emoji: p.$2,
          name: p.$1,
          status: status,
          onStatusChange: (newStatus) async {
            HapticFeedback.selectionClick();
            final rec = await ref
                .read(dailyRecordDaoProvider)
                .getOrCreateToday();
            await ref
                .read(dailyRecordDaoProvider)
                .updatePrayerStatus(
                  recordId: rec.id,
                  prayerName: p.$3,
                  status: newStatus,
                );
            // Sync to Supabase
            final updatedRec = await ref
                .read(dailyRecordDaoProvider)
                .getRecordByDate(DateTime.now());
            if (updatedRec != null) {
              await SyncManager.syncDailyRecord(ref, updatedRec);
            }
          },
        );
      }).toList(),
    );
  }
}

class _PrayerRow extends StatelessWidget {
  final String emoji, name;
  final PrayerStatus status;
  final void Function(PrayerStatus) onStatusChange;

  const _PrayerRow({
    required this.emoji,
    required this.name,
    required this.status,
    required this.onStatusChange,
  });

  Color _rowColor(BuildContext context) => switch (status) {
    PrayerStatus.performed => context.colors.success,
    PrayerStatus.qadaa => context.colors.warning,
    PrayerStatus.missed => context.colors.danger,
    _ => context.colors.textDim,
  };

  String get _statusLabel => switch (status) {
    PrayerStatus.performed => 'في وقتها ✓',
    PrayerStatus.qadaa => 'قضاء',
    PrayerStatus.missed => 'فاتت',
    PrayerStatus.pending => 'لم تُؤدَّ بعد',
    _ => 'لم يحن وقتها',
  };

  @override
  Widget build(BuildContext context) {
    final isDone = status == PrayerStatus.performed;
    final isQadaa = status == PrayerStatus.qadaa;
    final isMissed = status == PrayerStatus.missed;

    return GestureDetector(
      onTap: () => _showStatusPicker(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: 7),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: isDone
              ? context.colors.success.withOpacity(0.08)
              : isQadaa
              ? context.colors.warning.withOpacity(0.07)
              : isMissed
              ? context.colors.danger.withOpacity(0.07)
              : context.colors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDone
                ? context.colors.success.withOpacity(0.25)
                : isQadaa
                ? context.colors.warning.withOpacity(0.22)
                : isMissed
                ? context.colors.danger.withOpacity(0.22)
                : context.colors.border,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone ? context.colors.success : Colors.transparent,
                border: Border.all(
                  color: _rowColor(context),
                  width: isDone ? 0 : 1.8,
                ),
              ),
              child: isDone
                  ? const Center(
                      child: Text(
                        '✓',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: context.typography.bodyMedium.copyWith(
                      fontSize: 13,
                      color: context.colors.textPrimary,
                      fontWeight: isDone ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  Text(
                    _statusLabel,
                    style: context.typography.caption.copyWith(
                      fontSize: 10,
                      color: _rowColor(context),
                    ),
                  ),
                ],
              ),
            ),
            if (isDone)
              _MiniPts('+١٠', context.colors.success)
            else if (isMissed)
              _MiniPts('-٥', context.colors.danger),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_left_rounded,
              size: 18,
              color: context.colors.textDim,
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusPicker(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _PrayerStatusSheet(
        prayerName: name,
        currentStatus: status,
        onSelect: onStatusChange,
      ),
    );
  }
}

// ── Bottom sheet for prayer status ──
class _PrayerStatusSheet extends StatelessWidget {
  final String prayerName;
  final PrayerStatus currentStatus;
  final void Function(PrayerStatus) onSelect;

  const _PrayerStatusSheet({
    required this.prayerName,
    required this.currentStatus,
    required this.onSelect,
  });

  List<(PrayerStatus, String, String, Color)> _options(BuildContext context) =>
      [
        (PrayerStatus.performed, 'أُديت في وقتها', '✅', context.colors.success),
        (PrayerStatus.qadaa, 'قُضيت خارج الوقت', '🔄', context.colors.warning),
        (PrayerStatus.missed, 'فاتت (استغفر الله)', '❌', context.colors.danger),
        (PrayerStatus.pending, 'لم تُؤدَّ بعد', '⏳', context.colors.textDim),
      ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'صلاة $prayerName',
            style: context.typography.headingMedium.copyWith(
              fontSize: 18,
              color: context.colors.gold,
            ),
          ),
          const SizedBox(height: 14),
          ..._options(context).map(
            (opt) => _StatusOption(
              status: opt.$1,
              label: opt.$2,
              emoji: opt.$3,
              color: opt.$4,
              isSelected: currentStatus == opt.$1,
              onTap: () {
                onSelect(opt.$1);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusOption extends StatelessWidget {
  final PrayerStatus status;
  final String label, emoji;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusOption({
    required this.status,
    required this.label,
    required this.emoji,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.12) : context.colors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color.withOpacity(0.4) : context.colors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: context.typography.bodyMedium.copyWith(
                  fontSize: 13,
                  color: isSelected ? color : context.colors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: color, size: 18),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  IBADAH GROUP (قرآن + أذكار + صيام + صدقة + قيام)
// ═══════════════════════════════════════════════════════════════
class _IbadahGroup extends ConsumerWidget {
  final DailyRecord? record;
  final TextEditingController quranCtrl;
  const _IbadahGroup({required this.record, required this.quranCtrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (quranCtrl.text.isEmpty && (record?.quranPages ?? 0) > 0) {
      quranCtrl.text = record!.quranPages.toString();
    }

    return _GroupCard(
      icon: '📖',
      title: 'القرآن والأذكار',
      children: [
        _QuranInput(record: record, ctrl: quranCtrl),
        const SizedBox(height: 8),

        _ToggleRow(
          emoji: '🌅',
          label: 'أذكار الصباح',
          sublabel: 'بعد صلاة الفجر',
          points: '+٥',
          value: record?.morningAdhkar ?? false,
          onChanged: (v) async {
            final rec = await ref
                .read(dailyRecordDaoProvider)
                .getOrCreateToday();
            await ref
                .read(dailyRecordDaoProvider)
                .updateAdhkar(recordId: rec.id, morning: v);
            await SyncManager.syncDailyRecord(
              ref,
              await ref.read(dailyRecordDaoProvider).getOrCreateToday(),
            );
          },
        ),

        _ToggleRow(
          emoji: '🌆',
          label: 'أذكار المساء',
          sublabel: 'بعد صلاة العصر',
          points: '+٥',
          value: record?.eveningAdhkar ?? false,
          onChanged: (v) async {
            final rec = await ref
                .read(dailyRecordDaoProvider)
                .getOrCreateToday();
            await ref
                .read(dailyRecordDaoProvider)
                .updateAdhkar(recordId: rec.id, evening: v);
            await SyncManager.syncDailyRecord(
              ref,
              await ref.read(dailyRecordDaoProvider).getOrCreateToday(),
            );
          },
        ),

        _ToggleRow(
          emoji: '🌌',
          label: 'قيام الليل',
          sublabel: 'الثلث الأخير من الليل',
          points: '+١٥',
          value: record?.nightPrayer ?? false,
          onChanged: (v) async {
            final rec = await ref
                .read(dailyRecordDaoProvider)
                .getOrCreateToday();
            await ref.read(dailyRecordDaoProvider).toggleNightPrayer(rec.id, v);
            await SyncManager.syncDailyRecord(
              ref,
              await ref.read(dailyRecordDaoProvider).getOrCreateToday(),
            );
          },
        ),

        _FastingSelector(record: record),

        _ToggleRow(
          emoji: '💧',
          label: 'الصدقة',
          sublabel: 'ولو بكلمة طيبة',
          points: '+١٠',
          value: record?.sadaqah ?? false,
          onChanged: (v) async {
            final rec = await ref
                .read(dailyRecordDaoProvider)
                .getOrCreateToday();
            await ref.read(dailyRecordDaoProvider).toggleSadaqah(rec.id, v);
            await SyncManager.syncDailyRecord(
              ref,
              await ref.read(dailyRecordDaoProvider).getOrCreateToday(),
            );
          },
        ),
      ],
    );
  }
}

// ── حقل القرآن ──
class _QuranInput extends ConsumerWidget {
  final DailyRecord? record;
  final TextEditingController ctrl;
  const _QuranInput({required this.record, required this.ctrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasPages = (record?.quranPages ?? 0) > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: hasPages
            ? context.colors.teal.withOpacity(0.07)
            : context.colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasPages
              ? context.colors.teal.withOpacity(0.3)
              : context.colors.border,
        ),
      ),
      child: Row(
        children: [
          const Text('📖', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تلاوة القرآن الكريم',
                  style: context.typography.bodyMedium.copyWith(
                    fontSize: 13,
                    color: context.colors.textPrimary,
                  ),
                ),
                Text(
                  'أدخل عدد الصفحات التي قرأتها',
                  style: context.typography.caption.copyWith(
                    fontSize: 10,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 64,
            child: TextFormField(
              controller: ctrl,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              style: context.typography.bodyMedium.copyWith(
                fontSize: 15,
                color: context.colors.teal,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: '٠',
                hintStyle: context.typography.caption.copyWith(
                  fontSize: 13,
                  color: context.colors.textDim,
                ),
                filled: true,
                fillColor: context.colors.card,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: context.colors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: context.colors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: context.colors.teal,
                    width: 1.5,
                  ),
                ),
              ),
              onChanged: (v) async {
                final pages = int.tryParse(v) ?? 0;
                final rec = await ref
                    .read(dailyRecordDaoProvider)
                    .getOrCreateToday();
                await ref
                    .read(dailyRecordDaoProvider)
                    .updateQuran(recordId: rec.id, pages: pages);
                await SyncManager.syncDailyRecord(
                  ref,
                  await ref.read(dailyRecordDaoProvider).getOrCreateToday(),
                );
              },
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '+١',
            style: context.typography.caption.copyWith(
              fontSize: 10,
              color: context.colors.teal,
            ),
          ),
          Text(
            '/صفحة',
            style: context.typography.caption.copyWith(
              fontSize: 9,
              color: context.colors.textDim,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Toggle Row ──
class _ToggleRow extends StatelessWidget {
  final String emoji, label, sublabel, points;
  final bool value;
  final void Function(bool) onChanged;

  const _ToggleRow({
    required this.emoji,
    required this.label,
    required this.sublabel,
    required this.points,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onChanged(!value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 7),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: value
              ? context.colors.success.withOpacity(0.08)
              : context.colors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value
                ? context.colors.success.withOpacity(0.25)
                : context.colors.border,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: value ? context.colors.success : Colors.transparent,
                border: Border.all(
                  color: value ? context.colors.success : context.colors.border,
                  width: 1.8,
                ),
              ),
              child: value
                  ? const Center(
                      child: Text(
                        '✓',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: context.typography.bodyMedium.copyWith(
                      fontSize: 13,
                      color: context.colors.textPrimary,
                      fontWeight: value ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  Text(
                    sublabel,
                    style: context.typography.caption.copyWith(
                      fontSize: 10,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (value) _MiniPts(points, context.colors.success),
          ],
        ),
      ),
    );
  }
}

// ── Fasting Selector ──
class _FastingSelector extends ConsumerWidget {
  final DailyRecord? record;
  const _FastingSelector({required this.record});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = record?.fastingType ?? FastingType.none;

    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: current != FastingType.none
            ? context.colors.teal.withOpacity(0.07)
            : context.colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: current != FastingType.none
              ? context.colors.teal.withOpacity(0.25)
              : context.colors.border,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text('🌙', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'الصيام',
                  style: context.typography.bodyMedium.copyWith(
                    fontSize: 13,
                    color: context.colors.textPrimary,
                  ),
                ),
              ),
              if (current != FastingType.none)
                _MiniPts(
                  current == FastingType.fard ? '+٢٠' : '+١٠',
                  context.colors.teal,
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _fastChip(
                'فريضة',
                FastingType.fard,
                current,
                context.colors.gold,
                ref,
                context,
              ),
              const SizedBox(width: 6),
              _fastChip(
                'نافلة',
                FastingType.nafl,
                current,
                context.colors.teal,
                ref,
                context,
              ),
              const SizedBox(width: 6),
              _fastChip(
                'لم أصم',
                FastingType.none,
                current,
                context.colors.textDim,
                ref,
                context,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fastChip(
    String label,
    FastingType value,
    FastingType current,
    Color color,
    WidgetRef ref,
    BuildContext context,
  ) {
    final selected = current == value;
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          HapticFeedback.selectionClick();
          final rec = await ref.read(dailyRecordDaoProvider).getOrCreateToday();
          await ref.read(dailyRecordDaoProvider).updateFasting(rec.id, value);
          await SyncManager.syncDailyRecord(
            ref,
            await ref.read(dailyRecordDaoProvider).getOrCreateToday(),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.15) : context.colors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? color.withOpacity(0.4) : context.colors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: context.typography.caption.copyWith(
                fontSize: 11,
                color: selected ? color : context.colors.textDim,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  PROHIBITIONS GROUP
// ═══════════════════════════════════════════════════════════════
class _ProhibitionsGroup extends ConsumerWidget {
  final DailyRecord? record;
  const _ProhibitionsGroup({required this.record});

  static const _items = [
    (ProhibitionCategory.ghadhBasar, '👁️', 'غضّ البصر', 'حفظ النظر عن الحرام'),
    (ProhibitionCategory.gheeba, '🗣️', 'الغيبة', 'ذكر الناس بما يكرهون'),
    (ProhibitionCategory.nameema, '👂', 'النميمة', 'نقل الكلام بقصد الإفساد'),
    (ProhibitionCategory.kadhb, '🚫', 'الكذب', 'قول غير الحق'),
    (ProhibitionCategory.ghaDab, '😠', 'الغضب', 'إن غضبت فاسكت'),
    (
      ProhibitionCategory.idaatWaqt,
      '📱',
      'إضاعة الوقت',
      'التقصير في استثمار الوقت',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _GroupCard(
      icon: '⚠️',
      title: 'المحظورات والمهلكات',
      titleColor: context.colors.danger,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: context.colors.danger.withOpacity(0.07),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: context.colors.danger.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'حدد ما وقعت فيه اليوم بصدق مع نفسك',
                  style: context.typography.caption.copyWith(
                    fontSize: 11,
                    color: context.colors.danger.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
        ..._items.map(
          (item) => _ProhibitionRow(
            category: item.$1,
            emoji: item.$2,
            name: item.$3,
            desc: item.$4,
            recordId: record?.id,
          ),
        ),
      ],
    );
  }
}

class _ProhibitionRow extends ConsumerStatefulWidget {
  final ProhibitionCategory category;
  final String emoji, name, desc;
  final int? recordId;

  const _ProhibitionRow({
    required this.category,
    required this.emoji,
    required this.name,
    required this.desc,
    required this.recordId,
  });

  @override
  ConsumerState<_ProhibitionRow> createState() => _ProhibitionRowState();
}

class _ProhibitionRowState extends ConsumerState<_ProhibitionRow> {
  bool _committed = false;
  int _count = 0;

  Future<void> _toggle() async {
    if (widget.recordId == null) return;
    HapticFeedback.selectionClick();
    final newVal = !_committed;
    setState(() {
      _committed = newVal;
      if (!newVal) _count = 0;
    });

    await ref
        .read(dailyRecordDaoProvider)
        .logProhibition(
          recordId: widget.recordId!,
          category: widget.category,
          committed: newVal,
          timesCount: newVal ? (_count == 0 ? 1 : _count) : 0,
        );
    await SyncManager.syncDailyRecord(
      ref,
      await ref.read(dailyRecordDaoProvider).getOrCreateToday(),
    );
  }

  Future<void> _increment() async {
    if (!_committed || widget.recordId == null) return;
    HapticFeedback.selectionClick();
    setState(() => _count++);
    await ref
        .read(dailyRecordDaoProvider)
        .logProhibition(
          recordId: widget.recordId!,
          category: widget.category,
          committed: true,
          timesCount: _count,
        );
    await SyncManager.syncDailyRecord(
      ref,
      await ref.read(dailyRecordDaoProvider).getOrCreateToday(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: _committed
            ? context.colors.danger.withOpacity(0.07)
            : context.colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _committed
              ? context.colors.danger.withOpacity(0.25)
              : context.colors.border,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _toggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: _committed ? context.colors.danger : Colors.transparent,
                border: Border.all(
                  color: _committed
                      ? context.colors.danger
                      : context.colors.border,
                  width: 1.8,
                ),
              ),
              child: _committed
                  ? const Center(
                      child: Text(
                        '✗',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Text(widget.emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: context.typography.bodyMedium.copyWith(
                    fontSize: 13,
                    color: _committed
                        ? context.colors.danger
                        : context.colors.textPrimary,
                    fontWeight: _committed ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                Text(
                  widget.desc,
                  style: context.typography.caption.copyWith(
                    fontSize: 10,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (_committed) ...[
            GestureDetector(
              onTap: _increment,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: context.colors.danger.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: context.colors.danger.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$_count×',
                      style: context.typography.bodySmall.copyWith(
                        fontSize: 12,
                        color: context.colors.danger,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.add_rounded,
                      size: 14,
                      color: context.colors.danger,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            _MiniPts('-١٠', context.colors.danger),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  DAY NOTE FIELD
// ═══════════════════════════════════════════════════════════════
class _DayNoteField extends ConsumerStatefulWidget {
  final DailyRecord? record;
  const _DayNoteField({required this.record});

  @override
  ConsumerState<_DayNoteField> createState() => _DayNoteFieldState();
}

class _DayNoteFieldState extends ConsumerState<_DayNoteField> {
  final _ctrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _ctrl.text = widget.record?.notes ?? '';
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _GroupCard(
      icon: '📝',
      title: 'ملاحظة اليوم',
      children: [
        TextFormField(
          controller: _ctrl,
          maxLines: 3,
          maxLength: 300,
          style: context.typography.bodyMedium.copyWith(
            fontSize: 13,
            color: context.colors.textPrimary,
            height: 1.8,
          ),
          decoration: InputDecoration(
            hintText: 'اكتب ملاحظتك أو دعاءك لهذا اليوم...',
            hintStyle: context.typography.caption.copyWith(
              fontSize: 12,
              color: context.colors.textDim,
            ),
            counterStyle: context.typography.caption.copyWith(
              fontSize: 10,
              color: context.colors.textDim,
            ),
            filled: true,
            fillColor: context.colors.card,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.colors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.colors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.colors.gold, width: 1.5),
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),
        PrimaryButton(
          onTap: _saving ? null : () async => _save(),
          label: 'حفظ الملاحظة',
          isLoading: _saving,
        ),
      ],
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    HapticFeedback.mediumImpact();
    final rec = await ref.read(dailyRecordDaoProvider).getOrCreateToday();
    final db = ref.read(appDatabaseProvider);
    await (db.update(db.dailyRecords)..where((r) => r.id.equals(rec.id))).write(
      DailyRecordsCompanion(
        notes: Value(_ctrl.text.trim()),
        updatedAt: Value(DateTime.now()),
      ),
    );
    // Sync to Supabase
    final updatedRec = await ref
        .read(dailyRecordDaoProvider)
        .getOrCreateToday();
    await SyncManager.syncDailyRecord(ref, updatedRec);
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم الحفظ ✓',
            style: context.typography.bodySmall.copyWith(fontSize: 13),
          ),
          backgroundColor: context.colors.success,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}

// ═══════════════════════════════════════════════════════════════
//  SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════
class _GroupCard extends StatelessWidget {
  final String icon, title;
  final Color? titleColor, trailingColor;
  final String? trailing;
  final List<Widget> children;

  const _GroupCard({
    required this.icon,
    required this.title,
    required this.children,
    this.titleColor,
    this.trailingColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                title,
                style: context.typography.headingMedium.copyWith(
                  fontSize: 16,
                  color: titleColor ?? context.colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (trailing != null)
                Text(
                  trailing!,
                  style: context.typography.bodySmall.copyWith(
                    fontSize: 12,
                    color: trailingColor ?? context.colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Container(height: 1, color: context.colors.border),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _MiniPts extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniPts(this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Text(
      label,
      style: context.typography.caption.copyWith(
        fontSize: 10,
        color: color,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
