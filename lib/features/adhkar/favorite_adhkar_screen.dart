// ═══════════════════════════════════════════════════════════════
//  lib/features/adhkar/presentation/screens/favorite_adhkar_screen.dart
//  تقوى — شاشة أذكاري المفضلة
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:takwa/core/providers/adhkar_providers.dart';
import 'package:takwa/core/providers/favorites_providers.dart';
import 'package:takwa/core/theme/app_theme.dart';
import 'package:takwa/core/widgets/custom_pattern_background.dart';

class FavoriteAdhkarScreen extends ConsumerWidget {
  const FavoriteAdhkarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favIds = ref.watch(favoriteAdhkarProvider);
    final allDhikr = kAdhkarData.values.expand((l) => l).toList();
    final favDhikr = allDhikr.where((d) => favIds.contains(d.id)).toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: Stack(
          children: [
            const Positioned.fill(
              child:
                  CustomPatternBackground(pattern: BackgroundPattern.adhkar),
            ),
            Column(
              children: [
                // ── Top Bar ──
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: context.colors.card,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: context.colors.border),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 16,
                                color: context.colors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'أذكاري المفضلة',
                                style: context.typography.headingMedium
                                    .copyWith(
                                  fontSize: 20,
                                  color: context.colors.gold,
                                ),
                              ),
                              Text(
                                '${favDhikr.length} ذكر محفوظ',
                                style: context.typography.caption.copyWith(
                                  color: context.colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Text(
                          '❤️',
                          style: TextStyle(fontSize: 22),
                        ),
                      ],
                    ),
                  ),
                ),

                Container(
                  height: 1,
                  color: context.colors.border.withOpacity(0.5),
                ),
                const SizedBox(height: 4),

                // ── Content ──
                Expanded(
                  child: favDhikr.isEmpty
                      ? _EmptyFavs(colors: context.colors)
                      : _FavDhikrList(items: favDhikr),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
//  Empty state
// ──────────────────────────────────────────────
class _EmptyFavs extends StatelessWidget {
  final AppColorsExtension colors;
  const _EmptyFavs({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🤍', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 16),
          Text(
            'لا توجد أذكار مفضلة بعد',
            style: context.typography.headingMedium.copyWith(
              color: colors.textPrimary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اضغط على ❤️ في أي ذكر لحفظه هنا',
            style: context.typography.caption
                .copyWith(color: colors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
//  List
// ──────────────────────────────────────────────
class _FavDhikrList extends StatelessWidget {
  final List<DhikrItem> items;
  const _FavDhikrList({required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      itemCount: items.length,
      itemBuilder: (_, i) => _FavDhikrCard(item: items[i]),
    );
  }
}

// ──────────────────────────────────────────────
//  Individual card
// ──────────────────────────────────────────────
class _FavDhikrCard extends ConsumerStatefulWidget {
  final DhikrItem item;
  const _FavDhikrCard({required this.item});

  @override
  ConsumerState<_FavDhikrCard> createState() => _FavDhikrCardState();
}

class _FavDhikrCardState extends ConsumerState<_FavDhikrCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final favIds = ref.watch(favoriteAdhkarProvider);
    final isFav = favIds.contains(widget.item.id);

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          gradient: _expanded
              ? LinearGradient(
                  colors: [
                    context.colors.gold.withOpacity(0.12),
                    context.colors.teal.withOpacity(0.06),
                  ],
                )
              : null,
          color: _expanded ? null : context.colors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _expanded
                ? context.colors.gold.withOpacity(0.4)
                : context.colors.border,
            width: _expanded ? 1.5 : 1,
          ),
          boxShadow: _expanded
              ? [
                  BoxShadow(
                    color: context.colors.gold.withOpacity(0.1),
                    blurRadius: 12,
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _categoryLabel(widget.item.category),
                      style: context.typography.caption.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ),
                  // count badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: context.colors.gold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: context.colors.gold.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      '${widget.item.count}×',
                      style: context.typography.caption.copyWith(
                        color: context.colors.gold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Un-favorite
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref
                          .read(favoriteAdhkarProvider.notifier)
                          .toggle(widget.item.id);
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
                  ),
                  const SizedBox(width: 8),
                  // Copy
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                          ClipboardData(text: widget.item.arabic));
                      HapticFeedback.mediumImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('تم النسخ ✓'),
                          backgroundColor: context.colors.teal,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                    child: Icon(
                      Icons.copy_rounded,
                      size: 16,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Arabic text
              Text(
                widget.item.arabic,
                textAlign: TextAlign.center,
                style: context.typography.headingMedium.copyWith(
                  fontSize: 20,
                  height: 2.0,
                  fontWeight: FontWeight.w400,
                ),
              ),

              // Expanded details
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 250),
                crossFadeState: _expanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: const SizedBox.shrink(),
                secondChild: Column(
                  children: [
                    if (widget.item.transliteration != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        height: 1,
                        color: context.colors.border,
                        margin:
                            const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.item.transliteration!,
                        textAlign: TextAlign.center,
                        style: context.typography.caption.copyWith(
                          color: context.colors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    if (widget.item.fadl != null) ...[
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
                            color:
                                context.colors.gold.withOpacity(0.15),
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
                                widget.item.fadl!,
                                style: context.typography.caption
                                    .copyWith(
                                        color: context.colors.gold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (widget.item.source != null) ...[
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '— ${widget.item.source}',
                          style: context.typography.caption.copyWith(
                            color: context.colors.textDim,
                          ),
                        ),
                      ),
                    ],
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
                    color: context.colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _categoryLabel(AdhkarCategory cat) {
    return switch (cat) {
      AdhkarCategory.morning => '🌅 أذكار الصباح',
      AdhkarCategory.evening => '🌆 أذكار المساء',
      AdhkarCategory.afterPrayer => '🕌 بعد الصلاة',
      AdhkarCategory.sleep => '🌙 أذكار النوم',
      AdhkarCategory.misc => '📿 متنوعة',
    };
  }
}
