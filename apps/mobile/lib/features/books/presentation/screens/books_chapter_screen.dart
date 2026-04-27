// ═══════════════════════════════════════════════════════════════
//  lib/features/books/presentation/screens/books_chapter_screen.dart
//  تقوى — Premium Chapter & Book Details Screen
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:takwa/core/theme/app_theme.dart';
import 'package:takwa/core/widgets/app_bar_widget.dart';
import 'package:takwa/core/widgets/custom_leading_button.dart';
import 'package:takwa/features/books/data/books_data.dart';
import 'package:takwa/features/books/providers/books_reading_provider.dart';
import 'package:takwa/features/books/presentation/screens/book_reader_screen.dart';
import 'package:takwa/features/books/presentation/screens/book_pdf_reader_screen.dart';

class BooksChapterScreen extends ConsumerWidget {
  final IslamicBook book;
  const BooksChapterScreen({super.key, required this.book});

  Color _parseColor(String? hex) {
    if (hex == null) return const Color.fromARGB(255, 221, 144, 1);
    try {
      if (hex.startsWith('0x')) return Color(int.parse(hex));
      if (hex.startsWith('#')) {
        return Color(int.parse('0xFF${hex.substring(1)}'));
      }
      return Color(int.parse('0xFF$hex'));
    } catch (_) {
      return const Color(0xFFC8A96E);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final c1 = _parseColor(book.coverColor);
    final c2 = _parseColor(book.coverColor2);

    final progress = ref.watch(readingProgressProvider);
    final savedProgress = getProgress(progress, book.id);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBarWidget(
        title: book.titleAr,
        height: 260,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CustomLeadingButton(),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          book.titleAr,
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          book.authorAr,
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Hero(
                    tag: 'book-emoji-${book.id}',
                    child: Text(
                      book.emoji,
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _StatChip(
                    label: book.categoryLabel,
                    icon: Icons.category_outlined,
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    label: '${book.totalPages} صفحة',
                    icon: Icons.menu_book_rounded,
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    label: '~${book.estimatedReadingMinutes} د',
                    icon: Icons.schedule_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _ReadingProgressBar(book: book, accentColor: Colors.white),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          // ── Book Description ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'عن الكتاب',
                      style: typography.headingMedium.copyWith(
                        color: c1,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Amiri',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        color: c1,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  book.descriptionAr,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 15,
                    color: colors.textSecondary,
                    height: 1.8,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),

          // ── Primary Action ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: _PrimaryActionButton(
              book: book,
              savedProgress: savedProgress,
              accentColor: c1,
            ),
          ),

          // ── Chapters List ──────────────────────────────────
          if (book.pdfUrl == null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${book.chapters.length} فصل',
                    style: typography.caption.copyWith(color: colors.textDim),
                  ),
                  Text(
                    'الفصول المحتواة',
                    style: typography.labelLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Amiri',
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: List.generate(book.chapters.length, (i) {
                  final ch = book.chapters[i];
                  final isCurrent = savedProgress?.chapterIndex == i;
                  return _ChapterItem(
                    chapter: ch,
                    index: i,
                    accentColor: c1,
                    isCurrent: isCurrent,
                    currentPage: isCurrent ? savedProgress!.pageIndex : 0,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookReaderScreen(
                          book: book,
                          initialChapterIndex: i,
                          initialPageIndex: isCurrent
                              ? savedProgress!.pageIndex
                              : 0,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],

          const SizedBox(height: 60),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _StatChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: 'Amiri',
            ),
          ),
          const SizedBox(width: 6),
          Icon(icon, color: Colors.white70, size: 14),
        ],
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  final IslamicBook book;
  final BookReadingProgress? savedProgress;
  final Color accentColor;

  const _PrimaryActionButton({
    required this.book,
    required this.savedProgress,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isPdf = book.pdfUrl != null;

    String label = isPdf ? 'قراءة نسخة PDF' : 'ابدأ القراءة';
    IconData icon = isPdf
        ? Icons.picture_as_pdf_outlined
        : Icons.menu_book_rounded;

    if (!isPdf && savedProgress != null) {
      label = 'متابعة القراءة';
      icon = Icons.play_arrow_rounded;
    }

    return GestureDetector(
      onTap: () {
        if (isPdf) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => BookPdfReaderScreen(book: book)),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookReaderScreen(
                book: book,
                initialChapterIndex: savedProgress?.chapterIndex ?? 0,
                initialPageIndex: savedProgress?.pageIndex ?? 0,
              ),
            ),
          );
        }
      },
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [accentColor, accentColor.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Amiri',
              ),
            ),
            const SizedBox(width: 12),
            Icon(icon, color: Colors.white, size: 24),
          ],
        ),
      ),
    );
  }
}

class _ChapterItem extends StatelessWidget {
  final BookChapter chapter;
  final int index;
  final Color accentColor;
  final bool isCurrent;
  final int currentPage;
  final VoidCallback onTap;

  const _ChapterItem({
    required this.chapter,
    required this.index,
    required this.accentColor,
    required this.isCurrent,
    required this.currentPage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isCurrent ? accentColor.withOpacity(0.05) : colors.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isCurrent ? accentColor.withOpacity(0.3) : colors.border,
            width: isCurrent ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.chevron_left, color: colors.textDim, size: 20),
            const Spacer(),
            Expanded(
              flex: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    chapter.titleAr,
                    style: typography.labelLarge.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: isCurrent ? accentColor : colors.textPrimary,
                      fontFamily: 'Amiri',
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${chapter.totalPages} صفحة',
                        style: typography.caption,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•',
                        style: typography.caption.copyWith(
                          color: colors.textDim,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '~${chapter.estimatedMinutes} دقيقة',
                        style: typography.caption,
                      ),
                    ],
                  ),
                  if (isCurrent) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (currentPage + 1) / chapter.totalPages,
                        backgroundColor: accentColor.withOpacity(0.1),
                        color: accentColor,
                        minHeight: 4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 20),
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isCurrent ? accentColor : colors.card2,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: isCurrent ? Colors.white : colors.textDim,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: 'Amiri',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadingProgressBar extends ConsumerWidget {
  final IslamicBook book;
  final Color accentColor;

  const _ReadingProgressBar({required this.book, required this.accentColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref
        .watch(readingProgressProvider.notifier)
        .getProgress(book.id, book.totalPages);
    final percentage = (progress * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$percentage%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'تقدم القراءة',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontFamily: 'Amiri',
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
