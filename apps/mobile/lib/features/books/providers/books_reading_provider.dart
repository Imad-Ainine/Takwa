import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/books_data.dart';
import '../../../core/supabase/supabase_service.dart';
import '../../../core/providers/database_providers.dart';
import '../../../core/database/daos.dart';

class BookProgress {
  final int chapterIndex;
  final int pageIndex;
  final Set<int> readPages;

  const BookProgress({
    required this.chapterIndex,
    required this.pageIndex,
    required this.readPages,
  });
}

class ReadingProgressNotifier extends StateNotifier<Map<String, BookProgress>> {
  ReadingProgressNotifier(this._ref) : super({}) {
    _load();
  }

  final Ref _ref;

  BookProgressDao get _dao => _ref.read(bookProgressDaoProvider);

  /// Load all book progress from local Drift DB.
  Future<void> _load() async {
    try {
      final rows = await _dao.getAll();
      final map = <String, BookProgress>{};
      for (final row in rows) {
        final readPages = row.readPages.isEmpty
            ? <int>{}
            : row.readPages.split(',').map(int.parse).toSet();
        map[row.bookId] = BookProgress(
          chapterIndex: row.chapterIndex,
          pageIndex: row.pageIndex,
          readPages: readPages,
        );
      }
      state = map;
    } catch (e) {
      print('Failed to load book progress from local DB: $e');
    }
  }

  /// Save progress locally (Drift) and opportunistically push to Supabase.
  Future<void> save(String bookId, int chapterIndex, int pageIndex) async {
    final existing = state[bookId];
    final updatedReadPages = {...(existing?.readPages ?? <int>{}), pageIndex};

    // 1. Update in-memory state immediately.
    state = {
      ...state,
      bookId: BookProgress(
        chapterIndex: chapterIndex,
        pageIndex: pageIndex,
        readPages: updatedReadPages,
      ),
    };

    // 2. Write to local Drift DB (works offline).
    try {
      await _dao.markPage(
        bookId: bookId,
        chapterIndex: chapterIndex,
        pageIndex: pageIndex,
        readPages: updatedReadPages,
      );
    } catch (e) {
      print('Failed to write book progress to local DB: $e');
    }

    // 3. Best-effort push to Supabase (ignored if offline).
    try {
      await SupabaseService.upsertBookProgress(bookId, {
        'chapter_index': chapterIndex,
        'page_index': pageIndex,
        'read_pages': updatedReadPages.toList(),
      });
    } catch (e) {
      print('Offline book sync skipped: $e');
    }
  }

  /// Save PDF page progress locally and push to Supabase.
  Future<void> savePdfSession(
    String bookId,
    int pdfPage,
    int totalPdfPages,
    int readingSeconds,
  ) async {
    try {
      await _dao.savePdfSession(
        bookId: bookId,
        pdfPage: pdfPage,
        totalPdfPages: totalPdfPages,
        readingSeconds: readingSeconds,
      );
    } catch (e) {
      print('Failed to write pdf session to local DB: $e');
    }
    try {
      await SupabaseService.upsertPdfSession(
        bookId,
        pdfPage,
        totalPdfPages,
        readingSeconds,
      );
    } catch (e) {
      print('Offline pdf session sync skipped: $e');
    }
  }

  /// Pull remote progress from Supabase and merge into local Drift DB.
  Future<void> syncFromRemote() async {
    try {
      final remoteData = await SupabaseService.getAllBookProgress();
      if (remoteData.isEmpty) return;
      for (final item in remoteData) {
        await _dao.upsertFromRemote(item);
      }
      await _load();
    } catch (e) {
      print('Failed to sync remote book progress: $e');
    }
  }

  BookProgress? progressFor(String bookId) => state[bookId];

  bool isPageRead(String bookId, int pageIndex) =>
      state[bookId]?.readPages.contains(pageIndex) ?? false;

  double getProgress(String bookId, int totalPages) {
    if (totalPages == 0) return 0;
    final readCount = state[bookId]?.readPages.length ?? 0;
    return (readCount / totalPages).clamp(0, 1.0);
  }
}

final readingProgressProvider =
    StateNotifierProvider<ReadingProgressNotifier, Map<String, BookProgress>>(
      (ref) => ReadingProgressNotifier(ref),
    );

// Helper to read progress for a specific book
BookReadingProgress? getProgress(Map<String, BookProgress> map, String bookId) {
  final p = map[bookId];
  if (p == null) return null;
  return BookReadingProgress(
    chapterIndex: p.chapterIndex,
    pageIndex: p.pageIndex,
  );
}

class BookReadingProgress {
  final int chapterIndex;
  final int pageIndex;
  const BookReadingProgress({
    required this.chapterIndex,
    required this.pageIndex,
  });
}

// ─────────────────────────────────────────
//  FONT SIZE (0=small 1=medium 2=large)
// ─────────────────────────────────────────

class BookFontSizeNotifier extends StateNotifier<int> {
  BookFontSizeNotifier() : super(1) {
    _load();
  }

  static const _prefKey = 'book_font_size';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getInt(_prefKey) ?? 1;
  }

  Future<void> cycle() async {
    final next = (state + 1) % 3;
    state = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefKey, next);
  }
}

final bookFontSizeProvider = StateNotifierProvider<BookFontSizeNotifier, int>(
  (ref) => BookFontSizeNotifier(),
);

double fontSizeFromLevel(int level) {
  switch (level) {
    case 0:
      return 17.0;
    case 2:
      return 24.0;
    default:
      return 20.0;
  }
}

// ─────────────────────────────────────────
//  BOOKS LIST — offline-first
//  Tries Supabase first, falls back to kIslamicBooks if offline.
// ─────────────────────────────────────────
final booksListProvider = FutureProvider<List<IslamicBook>>((ref) async {
  try {
    final data = await SupabaseService.getBooks();
    if (data.isNotEmpty) {
      return data.map((json) => IslamicBook.fromJson(json)).toList();
    }
  } catch (_) {
    // Network unavailable — fall through to local data.
  }
  return kIslamicBooks;
});
