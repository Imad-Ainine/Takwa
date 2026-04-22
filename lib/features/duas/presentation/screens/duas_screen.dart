// ═══════════════════════════════════════════════════════════════
//  lib/features/duas/presentation/screens/duas_screen.dart
//  تقوى — شاشة الأدعية
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:takwa/core/theme/ramadan_theme.dart';

import 'package:takwa/core/widgets/custom_pattern_background.dart';
import 'package:takwa/core/widgets/custom_leading_button.dart';
import 'package:takwa/core/providers/database_providers.dart';
import 'package:takwa/core/widgets/primary_button.dart';
import 'package:takwa/core/providers/favorites_providers.dart';
import 'package:takwa/core/providers/user_content_providers.dart';
import 'package:takwa/core/supabase/supabase_service.dart';
import 'package:takwa/features/duas/data/duas_data.dart';
import 'package:takwa/features/duas/presentation/screens/favorite_duas_screen.dart';

const _categoryMeta = {
  DuaCategory.morning: ('🌅', 'الصباح'),
  DuaCategory.distress: ('🌊', 'الكرب'),
  DuaCategory.guidance: ('🌟', 'الهداية'),
  DuaCategory.forgiveness: ('🌿', 'المغفرة'),
  DuaCategory.rizq: ('🌾', 'الرزق'),
  DuaCategory.health: ('🫀', 'الصحة'),
  DuaCategory.parents: ('❤️', 'الوالدين'),
  DuaCategory.travel: ('✈️', 'السفر'),
  DuaCategory.rain: ('🌧️', 'الاستسقاء'),
  DuaCategory.general: ('🤲', 'عامة'),
};

// ─────────────────────────────────────────
//  PROVIDERS
// ─────────────────────────────────────────
final _duaSearchProvider = StateProvider<String>((ref) => '');
final _selectedCatProvider = StateProvider<DuaCategory?>((ref) => null);
// Persistent favorites are now managed by favoriteDuasProvider from favorites_providers.dart

// ═══════════════════════════════════════════════════════════════
//  DUAS SCREEN
// ═══════════════════════════════════════════════════════════════
class DuasScreen extends ConsumerStatefulWidget {
  const DuasScreen({super.key});
  @override
  ConsumerState<DuasScreen> createState() => _DuasScreenState();
}

class _DuasScreenState extends ConsumerState<DuasScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryCtrl;
  late final TabController _tabCtrl;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<DuaItem> get _filteredDuas {
    final query = ref.read(_duaSearchProvider).trim().toLowerCase();
    final cat = ref.read(_selectedCatProvider);

    final all = kDuasData.values.expand((l) => l).toList();

    return all.where((d) {
      final matchCat = cat == null || d.category == cat;
      final matchQ =
          query.isEmpty ||
          d.arabic.contains(query) ||
          d.meaning.toLowerCase().contains(query) ||
          d.occasion.toLowerCase().contains(query);
      return matchCat && matchQ;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isRamadan = ref.watch(ramadanModeProvider).value ?? false;
    final style = AdaptiveStyle(context, isRamadan);
    ref.watch(_duaSearchProvider);
    ref.watch(_selectedCatProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: style.bg,
        body: Stack(
          children: [
            const Positioned.fill(
              child: CustomPatternBackground(pattern: BackgroundPattern.duas),
            ),

            Column(
              children: [
                _DuasTopBar(
                  style: style,
                  searchCtrl: _searchCtrl,
                  tabCtrl: _tabCtrl,
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabCtrl,
                    children: [
                      Column(
                        children: [
                          _CategoryFilter(style: style),
                          Expanded(
                            child: _DuasList(
                              duas: _filteredDuas,
                              style: style,
                              entryCtrl: _entryCtrl,
                            ),
                          ),
                        ],
                      ),
                      _UserDuasTabView(style: style),
                      _CommunityDuasTabView(style: style),
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

class _DuasTopBar extends ConsumerWidget {
  final AdaptiveStyle style;
  final TextEditingController searchCtrl;
  final TabController tabCtrl;
  const _DuasTopBar({
    required this.style,
    required this.searchCtrl,
    required this.tabCtrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Column(
          children: [
            Row(
              children: [
                const CustomLeadingButton(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الأدعية المأثورة',
                        style: style.amiri(22, color: style.gold),
                      ),
                      Text(
                        'من الكتاب والسنة',
                        style: style.naskh(11, color: style.textSec),
                      ),
                    ],
                  ),
                ),
                // Favs button → navigate to FavoriteDuasScreen
                Consumer(
                  builder: (_, ref, _) {
                    final favCount = ref.watch(favoriteDuasProvider).length;
                    return GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const FavoriteDuasScreen(),
                        ),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: style.goldDim,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: style.gold.withOpacity(0.3),
                              ),
                            ),
                            child: const Center(
                              child: Text('❤️', style: TextStyle(fontSize: 18)),
                            ),
                          ),
                          if (favCount > 0)
                            Positioned(
                              top: -4,
                              right: -4,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade400,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '$favCount',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Search
            Container(
              decoration: BoxDecoration(
                color: style.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: style.border),
              ),
              child: TextField(
                controller: searchCtrl,
                textDirection: TextDirection.rtl,
                style: style.naskh(13),
                onChanged: (v) =>
                    ref.read(_duaSearchProvider.notifier).state = v,
                decoration: InputDecoration(
                  hintText: 'ابحث في الأدعية...',
                  hintStyle: style.naskh(12, color: style.textSec),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: style.textSec,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Theme(
              data: Theme.of(context).copyWith(
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
              ),
              child: TabBar(
                // 1. Removes the ink ripple on click
                splashFactory: NoSplash.splashFactory,
                // 2. Removes the grey circle highlight on long press
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                // 3. Optional: Remove indicator padding if it causes overflow
                indicatorPadding: EdgeInsets.zero,
                controller: tabCtrl,
                indicatorColor: style.gold,
                indicatorWeight: 3,
                labelColor: style.gold,
                unselectedLabelColor: style.textSec,
                labelStyle: style.naskh(14, weight: FontWeight.w600),
                unselectedLabelStyle: style.naskh(13, weight: FontWeight.w400),
                tabs: const [
                  Tab(text: 'المأثورة'),
                  Tab(text: 'أدعيتي'),
                  Tab(text: 'من المجتمع'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryFilter extends ConsumerWidget {
  final AdaptiveStyle style;
  const _CategoryFilter({required this.style});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(_selectedCatProvider);
    const cats = DuaCategory.values;

    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        reverse: true,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: cats.length + 1,
        itemBuilder: (_, i) {
          if (i == 0) {
            final isAll = selected == null;
            return _FilterChip(
              label: '🤲 الكل',
              isActive: isAll,
              style: style,
              onTap: () => ref.read(_selectedCatProvider.notifier).state = null,
            );
          }
          final cat = cats[i - 1];
          final meta = _categoryMeta[cat]!;
          return _FilterChip(
            label: '${meta.$1} ${meta.$2}',
            isActive: selected == cat,
            style: style,
            onTap: () => ref.read(_selectedCatProvider.notifier).state =
                selected == cat ? null : cat,
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final AdaptiveStyle style;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.style,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(colors: [style.gold, style.teal])
              : null,
          color: isActive ? null : style.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? style.gold : style.border),
        ),
        child: Text(
          label,
          style: style.naskh(
            12,
            color: isActive ? style.bg : style.textSec,
            weight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _DuasList extends ConsumerWidget {
  final List<DuaItem> duas;
  final AdaptiveStyle style;
  final AnimationController entryCtrl;

  const _DuasList({
    required this.duas,
    required this.style,
    required this.entryCtrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (duas.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔍', style: TextStyle(fontSize: 36)),
            const SizedBox(height: 10),
            Text('لا توجد نتائج', style: style.amiri(16)),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: duas.length,
      itemBuilder: (_, i) {
        final d = i * 0.06;
        return FadeTransition(
          opacity: Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(
              parent: entryCtrl,
              curve: Interval(
                d.clamp(0, 0.8),
                (d + 0.4).clamp(0, 1.0),
                curve: Curves.easeOut,
              ),
            ),
          ),
          child: _DuaCard(dua: duas[i], style: style),
        );
      },
    );
  }
}

class _DuaCard extends ConsumerStatefulWidget {
  final DuaItem dua;
  final AdaptiveStyle style;
  const _DuaCard({required this.dua, required this.style});

  @override
  ConsumerState<_DuaCard> createState() => _DuaCardState();
}

class _DuaCardState extends ConsumerState<_DuaCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.style;
    final favs = ref.watch(favoriteDuasProvider);
    final isFav = favs.contains(widget.dua.id);

    return GestureDetector(
      onTap: () {
        setState(() => _expanded = !_expanded);
        HapticFeedback.selectionClick();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          gradient: _expanded
              ? LinearGradient(
                  colors: [s.gold.withOpacity(0.12), s.teal.withOpacity(0.06)],
                )
              : null,
          color: _expanded ? null : s.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _expanded ? s.gold.withOpacity(0.4) : s.border,
            width: _expanded ? 1.5 : 1,
          ),
          boxShadow: _expanded
              ? [BoxShadow(color: s.gold.withOpacity(0.1), blurRadius: 12)]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Text(widget.dua.emoji, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.dua.occasion,
                      style: s.naskh(12, color: s.textSec),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref
                          .read(favoriteDuasProvider.notifier)
                          .toggle(widget.dua.id);
                    },
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        isFav
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        key: ValueKey(isFav),
                        color: isFav ? Colors.red.shade400 : s.textSec,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: widget.dua.arabic));
                      HapticFeedback.mediumImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'تم النسخ ✓',
                            style: TextStyle(
                              fontFamily: 'NotoNaskhArabic',
                              fontSize: 12,
                            ),
                          ),
                          backgroundColor: s.teal,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                    child: Icon(Icons.copy_rounded, size: 16, color: s.textSec),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Arabic text
              Text(
                widget.dua.arabic,
                textAlign: TextAlign.center,
                style: s
                    .amiri(19, color: s.text, weight: FontWeight.w400)
                    .copyWith(height: 2.0),
              ),

              // Meaning + source (collapsed)
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 250),
                crossFadeState: _expanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: const SizedBox.shrink(),
                secondChild: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(height: 1, color: s.border),
                    const SizedBox(height: 10),
                    Text(
                      widget.dua.meaning,
                      textAlign: TextAlign.center,
                      style: s
                          .naskh(12, color: s.textSec)
                          .copyWith(height: 1.8),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: s.goldDim,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: s.gold.withOpacity(0.2)),
                          ),
                          child: Text(
                            widget.dua.source,
                            style: s.naskh(
                              11,
                              color: s.gold,
                              weight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),
              Align(
                alignment: Alignment.center,
                child: AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: s.textSec,
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

// ═══════════════════════════════════════════════════════════════
//  TAB 2: MY DUAS
// ═══════════════════════════════════════════════════════════════
class _UserDuasTabView extends ConsumerWidget {
  final AdaptiveStyle style;
  const _UserDuasTabView({required this.style});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userDuasProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const AddDuaSheet(),
          );
        },
        backgroundColor: style.gold,
        child: Icon(Icons.add, color: style.bg),
      ),
      body: state.when(
        loading: () =>
            Center(child: CircularProgressIndicator(color: style.gold)),
        error: (err, _) => Center(
          child: Text(
            'حدث خطأ في جلب أدعيتك',
            style: style.naskh(14, color: Colors.red),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🤲', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),
                  Text(
                    'لم تقم بإضافة أي أدعية بعد',
                    style: style.amiri(18, color: style.textSec),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: items.length,
            itemBuilder: (_, i) {
              final dua = items[i];
              return _UserDuaCard(dua: dua, style: style);
            },
          );
        },
      ),
    );
  }
}

class _UserDuaCard extends ConsumerWidget {
  final UserDuaItem dua;
  final AdaptiveStyle style;

  const _UserDuaCard({required this.dua, required this.style});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: style.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: style.border),
        boxShadow: [
          BoxShadow(
            color: style.gold.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
            child: Row(
              children: [
                Text(
                  dua.emoji.isNotEmpty ? dua.emoji : '🤲',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    dua.titleAr,
                    style: style.naskh(
                      14,
                      weight: FontWeight.w700,
                      color: style.gold,
                    ),
                  ),
                ),
                // Copy
                IconButton(
                  iconSize: 18,
                  tooltip: 'نسخ',
                  icon: Icon(
                    Icons.copy_rounded,
                    color: style.textSec,
                    size: 18,
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: dua.textAr));
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'تم النسخ ✓',
                          style: TextStyle(
                            fontFamily: 'NotoNaskhArabic',
                            fontSize: 12,
                          ),
                        ),
                        backgroundColor: style.teal,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                ),
                // Share to community
                IconButton(
                  iconSize: 18,
                  tooltip: 'مشاركة مع المجتمع',
                  icon: Icon(Icons.public_rounded, color: style.teal, size: 20),
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) =>
                        _ShareToDuaCommunitySheet(dua: dua, style: style),
                  ),
                ),
                // Delete
                IconButton(
                  iconSize: 18,
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('حذف الدعاء', style: style.naskh(16)),
                        content: Text(
                          'هل تريد حذف هذا الدعاء؟',
                          style: style.naskh(13, color: style.textSec),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(
                              'إلغاء',
                              style: style.naskh(13, color: style.textSec),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(
                              'حذف',
                              style: style.naskh(13, color: Colors.redAccent),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (ok == true && context.mounted) {
                      await ref.read(userDuasProvider.notifier).delete(dua.id);
                    }
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  dua.textAr,
                  textAlign: TextAlign.center,
                  style: style
                      .amiri(19, color: style.text)
                      .copyWith(height: 1.9),
                ),
                if (dua.occasion.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(height: 1, color: style.border),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 12,
                        color: style.textSec,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dua.occasion,
                        style: style.naskh(12, color: style.textSec),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Share to Community Sheet for Duas ───────────────────────────
class _ShareToDuaCommunitySheet extends ConsumerStatefulWidget {
  final UserDuaItem dua;
  final AdaptiveStyle style;
  const _ShareToDuaCommunitySheet({required this.dua, required this.style});
  @override
  ConsumerState<_ShareToDuaCommunitySheet> createState() =>
      _ShareToDuaCommunitySheetState();
}

class _ShareToDuaCommunitySheetState
    extends ConsumerState<_ShareToDuaCommunitySheet> {
  bool _isSharing = false;
  bool _shared = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.style;
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      decoration: BoxDecoration(
        color: s.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: s.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _shared ? '✅ تمت المشاركة!' : '🌍 مشاركة مع المجتمع',
            style: s.amiri(20, color: _shared ? Colors.green : s.gold),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: s.teal.withOpacity(0.07),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: s.teal.withOpacity(0.25)),
            ),
            child: Text(
              widget.dua.textAr,
              textAlign: TextAlign.center,
              style: s.amiri(18, color: s.text).copyWith(height: 1.9),
            ),
          ),
          const SizedBox(height: 20),
          if (!_shared)
            PrimaryButton(
              onTap: _isSharing
                  ? null
                  : () async {
                      setState(() => _isSharing = true);
                      try {
                        await ref
                            .read(userDuasProvider.notifier)
                            .shareDua(widget.dua);
                        if (mounted) setState(() => _shared = true);
                        await Future.delayed(const Duration(seconds: 1));
                        if (mounted) Navigator.pop(context);
                      } catch (e) {
                        if (mounted) {
                          setState(() => _isSharing = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('خطأ: $e'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      }
                    },
              icon: Icons.public_rounded,
              label: 'مشاركة مع المجتمع',
              baseColor: s.teal,
              isLoading: _isSharing,
            )
          else
            Text(
              'شكراً لمشاركتك مع مجتمع تقوى 🤍',
              textAlign: TextAlign.center,
              style: s.naskh(13, color: s.textSec),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  TAB 3: COMMUNITY DUAS
// ═══════════════════════════════════════════════════════════════
class _CommunityDuasTabView extends ConsumerWidget {
  final AdaptiveStyle style;
  const _CommunityDuasTabView({required this.style});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(communityDuasProvider);

    return state.when(
      loading: () =>
          Center(child: CircularProgressIndicator(color: style.teal)),
      error: (err, _) => Center(
        child: Text(
          'تعذر تحميل أدعية المجتمع',
          style: style.naskh(14, color: Colors.red),
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return RefreshIndicator(
            color: style.teal,
            onRefresh: () => ref.read(communityDuasProvider.notifier).refresh(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: 300,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🌍', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد أدعية مشتركة حالياً',
                          style: style.amiri(18, color: style.textSec),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'اسحب للأسفل للتحديث',
                          style: style.naskh(12, color: style.textSec),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: style.teal,
          onRefresh: () => ref.read(communityDuasProvider.notifier).refresh(),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            itemCount: items.length,
            itemBuilder: (_, i) {
              final dua = items[i];
              return _CommunityDuaCard(dua: dua, style: style);
            },
          ),
        );
      },
    );
  }
}

class _CommunityDuaCard extends ConsumerStatefulWidget {
  final CommunityDuaItem dua;
  final AdaptiveStyle style;

  const _CommunityDuaCard({required this.dua, required this.style});

  @override
  ConsumerState<_CommunityDuaCard> createState() => _CommunityDuaCardState();
}

class _CommunityDuaCardState extends ConsumerState<_CommunityDuaCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _heartCtrl;
  late final Animation<double> _heartScale;

  @override
  void initState() {
    super.initState();
    _heartCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _heartScale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _heartCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _heartCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.style;
    final dua = widget.dua;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [s.teal.withOpacity(0.09), s.card],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: s.teal.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: s.teal.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
            child: Row(
              children: [
                Text(
                  dua.emoji.isNotEmpty ? dua.emoji : '🌐',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    dua.titleAr,
                    style: s.naskh(14, weight: FontWeight.w700, color: s.teal),
                  ),
                ),
                // Copy
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: dua.textAr));
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'تم النسخ ✓',
                          style: TextStyle(
                            fontFamily: 'NotoNaskhArabic',
                            fontSize: 12,
                          ),
                        ),
                        backgroundColor: s.teal,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.copy_rounded, size: 16, color: s.textSec),
                  ),
                ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Text(
              dua.textAr,
              textAlign: TextAlign.center,
              style: s.amiri(19, color: s.text).copyWith(height: 1.9),
            ),
          ),
          if (dua.occasion.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Column(
                children: [
                  Container(height: 1, color: s.teal.withOpacity(0.2)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.schedule_rounded, size: 12, color: s.textSec),
                      const SizedBox(width: 4),
                      Text(dua.occasion, style: s.naskh(12, color: s.textSec)),
                    ],
                  ),
                ],
              ),
            ),
          // Footer — like button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Like counter
                Text(
                  '${dua.likes}',
                  style: s.naskh(
                    13,
                    color: dua.likedByMe ? Colors.red.shade400 : s.textSec,
                    weight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                // Animated heart button
                GestureDetector(
                  onTap: dua.likedByMe
                      ? null
                      : () {
                          HapticFeedback.mediumImpact();
                          _heartCtrl.forward(from: 0);
                          ref
                              .read(communityDuasProvider.notifier)
                              .likeDua(dua.id);
                        },
                  child: ScaleTransition(
                    scale: _heartScale,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Icon(
                        dua.likedByMe
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        key: ValueKey(dua.likedByMe),
                        color: dua.likedByMe ? Colors.red.shade400 : s.textSec,
                        size: 22,
                      ),
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

// ═══════════════════════════════════════════════════════════════
//  ADD DUA SHEET
// ═══════════════════════════════════════════════════════════════
class AddDuaSheet extends ConsumerStatefulWidget {
  const AddDuaSheet({super.key});
  @override
  ConsumerState<AddDuaSheet> createState() => _AddDuaSheetState();
}

class _AddDuaSheetState extends ConsumerState<AddDuaSheet> {
  final _titleCtrl = TextEditingController();
  final _arabicCtrl = TextEditingController();
  final _occasionCtrl = TextEditingController();
  bool _shareToCommunity = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _arabicCtrl.dispose();
    _occasionCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    final arabic = _arabicCtrl.text.trim();
    if (title.isEmpty || arabic.isEmpty) return;

    setState(() => _isSaving = true);
    try {
      await ref
          .read(userDuasProvider.notifier)
          .add(
            textAr: arabic,
            titleAr: title,
            occasion: _occasionCtrl.text.trim(),
          );

      if (_shareToCommunity && mounted) {
        await SupabaseService.shareDuaToCommunity(
          textAr: arabic,
          titleAr: title,
          occasion: _occasionCtrl.text.trim(),
        );
      }

      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRamadan = ref.watch(ramadanModeProvider).value ?? false;
    final s = AdaptiveStyle(context, isRamadan);

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: s.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('إضافة دعاء', style: s.amiri(22, color: s.gold)),
              IconButton(
                icon: Icon(Icons.close, color: s.textSec),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleCtrl,
            textDirection: TextDirection.rtl,
            style: s.naskh(14),
            decoration: InputDecoration(
              labelText: 'عنوان الدعاء',
              labelStyle: s.naskh(12, color: s.textSec),
              filled: true,
              fillColor: s.border.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _arabicCtrl,
            textDirection: TextDirection.rtl,
            style: s.amiri(16),
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'نص الدعاء (عربي)',
              labelStyle: s.naskh(12, color: s.textSec),
              filled: true,
              fillColor: s.border.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _occasionCtrl,
            textDirection: TextDirection.rtl,
            style: s.naskh(14),
            decoration: InputDecoration(
              labelText: 'المناسبة (اختياري)',
              labelStyle: s.naskh(12, color: s.textSec),
              filled: true,
              fillColor: s.border.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'مشاركة مع مجتمع تقوى (ليستفيد منه الآخرون)',
                  style: s.naskh(12, color: s.text),
                ),
              ),
              Switch(
                value: _shareToCommunity,
                onChanged: (v) => setState(() => _shareToCommunity = v),
                activeColor: s.teal,
                activeTrackColor: s.teal.withOpacity(0.3),
                inactiveTrackColor: s.border,
                inactiveThumbColor: s.textDim,
              ),
            ],
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'حفظ',
            onTap: _isSaving ? null : _save,
            isLoading: _isSaving,
          ),
        ],
      ),
    );
  }
}
