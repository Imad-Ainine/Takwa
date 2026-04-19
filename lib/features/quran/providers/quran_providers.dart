// ═══════════════════════════════════════════════════════════════
//  lib/features/quran/providers/quran_providers.dart
// ═══════════════════════════════════════════════════════════════

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quran_library/quran_library.dart' as ql;
import 'package:shared_preferences/shared_preferences.dart';
import '../data/quran_models.dart';

// ─────────────────────────────────────────────────────────────
// Reader State
// ─────────────────────────────────────────────────────────────
final quranStateProvider =
    StateNotifierProvider<QuranStateNotifier, QuranReadingState>(
      (ref) => QuranStateNotifier(),
    );

class QuranStateNotifier extends StateNotifier<QuranReadingState> {
  QuranStateNotifier() : super(const QuranReadingState()) {
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    state = state.copyWith(
      theme: ReaderTheme.values[p.getInt('q_theme') ?? 0],
      fontSize: p.getDouble('q_fontsize') ?? 22.0,
      currentPage: p.getInt('q_last_page') ?? 1,
    );
  }

  Future<void> setTheme(ReaderTheme t) async {
    state = state.copyWith(theme: t);
    final p = await SharedPreferences.getInstance();
    await p.setInt('q_theme', t.index);
  }

  Future<void> setFontSize(double s) async {
    state = state.copyWith(fontSize: s.clamp(16, 36));
    final p = await SharedPreferences.getInstance();
    await p.setDouble('q_fontsize', s);
  }

  Future<void> setPage(int page) async {
    state = state.copyWith(currentPage: page);
    final p = await SharedPreferences.getInstance();
    await p.setInt('q_last_page', page);
  }

  void setMode(ReaderMode m) => state = state.copyWith(mode: m);
  void setSurah(int s) => state = state.copyWith(currentSurah: s);
  void setAyah(int a) => state = state.copyWith(currentAyah: a);
  void toggleToolbar() =>
      state = state.copyWith(showToolbar: !state.showToolbar);
}

// ─────────────────────────────────────────────────────────────
// Audio
// ─────────────────────────────────────────────────────────────
final quranAudioProvider =
    StateNotifierProvider<QuranAudioNotifier, QuranAudioState>(
      (ref) => QuranAudioNotifier(),
    );

class QuranAudioNotifier extends StateNotifier<QuranAudioState> {
  QuranAudioNotifier() : super(const QuranAudioState());
  final _player = AudioPlayer();

  static const _base =
      'https://cdn.islamic.network/quran/audio/128/ar.alafasy/';

  Future<void> playAyah(int surah, int ayah) async {
    state = state.copyWith(isLoading: true, surah: surah, ayah: ayah);
    try {
      final absAyah = _absoluteAyah(surah, ayah);
      await _player.setUrl('$_base$absAyah.mp3');
      await _player.setSpeed(state.speed);
      await _player.play();
      state = state.copyWith(isLoading: false, isPlaying: true);
      _player.playerStateStream.listen((s) {
        if (s.processingState == ProcessingState.completed) {
          state = state.copyWith(isPlaying: false);
        }
      });
    } catch (_) {
      state = state.copyWith(isLoading: false, isPlaying: false);
    }
  }

  Future<void> togglePlay(int surah, int ayah) async {
    if (state.isPlaying && state.surah == surah && state.ayah == ayah) {
      await _player.pause();
      state = state.copyWith(isPlaying: false);
    } else {
      await playAyah(surah, ayah);
    }
  }

  Future<void> stop() async {
    await _player.stop();
    state = state.copyWith(isPlaying: false, isLoading: false);
  }

  Future<void> setSpeed(double s) async {
    state = state.copyWith(speed: s);
    await _player.setSpeed(s);
  }

  int _absoluteAyah(int surah, int ayah) {
    int abs = 0;
    for (int i = 0; i < surah - 1; i++) {
      abs += ql.QuranLibrary.quranCtrl.surahsList[i].ayahsNumber;
    }
    return abs + ayah;
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

// ─────────────────────────────────────────────────────────────
// Last Read / Bookmarks
// ─────────────────────────────────────────────────────────────
final quranLastReadProvider =
    StateNotifierProvider<_LastReadNotifier, QuranBookmark?>(
      (ref) => _LastReadNotifier(),
    );

class _LastReadNotifier extends StateNotifier<QuranBookmark?> {
  _LastReadNotifier() : super(null) {
    _load();
  }
  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final r = p.getString('q_last_read');
    if (r != null) state = QuranBookmark.fromJson(jsonDecode(r));
  }

  Future<void> save(QuranBookmark b) async {
    state = b;
    final p = await SharedPreferences.getInstance();
    await p.setString('q_last_read', jsonEncode(b.toJson()));
  }
}

final quranBookmarksProvider =
    StateNotifierProvider<_BookmarksNotifier, List<QuranBookmark>>(
      (ref) => _BookmarksNotifier(),
    );

class _BookmarksNotifier extends StateNotifier<List<QuranBookmark>> {
  _BookmarksNotifier() : super([]) {
    _load();
  }
  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final l = p.getStringList('q_bookmarks') ?? [];
    state = l.map((s) => QuranBookmark.fromJson(jsonDecode(s))).toList();
  }

  Future<void> add(QuranBookmark b) async {
    if (state.any((x) => x.surahNum == b.surahNum && x.ayahNum == b.ayahNum)) {
      return;
    }
    state = [...state, b];
    await _persist();
  }

  Future<void> remove(int surah, int ayah) async {
    state = state
        .where((x) => !(x.surahNum == surah && x.ayahNum == ayah))
        .toList();
    await _persist();
  }

  Future<void> _persist() async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList(
      'q_bookmarks',
      state.map((b) => jsonEncode(b.toJson())).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Khatma
// ─────────────────────────────────────────────────────────────
final khatmaProvider = StateNotifierProvider<KhatmaNotifier, KhatmaSession?>(
  (ref) => KhatmaNotifier(),
);

class KhatmaNotifier extends StateNotifier<KhatmaSession?> {
  KhatmaNotifier() : super(null) {
    _load();
  }

  static const _activeKey = 'khatma_active';
  static const _historyKey = 'khatma_history';

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_activeKey);
    if (raw != null) {
      state = KhatmaSession.fromJson(jsonDecode(raw));
    }
  }

  Future<void> startNew({String label = 'ختمة جديدة'}) async {
    // Archive current if exists
    if (state != null) await _archive(state!);
    final session = KhatmaSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startDate: DateTime.now(),
      label: label,
    );
    state = session;
    await _persist();
  }

  Future<void> advancePage(int page) async {
    if (state == null) return;
    final newPagesRead = page > (state!.currentPage)
        ? state!.pagesRead + (page - state!.currentPage)
        : state!.pagesRead;
    final updated = state!.copyWith(
      currentPage: page,
      pagesRead: newPagesRead,
      completedDate: newPagesRead >= KhatmaSession.totalPages
          ? DateTime.now()
          : null,
    );
    state = updated;
    await _persist();
    if (updated.isCompleted) await _archive(updated);
  }

  Future<void> _persist() async {
    if (state == null) return;
    final p = await SharedPreferences.getInstance();
    await p.setString(_activeKey, jsonEncode(state!.toJson()));
  }

  Future<void> _archive(KhatmaSession s) async {
    final p = await SharedPreferences.getInstance();
    final list = p.getStringList(_historyKey) ?? [];
    list.add(jsonEncode(s.toJson()));
    await p.setStringList(_historyKey, list);
  }
}

final khatmaHistoryProvider = FutureProvider<List<KhatmaSession>>((ref) async {
  final p = await SharedPreferences.getInstance();
  final list = p.getStringList('khatma_history') ?? [];
  return list
      .map((s) => KhatmaSession.fromJson(jsonDecode(s)))
      .toList()
      .reversed
      .toList();
});

// ─────────────────────────────────────────────────────────────
// Daily Verse (random ayah from Al-Baqarah for demo)
// ─────────────────────────────────────────────────────────────
final dailyVerseProvider = Provider<Map<String, dynamic>>((ref) {
  final surahs = ql.QuranLibrary.quranCtrl.surahs;
  // Use day-of-year seed for consistency within the same day
  final now = DateTime.now();
  final seed = now.year * 1000 + now.month * 30 + now.day;
  final rng = Random(seed);
  // Pick a surah from 1-10 for daily verse (shorter surahs)
  final surahIdx = rng.nextInt(surahs.length);
  final surah = surahs[surahIdx];
  final ayahIdx = rng.nextInt(surah.ayahs.length);
  final ayah = surah.ayahs[ayahIdx];
  return {
    'surahName': surah.arabicName,
    'surahNumber': surahIdx + 1,
    'ayahNumber': ayahIdx + 1,
    'text': ayah.text,
  };
});
