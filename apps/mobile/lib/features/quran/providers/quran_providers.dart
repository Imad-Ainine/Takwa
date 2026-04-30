
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
    final surahs = ql.QuranLibrary.quranCtrl.surahsList;
    for (int i = 0; i < surah - 1 && i < surahs.length; i++) {
      abs += surahs[i].ayahsNumber;
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

  Future<void> clear() async {
    state = null;
    final p = await SharedPreferences.getInstance();
    await p.remove('q_last_read');
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
// Khatma Type
// ─────────────────────────────────────────────────────────────
enum KhatmaType { muyassara, multazima }

// ─────────────────────────────────────────────────────────────
// Extended KhatmaSession with type
// ─────────────────────────────────────────────────────────────
class KhatmaSessionEx {
  final String id;
  final String label;
  final KhatmaType type;
  final DateTime startDate;
  final DateTime? endDate; // target end date for multazima
  final DateTime? completedDate;
  final DateTime? cancelledDate;
  final int startPage;
  final int currentPage;
  final int pagesRead;
  final bool notificationsEnabled;
  final int? dailyPages; // for multazima
  static const int totalPages = 604;

  const KhatmaSessionEx({
    required this.id,
    required this.label,
    required this.type,
    required this.startDate,
    this.endDate,
    this.completedDate,
    this.cancelledDate,
    this.startPage = 1,
    this.currentPage = 1,
    this.pagesRead = 0,
    this.notificationsEnabled = false,
    this.dailyPages,
  });

  double get progress => pagesRead / totalPages;
  bool get isCompleted => completedDate != null || pagesRead >= totalPages;
  bool get isCancelled => cancelledDate != null;
  bool get isActive => !isCompleted && !isCancelled;

  KhatmaSessionEx copyWith({
    int? currentPage,
    int? pagesRead,
    DateTime? completedDate,
    DateTime? cancelledDate,
    String? label,
  }) => KhatmaSessionEx(
    id: id,
    label: label ?? this.label,
    type: type,
    startDate: startDate,
    endDate: endDate,
    completedDate: completedDate ?? this.completedDate,
    cancelledDate: cancelledDate ?? this.cancelledDate,
    startPage: startPage,
    currentPage: currentPage ?? this.currentPage,
    pagesRead: pagesRead ?? this.pagesRead,
    notificationsEnabled: notificationsEnabled,
    dailyPages: dailyPages,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'type': type.name,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'completedDate': completedDate?.toIso8601String(),
    'cancelledDate': cancelledDate?.toIso8601String(),
    'startPage': startPage,
    'currentPage': currentPage,
    'pagesRead': pagesRead,
    'notificationsEnabled': notificationsEnabled,
    'dailyPages': dailyPages,
  };

  factory KhatmaSessionEx.fromJson(Map<String, dynamic> j) => KhatmaSessionEx(
    id: j['id'] as String,
    label: j['label'] as String? ?? 'ختمة',
    type: KhatmaType.values.firstWhere(
      (t) => t.name == j['type'],
      orElse: () => KhatmaType.muyassara,
    ),
    startDate: DateTime.parse(j['startDate'].toString()),
    endDate: j['endDate'] != null
        ? DateTime.tryParse(j['endDate'].toString())
        : null,
    completedDate: j['completedDate'] != null
        ? DateTime.tryParse(j['completedDate'].toString())
        : null,
    cancelledDate: j['cancelledDate'] != null
        ? DateTime.tryParse(j['cancelledDate'].toString())
        : null,
    startPage: j['startPage'] as int? ?? 1,
    currentPage: j['currentPage'] as int? ?? 1,
    pagesRead: j['pagesRead'] as int? ?? 0,
    notificationsEnabled: j['notificationsEnabled'] as bool? ?? false,
    dailyPages: j['dailyPages'] as int?,
  );
}

// ─────────────────────────────────────────────────────────────
// Khatma Notifier (extended)
// ─────────────────────────────────────────────────────────────
final khatmaExProvider =
    StateNotifierProvider<KhatmaExNotifier, KhatmaSessionEx?>(
      (ref) => KhatmaExNotifier(),
    );

class KhatmaExNotifier extends StateNotifier<KhatmaSessionEx?> {
  KhatmaExNotifier() : super(null) {
    _load();
  }

  static const _activeKey = 'khatma_ex_active';
  static const _historyKey = 'khatma_ex_history';

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_activeKey);
    if (raw != null) {
      try {
        state = KhatmaSessionEx.fromJson(jsonDecode(raw));
      } catch (_) {}
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
    if (state != null && state!.isActive) await _archive(state!);
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
    await _persist();
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
    await _persist();
    if (updated.isCompleted) await _archive(updated);
  }

  Future<void> cancel() async {
    if (state == null) return;
    final cancelled = state!.copyWith(cancelledDate: DateTime.now());
    await _archive(cancelled);
    state = null;
    final p = await SharedPreferences.getInstance();
    await p.remove(_activeKey);
  }

  Future<void> _persist() async {
    if (state == null) return;
    final p = await SharedPreferences.getInstance();
    await p.setString(_activeKey, jsonEncode(state!.toJson()));
  }

  Future<void> _archive(KhatmaSessionEx s) async {
    final p = await SharedPreferences.getInstance();
    final list = p.getStringList(_historyKey) ?? [];
    list.removeWhere((item) {
      try {
        final m = jsonDecode(item) as Map;
        return m['id'] == s.id;
      } catch (_) {
        return false;
      }
    });
    list.add(jsonEncode(s.toJson()));
    await p.setStringList(_historyKey, list);
  }
}

// History providers
final khatmaCompletedProvider = FutureProvider<List<KhatmaSessionEx>>((
  ref,
) async {
  final p = await SharedPreferences.getInstance();
  final list = p.getStringList('khatma_ex_history') ?? [];
  return list
      .map((s) => KhatmaSessionEx.fromJson(jsonDecode(s)))
      .where((s) => s.isCompleted)
      .toList()
      .reversed
      .toList();
});

final khatmaCancelledProvider = FutureProvider<List<KhatmaSessionEx>>((
  ref,
) async {
  final p = await SharedPreferences.getInstance();
  final list = p.getStringList('khatma_ex_history') ?? [];
  return list
      .map((s) => KhatmaSessionEx.fromJson(jsonDecode(s)))
      .where((s) => s.isCancelled)
      .toList()
      .reversed
      .toList();
});

// Legacy compatibility
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
      try {
        state = KhatmaSession.fromJson(jsonDecode(raw));
      } catch (_) {}
    }
  }

  Future<void> startNew({String label = 'ختمة جديدة'}) async {
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
