// ═══════════════════════════════════════════════════════════════
//  lib/features/books/presentation/screens/books_chapter_screen.dart
//  تقوى — Chapter List Screen
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:takwa/core/theme/app_theme.dart';
import 'package:takwa/features/books/data/books_data.dart';
import 'package:takwa/features/books/providers/books_reading_provider.dart';
import 'package:takwa/features/books/presentation/screens/book_reader_screen.dart';
import 'package:takwa/features/books/presentation/screens/book_pdf_reader_screen.dart';

class BooksChapterScreen extends ConsumerWidget {
  final IslamicBook book;
  const BooksChapterScreen({super.key, required this.book});

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
    final c1 = _parseColor(book.coverColor);
    final c2 = _parseColor(book.coverColor2);

    final progress = ref.watch(readingProgressProvider);
    final savedProgress = getProgress(progress, book.id);

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        slivers: [
          // ── Book header / hero ────────────────────────────────
          SliverAppBar(
            expandedHeight: 230,
            pinned: true,
            backgroundColor: colors.deep,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [c1, c2],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    book.titleAr,
                                    style: const TextStyle(
                                      fontFamily: 'Amiri',
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      height: 1.4,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    book.authorAr,
                                    style: const TextStyle(
                                      fontFamily: 'Amiri',
                                      fontSize: 15,
                                      color: Colors.white70,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              book.emoji,
                              style: const TextStyle(fontSize: 50),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Description
                        Text(
                          book.descriptionAr,
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 13,
                            color: Colors.white70,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.right,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        // Meta chips row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _MetaChip(
                                label: book.categoryLabel,
                                icon: Icons.bookmark_outline),
                            const SizedBox(width: 8),
                            _MetaChip(
                                label: '${book.totalPages} صفحة',
                                icon: Icons.menu_book_outlined),
                            const SizedBox(width: 8),
                            _MetaChip(
                                label:
                                    '~${book.estimatedReadingMinutes} د',
                                icon: Icons.timer_outlined),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Continue reading banner / PDF button ─────────────────
          if (book.pdfUrl != null)
            SliverToBoxAdapter(
              child: _PdfReadBanner(
                accentColor: c1,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookPdfReaderScreen(book: book),
                  ),
                ),
              ),
            )
          else if (savedProgress != null &&
              savedProgress.chapterIndex < book.chapters.length)
            SliverToBoxAdapter(
              child: _ContinueBanner(
                book: book,
                progress: savedProgress,
                accentColor: c1,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookReaderScreen(
                      book: book,
                      initialChapterIndex: savedProgress.chapterIndex,
                      initialPageIndex: savedProgress.pageIndex,
                    ),
                  ),
                ),
              ),
            ),

          // ── Chapters section label ────────────────────────────
          if (book.pdfUrl == null) ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'الفصول (${book.chapters.length})',
                  style: typography.labelLarge,
                  textAlign: TextAlign.right,
                ),
              ),
            ),

            // ── Chapter list ──────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final ch = book.chapters[i];
                    final isCurrentChapter = savedProgress?.chapterIndex == i;
                    return _ChapterRow(
                      chapter: ch,
                      index: i,
                      accentColor: c1,
                      isCurrent: isCurrentChapter,
                      currentPage: isCurrentChapter ? savedProgress!.pageIndex : 0,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookReaderScreen(
                            book: book,
                            initialChapterIndex: i,
                            initialPageIndex: isCurrentChapter ? savedProgress!.pageIndex : 0,
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: book.chapters.length,
                ),
              ),
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
//  META CHIP
// ─────────────────────────────────────────

class _MetaChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _MetaChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 12,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 4),
          Icon(icon, color: Colors.white70, size: 13),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
//  CONTINUE READING BANNER
// ─────────────────────────────────────────

class _ContinueBanner extends StatelessWidget {
  final IslamicBook book;
  final BookReadingProgress progress;
  final Color accentColor;
  final VoidCallback onTap;

  const _ContinueBanner({
    required this.book,
    required this.progress,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final chapter = book.chapters[progress.chapterIndex];
    final page = chapter.pages[progress.pageIndex];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              accentColor.withOpacity(0.15),
              accentColor.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: accentColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.play_arrow_rounded,
                  color: accentColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                children: [
                  Text(
                    'متابعة القراءة',
                    style: typography.labelLarge
                        .copyWith(color: accentColor),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${chapter.titleAr}  •  ${page.title ?? 'صفحة ${progress.pageIndex + 1}'}',
                    style: typography.caption,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  PDF READ BANNER
// ─────────────────────────────────────────

class _PdfReadBanner extends StatelessWidget {
  final Color accentColor;
  final VoidCallback onTap;

  const _PdfReadBanner({
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              accentColor.withOpacity(0.15),
              accentColor.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.picture_as_pdf_rounded, color: accentColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'قراءة الكتاب (PDF)',
                    style: typography.labelLarge.copyWith(color: accentColor),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'فتح الغلاف المصور والصفحات المطابقة للأصل',
                    style: typography.caption,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  CHAPTER ROW
// ─────────────────────────────────────────

class _ChapterRow extends StatelessWidget {
  final BookChapter chapter;
  final int index;
  final Color accentColor;
  final bool isCurrent;
  final int currentPage;
  final VoidCallback onTap;

  const _ChapterRow({
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
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCurrent
              ? accentColor.withOpacity(0.08)
              : colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCurrent
                ? accentColor.withOpacity(0.35)
                : colors.border,
          ),
        ),
        child: Row(
          children: [
            // Chapter number badge
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isCurrent
                    ? accentColor.withOpacity(0.2)
                    : colors.card2,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isCurrent
                      ? accentColor
                      : colors.border,
                ),
              ),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color:
                      isCurrent ? accentColor : colors.textDim,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                children: [
                  Text(
                    chapter.titleAr,
                    style: typography.labelLarge
                        .copyWith(fontSize: 16),
                    textAlign: TextAlign.right,
                  ),
                  if (chapter.intro != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      chapter.intro!,
                      style: typography.caption,
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.end,
                    children: [
                      if (isCurrent && currentPage > 0) ...[
                        Text(
                          'صفحة ${currentPage + 1} / ${chapter.totalPages}',
                          style: typography.caption
                              .copyWith(color: accentColor),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        '${chapter.totalPages} صفحة',
                        style: typography.caption,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '~${chapter.estimatedMinutes} د',
                        style: typography.caption,
                      ),
                    ],
                  ),
                  if (isCurrent && currentPage > 0) ...[
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: currentPage /
                          chapter.totalPages,
                      backgroundColor: colors.border,
                      color: accentColor,
                      minHeight: 3,
                      borderRadius:
                          BorderRadius.circular(4),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.arrow_back_ios_new,
              color: colors.textDim,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
