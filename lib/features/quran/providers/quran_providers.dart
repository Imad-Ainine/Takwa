// ═══════════════════════════════════════════════════════════════
//  lib/features/quran/providers/quran_providers.dart
// ═══════════════════════════════════════════════════════════════

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/quran_data.dart';

// Night mode
final quranNightModeProvider = StateProvider<bool>((ref) => true);

// Font size
final quranFontSizeProvider = StateProvider<double>((ref) => 22.0);

// Last read
class LastReadNotifier extends StateNotifier<QuranBookmark?> {
  LastReadNotifier() : super(null) { _load(); }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('quran_last_read');
    if (raw != null) {
      state = QuranBookmark.fromJson(jsonDecode(raw));
    }
  }

  Future<void> save(QuranBookmark bm) async {
    state = bm;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('quran_last_read', jsonEncode(bm.toJson()));
  }
}

final quranLastReadProvider =
    StateNotifierProvider<LastReadNotifier, QuranBookmark?>(
        (ref) => LastReadNotifier());

// Bookmarks
class BookmarksNotifier extends StateNotifier<List<QuranBookmark>> {
  BookmarksNotifier() : super([]) { _load(); }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('quran_bookmarks') ?? [];
    state = raw.map((s) => QuranBookmark.fromJson(jsonDecode(s))).toList();
  }

  Future<void> add(QuranBookmark bm) async {
    // avoid duplicates
    final exists = state.any(
        (b) => b.surahNum == bm.surahNum && b.ayahNum == bm.ayahNum);
    if (exists) return;
    state = [...state, bm];
    await _persist();
  }

  Future<void> remove(QuranBookmark bm) async {
    state = state.where(
        (b) => !(b.surahNum == bm.surahNum && b.ayahNum == bm.ayahNum)).toList();
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('quran_bookmarks',
        state.map((b) => jsonEncode(b.toJson())).toList());
  }
}

final quranBookmarksProvider =
    StateNotifierProvider<BookmarksNotifier, List<QuranBookmark>>(
        (ref) => BookmarksNotifier());

// Reading progress (page percentage)
final quranProgressProvider = Provider<double>((ref) {
  final last = ref.watch(quranLastReadProvider);
  if (last == null) return 0;
  return last.page / 604;
});
