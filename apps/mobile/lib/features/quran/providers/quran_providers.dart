
import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quran_library/quran_library.dart' as ql;
import '../../../core/providers/shared_preferences_provider.dart';
import '../data/quran_models.dart';
import '../data/quran_prefs_repository.dart';

// ─────────────────────────────────────────────────────────────
// Repository
// ─────────────────────────────────────────────────────────────
final quranPrefsRepositoryProvider = Provider<QuranPrefsRepository>((ref) {
  return QuranPrefsRepository(ref.watch(sharedPreferencesProvider));
});

// ─────────────────────────────────────────────────────────────
// Reader State
// ─────────────────────────────────────────────────────────────
final quranStateProvider =
    StateNotifierProvider<QuranStateNotifier, QuranReadingState>(
      (ref) => QuranStateNotifier(ref.watch(quranPrefsRepositoryProvider)),
    );

class QuranStateNotifier extends StateNotifier<QuranReadingState> {
  QuranStateNotifier(this._repo)
    : super(
        QuranReadingState(
          theme: _repo.getReaderTheme(),
          fontSize: _repo.getFontSize(),
          currentPage: _repo.getLastPage(),
        ),
      );

  final QuranPrefsRepository _repo;

  Future<void> setTheme(ReaderTheme t) async {
    state = state.copyWith(theme: t);
    await _repo.setReaderTheme(t);
  }

  Future<void> setFontSize(double s) async {
    state = state.copyWith(fontSize: s.clamp(16, 36));
    await _repo.setFontSize(s);
  }

  Future<void> setPage(int page) async {
    state = state.copyWith(currentPage: page);
    await _repo.setLastPage(page);
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
  QuranAudioNotifier() : super(const QuranAudioState()) {
    // Subscribe once; playAyah only changes the URL being played.
    _playerStateSub = _player.playerStateStream.listen((s) {
      if (s.processingState == ProcessingState.completed) {
        state = state.copyWith(isPlaying: false);
      }
    });
  }
  final _player = AudioPlayer();
  StreamSubscription<PlayerState>? _playerStateSub;
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
    final surahs = ql.QuranLibrary.quranCtrl.surahsList;
    for (int i = 0; i < surah - 1 && i < surahs.length; i++) {
      abs += surahs[i].ayahsNumber;
    }
    return abs + ayah;
  }

  @override
  void dispose() {
    _playerStateSub?.cancel();
    _player.dispose();
    super.dispose();
  }
}

// ─────────────────────────────────────────────────────────────
// Last Read / Bookmarks
// ─────────────────────────────────────────────────────────────
final quranLastReadProvider =
    StateNotifierProvider<_LastReadNotifier, QuranBookmark?>(
      (ref) => _LastReadNotifier(ref.watch(quranPrefsRepositoryProvider)),
    );

class _LastReadNotifier extends StateNotifier<QuranBookmark?> {
  _LastReadNotifier(this._repo) : super(_repo.getLastRead());

  final QuranPrefsRepository _repo;

  Future<void> save(QuranBookmark b) async {
    state = b;
    await _repo.setLastRead(b);
  }

  Future<void> clear() async {
    state = null;
    await _repo.clearLastRead();
  }
}

final quranBookmarksProvider =
    StateNotifierProvider<_BookmarksNotifier, List<QuranBookmark>>(
      (ref) => _BookmarksNotifier(ref.watch(quranPrefsRepositoryProvider)),
    );

class _BookmarksNotifier extends StateNotifier<List<QuranBookmark>> {
  _BookmarksNotifier(this._repo) : super(_repo.getBookmarks());

  final QuranPrefsRepository _repo;

  Future<void> add(QuranBookmark b) async {
    if (state.any((x) => x.surahNum == b.surahNum && x.ayahNum == b.ayahNum)) {
      return;
    }
    state = [...state, b];
    await _repo.setBookmarks(state);
  }

  Future<void> remove(int surah, int ayah) async {
    state = state
        .where((x) => !(x.surahNum == surah && x.ayahNum == ayah))
        .toList();
    await _repo.setBookmarks(state);
  }
}

// ─────────────────────────────────────────────────────────────
// Khatma Notifier (extended)
// ─────────────────────────────────────────────────────────────
final khatmaExProvider =
    StateNotifierProvider<KhatmaExNotifier, KhatmaSessionEx?>(
      (ref) => KhatmaExNotifier(ref.watch(quranPrefsRepositoryProvider)),
    );

class KhatmaExNotifier extends StateNotifier<KhatmaSessionEx?> {
  KhatmaExNotifier(this._repo) : super(_repo.getActiveKhatma());

  final QuranPrefsRepository _repo;

  Future<void> createNew({
    required String label,
    required KhatmaType type,
    required int startPage,
    bool notificationsEnabled = false,
    int? dailyPages,
    DateTime? endDate,
  }) async {
    if (state != null && state!.isActive) await _repo.archiveKhatma(state!);
    final session = KhatmaSessionEx(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      label: label,
      type: type,
      startDate: DateTime.now(),
      endDate: endDate,
      startPage: startPage,
      currentPage: startPage,
      notificationsEnabled: notificationsEnabled,
      dailyPages: dailyPages,
    );
    state = session;
    await _repo.setActiveKhatma(session);
  }

  Future<void> advancePage(int page) async {
    if (state == null) return;
    final newPagesRead = page > state!.currentPage
        ? state!.pagesRead + (page - state!.currentPage)
        : state!.pagesRead;
    final updated = state!.copyWith(
      currentPage: page,
      pagesRead: newPagesRead,
      completedDate: newPagesRead >= KhatmaSessionEx.totalPages
          ? DateTime.now()
          : null,
    );
    state = updated;
    await _repo.setActiveKhatma(updated);
    if (updated.isCompleted) await _repo.archiveKhatma(updated);
  }

  Future<void> cancel() async {
    if (state == null) return;
    final cancelled = state!.copyWith(cancelledDate: DateTime.now());
    await _repo.archiveKhatma(cancelled);
    state = null;
    await _repo.clearActiveKhatma();
  }
}

// History providers
final khatmaCompletedProvider = FutureProvider<List<KhatmaSessionEx>>((
  ref,
) async {
  final history = ref.watch(quranPrefsRepositoryProvider).getKhatmaHistory();
  return history.where((s) => s.isCompleted).toList().reversed.toList();
});

final khatmaCancelledProvider = FutureProvider<List<KhatmaSessionEx>>((
  ref,
) async {
  final history = ref.watch(quranPrefsRepositoryProvider).getKhatmaHistory();
  return history.where((s) => s.isCancelled).toList().reversed.toList();
});

// ─────────────────────────────────────────────────────────────
// Daily Verse
// ─────────────────────────────────────────────────────────────
final dailyVerseProvider = Provider<Map<String, dynamic>>((ref) {
  final surahs = ql.QuranLibrary.quranCtrl.surahs;
  final now = DateTime.now();
  final seed = now.year * 1000 + now.month * 30 + now.day;
  final rng = Random(seed);
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
