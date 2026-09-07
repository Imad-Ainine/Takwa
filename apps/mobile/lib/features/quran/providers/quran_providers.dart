import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quran_library/quran_library.dart' as ql;
import '../../../core/providers/database_providers.dart';
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

  /// Marks the active Khatma as finished regardless of pagesRead —
  /// distinct from the automatic completion in [advancePage] (which
  /// triggers only once every page has actually been read through the
  /// app). This is the "I finished reading from another source" path:
  /// user-declared, not derived from tracked pages.
  Future<void> markAsFinished() async {
    if (state == null) return;
    final finished = state!.copyWith(completedDate: DateTime.now());
    await _repo.archiveKhatma(finished);
    state = null;
    await _repo.clearActiveKhatma();
  }

  /// Accumulates time spent actively reading toward this Khatma. Called
  /// once per reading session (see QuranReaderScreen's dispose), not per
  /// page, so "average reading time" means "average per sitting" rather
  /// than some fraction of a page.
  Future<void> addReadingTime(int seconds) async {
    if (state == null || seconds <= 0) return;
    final updated = state!.copyWith(
      totalReadingSeconds: state!.totalReadingSeconds + seconds,
      readingSessionsCount: state!.readingSessionsCount + 1,
    );
    state = updated;
    await _repo.setActiveKhatma(updated);
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

/// Permanently deletes one history entry (completed or cancelled) by id.
/// Callers must invalidate khatmaCompletedProvider/khatmaCancelledProvider
/// themselves afterward to see the change — this is a plain repository
/// call, not a StateNotifier, since history entries aren't the "current
/// state" of anything.
final khatmaDeleteHistoryProvider = Provider<Future<void> Function(String)>(
  (ref) => (id) => ref.read(quranPrefsRepositoryProvider).deleteFromHistory(id),
);

// ─────────────────────────────────────────────────────────────
// Reading-habit stats (from real daily_records rows)
// ─────────────────────────────────────────────────────────────

/// Aggregated reading-habit stats derived from real `daily_records` rows
/// (the same table the Stats/Prayer screens read), scoped to whatever a
/// Khatma progress screen needs: which recent days had Quran reading
/// logged (for the reading-days calendar), and the streaks/last-read date
/// that follow from that. Computed fresh on every watch rather than
/// cached — cheap (≤60 rows) and must reflect today's just-logged pages
/// immediately.
class KhatmaReadingStats {
  final Map<DateTime, int> pagesByDay; // date-only keys
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastReadDate;

  const KhatmaReadingStats({
    required this.pagesByDay,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastReadDate,
  });

  static DateTime dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}

final khatmaReadingStatsProvider = FutureProvider<KhatmaReadingStats>((
  ref,
) async {
  final records = await ref.watch(dailyRecordDaoProvider).getLastNDays(60);
  final byDay = <DateTime, int>{
    for (final r in records)
      KhatmaReadingStats.dayOnly(r.date): r.quranPages,
  };

  final today = KhatmaReadingStats.dayOnly(DateTime.now());

  // Current streak: walk back from today, or from yesterday if today
  // simply hasn't been read yet — a day still in progress shouldn't zero
  // out an otherwise-intact streak.
  int currentStreak = 0;
  var cursor = (byDay[today] ?? 0) > 0
      ? today
      : today.subtract(const Duration(days: 1));
  while ((byDay[cursor] ?? 0) > 0) {
    currentStreak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }

  // Longest streak within the fetched 60-day window.
  int longestStreak = 0;
  int running = 0;
  for (int i = 59; i >= 0; i--) {
    final d = today.subtract(Duration(days: i));
    if ((byDay[d] ?? 0) > 0) {
      running++;
      if (running > longestStreak) longestStreak = running;
    } else {
      running = 0;
    }
  }

  DateTime? lastRead;
  for (final entry in byDay.entries) {
    if (entry.value > 0 && (lastRead == null || entry.key.isAfter(lastRead))) {
      lastRead = entry.key;
    }
  }

  return KhatmaReadingStats(
    pagesByDay: byDay,
    currentStreak: currentStreak,
    longestStreak: longestStreak,
    lastReadDate: lastRead,
  );
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
