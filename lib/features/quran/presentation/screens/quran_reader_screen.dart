// ═══════════════════════════════════════════════════════════════
//  lib/features/quran/presentation/screens/quran_reader_screen.dart
//  Page-based Quran Reader — dark green theme
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_library/quran_library.dart' as ql;
import 'package:takwa/core/widgets/custom_leading_button.dart';
import '../../data/quran_data.dart';
import '../../data/quran_models.dart';
import '../../providers/quran_providers.dart';
import '../../utils/quran_helpers.dart';

// ─────────────────────────────────────────────────────────────
class QuranReaderScreen extends ConsumerStatefulWidget {
  /// When true the reader advances the active Khatma session as pages turn.
  final bool startFromKhatma;

  /// Jump directly to this surah's start page (free-reading mode).
  final int? initialSurah;

  const QuranReaderScreen({
    super.key,
    this.startFromKhatma = false,
    this.initialSurah,
  });

  @override
  ConsumerState<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends ConsumerState<QuranReaderScreen>
    with TickerProviderStateMixin {
  late PageController _pageCtrl;
  late AnimationController _toolbarAnim;
  late Animation<double> _toolbarFade;
  late Animation<Offset> _topSlide;
  late Animation<Offset> _bottomSlide;

  int _currentPage = 1;
  bool _toolbarVisible = true;
  static const int _totalPages = 604;

  // ── Lifecycle ─────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    // Determine start page
    int startPage = ref
        .read(quranStateProvider)
        .currentPage
        .clamp(1, _totalPages);
    if (widget.initialSurah != null) {
      final si = (widget.initialSurah! - 1).clamp(0, kSurahData.length - 1);
      startPage = kSurahData[si].startPage;
    }
    _currentPage = startPage;

    // Toolbar animation
    _toolbarAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 270),
      value: 1.0,
    );
    _toolbarFade = _toolbarAnim;
    _topSlide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _toolbarAnim, curve: Curves.easeOut));
    _bottomSlide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _toolbarAnim, curve: Curves.easeOut));

    // Page controller — start at correct page (0-indexed)
    _pageCtrl = PageController(initialPage: _currentPage - 1);
    _pageCtrl.addListener(_onPageChange);
  }

  @override
  void dispose() {
    _pageCtrl
      ..removeListener(_onPageChange)
      ..dispose();
    _toolbarAnim.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────
  /// Returns 1-based surah number for a given Mushaf page.
  int _surahForPage(int page) {
    for (int i = kSurahData.length - 1; i >= 0; i--) {
      if (page >= kSurahData[i].startPage) return i + 1;
    }
    return 1;
  }

  void _onPageChange() {
    final p = (_pageCtrl.page?.round() ?? 0) + 1;
    if (p == _currentPage || p < 1 || p > _totalPages) return;
    setState(() => _currentPage = p);
    ref.read(quranStateProvider.notifier).setPage(p);
    if (widget.startFromKhatma) {
      ref.read(khatmaProvider.notifier).advancePage(p);
    }
    // Persist last-read bookmark
    final surahNum = _surahForPage(p);
    ref
        .read(quranLastReadProvider.notifier)
        .save(
          QuranBookmark(
            surahNum: surahNum,
            ayahNum: 1,
            page: p,
            surahName:
                ql.QuranLibrary.quranCtrl.surahs[surahNum - 1].arabicName,
            savedAt: DateTime.now(),
          ),
        );
  }

  void _toggleToolbar() {
    setState(() => _toolbarVisible = !_toolbarVisible);
    _toolbarVisible ? _toolbarAnim.forward() : _toolbarAnim.reverse();
  }

  // ── Build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quranStateProvider);
    final audio = ref.watch(quranAudioProvider);
    final juz = pageToJuz(_currentPage);
    final surahIdx = _surahForPage(_currentPage) - 1;
    final surahName = ql.QuranLibrary.quranCtrl.surahs[surahIdx].arabicName;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Stack(
          children: [
            // ── 1. Page viewer  ──────────────────────────────────
            // FIX: Listener wraps PageView so taps toggle toolbar
            //      without blocking horizontal swipe gestures.
            Listener(
              onPointerUp: (_) {
                // Only count very short taps (no drag), toggle toolbar
                // We use a simple flag approach via the page scroll callback.
              },
              child: GestureDetector(
                // onTap only fires when user taps in place (no swipe)
                onTap: _toggleToolbar,
                // Pass horizontal drags through to PageView
                behavior: HitTestBehavior.translucent,
                child: PageView.builder(
                  controller: _pageCtrl,
                  // Arabic Mushaf: swipe LEFT reveals the NEXT page
                  // (higher page number is "to the left" in RTL)
                  reverse: false,
                  itemCount: _totalPages,
                  itemBuilder: (_, i) => _PageContent(
                    page: i + 1,
                    state: state,
                    surahForPage: _surahForPage,
                    onAyahTap: (surah, ayah) => ref
                        .read(quranAudioProvider.notifier)
                        .togglePlay(surah, ayah),
                    audio: audio,
                  ),
                ),
              ),
            ),

            // ── 2. Top toolbar (FIX: Positioned is direct Stack child) ──
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SlideTransition(
                position: _topSlide,
                child: FadeTransition(
                  opacity: _toolbarFade,
                  child: _TopBar(
                    surahName: surahName,
                    onBack: () => Navigator.pop(context),
                    onSettings: _showSettings,
                  ),
                ),
              ),
            ),

            // ── 3. Bottom bar (FIX: Positioned is direct Stack child) ──
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SlideTransition(
                position: _bottomSlide,
                child: FadeTransition(
                  opacity: _toolbarFade,
                  child: _BottomBar(
                    juz: juz,
                    currentPage: _currentPage,
                    surahName: surahName,
                    surahNum: surahIdx + 1,
                    audio: audio,
                    state: state,
                    onTogglePlay: () => ref
                        .read(quranAudioProvider.notifier)
                        .togglePlay(surahIdx + 1, state.currentAyah),
                    onStop: () => ref.read(quranAudioProvider.notifier).stop(),
                    onSpeedTap: () {
                      const speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
                      final idx = speeds.indexOf(audio.speed);
                      ref
                          .read(quranAudioProvider.notifier)
                          .setSpeed(speeds[(idx + 1) % speeds.length]);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Settings sheet ─────────────────────────────────────────────
  void _showSettings() {
    final state = ref.read(quranStateProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _SettingsSheet(
        fontSize: state.fontSize,
        theme: state.theme,
        onFontSizeChanged: (v) =>
            ref.read(quranStateProvider.notifier).setFontSize(v),
        onThemeChanged: (t) =>
            ref.read(quranStateProvider.notifier).setTheme(t),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════
// Page content — extracted widget so PageView can re-use efficiently
// ═════════════════════════════════════════════════════════════════
class _PageContent extends StatelessWidget {
  final int page;
  final QuranReadingState state;
  final QuranAudioState audio;
  final int Function(int) surahForPage;
  final void Function(int surah, int ayah) onAyahTap;

  const _PageContent({
    required this.page,
    required this.state,
    required this.audio,
    required this.surahForPage,
    required this.onAyahTap,
  });

  @override
  Widget build(BuildContext context) {
    final surahIdx = surahForPage(page) - 1;
    final surah = ql.QuranLibrary.quranCtrl.surahs[surahIdx];
    final isSurahStart = kSurahData[surahIdx].startPage == page;

    return Padding(
      padding: const EdgeInsets.only(top: 76, bottom: 108),
      child: SingleChildScrollView(
        child: Column(
          children: [
            if (isSurahStart) _SurahHeader(name: surah.arabicName),
            if (isSurahStart && surahIdx != 8) // no basmala for At-Tawbah
              const _Basmala(),
            _AyahBlock(
              surahNum: surahIdx + 1,
              surah: surah,
              fontSize: state.fontSize,
              audio: audio,
              onAyahTap: onAyahTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _SurahHeader extends StatelessWidget {
  final String name;
  const _SurahHeader({required this.name});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(24, 8, 24, 8),
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF1A6040), Color(0xFF0D3A26)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: kGoldChip.withOpacity(0.5), width: 1.4),
    ),
    child: Center(
      child: Text(
        'سورة $name',
        style: GoogleFonts.amiri(
          fontSize: 20,
          color: kGoldChip,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

class _Basmala extends StatelessWidget {
  const _Basmala();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Text(
      'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ',
      textAlign: TextAlign.center,
      style: GoogleFonts.amiriQuran(
        fontSize: 22,
        color: Colors.white,
        height: 2,
      ),
    ),
  );
}

class _AyahBlock extends StatelessWidget {
  final int surahNum;
  final dynamic surah; // ql.Surah
  final double fontSize;
  final QuranAudioState audio;
  final void Function(int, int) onAyahTap;

  const _AyahBlock({
    required this.surahNum,
    required this.surah,
    required this.fontSize,
    required this.audio,
    required this.onAyahTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text.rich(
        TextSpan(
          children: (surah.ayahs as List).map<InlineSpan>((a) {
            final isPlaying =
                audio.isPlaying &&
                audio.surah == surahNum &&
                audio.ayah == (a.ayahNumber as int);
            return TextSpan(
              children: [
                TextSpan(
                  text: '${a.text} ',
                  style: GoogleFonts.amiriQuran(
                    fontSize: fontSize,
                    color: isPlaying ? kGoldChip : Colors.white,
                    height: 1.9,
                  ),
                ),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () => onAyahTap(surahNum, a.ayahNumber as int),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isPlaying ? kGoldChip : Colors.white30,
                        ),
                        color: isPlaying
                            ? kGoldChip.withOpacity(0.2)
                            : Colors.transparent,
                      ),
                      child: Text(
                        ar(a.ayahNumber as int),
                        style: GoogleFonts.amiri(
                          fontSize: 11,
                          color: isPlaying ? kGoldChip : Colors.white54,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════
// Top bar widget
// ═════════════════════════════════════════════════════════════════
class _TopBar extends StatelessWidget {
  final String surahName;
  final VoidCallback onBack;
  final VoidCallback onSettings;

  const _TopBar({
    required this.surahName,
    required this.onBack,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xDD0A3020), Colors.transparent],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 18),
          child: Row(
            children: [
              _BarIcon(Icons.wb_sunny_outlined, onSettings),
              _BarIcon(Icons.headphones_rounded, () {}),
              _BarIcon(Icons.menu_book_outlined, () {}),
              _BarIcon(Icons.history_rounded, () {}),
              const Spacer(),
              Text(
                'سورة $surahName',
                style: GoogleFonts.amiri(
                  fontSize: 17,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              const CustomLeadingButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _BarIcon(this.icon, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: Icon(icon, color: Colors.white70, size: 22),
    ),
  );
}

// ═════════════════════════════════════════════════════════════════
// Bottom bar widget
// ═════════════════════════════════════════════════════════════════
class _BottomBar extends StatelessWidget {
  final int juz;
  final int currentPage;
  final String surahName;
  final int surahNum;
  final QuranAudioState audio;
  final QuranReadingState state;
  final VoidCallback onTogglePlay;
  final VoidCallback onStop;
  final VoidCallback onSpeedTap;

  const _BottomBar({
    required this.juz,
    required this.currentPage,
    required this.surahName,
    required this.surahNum,
    required this.audio,
    required this.state,
    required this.onTogglePlay,
    required this.onStop,
    required this.onSpeedTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0xEF082018), Colors.transparent],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Chip('جزء: ${ar(juz)}'),
                  _Chip('صفحة: ${ar(currentPage)} / ${ar(604)}'),
                  _Chip('سورة: $surahName'),
                ],
              ),
              const SizedBox(height: 10),
              // Audio row
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    // Play/pause button
                    GestureDetector(
                      onTap: onTogglePlay,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: kGoldChip,
                        ),
                        child: Icon(
                          audio.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow_rounded,
                          color: const Color(0xFF0C3426),
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$surahName: ${ar(state.currentAyah)}',
                        style: GoogleFonts.amiri(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Speed chip
                    GestureDetector(
                      onTap: onSpeedTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white24),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${audio.speed}x',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Stop
                    GestureDetector(
                      onTap: onStop,
                      child: const Icon(
                        Icons.stop_rounded,
                        color: Colors.white38,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  const _Chip(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: GoogleFonts.outfit(fontSize: 11, color: Colors.white54),
  );
}

// ═════════════════════════════════════════════════════════════════
// Settings Sheet
// ═════════════════════════════════════════════════════════════════
class _SettingsSheet extends StatelessWidget {
  final double fontSize;
  final ReaderTheme theme;
  final ValueChanged<double> onFontSizeChanged;
  final ValueChanged<ReaderTheme> onThemeChanged;

  const _SettingsSheet({
    required this.fontSize,
    required this.theme,
    required this.onFontSizeChanged,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
      decoration: const BoxDecoration(
        color: Color(0xFF0D3A26),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'إعدادات القراءة',
            style: GoogleFonts.amiri(
              fontSize: 22,
              color: kGoldChip,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'حجم الخط',
            style: GoogleFonts.outfit(color: Colors.white60, fontSize: 13),
          ),
          StatefulBuilder(
            builder: (_, set) => Slider(
              value: fontSize,
              min: 14,
              max: 34,
              activeColor: kGoldChip,
              inactiveColor: Colors.white12,
              onChanged: (v) {
                onFontSizeChanged(v);
                set(() {});
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'نمط الخلفية',
            style: GoogleFonts.outfit(color: Colors.white60, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: ReaderTheme.values.map((t) {
              const labels = {
                'night': 'ليلي',
                'sepia': 'عاجي',
                'white': 'فاتح',
              };
              final selected = theme == t;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onThemeChanged(t),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: selected ? kGoldChip : Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        labels[t.name] ?? t.name,
                        style: TextStyle(
                          color: selected
                              ? const Color(0xFF0D3A26)
                              : Colors.white54,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
