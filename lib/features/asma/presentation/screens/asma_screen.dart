// ═══════════════════════════════════════════════════════════════
//  lib/features/asma/presentation/screens/asma_screen.dart
//  محاسبة النفس — أسماء الله الحسنى (99 اسم)
// ═══════════════════════════════════════════════════════════════

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muhasabah/features/asma/data/asma_data.dart';

import '../../../../core/theme/ramadan_theme.dart';
import '../../../../core/providers/database_providers.dart';

// ═══════════════════════════════════════════════════════════════
//  ASMA SCREEN
// ═══════════════════════════════════════════════════════════════
class AsmaScreen extends ConsumerStatefulWidget {
  const AsmaScreen({super.key});
  @override
  ConsumerState<AsmaScreen> createState() => _AsmaScreenState();
}

class _AsmaScreenState extends ConsumerState<AsmaScreen>
    with TickerProviderStateMixin {
  late final AnimationController _bgCtrl;
  late final AnimationController _entryCtrl;
  final _searchCtrl = TextEditingController();
  String _query = '';
  int? _expandedIdx;
  bool _gridMode = false;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _entryCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<AsmaItem> get _filtered => kAsmaData
      .where(
        (a) =>
            _query.isEmpty ||
            a.name.contains(_query) ||
            a.meaning.contains(_query) ||
            a.explanation.contains(_query) ||
            a.number.toString() == _query,
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    final isRamadan = ref.watch(ramadanModeProvider).value ?? false;
    final s = AdaptiveStyle(context, isRamadan); // Fixed: added context
    final filtered = _filtered;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: s.bg,
        body: Stack(
          children: [
            // ── خلفية ──
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _bgCtrl,
                builder: (_, __) => CustomPaint(
                  painter: _AsmaBgPainter(
                    t: _bgCtrl.value,
                    isRamadan: isRamadan,
                  ),
                ),
              ),
            ),

            Column(
              children: [
                _AsmaTopBar(
                  style: s,
                  query: _query,
                  gridMode: _gridMode,
                  onSearch: (v) => setState(() => _query = v),
                  onToggleView: () => setState(() => _gridMode = !_gridMode),
                  searchCtrl: _searchCtrl,
                ),

                // Count badge
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Row(
                    children: [
                      Text(
                        'أسماء الله الحسنى',
                        style: s.naskh(11, color: s.textSec),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: s.goldDim,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: s.gold.withOpacity(0.2)),
                        ),
                        child: Text(
                          '${filtered.length} / ٩٩',
                          style: s.naskh(
                            10,
                            color: s.gold,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: _gridMode
                      ? _AsmaGrid(
                          items: filtered,
                          style: s,
                          entryCtrl: _entryCtrl,
                          onTap: (i) => _showDetail(context, filtered[i], s),
                        )
                      : _AsmaList(
                          items: filtered,
                          style: s,
                          entryCtrl: _entryCtrl,
                          expanded: _expandedIdx,
                          onExpand: (i) => setState(
                            () => _expandedIdx = _expandedIdx == i ? null : i,
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, AsmaItem item, AdaptiveStyle s) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AsmaDetailSheet(item: item, style: s),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  TOP BAR
// ═══════════════════════════════════════════════════════════════
class _AsmaTopBar extends StatelessWidget {
  final AdaptiveStyle style;
  final String query;
  final bool gridMode;
  final Function(String) onSearch;
  final VoidCallback onToggleView;
  final TextEditingController searchCtrl;

  const _AsmaTopBar({
    required this.style,
    required this.query,
    required this.gridMode,
    required this.onSearch,
    required this.onToggleView,
    required this.searchCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final s = style;
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 10,
        16,
        16,
      ),
      decoration: BoxDecoration(
        color: s.card,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: s.text,
                  size: 20,
                ),
              ),
              Expanded(
                child: Text(
                  'أسماء الله الحسنى',
                  style: s.amiri(22, weight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                onPressed: onToggleView,
                icon: Icon(
                  gridMode
                      ? Icons.format_list_bulleted_rounded
                      : Icons.grid_view_rounded,
                  color: s.gold,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: s.bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: s.border),
            ),
            child: TextField(
              controller: searchCtrl,
              onChanged: onSearch,
              style: s.naskh(14),
              decoration: InputDecoration(
                hintText: 'ابحث عن اسم، معنى، أو رقم...',
                hintStyle: s.naskh(12, color: s.textDim),
                border: InputBorder.none,
                icon: Icon(Icons.search_rounded, color: s.gold, size: 20),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          searchCtrl.clear();
                          onSearch('');
                        },
                        icon: Icon(
                          Icons.close_rounded,
                          color: s.textDim,
                          size: 18,
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  ASMA LIST & GRID
// ═══════════════════════════════════════════════════════════════
class _AsmaList extends StatelessWidget {
  final List<AsmaItem> items;
  final AdaptiveStyle style;
  final AnimationController entryCtrl;
  final int? expanded;
  final Function(int) onExpand;

  const _AsmaList({
    required this.items,
    required this.style,
    required this.entryCtrl,
    this.expanded,
    required this.onExpand,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      itemBuilder: (ctx, i) => _AsmaListTile(
        item: items[i],
        style: style,
        anim: CurvedAnimation(
          parent: entryCtrl,
          curve: Interval(
            math.min(1.0, i * 0.02),
            math.min(1.0, i * 0.02 + 0.3),
            curve: Curves.easeOut,
          ),
        ),
        expanded: expanded == i,
        onTap: () => onExpand(i),
      ),
    );
  }
}

class _AsmaGrid extends StatelessWidget {
  final List<AsmaItem> items;
  final AdaptiveStyle style;
  final AnimationController entryCtrl;
  final Function(int) onTap;

  const _AsmaGrid({
    required this.items,
    required this.style,
    required this.entryCtrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: items.length,
      itemBuilder: (ctx, i) => _AsmaGridTile(
        item: items[i],
        style: style,
        onTap: () => onTap(i),
        anim: CurvedAnimation(
          parent: entryCtrl,
          curve: Interval(
            math.min(1.0, i * 0.01),
            math.min(1.0, i * 0.01 + 0.3),
            curve: Curves.easeOut,
          ),
        ),
      ),
    );
  }
}

// ── Tiles ──
class _AsmaListTile extends StatelessWidget {
  final AsmaItem item;
  final AdaptiveStyle style;
  final Animation<double> anim;
  final bool expanded;
  final VoidCallback onTap;

  const _AsmaListTile({
    required this.item,
    required this.style,
    required this.anim,
    required this.expanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = style;
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.1, 0),
          end: Offset.zero,
        ).animate(anim),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: expanded ? s.goldDim.withOpacity(0.05) : s.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: expanded ? s.gold : s.border,
              width: expanded ? 1.5 : 1,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      _NumberBadge(num: item.number, style: s),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: s.amiri(
                                18,
                                weight: FontWeight.w700,
                                color: s.gold,
                              ),
                            ),
                            Text(
                              item.meaning,
                              style: s.naskh(11, color: s.textDim),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                if (expanded) ...[
                  Divider(height: 1, color: s.border),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.explanation, style: s.naskh(13, height: 1.8)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: s.bg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'دعاء: ${item.dua}',
                            style: s.naskh(
                              12,
                              color: s.teal,
                              weight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AsmaGridTile extends StatelessWidget {
  final AsmaItem item;
  final AdaptiveStyle style;
  final VoidCallback onTap;
  final Animation<double> anim;

  const _AsmaGridTile({
    required this.item,
    required this.style,
    required this.onTap,
    required this.anim,
  });

  @override
  Widget build(BuildContext context) {
    final s = style;
    return ScaleTransition(
      scale: anim,
      child: FadeTransition(
        opacity: anim,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: s.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: s.border),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [s.card, s.goldDim.withOpacity(0.05)],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _NumberBadge(num: item.number, style: s, mini: true),
                const SizedBox(height: 8),
                Text(
                  item.name,
                  style: s.amiri(16, weight: FontWeight.w700, color: s.gold),
                ),
                const SizedBox(height: 2),
                Text(
                  item.transliteration,
                  style: GoogleFonts.inter(fontSize: 8, color: s.textSec),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NumberBadge extends StatelessWidget {
  final int num;
  final AdaptiveStyle style;
  final bool mini;
  const _NumberBadge({
    required this.num,
    required this.style,
    this.mini = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: mini ? 24 : 36,
      height: mini ? 24 : 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [style.gold, style.teal]),
        boxShadow: [
          BoxShadow(color: style.gold.withOpacity(0.3), blurRadius: 4),
        ],
      ),
      child: Center(
        child: Text(
          num.toString(),
          style: GoogleFonts.inter(
            color: style.bg,
            fontWeight: FontWeight.w700,
            fontSize: mini ? 10 : 13,
          ),
        ),
      ),
    );
  }
}

// ── Detail Sheet ──
class _AsmaDetailSheet extends StatelessWidget {
  final AsmaItem item;
  final AdaptiveStyle style;
  const _AsmaDetailSheet({required this.item, required this.style});

  @override
  Widget build(BuildContext context) {
    final s = style;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: s.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(top: BorderSide(color: s.gold, width: 2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: s.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            item.name,
            style: s.amiri(42, weight: FontWeight.w700, color: s.gold),
          ),
          Text(item.meaning, style: s.naskh(16, color: s.textDim)),
          const SizedBox(height: 32),
          _DetailSection(
            title: 'الشرح والبيان',
            content: item.explanation,
            style: s,
          ),
          const SizedBox(height: 20),
          _DetailSection(
            title: 'من القرآن الكريم',
            content: item.quranRef,
            style: s,
            isVerse: true,
          ),
          const SizedBox(height: 20),
          _DetailSection(
            title: 'الدعاء بهذا الاسم',
            content: item.dua,
            style: s,
            isDua: true,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: s.gold,
              foregroundColor: s.bg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: Text('إغلاق', style: s.naskh(14, weight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title, content;
  final AdaptiveStyle style;
  final bool isVerse, isDua;
  const _DetailSection({
    required this.title,
    required this.content,
    required this.style,
    this.isVerse = false,
    this.isDua = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                color: style.gold,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: style.naskh(
                12,
                weight: FontWeight.w700,
                color: style.gold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: style.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: style.border),
          ),
          child: Text(
            content,
            style: isVerse
                ? style.amiri(16, height: 1.8)
                : style.naskh(14, height: 1.8),
            textAlign: isVerse ? TextAlign.center : TextAlign.start,
          ),
        ),
      ],
    );
  }
}

// ── Background Painter ──
class _AsmaBgPainter extends CustomPainter {
  final double t;
  final bool isRamadan;
  _AsmaBgPainter({required this.t, required this.isRamadan});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.stroke;
    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < 3; i++) {
      paint.color =
          (isRamadan ? const Color(0xFFC19E67) : const Color(0xFF2E6B6B))
              .withOpacity(0.05 * (1 - (t + i / 3) % 1));
      final radius = (size.width * 0.4) + (i * 100) + (t * 50);
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AsmaBgPainter old) => old.t != t;
}

class RamadanBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF0F172A),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
