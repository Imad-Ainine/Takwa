import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:takwa/core/theme/app_theme.dart';
import 'package:takwa/core/widgets/custom_pattern_background.dart';
import 'package:takwa/features/books/data/books_data.dart';
import 'package:takwa/features/books/providers/books_reading_provider.dart';
import 'package:takwa/features/books/presentation/screens/books_chapter_screen.dart';

class BooksLibraryScreen extends ConsumerStatefulWidget {
  const BooksLibraryScreen({super.key});

  @override
  ConsumerState<BooksLibraryScreen> createState() => _BooksLibraryScreenState();
}

class _BooksLibraryScreenState extends ConsumerState<BooksLibraryScreen> {
  String _searchQuery = '';
  BookCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final booksAsync = ref.watch(booksListProvider);

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        slivers: [
          // ── Premium App Bar ──────────────────────────────────
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            stretch: true,
            backgroundColor: colors.deep,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: const EdgeInsets.only(right: 16, bottom: 16),
              title: Text(
                'المكتبة الإسلامية',
                style: typography.headingMedium.copyWith(
                  fontSize: 22,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                textDirection: TextDirection.rtl,
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          colors.deep,
                          colors.gold.withOpacity(0.3),
                          colors.deep,
                        ],
                      ),
                    ),
                  ),
                  const CustomPatternBackground(
                    pattern: BackgroundPattern.adhkar,
                    opacity: 0.15,
                  ),
                  Positioned(
                    left: -20,
                    bottom: -20,
                    child: Opacity(
                      opacity: 0.2,
                      child: Icon(Icons.menu_book,
                          size: 180, color: colors.gold),
                    ),
                  ),
                ],
              ),
            ),
          ),

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
                    _selectedCategory == null || b.category == _selectedCategory;
                final matchSearch = _searchQuery.isEmpty ||
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final book = filtered[i];
                      return _BookCard(
                        book: book,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BooksChapterScreen(book: book),
                          ),
                        ),
                      );
                    },
                    childCount: filtered.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: Center(child: Text('حدث خطأ: $err')),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
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
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
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
                          Icon(Icons.arrow_back_ios_new,
                              size: 14, color: colors.textSecondary.withOpacity(0.3)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
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
              right: 0,
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
                              child: Text(book.emoji,
                                  style: const TextStyle(fontSize: 40)),
                            ),
                          )
                        else
                          Center(
                            child:
                                Text(book.emoji, style: const TextStyle(fontSize: 40)),
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
