// ═══════════════════════════════════════════════════════════════
//  lib/features/adhkar/presentation/screens/adhkar_screen.dart
// تقوى — شاشة الأذكار الكاملة
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takwa/core/providers/adhkar_providers.dart';
import 'package:takwa/core/providers/database_providers.dart';
import 'package:takwa/core/theme/app_theme.dart';
import 'package:takwa/core/theme/ramadan_theme.dart';
import 'package:takwa/core/utils/overlay_helper.dart';
import 'package:takwa/core/widgets/primary_button.dart';
import 'package:takwa/core/widgets/custom_leading_button.dart';
import 'package:takwa/core/widgets/custom_pattern_background.dart';
import 'package:takwa/features/adhkar/_user_community_adhkar_views.dart';
import 'package:takwa/core/providers/favorites_providers.dart';
import 'package:takwa/core/routes/app_routes.dart';

// ═══════════════════════════════════════════════════════════════
//  ADHKAR SCREEN
// ═══════════════════════════════════════════════════════════════
class AdhkarScreen extends ConsumerStatefulWidget {
  final int initialCategoryIndex;

  const AdhkarScreen({super.key, this.initialCategoryIndex = 0});
  @override
  ConsumerState<AdhkarScreen> createState() => _AdhkarScreenState();
}

class _AdhkarScreenState extends ConsumerState<AdhkarScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryCtrl;
  late final TabController _tabCtrl;
  static const _tabs = [
    ('🌅', 'الصباح'),
    ('🌆', 'المساء'),
    ('🕌', 'بعد الصلاة'),
    ('🌙', 'النوم'),
    ('📿', 'متنوعة'),
    ('✨', 'أذكاري'),
    ('🌍', 'المجتمع'),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(
      initialIndex: widget.initialCategoryIndex,
      length: _tabs.length,
      vsync: this,
    );
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        _entryCtrl.forward(from: 0);
      }
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRamadan = ref.watch(ramadanModeProvider).value ?? false;
    final style = AdaptiveStyle(context, isRamadan);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: style.bg,
        body: Stack(
          children: [
            const Positioned.fill(
              child: CustomPatternBackground(pattern: BackgroundPattern.adhkar),
            ),
            Column(
              children: [
                _AdhkarTopBar(tabCtrl: _tabCtrl, tabs: _tabs),
                Expanded(
                  child: TabBarView(
                    controller: _tabCtrl,
                    children: [
                      ...AdhkarCategory.values.map(
                        (cat) => _AdhkarCategoryView(
                          category: cat,
                          entryCtrl: _entryCtrl,
                        ),
                      ),
                      _UserAdhkarTabView(entryCtrl: _entryCtrl),
                      _CommunityAdhkarTabView(entryCtrl: _entryCtrl),
                    ],
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

// ─────────────────────────────────────────
//  TOP BAR + TABS
// ─────────────────────────────────────────
class _AdhkarTopBar extends StatelessWidget {
  final TabController tabCtrl;
  final List<(String, String)> tabs;

  const _AdhkarTopBar({required this.tabCtrl, required this.tabs});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [context.colors.gold.withOpacity(0.1), Colors.transparent],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  const CustomLeadingButton(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الأذكار والأدعية',
                          style: context.typography.headingMedium.copyWith(
                            fontSize: 22,
                            color: context.colors.gold,
                            fontWeight: FontWeight.w700,
                            shadows: [
                              Shadow(
                                color: context.colors.gold.withOpacity(0.3),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'حصن المسلم',
                          style: context.typography.caption.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(
                            context,
                          ).pushNamed(Routes.favoriteAdhkar);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: context.colors.card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: context.colors.border),
                          ),
                          child: const Center(
                            child: Text('❤️', style: TextStyle(fontSize: 18)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Consumer(builder: (_, ref, _) => _NotifSettingsButton()),
                    ],
                  ),
                ],
              ),
            ),

            // Tabs
            TabBar(
              // 1. Removes the ink ripple on click
              splashFactory: NoSplash.splashFactory,
              // 2. Removes the grey circle highlight on long press
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              // 3. Optional: Remove indicator padding if it causes overflow
              controller: tabCtrl,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                gradient: LinearGradient(
                  colors: [context.colors.gold, context.colors.teal],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.symmetric(
                vertical: 6,
                horizontal: 0,
              ),
              labelStyle: context.typography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: context.typography.bodySmall,
              labelColor: context.colors.night,
              unselectedLabelColor: context.colors.textSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              tabs: tabs
                  .map((t) => Tab(text: '${t.$1} ${t.$2}', height: 36))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  CATEGORY VIEW
// ─────────────────────────────────────────
class _AdhkarCategoryView extends ConsumerStatefulWidget {
  final AdhkarCategory category;
  final AnimationController entryCtrl;

  const _AdhkarCategoryView({required this.category, required this.entryCtrl});

  @override
  ConsumerState<_AdhkarCategoryView> createState() =>
      _AdhkarCategoryViewState();
}

class _AdhkarCategoryViewState extends ConsumerState<_AdhkarCategoryView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final items = kAdhkarData[widget.category] ?? [];
    final progress = ref.watch(adhkarProgressProvider(widget.category));
    final doneCount = progress.values.where((v) => v >= 1).length;

    return Column(
      children: [
        // Progress header
        _CategoryProgressBar(
          total: items.length,
          done: doneCount,
          category: widget.category,
          onReset: () => ref
              .read(adhkarProgressProvider(widget.category).notifier)
              .reset(),
        ),

        // List
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: items.length,
            itemBuilder: (_, i) {
              final delay = (i * 0.05).clamp(0.0, 0.5);
              return FadeTransition(
                opacity: Tween<double>(begin: 0, end: 1).animate(
                  CurvedAnimation(
                    parent: widget.entryCtrl,
                    curve: Interval(
                      delay,
                      (delay + 0.4).clamp(0, 1),
                      curve: Curves.easeOut,
                    ),
                  ),
                ),
                child: SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: const Offset(0, 0.08),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: widget.entryCtrl,
                          curve: Interval(
                            delay,
                            (delay + 0.4).clamp(0, 1),
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                      ),
                  child: _DhikrCard(
                    dhikr: items[i],
                    category: widget.category,
                    index: i,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
//  PROGRESS HEADER
// ─────────────────────────────────────────
class _CategoryProgressBar extends StatelessWidget {
  final int total, done;
  final AdhkarCategory category;
  final VoidCallback onReset;

  const _CategoryProgressBar({
    required this.total,
    required this.done,
    required this.category,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? done / total : 0.0;
    final isDone = done >= total;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDone
            ? context.colors.success.withOpacity(0.1)
            : context.colors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDone
              ? context.colors.success.withOpacity(0.3)
              : context.colors.border,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                isDone ? '✅ مكتمل الحمد لله!' : '$done / $total ذكر',
                style: context.typography.bodySmall.copyWith(
                  color: isDone
                      ? context.colors.success
                      : context.colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (done > 0)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onReset();
                  },
                  child: Text(
                    'إعادة',
                    style: context.typography.caption.copyWith(
                      color: context.colors.textDim,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                Container(height: 5, color: context.colors.border),
                AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 400),
                  widthFactor: pct,
                  child: Container(
                    height: 5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDone
                            ? [context.colors.success, context.colors.teal]
                            : [context.colors.gold, context.colors.teal],
                      ),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (isDone
                                      ? context.colors.success
                                      : context.colors.gold)
                                  .withOpacity(0.4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
//  DHIKR CARD
// ─────────────────────────────────────────
class _DhikrCard extends ConsumerStatefulWidget {
  final DhikrItem dhikr;
  final AdhkarCategory category;
  final int index;

  const _DhikrCard({
    required this.dhikr,
    required this.category,
    required this.index,
  });

  @override
  ConsumerState<_DhikrCard> createState() => _DhikrCardState();
}

class _DhikrCardState extends ConsumerState<_DhikrCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _tapCtrl;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _tapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
  }

  @override
  void dispose() {
    _tapCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(adhkarProgressProvider(widget.category));
    final count = progress[widget.index] ?? 0;
    final isDone = count >= widget.dhikr.count;
    final remaining = (widget.dhikr.count - count).clamp(0, widget.dhikr.count);

    return GestureDetector(
      onTap: () {
        if (isDone) return;
        HapticFeedback.selectionClick();
        _tapCtrl.forward(from: 0).then((_) => _tapCtrl.reverse());
        ref
            .read(adhkarProgressProvider(widget.category).notifier)
            .increment(widget.index, widget.dhikr.count);
      },
      onLongPress: () {
        HapticFeedback.mediumImpact();
        setState(() => _expanded = !_expanded);
      },
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 1,
          end: 0.96,
        ).animate(CurvedAnimation(parent: _tapCtrl, curve: Curves.easeOut)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            gradient: isDone
                ? LinearGradient(
                    colors: [
                      context.colors.success.withOpacity(0.08),
                      context.colors.teal.withOpacity(0.05),
                    ],
                  )
                : null,
            color: isDone ? null : context.colors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDone
                  ? context.colors.success.withOpacity(0.3)
                  : context.colors.border,
              width: isDone ? 1.5 : 1,
            ),
            boxShadow: isDone
                ? [
                    BoxShadow(
                      color: context.colors.success.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // النص العربي
                    Text(
                      widget.dhikr.arabic,
                      textAlign: TextAlign.center,
                      style: context.typography.headingMedium.copyWith(
                        fontSize: 20,
                        color: isDone
                            ? context.colors.success.withOpacity(0.8)
                            : context.colors.textPrimary,
                        height: 2.0,
                      ),
                    ),

                    // الفضل (عند التوسع)
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 250),
                      crossFadeState: _expanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      firstChild: const SizedBox.shrink(),
                      secondChild: Column(
                        children: [
                          if (widget.dhikr.transliteration != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              height: 1,
                              color: context.colors.border,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.dhikr.transliteration!,
                              textAlign: TextAlign.center,
                              style: context.typography.caption.copyWith(
                                color: context.colors.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                          if (widget.dhikr.fadl != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: context.colors.gold.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: context.colors.gold.withOpacity(0.15),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Text(
                                    '✨',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      widget.dhikr.fadl!,
                                      style: context.typography.caption
                                          .copyWith(color: context.colors.gold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (widget.dhikr.source != null) ...[
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '— ${widget.dhikr.source}',
                                style: context.typography.caption.copyWith(
                                  color: context.colors.textDim,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // الشريط السفلي
                    Row(
                      children: [
                        // عداد
                        if (!isDone) ...[
                          _CounterBubble(
                            current: count,
                            total: widget.dhikr.count,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$remaining متبقي',
                            style: context.typography.caption.copyWith(
                              color: context.colors.textDim,
                            ),
                          ),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: context.colors.success.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: context.colors.success.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_rounded,
                                  size: 14,
                                  color: context.colors.success,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'مكتمل ${widget.dhikr.count}×',
                                  style: context.typography.bodySmall.copyWith(
                                    color: context.colors.success,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const Spacer(),

                        Consumer(
                          builder: (context, ref, _) {
                            final favs = ref.watch(favoriteAdhkarProvider);
                            final isFav = favs.contains(widget.dhikr.id);
                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                ref
                                    .read(favoriteAdhkarProvider.notifier)
                                    .toggle(widget.dhikr.id);
                              },
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  isFav
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  key: ValueKey(isFav),
                                  color: isFav
                                      ? Colors.red.shade400
                                      : context.colors.textSecondary,
                                  size: 20,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),

                        // expand hint
                        Text(
                          _expanded ? 'إخفاء' : 'الفضل',
                          style: context.typography.caption.copyWith(
                            color: context.colors.textDim,
                          ),
                        ),
                        const SizedBox(width: 4),
                        AnimatedRotation(
                          turns: _expanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 250),
                          child: Icon(
                            Icons.expand_more_rounded,
                            size: 16,
                            color: context.colors.textDim,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // شريط تقدم أسفل البطاقة
              if (!isDone)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(15),
                  ),
                  child: AnimatedFractionallySizedBox(
                    duration: const Duration(milliseconds: 300),
                    alignment: AlignmentDirectional.centerEnd,
                    widthFactor: widget.dhikr.count > 0
                        ? count / widget.dhikr.count
                        : 0,
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [context.colors.gold, context.colors.teal],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── فقاعة العداد ──
class _CounterBubble extends StatelessWidget {
  final int current, total;
  const _CounterBubble({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: context.colors.gold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.gold.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$current',
            style: context.typography.bodyMedium.copyWith(
              color: context.colors.gold,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            ' / $total',
            style: context.typography.caption.copyWith(
              color: context.colors.textDim,
            ),
          ),
        ],
      ),
    );
  }
}

// ── زر إعدادات الإشعارات ──
class _NotifSettingsButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(adhkarNotifEnabledProvider);
    return GestureDetector(
      onTap: () => _showNotifSettings(context, ref),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: enabled
              ? context.colors.gold.withOpacity(0.1)
              : context.colors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: enabled
                ? context.colors.gold.withOpacity(0.3)
                : context.colors.border,
          ),
        ),
        child: Center(
          child: Text(
            enabled ? '🔔' : '🔕',
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }

  void _showNotifSettings(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _AdhkarNotifSheet(),
    );
  }
}

// ─────────────────────────────────────────
//  NOTIFICATION SETTINGS SHEET
// ─────────────────────────────────────────
class _AdhkarNotifSheet extends ConsumerWidget {
  const _AdhkarNotifSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(adhkarNotifEnabledProvider);
    final morningTime = ref.watch(adhkarMorningTimeProvider);
    final eveningTime = ref.watch(adhkarEveningTimeProvider);
    final afterFajr = ref.watch(adhkarAfterFajrProvider);
    final afterAsr = ref.watch(adhkarAfterAsrProvider);
    final sleepTime = ref.watch(adhkarSleepTimeProvider);

    return Container(
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: context.colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Text(
                  'إشعارات الأذكار',
                  style: context.typography.headingMedium.copyWith(
                    fontSize: 18,
                    color: context.colors.gold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: enabled,
                  onChanged: (v) {
                    ref.read(adhkarNotifEnabledProvider.notifier).set(v);
                    if (!v) AdhkarNotificationService.cancelAll();
                  },
                  activeColor: context.colors.gold,
                  activeTrackColor: context.colors.gold.withOpacity(0.3),
                  inactiveTrackColor: context.colors.border,
                  inactiveThumbColor: context.colors.textDim,
                ),
              ],
            ),
          ),
          const Divider(height: 20),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: enabled
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Row(
                children: [
                  const Text('🔕', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Text(
                    'الإشعارات متوقفة',
                    style: context.typography.bodyMedium.copyWith(
                      color: context.colors.textDim,
                    ),
                  ),
                ],
              ),
            ),
            secondChild: ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              children: [
                _NotifRow(
                  icon: '🌅',
                  label: 'أذكار الصباح',
                  time: morningTime,
                  onTimeTap: () async {
                    final t = await _pickTime(context, morningTime);
                    if (t != null) {
                      ref.read(adhkarMorningTimeProvider.notifier).set(t);
                      await AdhkarNotificationService.scheduleMorning(t);
                    }
                  },
                ),
                _NotifRow(
                  icon: '🌆',
                  label: 'أذكار المساء',
                  time: eveningTime,
                  onTimeTap: () async {
                    final t = await _pickTime(context, eveningTime);
                    if (t != null) {
                      ref.read(adhkarEveningTimeProvider.notifier).set(t);
                      await AdhkarNotificationService.scheduleEvening(t);
                    }
                  },
                ),
                _NotifRow(
                  icon: '🌙',
                  label: 'أذكار النوم',
                  time: sleepTime,
                  onTimeTap: () async {
                    final t = await _pickTime(context, sleepTime);
                    if (t != null) {
                      ref.read(adhkarSleepTimeProvider.notifier).set(t);
                    }
                  },
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                _ToggleRow(
                  icon: '🌅',
                  label: 'بعد صلاة الفجر',
                  value: afterFajr,
                  onChanged: (v) =>
                      ref.read(adhkarAfterFajrProvider.notifier).set(v),
                ),
                _ToggleRow(
                  icon: '🌇',
                  label: 'بعد صلاة العصر',
                  value: afterAsr,
                  onChanged: (v) =>
                      ref.read(adhkarAfterAsrProvider.notifier).set(v),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    onTap: () async {
                      final dhikr = (kAdhkarData[AdhkarCategory.morning]!)[0];
                      await AdhkarNotificationService.showDhikrNow(dhikr);
                      if (context.mounted) Navigator.pop(context);
                    },
                    icon: Icons.notifications_active_outlined,
                    label: 'اختبار إشعار ذكر الآن',
                    isOutline: true,
                    baseColor: context.colors.gold,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    onTap: () async {
                      OverlayHelper.show(type: 'adhkar');
                    },
                    icon: Icons.star_rounded,
                    label: 'اختبار الـ Overlay',
                    isOutline: false,
                    baseColor: context.colors.teal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<TimeOfDay?> _pickTime(BuildContext context, TimeOfDay current) =>
      showTimePicker(
        context: context,
        initialTime: current,
        builder: (ctx, child) => Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: ColorScheme.dark(primary: context.colors.gold),
          ),
          child: child!,
        ),
      );
}

class _NotifRow extends StatelessWidget {
  final String icon, label;
  final TimeOfDay time;
  final VoidCallback onTimeTap;

  const _NotifRow({
    required this.icon,
    required this.label,
    required this.time,
    required this.onTimeTap,
  });

  @override
  Widget build(BuildContext context) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: context.typography.bodyMedium.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
          ),
          GestureDetector(
            onTap: onTimeTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: context.colors.gold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: context.colors.gold.withOpacity(0.25),
                ),
              ),
              child: Text(
                '$h:$m',
                style: context.typography.bodyLarge.copyWith(
                  color: context.colors.gold,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String icon, label;
  final bool value;
  final void Function(bool) onChanged;

  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: context.typography.bodyMedium.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: context.colors.teal,
          activeTrackColor: context.colors.teal.withOpacity(0.3),
          inactiveTrackColor: context.colors.border,
          inactiveThumbColor: context.colors.textDim,
        ),
      ],
    ),
  );
}

// ═══════════════════════════════════════════════════════════════
//  USER & COMMUNITY ADHKAR (delegates to _user_community_adhkar_views.dart)
// ═══════════════════════════════════════════════════════════════

class _UserAdhkarTabView extends StatelessWidget {
  final AnimationController entryCtrl;
  const _UserAdhkarTabView({required this.entryCtrl});

  @override
  Widget build(BuildContext context) => UserAdhkarTabView(entryCtrl: entryCtrl);
}

class _CommunityAdhkarTabView extends StatelessWidget {
  final AnimationController entryCtrl;
  const _CommunityAdhkarTabView({required this.entryCtrl});

  @override
  Widget build(BuildContext context) =>
      CommunityAdhkarTabView(entryCtrl: entryCtrl);
}
