// ═══════════════════════════════════════════════════════════════
//  lib/features/duas/presentation/screens/favorite_duas_screen.dart
//  تقوى — شاشة أدعيتي المفضلة
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:takwa/core/providers/favorites_providers.dart';
import 'package:takwa/core/theme/app_theme.dart';
import 'package:takwa/core/widgets/custom_pattern_background.dart';
import 'package:takwa/features/duas/presentation/screens/duas_screen.dart';

class FavoriteDuasScreen extends ConsumerWidget {
  const FavoriteDuasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favIds = ref.watch(favoriteDuasProvider);
    final allDuas = kDuasData.values.expand((l) => l).toList();
    final favDuas = allDuas.where((d) => favIds.contains(d.id)).toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: Stack(
          children: [
            const Positioned.fill(
              child: CustomPatternBackground(pattern: BackgroundPattern.duas),
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
                              border: Border.all(color: context.colors.border),
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
                                'أدعيتي المفضلة',
                                style: context.typography.headingMedium.copyWith(
                                  fontSize: 20,
                                  color: context.colors.gold,
                                ),
                              ),
                              Text(
                                '${favDuas.length} دعاء محفوظ',
                                style: context.typography.caption.copyWith(
                                  color: context.colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Text('❤️', style: TextStyle(fontSize: 22)),
                      ],
                    ),
                  ),
                ),

                // ── Divider ──
                Container(height: 1, color: context.colors.border.withOpacity(0.5)),
                const SizedBox(height: 4),

                // ── Content ──
                Expanded(
                  child: favDuas.isEmpty
                      ? _EmptyFavs(colors: context.colors)
                      : _FavDuasList(duas: favDuas),
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
            'لا توجد أدعية مفضلة بعد',
            style: context.typography.headingMedium.copyWith(
              color: colors.textPrimary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اضغط على ❤️ داخل أي دعاء لحفظه هنا',
            style: context.typography.caption.copyWith(color: colors.textSecondary),
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
class _FavDuasList extends ConsumerWidget {
  final List<DuaItem> duas;
  const _FavDuasList({required this.duas});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      itemCount: duas.length,
      itemBuilder: (_, i) => _FavDuaCard(dua: duas[i]),
    );
  }
}

// ──────────────────────────────────────────────
//  Individual card
// ──────────────────────────────────────────────
class _FavDuaCard extends ConsumerStatefulWidget {
  final DuaItem dua;
  const _FavDuaCard({required this.dua});

  @override
  ConsumerState<_FavDuaCard> createState() => _FavDuaCardState();
}

class _FavDuaCardState extends ConsumerState<_FavDuaCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final favs = ref.watch(favoriteDuasProvider);
    final isFav = favs.contains(widget.dua.id);

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
                  )
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(widget.dua.emoji, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.dua.occasion,
                      style: context.typography.caption.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ),
                  // Un-favorite button
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
                        color: isFav ? Colors.red.shade400 : context.colors.textSecondary,
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
                          content: Text(
                            'تم النسخ ✓',
                            style: GoogleFonts.notoNaskhArabic(fontSize: 12),
                          ),
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
              Text(
                widget.dua.arabic,
                textAlign: TextAlign.center,
                style: context.typography.headingMedium.copyWith(
                  fontSize: 19,
                  height: 2.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 250),
                crossFadeState: _expanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: const SizedBox.shrink(),
                secondChild: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(height: 1, color: context.colors.border),
                    const SizedBox(height: 10),
                    Text(
                      widget.dua.meaning,
                      textAlign: TextAlign.center,
                      style: context.typography.bodySmall.copyWith(
                        color: context.colors.textSecondary,
                        height: 1.8,
                      ),
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
                            color: context.colors.gold.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: context.colors.gold.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            widget.dua.source,
                            style: context.typography.caption.copyWith(
                              color: context.colors.gold,
                              fontWeight: FontWeight.w600,
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
}
