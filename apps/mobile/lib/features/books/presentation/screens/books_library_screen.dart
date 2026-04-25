// ═══════════════════════════════════════════════════════════════
//  lib/features/books/presentation/screens/books_library_screen.dart
//  تقوى — Islamic Books Library (Entry Screen)
// ═══════════════════════════════════════════════════════════════

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:takwa/core/theme/app_theme.dart';
import 'package:takwa/core/widgets/custom_pattern_background.dart';
import 'package:takwa/features/books/data/books_data.dart';
import 'package:takwa/features/books/providers/books_reading_provider.dart';
import 'package:takwa/features/books/presentation/screens/books_chapter_screen.dart';

class BooksLibraryScreen extends ConsumerWidget {
  const BooksLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        slivers: [
          // ── Premium App Bar ──────────────────────────────────
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            backgroundColor: colors.deep,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(right: 16, bottom: 14),
              title: Text(
                'مكتبتي الإسلامية',
                style: typography.headingMedium.copyWith(fontSize: 18),
                textDirection: TextDirection.rtl,
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [colors.deep, colors.card, colors.deep],
                  ),
                ),
                child: const Stack(
                  children: [
                    CustomPatternBackground(pattern: BackgroundPattern.adhkar),
                    Positioned(
                      right: 16,
                      top: 52,
                      child: Text('📚', style: TextStyle(fontSize: 40)),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Stats bar ────────────────────────────────────────
          const SliverToBoxAdapter(child: _StatsBar(books: kIslamicBooks)),

          // ── Section label ─────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                'الكتب المتاحة',
                style: typography.labelLarge,
                textAlign: TextAlign.right,
              ),
            ),
          ),

          // ── Book Grid ─────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((ctx, i) {
                final book = kIslamicBooks[i];
                return _BookCard(
                  book: book,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BooksChapterScreen(book: book),
                    ),
                  ),
                );
              }, childCount: kIslamicBooks.length),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
//  STATS BAR
// ─────────────────────────────────────────

class _StatsBar extends StatelessWidget {
  final List<IslamicBook> books;
  const _StatsBar({required this.books});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final totalPages = books.fold<int>(0, (s, b) => s + b.totalPages);
    final totalMinutes = books.fold<int>(
      0,
      (s, b) => s + b.estimatedReadingMinutes,
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: colors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.gold.withOpacity(0.25), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(value: '${books.length}', label: 'كتاب'),
          _divider(colors),
          _StatItem(value: '$totalPages', label: 'صفحة'),
          _divider(colors),
          _StatItem(value: '$totalMinutes', label: 'دقيقة قراءة'),
        ],
      ),
    );
  }

  Widget _divider(AppColorsExtension c) =>
      Container(width: 1, height: 30, color: c.border);
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    return Column(
      children: [
        Text(
          value,
          style: typography.headingMedium.copyWith(color: colors.gold),
        ),
        const SizedBox(height: 2),
        Text(label, style: typography.caption),
      ],
    );
  }
}

// ─────────────────────────────────────────
//  BOOK CARD
// ─────────────────────────────────────────

class _BookCard extends ConsumerWidget {
  final IslamicBook book;
  final VoidCallback onTap;
  const _BookCard({required this.book, required this.onTap});

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex));
    } catch (_) {
      return const Color(0xFFC8A96E);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final progress = ref.watch(readingProgressProvider);
    final p = getProgress(progress, book.id);

    final c1 = _parseColor(book.coverColor);
    final c2 = _parseColor(book.coverColor2);

    // Build percentage
    double percent = 0;
    if (p != null && book.totalPages > 0) {
      int done = 0;
      for (int ci = 0; ci < p.chapterIndex; ci++) {
        done += book.chapters[ci].totalPages;
      }
      done += p.pageIndex;
      percent = (done / book.totalPages).clamp(0.0, 1.0);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: c1.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Cover gradient panel
            Container(
              width: 100,
              height: 148,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [c1, c2],
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (book.coverUrl != null)
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: book.coverUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(),
                        errorWidget: (context, url, err) => Center(
                          child: Text(book.emoji, style: const TextStyle(fontSize: 42)),
                        ),
                      ),
                    )
                  else
                    Center(
                      child: Text(
                        book.emoji,
                        style: const TextStyle(fontSize: 42),
                      ),
                    ),
                  // Reading progress ring at bottom
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: _ProgressRing(
                        percent: percent,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      book.titleAr,
                      style: typography.headingMedium.copyWith(
                        fontSize: 17,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.authorAr,
                      style: typography.caption.copyWith(color: colors.gold),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 8),
                    // Category badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: c1.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: c1.withOpacity(0.3)),
                      ),
                      child: Text(
                        book.categoryLabel,
                        style: typography.caption.copyWith(color: c1),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Stats row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${book.chapters.length} فصول',
                          style: typography.caption,
                        ),
                        Text('  •  ', style: typography.caption),
                        Text(
                          '${book.totalPages} صفحة',
                          style: typography.caption,
                        ),
                      ],
                    ),
                    if (percent > 0) ...[
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: percent,
                        backgroundColor: colors.border,
                        color: c1,
                        borderRadius: BorderRadius.circular(4),
                        minHeight: 4,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(percent * 100).round()}٪ مكتمل',
                        style: typography.caption.copyWith(
                          color: c1,
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ],
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
//  PROGRESS RING
// ─────────────────────────────────────────

class _ProgressRing extends StatelessWidget {
  final double percent;
  final Color color;
  const _ProgressRing({required this.percent, required this.color});

  @override
  Widget build(BuildContext context) {
    if (percent == 0) return const SizedBox.shrink();
    return SizedBox(
      width: 36,
      height: 36,
      child: CustomPaint(
        painter: _RingPainter(percent: percent, color: color),
        child: Center(
          child: Text(
            '${(percent * 100).round()}%',
            style: TextStyle(
              fontSize: 8,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double percent;
  final Color color;
  _RingPainter({required this.percent, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 3.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - stroke) / 2;

    final bg = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawCircle(center, radius, bg);

    final fg = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * percent,
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.percent != percent;
}
