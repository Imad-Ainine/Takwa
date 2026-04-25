// ═══════════════════════════════════════════════════════════════
//  lib/features/books/presentation/screens/book_reader_screen.dart
//  تقوى — Immersive Book Reader Screen
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:takwa/core/theme/app_theme.dart';
import 'package:takwa/features/books/data/books_data.dart';
import 'package:takwa/features/books/providers/books_reading_provider.dart';

class BookReaderScreen extends ConsumerStatefulWidget {
  final IslamicBook book;
  final int initialChapterIndex;
  final int initialPageIndex;

  const BookReaderScreen({
    super.key,
    required this.book,
    this.initialChapterIndex = 0,
    this.initialPageIndex = 0,
  });

  @override
  ConsumerState<BookReaderScreen> createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends ConsumerState<BookReaderScreen>
    with SingleTickerProviderStateMixin {
  late int _chapterIdx;
  late int _pageIdx;
  bool _showUI = true;
  late AnimationController _uiAnim;
  late Animation<double> _uiFade;
  final PageController _pageController = PageController();

  // ── Computed helpers ─────────────────────────────────────────
  BookChapter get _chapter => widget.book.chapters[_chapterIdx];
  BookPage get _page => _chapter.pages[_pageIdx];
  bool get _isFirstPage => _chapterIdx == 0 && _pageIdx == 0;
  bool get _isLastPage =>
      _chapterIdx == widget.book.chapters.length - 1 &&
      _pageIdx == _chapter.pages.length - 1;

  @override
  void initState() {
    super.initState();
    _chapterIdx = widget.initialChapterIndex;
    _pageIdx = widget.initialPageIndex;

    _uiAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: 1.0,
    );
    _uiFade = CurvedAnimation(parent: _uiAnim, curve: Curves.easeInOut);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _uiAnim.dispose();
    _pageController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggleUI() {
    setState(() => _showUI = !_showUI);
    if (_showUI) {
      _uiAnim.forward();
    } else {
      _uiAnim.reverse();
    }
  }

  void _goNext() {
    if (_isLastPage) return;
    setState(() {
      if (_pageIdx < _chapter.pages.length - 1) {
        _pageIdx++;
      } else {
        _chapterIdx++;
        _pageIdx = 0;
      }
    });
    _saveProgress();
  }

  void _goPrev() {
    if (_isFirstPage) return;
    setState(() {
      if (_pageIdx > 0) {
        _pageIdx--;
      } else {
        _chapterIdx--;
        _pageIdx = widget.book.chapters[_chapterIdx].pages.length - 1;
      }
    });
    _saveProgress();
  }

  void _saveProgress() {
    ref
        .read(readingProgressProvider.notifier)
        .save(widget.book.id, _chapterIdx, _pageIdx);
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex));
    } catch (_) {
      return const Color(0xFFC8A96E);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final fontSizeLevel = ref.watch(bookFontSizeProvider);
    final fontSize = fontSizeFromLevel(fontSizeLevel);
    final accentColor = _parseColor(widget.book.coverColor);

    return Scaffold(
      backgroundColor: colors.background,
      body: GestureDetector(
        onTap: _toggleUI,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            // ── Page Content ──────────────────────────────────
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 100, 20, 120),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Chapter indicator
                    Text(
                      _chapter.titleAr,
                      style: typography.caption.copyWith(
                        color: accentColor,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 6),

                    // Hadith card style
                    if (_page.isHadith) ...[
                      _HadithCard(
                        page: _page,
                        accentColor: accentColor,
                        bodyFontSize: fontSize,
                      ),
                    ] else ...[
                      // Title
                      if (_page.title != null) ...[
                        Text(
                          _page.title!,
                          style: typography.headingMedium.copyWith(
                            color: accentColor,
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        const SizedBox(height: 16),
                      ],
                      // Body text
                      Text(
                        _page.content,
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: fontSize,
                          color: colors.textPrimary,
                          height: 2.0,
                        ),
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── Top bar (fade in/out) ─────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _uiFade,
                child: _TopBar(
                  book: widget.book,
                  chapter: _chapter,
                  accentColor: accentColor,
                  fontSizeLevel: fontSizeLevel,
                  onFontSizeToggle: () =>
                      ref.read(bookFontSizeProvider.notifier).cycle(),
                ),
              ),
            ),

            // ── Bottom navigation ─────────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _uiFade,
                child: _BottomNav(
                  book: widget.book,
                  chapterIndex: _chapterIdx,
                  pageIndex: _pageIdx,
                  accentColor: accentColor,
                  isFirst: _isFirstPage,
                  isLast: _isLastPage,
                  onPrev: _goPrev,
                  onNext: _goNext,
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
//  HADITH CARD
// ─────────────────────────────────────────

class _HadithCard extends StatelessWidget {
  final BookPage page;
  final Color accentColor;
  final double bodyFontSize;

  const _HadithCard({
    required this.page,
    required this.accentColor,
    required this.bodyFontSize,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Hadith number + source row
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (page.source != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colors.tealDim,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colors.teal.withOpacity(0.3)),
                ),
                child: Text(
                  page.source!,
                  style: typography.caption.copyWith(color: colors.teal),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accentColor, accentColor.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                page.hadithNumber ?? '',
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Title
        if (page.title != null) ...[
          Text(
            page.title!,
            style: typography.headingMedium.copyWith(
              color: accentColor,
              fontSize: 18,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 16),
        ],

        // Hadith text in a decorative frame
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                accentColor.withOpacity(0.12),
                accentColor.withOpacity(0.04),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accentColor.withOpacity(0.3)),
          ),
          child: Text(
            page.content,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: bodyFontSize,
              color: context.colors.textPrimary,
              height: 2.2,
            ),
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
//  TOP BAR
// ─────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final IslamicBook book;
  final BookChapter chapter;
  final Color accentColor;
  final int fontSizeLevel;
  final VoidCallback onFontSizeToggle;

  const _TopBar({
    required this.book,
    required this.chapter,
    required this.accentColor,
    required this.fontSizeLevel,
    required this.onFontSizeToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final fontLabels = ['ص', 'م', 'ك'];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colors.background, colors.background.withOpacity(0.0)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
          child: Row(
            children: [
              // Font size button
              _IconBtn(
                onTap: onFontSizeToggle,
                child: Text(
                  fontLabels[fontSizeLevel],
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 16,
                    color: accentColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              Expanded(
                child: Column(
                  children: [
                    Text(
                      book.titleAr,
                      style: typography.caption.copyWith(color: accentColor),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      chapter.titleAr,
                      style: typography.caption,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Back button
              _IconBtn(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: colors.textSecondary,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  BOTTOM NAVIGATION
// ─────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final IslamicBook book;
  final int chapterIndex;
  final int pageIndex;
  final Color accentColor;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _BottomNav({
    required this.book,
    required this.chapterIndex,
    required this.pageIndex,
    required this.accentColor,
    required this.isFirst,
    required this.isLast,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    // Compute global page number for progress display
    int globalDone = 0;
    for (int ci = 0; ci < chapterIndex; ci++) {
      globalDone += book.chapters[ci].totalPages;
    }
    globalDone += pageIndex + 1;
    final total = book.totalPages;
    final progress = globalDone / total;

    final chapter = book.chapters[chapterIndex];
    final localPage = pageIndex + 1;
    final localTotal = chapter.totalPages;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [colors.background, colors.background.withOpacity(0.0)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Progress bar
              LinearProgressIndicator(
                value: progress,
                backgroundColor: colors.border,
                color: accentColor,
                minHeight: 3,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  // Next (in Arabic RTL = left is next)
                  _NavButton(
                    icon: Icons.arrow_back_ios_new,
                    label: 'التالي',
                    enabled: !isLast,
                    accentColor: accentColor,
                    onTap: onNext,
                  ),

                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '$localPage / $localTotal',
                          style: typography.labelMedium.copyWith(
                            color: accentColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '$globalDone من $total',
                          style: typography.caption,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  // Prev
                  _NavButton(
                    icon: Icons.arrow_forward_ios,
                    label: 'السابق',
                    enabled: !isFirst,
                    accentColor: accentColor,
                    onTap: onPrev,
                    iconFirst: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final Color accentColor;
  final VoidCallback onTap;
  final bool iconFirst;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.accentColor,
    required this.onTap,
    this.iconFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = enabled ? accentColor : colors.textDim;

    final iconW = Icon(icon, color: color, size: 16);
    final labelW = Text(
      label,
      style: TextStyle(fontFamily: 'Amiri', fontSize: 14, color: color),
    );

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: enabled ? accentColor.withOpacity(0.1) : colors.card2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: enabled ? accentColor.withOpacity(0.3) : colors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: iconFirst
              ? [iconW, const SizedBox(width: 4), labelW]
              : [labelW, const SizedBox(width: 4), iconW],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  GENERIC ICON BUTTON
// ─────────────────────────────────────────

class _IconBtn extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _IconBtn({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border),
        ),
        child: child,
      ),
    );
  }
}
