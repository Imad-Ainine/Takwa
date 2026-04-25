// ═══════════════════════════════════════════════════════════════
//  lib/features/books/providers/books_reading_provider.dart
//  تقوى — Books Reading State (Riverpod + SharedPreferences)
// ═══════════════════════════════════════════════════════════════

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────
//  READING PROGRESS (bookId → pageIndex)
// ─────────────────────────────────────────

class ReadingProgressNotifier
    extends StateNotifier<Map<String, _BookProgress>> {
  ReadingProgressNotifier() : super({}) {
    _load();
  }

  static const _prefPrefix = 'book_progress_';
  static const _chapterSuffix = '_chapter';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_prefPrefix));
    final map = <String, _BookProgress>{};
    for (final key in keys) {
      if (key.endsWith(_chapterSuffix)) continue;
      final bookId = key.substring(_prefPrefix.length);
      final page = prefs.getInt(key) ?? 0;
      final chapter =
          prefs.getInt('$_prefPrefix$bookId$_chapterSuffix') ?? 0;
      map[bookId] = _BookProgress(chapterIndex: chapter, pageIndex: page);
    }
    state = map;
  }

  Future<void> save(String bookId, int chapterIndex, int pageIndex) async {
    state = {
      ...state,
      bookId: _BookProgress(chapterIndex: chapterIndex, pageIndex: pageIndex),
    };
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_prefPrefix$bookId', pageIndex);
    await prefs.setInt('$_prefPrefix$bookId$_chapterSuffix', chapterIndex);
  }

  _BookProgress? progressFor(String bookId) => state[bookId];
}

class _BookProgress {
  final int chapterIndex;
  final int pageIndex;
  const _BookProgress({required this.chapterIndex, required this.pageIndex});
}

final readingProgressProvider =
    StateNotifierProvider<ReadingProgressNotifier, Map<String, _BookProgress>>(
  (ref) => ReadingProgressNotifier(),
);

// Helper to read progress for a specific book
BookReadingProgress? getProgress(
    Map<String, _BookProgress> map, String bookId) {
  final p = map[bookId];
  if (p == null) return null;
  return BookReadingProgress(
      chapterIndex: p.chapterIndex, pageIndex: p.pageIndex);
}

class BookReadingProgress {
  final int chapterIndex;
  final int pageIndex;
  const BookReadingProgress(
      {required this.chapterIndex, required this.pageIndex});
}

// ─────────────────────────────────────────
//  FONT SIZE (0=small, 1=medium, 2=large)
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

final bookFontSizeProvider =
    StateNotifierProvider<BookFontSizeNotifier, int>(
  (ref) => BookFontSizeNotifier(),
);

/// Returns the actual pixel size from the font-size level
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
