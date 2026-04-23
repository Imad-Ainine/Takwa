// ═══════════════════════════════════════════════════════════════
//  lib/features/quran/presentation/screens/quran_reader_screen.dart
//  Page-based Quran Reader — matches reference screenshots 14-15
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_library/quran_library.dart' as ql;
import '../../data/quran_data.dart';
import '../../data/quran_models.dart';
import '../../providers/quran_providers.dart';
import '../../utils/quran_helpers.dart';

const _kBgDark = Color(0xFF0D1E2D);
const _kBgGreen = Color(0xFF0A2818);
const _kGold = Color(0xFFC8A96E);
const _kGreenHeader = Color(0xFF1A5234);
const _kBorder = Color(0xFF1E3040);

class QuranReaderScreen extends ConsumerStatefulWidget {
  final bool startFromKhatma;
  final int? initialSurah;
  final int? initialPage;

  const QuranReaderScreen({
    super.key,
    this.startFromKhatma = false,
    this.initialSurah,
    this.initialPage,
  });

  @override
  ConsumerState<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends ConsumerState<QuranReaderScreen>
    with TickerProviderStateMixin {
  late PageController _pageCtrl;
  late AnimationController _toolbarAnim;
  late Animation<double> _topFade;
  late Animation<Offset> _topSlide, _bottomSlide;

  int _currentPage = 1;
  bool _toolbarVisible = true;
  static const int _totalPages = 604;

  @override
  void initState() {
    super.initState();
    // Determine initial page
    int startPage = 1;
    if (widget.initialPage != null) {
      startPage = widget.initialPage!.clamp(1, _totalPages);
    } else if (widget.initialSurah != null) {
      final idx = (widget.initialSurah! - 1).clamp(0, kSurahData.length - 1);
      startPage = kSurahData[idx].startPage;
    } else {
      startPage = ref
          .read(quranStateProvider)
          .currentPage
          .clamp(1, _totalPages);
    }
    _currentPage = startPage;

    _toolbarAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      value: 1.0,
    );
    _topFade = _toolbarAnim;
    _topSlide = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _toolbarAnim, curve: Curves.easeOutCubic),
        );
    _bottomSlide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _toolbarAnim, curve: Curves.easeOutCubic),
        );

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
      ref.read(khatmaExProvider.notifier).advancePage(p);
    }

    // Save last read
    final surahNum = _surahForPage(p);
    final surahName = ql.QuranLibrary.quranCtrl.surahs[surahNum - 1].arabicName;
    ref
        .read(quranLastReadProvider.notifier)
        .save(
          QuranBookmark(
            surahNum: surahNum,
            ayahNum: 1,
            page: p,
            surahName: surahName,
            savedAt: DateTime.now(),
          ),
        );
  }

  void _toggleToolbar() {
    setState(() => _toolbarVisible = !_toolbarVisible);
    _toolbarVisible ? _toolbarAnim.forward() : _toolbarAnim.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quranStateProvider);
    final audio = ref.watch(quranAudioProvider);
    final juz = pageToJuz(_currentPage);
    final surahNum = _surahForPage(_currentPage);
    final surahName = ql.QuranLibrary.quranCtrl.surahs[surahNum - 1].arabicName;

    // Determine background color based on theme
    final bgColor = state.theme == ReaderTheme.white
        ? Colors.white
        : state.theme == ReaderTheme.sepia
        ? const Color(0xFFF4ECD8)
        : _kBgDark;

    final textColor = state.theme == ReaderTheme.white
        ? Colors.black87
        : state.theme == ReaderTheme.sepia
        ? const Color(0xFF3A2810)
        : Colors.white;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: state.theme == ReaderTheme.white
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: bgColor,
        body: Stack(
          children: [
            // ── Page Viewer ──────────────────────────
            GestureDetector(
              onTap: _toggleToolbar,
              behavior: HitTestBehavior.opaque,
              child: PageView.builder(
                controller: _pageCtrl,
                itemCount: _totalPages,
                itemBuilder: (_, i) => _QuranPageView(
                  page: i + 1,
                  surahForPage: _surahForPage,
                  fontSize: state.fontSize,
                  textColor: textColor,
                  bgColor: bgColor,
                  audio: audio,
                  onAyahTap: (s, a) =>
                      ref.read(quranAudioProvider.notifier).togglePlay(s, a),
                ),
              ),
            ),

            // ── Top Bar ──────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SlideTransition(
                position: _topSlide,
                child: FadeTransition(
                  opacity: _topFade,
                  child: _TopBar(
                    surahName: surahName,
                    onBack: () => Navigator.pop(context),
                    onSettings: _showSettings,
                    theme: state.theme,
                  ),
                ),
              ),
            ),

            // ── Bottom Bar ───────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SlideTransition(
                position: _bottomSlide,
                child: FadeTransition(
                  opacity: _topFade,
                  child: _BottomBar(
                    juz: juz,
                    currentPage: _currentPage,
                    surahName: surahName,
                    audio: audio,
                    onTogglePlay: () => ref
                        .read(quranAudioProvider.notifier)
                        .togglePlay(surahNum, 1),
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

// ─────────────────────────────────────────────────────────────
// QURAN PAGE VIEW
// ─────────────────────────────────────────────────────────────
class _QuranPageView extends StatelessWidget {
  final int page;
  final int Function(int) surahForPage;
  final double fontSize;
  final Color textColor, bgColor;
  final QuranAudioState audio;
  final void Function(int, int) onAyahTap;

  const _QuranPageView({
    required this.page,
    required this.surahForPage,
    required this.fontSize,
    required this.textColor,
    required this.bgColor,
    required this.audio,
    required this.onAyahTap,
  });

  @override
  Widget build(BuildContext context) {
    final surahNum = surahForPage(page);
    final surahIdx = surahNum - 1;
    final surahs = ql.QuranLibrary.quranCtrl.surahs;
    if (surahIdx >= surahs.length) return const SizedBox();
    final surah = surahs[surahIdx];
    final isSurahStart = kSurahData[surahIdx].startPage == page;
    final noBasmala = surahIdx == 8; // At-Tawbah

    // For single-surah pages (like Fatiha), show all ayahs
    // For multi-surah pages, show content proportionally
    return Container(
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.only(top: 80, bottom: 90),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              if (isSurahStart) _SurahHeaderWidget(surahName: surah.arabicName),
              if (isSurahStart && !noBasmala)
                _BasmalaWidget(textColor: textColor),
              const SizedBox(height: 12),
              _AyahTextWidget(
                surahNum: surahNum,
                surah: surah,
                fontSize: fontSize,
                textColor: textColor,
                audio: audio,
                onAyahTap: onAyahTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SurahHeaderWidget extends StatelessWidget {
  final String surahName;
  const _SurahHeaderWidget({required this.surahName});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 8, 24, 12),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A6040), Color(0xFF0D3A26)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kGold.withOpacity(0.5), width: 1.4),
      ),
      child: Center(
        child: Text(
          'سورة $surahName',
          style: const TextStyle(
            fontFamily: 'Amiri',
            fontSize: 22,
            color: _kGold,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _BasmalaWidget extends StatelessWidget {
  final Color textColor;
  const _BasmalaWidget({required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: Text(
        'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Amiri',
          fontSize: 22,
          color: textColor,
          height: 2.0,
        ),
      ),
    );
  }
}

class _AyahTextWidget extends StatelessWidget {
  final int surahNum;
  final dynamic surah;
  final double fontSize;
  final Color textColor;
  final QuranAudioState audio;
  final void Function(int, int) onAyahTap;

  const _AyahTextWidget({
    required this.surahNum,
    required this.surah,
    required this.fontSize,
    required this.textColor,
    required this.audio,
    required this.onAyahTap,
  });

  @override
  Widget build(BuildContext context) {
    final ayahs = surah.ayahs as List;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text.rich(
        TextSpan(
          children: ayahs.map<InlineSpan>((a) {
            final ayahNum = a.ayahNumber as int;
            final isPlaying =
                audio.isPlaying &&
                audio.surah == surahNum &&
                audio.ayah == ayahNum;

            return TextSpan(
              children: [
                TextSpan(
                  text: '${a.text} ',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: fontSize,
                    color: isPlaying ? _kGold : textColor,
                    height: 2.0,
                  ),
                ),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () => onAyahTap(surahNum, ayahNum),
                    child: _AyahMarker(num: ayahNum, isPlaying: isPlaying),
                  ),
                ),
                const TextSpan(text: ' '),
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

class _AyahMarker extends StatelessWidget {
  final int num;
  final bool isPlaying;
  const _AyahMarker({required this.num, required this.isPlaying});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isPlaying ? _kGold.withOpacity(0.2) : Colors.transparent,
        border: Border.all(
          color: isPlaying ? _kGold : Colors.white24,
          width: 0.8,
        ),
      ),
      child: Center(
        child: Text(
          ar(num),
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 10,
            color: isPlaying ? _kGold : Colors.white38,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TOP BAR
// ─────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final String surahName;
  final VoidCallback onBack, onSettings;
  final ReaderTheme theme;

  const _TopBar({
    required this.surahName,
    required this.onBack,
    required this.onSettings,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme != ReaderTheme.white;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [const Color(0xDF0A2818), Colors.transparent]
              : [Colors.white.withOpacity(0.95), Colors.transparent],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 18),
          child: Row(
            children: [
              _barIcon(Icons.wb_sunny_outlined, onSettings, isDark),
              _barIcon(Icons.headphones_rounded, () {}, isDark),
              _barIcon(Icons.bookmark_border_rounded, () {}, isDark),
              _barIcon(Icons.screen_rotation_rounded, () {}, isDark),
              const Spacer(),
              Text(
                'سورة $surahName',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.chevron_right,
                    color: isDark ? Colors.white70 : Colors.black54,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _barIcon(IconData icon, VoidCallback onTap, bool isDark) =>
      GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            color: isDark ? Colors.white60 : Colors.black38,
            size: 22,
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────
// BOTTOM BAR
// ─────────────────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  final int juz, currentPage;
  final String surahName;
  final QuranAudioState audio;
  final VoidCallback onTogglePlay, onStop, onSpeedTap;

  const _BottomBar({
    required this.juz,
    required this.currentPage,
    required this.surahName,
    required this.audio,
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
          colors: [Color(0xF00A2818), Colors.transparent],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Status row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _chip('جزء: ${ar(juz)}'),
                  _chip('صفحة: ${ar(currentPage)} من ${ar(604)}'),
                  _chip('سورة: $surahName'),
                ],
              ),
              const SizedBox(height: 10),
              // Audio control
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    // Play button
                    GestureDetector(
                      onTap: onTogglePlay,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: _kGold,
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
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        audio.isLoading ? 'جاري التحميل...' : 'الشيخ المنشاوي',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 14,
                          color: Colors.white60,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Speed
                    GestureDetector(
                      onTap: onSpeedTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: const BoxDecoration(
                          border: Border.fromBorderSide(BorderSide(color: Colors.white24)),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: Text(
                          '${audio.speed}x',
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
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

  Widget _chip(String text) => Text(
    text,
    style: const TextStyle(
      fontFamily: 'NotoNaskhArabic',
      fontSize: 11,
      color: Colors.white54,
    ),
  );
}

// ─────────────────────────────────────────────────────────────
// SETTINGS SHEET
// ─────────────────────────────────────────────────────────────
class _SettingsSheet extends StatefulWidget {
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
  State<_SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<_SettingsSheet> {
  late double _fontSize;

  @override
  void initState() {
    super.initState();
    _fontSize = widget.fontSize;
  }

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
          const Text(
            'إعدادات القراءة',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 22,
              color: _kGold,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'حجم الخط',
              style: TextStyle(
                fontFamily: 'NotoNaskhArabic',
                color: Colors.white60,
                fontSize: 13,
              ),
            ),
          ),
          Slider(
            value: _fontSize,
            min: 14,
            max: 34,
            activeColor: _kGold,
            inactiveColor: Colors.white12,
            onChanged: (v) {
              setState(() => _fontSize = v);
              widget.onFontSizeChanged(v);
            },
          ),
          const SizedBox(height: 8),
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'نمط الخلفية',
              style: TextStyle(
                fontFamily: 'NotoNaskhArabic',
                color: Colors.white60,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: ReaderTheme.values.map((t) {
              const labels = {
                'night': 'ليلي',
                'sepia': 'عاجي',
                'white': 'فاتح',
              };
              final selected = widget.theme == t;
              return Expanded(
                child: GestureDetector(
                  onTap: () => widget.onThemeChanged(t),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: selected ? _kGold : Colors.white10,
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
