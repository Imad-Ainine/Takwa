import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:takwa/core/theme/app_theme.dart';
import 'package:takwa/core/widgets/custom_leading_button.dart';
import 'package:takwa/features/books/data/books_data.dart';
import 'package:takwa/features/books/providers/books_reading_provider.dart';
import 'package:takwa/features/books/presentation/screens/books_chapter_screen.dart';
import 'package:takwa/core/widgets/app_bar_widget.dart';
import 'package:takwa/core/widgets/takwa_loading_indicator.dart';
import 'package:takwa/core/widgets/takwa_refresh_indicator.dart';

class BooksLibraryScreen extends ConsumerStatefulWidget {
  const BooksLibraryScreen({super.key});

  @override
  ConsumerState<BooksLibraryScreen> createState() => _BooksLibraryScreenState();
}

class _BooksLibraryScreenState extends ConsumerState<BooksLibraryScreen> {
  String _searchQuery = '';
  BookCategory? _selectedCategory;
  bool _isGridView = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final booksAsync = ref.watch(booksListProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBarWidget(
        title: 'المكتبة الإسلامية',
        leading: const CustomLeadingButton(),
        actions: [
          IconButton(
            onPressed: () => setState(() => _isGridView = !_isGridView),
            icon: Icon(
              _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
              color: Colors.white,
            ),
            tooltip: _isGridView ? 'عرض القائمة' : 'عرض الشبكة',
          ),
        ],
      ),
      body: TakwaRefreshIndicator(
        onRefresh: () async {
          ref.invalidate(booksListProvider);
          try {
            await ref.read(booksListProvider.future);
          } catch (_) {}
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── Search Bar ────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: _SearchBar(
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
            ),

            // ── Categories ────────────────────────────────────────
            SliverToBoxAdapter(
              child: _CategorySelector(
                selected: _selectedCategory,
                onSelect: (cat) => setState(() => _selectedCategory = cat),
              ),
            ),

            // ── Book List/Grid ────────────────────────────────────
            booksAsync.when(
              data: (books) {
                final filtered = books.where((b) {
                  final matchCat =
                      _selectedCategory == null ||
                      b.category == _selectedCategory;
                  final matchSearch =
                      _searchQuery.isEmpty ||
                      b.titleAr.contains(_searchQuery) ||
                      b.authorAr.contains(_searchQuery);
                  return matchCat && matchSearch;
                }).toList();

                if (filtered.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('🧐', style: TextStyle(fontSize: 50)),
                          SizedBox(height: 16),
                          Text('لم يتم العثور على كتب'),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  sliver: _isGridView
                      ? SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.65,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                              ),
                          delegate: SliverChildBuilderDelegate((ctx, i) {
                            final book = filtered[i];
                            return _BookGridCard(
                              book: book,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      BooksChapterScreen(book: book),
                                ),
                              ),
                            );
                          }, childCount: filtered.length),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate((ctx, i) {
                            final book = filtered[i];
                            return _BookCard(
                              book: book,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      BooksChapterScreen(book: book),
                                ),
                              ),
                            );
                          }, childCount: filtered.length),
                        ),
                );
              },
              loading: () => const SliverFillRemaining(child: _BooksSkeleton()),
              error: (err, stack) => SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.wifi_off_rounded,
                        size: 80,
                        color: colors.textSecondary.withOpacity(0.3),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'تعذر الاتصال بالخادم',
                        style: typography.headingMedium.copyWith(fontSize: 22),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'يرجى التحقق من اتصالك بالإنترنت والمحاولة مجدداً\nأو اسحب الشاشة للأسفل للتحديث',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 15,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(booksListProvider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.gold,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.refresh, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'إعادة المحاولة',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  SEARCH BAR
// ─────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: 'ابحث عن كتاب أو مؤلف...',
          hintStyle: TextStyle(color: colors.textSecondary.withOpacity(0.5)),
          prefixIcon: Icon(Icons.search, color: colors.gold),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 20,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  CATEGORY SELECTOR
// ─────────────────────────────────────────

class _CategorySelector extends StatelessWidget {
  final BookCategory? selected;
  final ValueChanged<BookCategory?> onSelect;

  const _CategorySelector({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const categories = BookCategory.values;

    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        reverse: true, // RTL feel
        itemCount: categories.length + 1,
        itemBuilder: (ctx, i) {
          final isAll = i == 0;
          final cat = isAll ? null : categories[i - 1];
          final isSelected = selected == cat;
          final label = isAll ? 'الكل' : _labelFor(cat!);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => onSelect(cat),
              backgroundColor: colors.card,
              selectedColor: colors.gold.withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? colors.gold : colors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? colors.gold : colors.border,
                ),
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  String _labelFor(BookCategory cat) => switch (cat) {
    BookCategory.hadith => 'الحديث',
    BookCategory.fiqh => 'الفقه',
    BookCategory.seerah => 'السيرة',
    BookCategory.aqeedah => 'العقيدة',
    BookCategory.adab => 'الآداب',
    BookCategory.tazkiyah => 'التزكية',
    BookCategory.quran => 'علوم القرآن',
  };
}

// ─────────────────────────────────────────
//  BOOK CARD (IMPROVED)
// ─────────────────────────────────────────

class _BookCard extends ConsumerWidget {
  final IslamicBook book;
  final VoidCallback onTap;
  const _BookCard({required this.book, required this.onTap});

  Color _parseColor(String hex) {
    try {
      if (hex.startsWith('0x')) return Color(int.parse(hex));
      return Color(int.parse('0xFF$hex'));
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
      // Note: Supabase books might not have chapters locally loaded yet
      // This is a placeholder logic for now
      percent = 0.1; // Demo
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        margin: const EdgeInsets.only(bottom: 20),
        child: Stack(
          children: [
            // Background Card
            Positioned.fill(
              left: 40,
              child: Container(
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: colors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.arrow_back_ios_new,
                            size: 14,
                            color: colors.textSecondary.withOpacity(0.3),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: c1.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              book.categoryLabel,
                              style: typography.caption.copyWith(
                                color: c1,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        book.titleAr,
                        style: typography.headingMedium.copyWith(
                          fontSize: 18,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.right,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Text(
                        book.authorAr,
                        style: typography.caption.copyWith(
                          color: colors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _InfoChip(
                            icon: Icons.calendar_today,
                            text: '${book.publishYear} هـ',
                          ),
                          const SizedBox(width: 12),
                          _InfoChip(
                            icon: Icons.auto_stories,
                            text: book.publishYear > 500 ? "مجلد" : "كتيب",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Floating Book Cover
            Positioned(
              right: 20,
              top: 10,
              bottom: 10,
              child: Hero(
                tag: 'book_${book.id}',
                child: Container(
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: c1.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(4, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [c1, c2],
                            ),
                          ),
                        ),
                        if (book.coverUrl != null && book.coverUrl!.isNotEmpty)
                          CachedNetworkImage(
                            imageUrl: book.coverUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Center(
                              child: Text(
                                book.emoji,
                                style: const TextStyle(fontSize: 40),
                              ),
                            ),
                          )
                        else
                          Center(
                            child: Text(
                              book.emoji,
                              style: const TextStyle(fontSize: 40),
                            ),
                          ),
                        // Overlay shine
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: const Alignment(-0.5, -0.5),
                              colors: [
                                Colors.white.withOpacity(0.2),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
//  BOOK GRID CARD
// ─────────────────────────────────────────

class _BookGridCard extends StatelessWidget {
  final IslamicBook book;
  final VoidCallback onTap;
  const _BookGridCard({required this.book, required this.onTap});

  Color _parseColor(String hex) {
    try {
      if (hex.startsWith('0x')) return Color(int.parse(hex));
      return Color(int.parse('0xFF$hex'));
    } catch (_) {
      return const Color(0xFFC8A96E);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final c1 = _parseColor(book.coverColor);
    final c2 = _parseColor(book.coverColor2);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [c1, c2],
                        ),
                      ),
                    ),
                    if (book.coverUrl != null && book.coverUrl!.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: book.coverUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Center(
                          child: Text(
                            book.emoji,
                            style: const TextStyle(fontSize: 30),
                          ),
                        ),
                      )
                    else
                      Center(
                        child: Text(
                          book.emoji,
                          style: const TextStyle(fontSize: 30),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      book.titleAr,
                      style: typography.labelLarge.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.authorAr,
                      style: typography.caption.copyWith(
                        color: colors.textSecondary,
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colors.goldDim,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        book.categoryLabel,
                        style: typography.caption.copyWith(
                          color: colors.gold,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
}

// ─────────────────────────────────────────
//  INFO CHIP
// ─────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(
            color: colors.textSecondary.withOpacity(0.7),
            fontSize: 11,
          ),
        ),
        const SizedBox(width: 4),
        Icon(icon, size: 12, color: colors.gold.withOpacity(0.6)),
      ],
    );
  }
}

// ─────────────────────────────────────────
//  BOOKS SKELETON (LOADING STATE)
// ─────────────────────────────────────────
class _BooksSkeleton extends StatelessWidget {
  const _BooksSkeleton();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Container(
        height: 160,
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TakwaLoadingIndicator(),
              const SizedBox(height: 16),
              Text(
                'جاري تحميل الكتب...',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 14,
                  fontFamily: 'Amiri',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
