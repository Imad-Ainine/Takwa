// ═══════════════════════════════════════════════════════════════
//  lib/features/quran/data/quran_models.dart
// ═══════════════════════════════════════════════════════════════

enum ReaderMode { reading, tahajjud, tafseer, translation }
enum ReaderTheme { night, sepia, white }

class QuranReadingState {
  final int currentSurah;
  final int currentAyah;
  final int currentPage;
  final ReaderMode mode;
  final ReaderTheme theme;
  final double fontSize;
  final bool isPlaying;
  final int playingAyah;
  final double playbackSpeed;
  final bool showToolbar;

  const QuranReadingState({
    this.currentSurah = 1,
    this.currentAyah = 1,
    this.currentPage = 1,
    this.mode = ReaderMode.reading,
    this.theme = ReaderTheme.night,
    this.fontSize = 24.0,
    this.isPlaying = false,
    this.playingAyah = -1,
    this.playbackSpeed = 1.0,
    this.showToolbar = true,
  });

  QuranReadingState copyWith({
    int? currentSurah,
    int? currentAyah,
    int? currentPage,
    ReaderMode? mode,
    ReaderTheme? theme,
    double? fontSize,
    bool? isPlaying,
    int? playingAyah,
    double? playbackSpeed,
    bool? showToolbar,
  }) => QuranReadingState(
    currentSurah: currentSurah ?? this.currentSurah,
    currentAyah: currentAyah ?? this.currentAyah,
    currentPage: currentPage ?? this.currentPage,
    mode: mode ?? this.mode,
    theme: theme ?? this.theme,
    fontSize: fontSize ?? this.fontSize,
    isPlaying: isPlaying ?? this.isPlaying,
    playingAyah: playingAyah ?? this.playingAyah,
    playbackSpeed: playbackSpeed ?? this.playbackSpeed,
    showToolbar: showToolbar ?? this.showToolbar,
  );
}

class QuranAudioState {
  final bool isPlaying, isLoading;
  final int surah, ayah;
  final double speed;
  const QuranAudioState({
    this.isPlaying = false,
    this.isLoading = false,
    this.surah = 1,
    this.ayah = 1,
    this.speed = 1.0,
  });
  QuranAudioState copyWith({
    bool? isPlaying,
    bool? isLoading,
    int? surah,
    int? ayah,
    double? speed,
  }) => QuranAudioState(
    isPlaying: isPlaying ?? this.isPlaying,
    isLoading: isLoading ?? this.isLoading,
    surah: surah ?? this.surah,
    ayah: ayah ?? this.ayah,
    speed: speed ?? this.speed,
  );
}
