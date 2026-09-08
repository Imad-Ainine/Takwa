import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quran_library/quran_library.dart' as ql;
import '../../../core/providers/database_providers.dart';
import '../../../core/providers/shared_preferences_provider.dart';
import '../../../core/supabase/supabase_config.dart';
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
  String _reciterBaseUrl(String reciterId) =>
      'https://cdn.islamic.network/quran/audio/128/$reciterId/';

  // Guards against a stale async response clobbering newer state: if the
  // user taps a different ayah (or the same one again — "reload") before
  // the previous playAyah() call's setUrl()/play() has resolved, only the
  // most recent call is allowed to write its result into `state`. Without
  // this, a slow first request completing after a faster second one could
  // flip `isPlaying`/`surah`/`ayah` back to stale values even though the
  // player itself had already moved on — the "stale state on reload" bug.
  int _playRequestId = 0;

  Future<void> setReciter(String reciterId) async {
    state = state.copyWith(reciterId: reciterId);
    if (state.isPlaying) {
      await playAyah(state.surah, state.ayah);
    }
  }

  Future<void> playAyah(int surah, int ayah) async {
    final requestId = ++_playRequestId;
    state = state.copyWith(
      isLoading: true,
      isPlaying: false,
      hasError: false,
      surah: surah,
      ayah: ayah,
    );
    try {
      final absAyah = _absoluteAyah(surah, ayah);
      final base = _reciterBaseUrl(state.reciterId);
      await _player.setUrl('$base$absAyah.mp3');
      await _player.setSpeed(state.speed);
      await _player.play();
      if (requestId != _playRequestId) return; // superseded, drop the result
      state = state.copyWith(isLoading: false, isPlaying: true);
    } catch (_) {
      if (requestId != _playRequestId) return;
      state = state.copyWith(
        isLoading: false,
        isPlaying: false,
        hasError: true,
      );
    }
  }

  Future<void> togglePlay(int surah, int ayah) async {
    if (state.isPlaying && state.surah == surah && state.ayah == ayah) {
      _playRequestId++; // invalidate any in-flight playAyah for this ayah
      await _player.pause();
      state = state.copyWith(isPlaying: false);
    } else {
      await playAyah(surah, ayah);
    }
  }

  Future<void> stop() async {
    _playRequestId++; // invalidate any in-flight playAyah call
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
      (ref) => _LastReadNotifier(ref, ref.watch(quranPrefsRepositoryProvider)),
    );

class _LastReadNotifier extends StateNotifier<QuranBookmark?> {
  _LastReadNotifier(this._ref, this._repo) : super(_repo.getLastRead());

  final Ref _ref;
  final QuranPrefsRepository _repo;

  Future<void> save(QuranBookmark b) async {
    state = b;
    await _repo.setLastRead(b);
    // Best-effort push to Supabase (silently no-ops offline/signed-out,
    // same as ReadingProgressNotifier's book-progress sync) so "continue
    // reading" carries over to a user's other devices.
    try {
      await _ref.read(supabaseServiceProvider).upsertQuranLastRead({
        'surah_num': b.surahNum,
        'ayah_num': b.ayahNum,
        'page': b.page,
        'surah_name': b.surahName,
        'saved_at': (b.savedAt ?? DateTime.now()).toIso8601String(),
      });
    } catch (e) {
      developer.log(
        'Offline quran last-read sync skipped: $e',
        name: 'QuranProviders',
      );
    }
  }

  Future<void> clear() async {
    state = null;
    await _repo.clearLastRead();
  }

  /// Pulls the remote last-read position (called from SyncManager on app
  /// start) and adopts it locally unless the local one is already the same
  /// position or further along — so switching devices doesn't silently
  /// discard progress this device already made but hasn't pushed yet.
  Future<void> syncFromRemote() async {
    try {
      final remote = await _ref
          .read(supabaseServiceProvider)
          .getQuranLastRead();
      if (remote == null) return;
      final remoteSavedAt = DateTime.tryParse(
        remote['saved_at']?.toString() ?? '',
      );
      final local = state;
      if (local?.savedAt != null &&
          remoteSavedAt != null &&
          !remoteSavedAt.isAfter(local!.savedAt!)) {
        return;
      }
      final bookmark = QuranBookmark(
        surahNum: remote['surah_num'] as int,
        ayahNum: remote['ayah_num'] as int,
        page: remote['page'] as int,
        surahName: remote['surah_name'] as String,
        savedAt: remoteSavedAt,
      );
      state = bookmark;
      await _repo.setLastRead(bookmark);
    } catch (e) {
      developer.log(
        'Failed to sync remote quran last-read: $e',
        name: 'QuranProviders',
      );
    }
  }
}

final quranBookmarksProvider =
    StateNotifierProvider<_BookmarksNotifier, List<QuranBookmark>>(
      (ref) => _BookmarksNotifier(ref, ref.watch(quranPrefsRepositoryProvider)),
    );

class _BookmarksNotifier extends StateNotifier<List<QuranBookmark>> {
  _BookmarksNotifier(this._ref, this._repo) : super(_repo.getBookmarks());

  final Ref _ref;
  final QuranPrefsRepository _repo;

  Future<void> add(QuranBookmark b) async {
    if (state.any((x) => x.surahNum == b.surahNum && x.ayahNum == b.ayahNum)) {
      return;
    }
    state = [...state, b];
    await _repo.setBookmarks(state);
    try {
      await _ref.read(supabaseServiceProvider).upsertQuranBookmark({
        'surah_num': b.surahNum,
        'ayah_num': b.ayahNum,
        'page': b.page,
        'surah_name': b.surahName,
        'saved_at': (b.savedAt ?? DateTime.now()).toIso8601String(),
      });
    } catch (e) {
      developer.log(
        'Offline quran bookmark sync skipped: $e',
        name: 'QuranProviders',
      );
    }
  }

  Future<void> remove(int surah, int ayah) async {
    state = state
        .where((x) => !(x.surahNum == surah && x.ayahNum == ayah))
        .toList();
    await _repo.setBookmarks(state);
    try {
      await _ref.read(supabaseServiceProvider).deleteQuranBookmark(surah, ayah);
    } catch (e) {
      developer.log(
        'Offline quran bookmark delete sync skipped: $e',
        name: 'QuranProviders',
      );
    }
  }

  /// Pulls remote bookmarks (called from SyncManager) and merges them into
  /// local storage — additive only: a bookmark saved on another device is
  /// added here, but nothing already local is ever removed by a pull.
  Future<void> syncFromRemote() async {
    try {
      final remote = await _ref
          .read(supabaseServiceProvider)
          .getQuranBookmarks();
      if (remote.isEmpty) return;
      final merged = [...state];
      for (final r in remote) {
        final surahNum = r['surah_num'] as int;
        final ayahNum = r['ayah_num'] as int;
        if (merged.any(
          (x) => x.surahNum == surahNum && x.ayahNum == ayahNum,
        )) {
          continue;
        }
        merged.add(
          QuranBookmark(
            surahNum: surahNum,
            ayahNum: ayahNum,
            page: r['page'] as int,
            surahName: r['surah_name'] as String,
            savedAt: DateTime.tryParse(r['saved_at']?.toString() ?? ''),
          ),
        );
      }
      if (merged.length != state.length) {
        state = merged;
        await _repo.setBookmarks(state);
      }
    } catch (e) {
      developer.log(
        'Failed to sync remote quran bookmarks: $e',
        name: 'QuranProviders',
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────
// Khatma Notifier (extended)
// ─────────────────────────────────────────────────────────────
final khatmaExProvider =
    StateNotifierProvider<KhatmaExNotifier, KhatmaSessionEx?>(
      (ref) => KhatmaExNotifier(ref, ref.watch(quranPrefsRepositoryProvider)),
    );

class KhatmaExNotifier extends StateNotifier<KhatmaSessionEx?> {
  KhatmaExNotifier(this._ref, this._repo) : super(_repo.getActiveKhatma());

  final Ref _ref;
  final QuranPrefsRepository _repo;

  Future<void> _pushToRemote(KhatmaSessionEx session) async {
    try {
      await _ref.read(supabaseServiceProvider).upsertKhatmaSession({
        'id': session.id,
        'label': session.label,
        'type': session.type.name,
        'start_date': session.startDate.toIso8601String(),
        'end_date': session.endDate?.toIso8601String(),
        'completed_date': session.completedDate?.toIso8601String(),
        'cancelled_date': session.cancelledDate?.toIso8601String(),
        'start_page': session.startPage,
        'current_page': session.currentPage,
        'pages_read': session.pagesRead,
        'notifications_enabled': session.notificationsEnabled,
        'daily_pages': session.dailyPages,
        'total_reading_seconds': session.totalReadingSeconds,
        'reading_sessions_count': session.readingSessionsCount,
      });
    } catch (e) {
      developer.log(
        'Offline khatma session sync skipped: $e',
        name: 'QuranProviders',
      );
    }
  }

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
    await _pushToRemote(session);
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
    await _pushToRemote(updated);
  }

  Future<void> cancel() async {
    if (state == null) return;
    final cancelled = state!.copyWith(cancelledDate: DateTime.now());
    await _repo.archiveKhatma(cancelled);
    state = null;
    await _repo.clearActiveKhatma();
    await _pushToRemote(cancelled);
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
    await _pushToRemote(finished);
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
    await _pushToRemote(updated);
  }

  /// Pulls remote Khatma sessions (called from SyncManager on app start).
  /// A finished/cancelled remote session is merged straight into local
  /// history (archiveKhatma is already an upsert-by-id). A remote *active*
  /// session is only adopted when there's no local active session, or it's
  /// the same session further along than what's stored locally — never
  /// overwrites a different, still-active local session with a stale or
  /// unrelated remote one.
  Future<void> syncFromRemote() async {
    try {
      final rows = await _ref.read(supabaseServiceProvider).getKhatmaSessions();
      if (rows.isEmpty) return;
      for (final r in rows) {
        final session = KhatmaSessionEx(
          id: r['id'] as String,
          label: r['label'] as String? ?? 'ختمة',
          type: KhatmaType.values.firstWhere(
            (t) => t.name == r['type'],
            orElse: () => KhatmaType.muyassara,
          ),
          startDate:
              DateTime.tryParse(r['start_date']?.toString() ?? '') ??
              DateTime.now(),
          endDate: r['end_date'] != null
              ? DateTime.tryParse(r['end_date'].toString())
              : null,
          completedDate: r['completed_date'] != null
              ? DateTime.tryParse(r['completed_date'].toString())
              : null,
          cancelledDate: r['cancelled_date'] != null
              ? DateTime.tryParse(r['cancelled_date'].toString())
              : null,
          startPage: r['start_page'] as int? ?? 1,
          currentPage: r['current_page'] as int? ?? 1,
          pagesRead: r['pages_read'] as int? ?? 0,
          notificationsEnabled: r['notifications_enabled'] as bool? ?? false,
          dailyPages: r['daily_pages'] as int?,
          totalReadingSeconds: r['total_reading_seconds'] as int? ?? 0,
          readingSessionsCount: r['reading_sessions_count'] as int? ?? 0,
        );

        if (!session.isActive) {
          await _repo.archiveKhatma(session);
          continue;
        }
        final local = state;
        final shouldAdopt =
            local == null ||
            (local.id == session.id && session.pagesRead > local.pagesRead);
        if (shouldAdopt) {
          state = session;
          await _repo.setActiveKhatma(session);
        }
      }
    } catch (e) {
      developer.log(
        'Failed to sync remote khatma sessions: $e',
        name: 'QuranProviders',
      );
    }
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
// Bumped by the verse card's "refresh" button to pick a new random verse
// on demand. dailyVerseProvider is a plain Provider that Riverpod caches
// after the first read, so without depending on something that actually
// changes, tapping refresh (previously just a bare setState()) rebuilt the
// screen but kept returning the exact same cached verse.
final dailyVerseRefreshProvider = StateProvider<int>((ref) => 0);

final dailyVerseProvider = Provider<Map<String, dynamic>>((ref) {
  final refreshNonce = ref.watch(dailyVerseRefreshProvider);
  final surahs = ql.QuranLibrary.quranCtrl.surahs;
  final now = DateTime.now();
  final seed = now.year * 1000 + now.month * 30 + now.day + refreshNonce;
  final rng = Random(seed);
  final surahIdx = rng.nextInt(surahs.length);
  final surah = surahs[surahIdx];
  final ayahIdx = rng.nextInt(surah.ayahs.length);
  final ayah = surah.ayahs[ayahIdx];
  return {
    'surahName': surah.arabicName,
    'surahNumber': surahIdx + 1,
    'ayahNumber': ayah.ayahNumber,
    'text': ayah.text,
    // Included so the "»»" navigation and share button can jump straight
    // to this exact ayah instead of only the start of its surah.
    'page': ayah.page,
    'ayahUQNumber': ayah.ayahUQNumber,
  };
});
