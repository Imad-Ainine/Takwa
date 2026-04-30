import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takwa/core/widgets/custom_leading_button.dart';
import 'package:takwa/core/widgets/takwa_loading_indicator.dart';
import 'package:quran_library/quran_library.dart' as ql;
import '../../data/quran_data.dart';
import '../../data/quran_models.dart';
import '../../providers/quran_providers.dart';
import '../../utils/quran_helpers.dart';

// ── Color constants ──────────────────────────────────────────
const _kBgDark = Color(0xFF0D1E2D);
const _kBgGreen = Color(0xFF0A2818);
const _kGold = Color(0xFFC8A96E);
const _kGoldLight = Color(0xFFE4C98A);
const _kGreenHdr = Color(0xFF1A5234);
const _kBorderG = Color(0xFF2A7A50);
const _kTextWhite = Color(0xFFF5F0E8);
const _kTextDim = Color(0xFFB0C8B8);

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

  // Tracks how many pages read in this session
  int _sessionPagesRead = 0;
  int _sessionStartPage = 1;

  @override
  void initState() {
    super.initState();

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
    _sessionStartPage = startPage;

    _toolbarAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
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

    // Show reading guide on first launch
    //WidgetsBinding.instance.addPostFrameCallback((_) => _checkShowGuide());
  }

  @override
  void dispose() {
    _pageCtrl
      ..removeListener(_onPageChange)
      ..dispose();
    _toolbarAnim.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────
  int _surahForPage(int page) {
    for (int i = kSurahData.length - 1; i >= 0; i--) {
      if (page >= kSurahData[i].startPage) return i + 1;
    }
    return 1;
  }

  void _onPageChange() {
    final p = (_pageCtrl.page?.round() ?? 0) + 1;
    if (p == _currentPage || p < 1 || p > _totalPages) return;
    setState(() {
      _sessionPagesRead = (p - _sessionStartPage).abs();
      _currentPage = p;
    });
    ref.read(quranStateProvider.notifier).setPage(p);

    if (widget.startFromKhatma) {
      ref.read(khatmaExProvider.notifier).advancePage(p);
    }

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

  void _checkShowGuide() {
    // Show guide only once — in production, check SharedPreferences
    _showReadingGuide();
  }

  // ── Dialogs ────────────────────────────────────────────────
  void _showReadingGuide() {
    showDialog(context: context, builder: (_) => const _ReadingGuideDialog());
  }

  void _showPageNavigation() {
    showDialog(
      context: context,
      builder: (_) => _PageNavigationDialog(
        currentPage: _currentPage,
        totalPages: _totalPages,
        onNavigate: (page) {
          _pageCtrl.animateToPage(
            page - 1,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        },
      ),
    );
  }

  void _showAyahOptions(int surahNum, int ayahNum) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _AyahOptionsSheet(
        surahNum: surahNum,
        ayahNum: ayahNum,
        onPlay: () {
          Navigator.pop(context);
          ref.read(quranAudioProvider.notifier).togglePlay(surahNum, ayahNum);
        },
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

  // ── Build ───────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quranStateProvider);
    final audio = ref.watch(quranAudioProvider);
    final juz = pageToJuz(_currentPage);
    final surahNum = _surahForPage(_currentPage);
    final surahName = ql.QuranLibrary.quranCtrl.surahs[surahNum - 1].arabicName;

    // Theme colors
    final bgColor = switch (state.theme) {
      ReaderTheme.white => Colors.white,
      ReaderTheme.sepia => const Color(0xFFF4ECD8),
      ReaderTheme.night => _kBgDark,
    };
    final textColor = switch (state.theme) {
      ReaderTheme.white => Colors.black87,
      ReaderTheme.sepia => const Color(0xFF3A2810),
      ReaderTheme.night => _kTextWhite,
    };
    final isDark = state.theme == ReaderTheme.night;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: bgColor,
        body: Stack(
          children: [
            // ── Background pattern ───────────────────────────
            if (isDark) Positioned.fill(child: _QuranBgDecor()),

            // ── Page viewer (horizontal swipe) ───────────────
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
                  isDark: isDark,
                  audio: audio,
                  onAyahTap: _showAyahOptions,
                ),
              ),
            ),

            // ── Top toolbar ──────────────────────────────────
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
                    isDark: isDark,
                    onBack: () => Navigator.pop(context),
                    onAudio: () => ref
                        .read(quranAudioProvider.notifier)
                        .togglePlay(surahNum, 1),
                    onNightMode: _showSettings,
                    onBookmark: () {},
                    onGuide: _showReadingGuide,
                  ),
                ),
              ),
            ),

            // ── Bottom bar ───────────────────────────────────
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
                    totalPages: _totalPages,
                    surahNum: surahNum,
                    pagesRead: _sessionPagesRead,
                    isDark: isDark,
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
                    onPageNav: _showPageNavigation,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuranBgDecor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _QuranBgPainter(), size: Size.infinite);
  }
}

class _QuranBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Base gradient
    const gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF0B1E2D), Color(0xFF0A1A28), Color(0xFF0D1F2E)],
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = gradient.createShader(
          Rect.fromLTWH(0, 0, size.width, size.height),
        ),
    );

    // Subtle gold geometric pattern
    final p = Paint()
      ..color = const Color.fromARGB(6, 255, 166, 0)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    const step = 80.0;
    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        _drawStar(canvas, Offset(x, y), step * 0.35, p);
      }
    }

    // Top glow
    final topGlow = RadialGradient(
      colors: [_kGreenHdr.withOpacity(0.12), Colors.transparent],
    );
    canvas.drawCircle(
      Offset(size.width / 2, 0),
      size.width * 0.7,
      Paint()
        ..shader = topGlow.createShader(
          Rect.fromCircle(
            center: Offset(size.width / 2, 0),
            radius: size.width * 0.7,
          ),
        ),
    );
  }

  void _drawStar(Canvas canvas, Offset c, double r, Paint p) {
    const n = 8;
    final path = Path();
    for (int i = 0; i < n * 2; i++) {
      final angle = i * 3.14159 / n;
      final dist = i.isEven ? r : r * 0.45;
      final pt = Offset(c.dx + dist * _cos(angle), c.dy + dist * _sin(angle));
      i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
    }
    path.close();
    canvas.drawPath(path, p);
  }

  double _cos(double a) => math.cos(a);
  double _sin(double a) => math.sin(a);

  @override
  bool shouldRepaint(_) => false;
}

class _QuranPageView extends StatelessWidget {
  final int page;
  final int Function(int) surahForPage;
  final double fontSize;
  final Color textColor, bgColor;
  final bool isDark;
  final QuranAudioState audio;
  final void Function(int, int) onAyahTap;

  const _QuranPageView({
    required this.page,
    required this.surahForPage,
    required this.fontSize,
    required this.textColor,
    required this.bgColor,
    required this.isDark,
    required this.audio,
    required this.onAyahTap,
  });

  @override
  Widget build(BuildContext context) {
    final pageAyahs = ql.QuranLibrary.quranCtrl.getPageAyahsByIndex(page - 1);
    if (pageAyahs.isEmpty) return const SizedBox();

    // Group ayahs by surah number
    final groups = <int, List<ql.AyahModel>>{};
    for (final a in pageAyahs) {
      final sNum = a.surahNumber ?? 1;
      groups.putIfAbsent(sNum, () => []).add(a);
    }
    final sortedSurahNums = groups.keys.toList()..sort();

    return Container(
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.only(top: 76, bottom: 96),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: sortedSurahNums.map((sNum) {
              final surahAyahs = groups[sNum]!;
              final surahIdx = sNum - 1;
              final isSurahStart = kSurahData[surahIdx].startPage == page;
              final noBasmala = sNum == 9; // At-Tawbah is index 9 (1-based)

              return Column(
                children: [
                  if (isSurahStart) ...[
                    _SurahHeader(surahMeta: kSurahData[surahIdx]),
                    if (!noBasmala)
                      _BasmalaLine(textColor: textColor, isDark: isDark),
                    const SizedBox(height: 8),
                  ],
                  _PageContent(
                    surahNum: sNum,
                    ayahs: surahAyahs,
                    fontSize: fontSize,
                    textColor: textColor,
                    audio: audio,
                    isDark: isDark,
                    onAyahTap: onAyahTap,
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ── Surah Header (matches reference screenshots) ────────────
class _SurahHeader extends StatelessWidget {
  final SurahMeta surahMeta;
  const _SurahHeader({required this.surahMeta});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E3B), Color(0xFF0E3D26)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _kGold.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _kGreenHdr.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Corner decorations
          const Positioned(
            top: 4,
            right: 8,
            child: _CornerOrnament(flip: false),
          ),
          const Positioned(top: 4, left: 8, child: _CornerOrnament(flip: true)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  surahMeta.type == 'meccan' ? 'مكية' : 'مدنية',
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 12,
                    color: _kGoldLight,
                  ),
                ),
                Text(
                  'سُورَةُ ${surahMeta.nameAr}',
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 22,
                    color: _kGold,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Color(0x40C8A96E), blurRadius: 8)],
                  ),
                ),
                Text(
                  '${ar(surahMeta.ayahCount)} آية',
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 12,
                    color: _kGoldLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CornerOrnament extends StatelessWidget {
  final bool flip;
  const _CornerOrnament({required this.flip});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleX: flip ? -1 : 1,
      child: const Text(
        '﴾',
        style: TextStyle(fontFamily: 'Amiri', fontSize: 20, color: _kGold),
      ),
    );
  }
}

// ── Basmala ─────────────────────────────────────────────────
class _BasmalaLine extends StatelessWidget {
  final Color textColor;
  final bool isDark;
  const _BasmalaLine({required this.textColor, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
      child: Text(
        'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Amiri',
          fontSize: 22,
          color: isDark ? _kGoldLight : textColor,
          height: 1.8,
        ),
      ),
    );
  }
}

// ── Page Content ─────────────────────────────────────────────
class _PageContent extends StatelessWidget {
  final int surahNum;
  final List<ql.AyahModel> ayahs;
  final double fontSize;
  final Color textColor;
  final QuranAudioState audio;
  final bool isDark;
  final void Function(int, int) onAyahTap;

  const _PageContent({
    required this.surahNum,
    required this.ayahs,
    required this.fontSize,
    required this.textColor,
    required this.audio,
    required this.isDark,
    required this.onAyahTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Text.rich(
        TextSpan(
          children: ayahs.map<InlineSpan>((a) {
            final ayahNum = a.ayahNumber;
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
                    height: 2.1,
                  ),
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: GestureDetector(
                    onTap: () => onAyahTap(surahNum, ayahNum),
                    onLongPress: () => onAyahTap(surahNum, ayahNum),
                    child: _AyahNumberBadge(
                      num: ayahNum,
                      isPlaying: isPlaying,
                      isDark: isDark,
                    ),
                  ),
                ),
                const TextSpan(text: '  '),
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

// ── Ayah number badge ────────────────────────────────────────
class _AyahNumberBadge extends StatelessWidget {
  final int num;
  final bool isPlaying, isDark;
  const _AyahNumberBadge({
    required this.num,
    required this.isPlaying,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final ring = isPlaying
        ? _kGold
        : (isDark ? Colors.white24 : Colors.black26);
    final txt = isPlaying ? _kGold : (isDark ? Colors.white54 : Colors.black45);

    return Container(
      width: 26,
      height: 26,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isPlaying ? _kGold.withOpacity(0.15) : Colors.transparent,
        border: Border.all(color: ring, width: 0.8),
      ),
      child: Center(
        child: Text(
          ar(num),
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 9,
            color: txt,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String surahName;
  final bool isDark;
  final VoidCallback onBack, onAudio, onNightMode, onBookmark, onGuide;

  const _TopBar({
    required this.surahName,
    required this.isDark,
    required this.onBack,
    required this.onAudio,
    required this.onNightMode,
    required this.onBookmark,
    required this.onGuide,
  });

  @override
  Widget build(BuildContext context) {
    final overlay = isDark
        ? const Color(0xD00A2818)
        : Colors.white.withOpacity(0.92);
    final fg = isDark ? Colors.white70 : Colors.black54;
    final divider = isDark ? Colors.white12 : Colors.black12;

    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [overlay, Colors.transparent],
              )
            : null,
        color: isDark ? null : overlay,
        border: Border(bottom: BorderSide(color: divider)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 14),
          child: Row(
            children: [
              // Left icons: brightness, headphones, bookmark, history
              _TapIcon(
                icon: Icons.wb_sunny_outlined,
                color: fg,
                onTap: onNightMode,
              ),
              _TapIcon(
                icon: Icons.headphones_rounded,
                color: fg,
                onTap: onAudio,
              ),
              _TapIcon(
                icon: Icons.bookmark_border_rounded,
                color: fg,
                onTap: onBookmark,
              ),
              _TapIcon(
                icon: Icons.help_outline_rounded,
                color: fg,
                onTap: onGuide,
              ),
              const Spacer(),
              // Surah name
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
              // Right: back button
              const CustomLeadingButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TapIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _TapIcon({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: Icon(icon, color: color, size: 22),
    ),
  );
}

class _BottomBar extends StatelessWidget {
  final int juz, currentPage, totalPages, surahNum, pagesRead;
  final bool isDark;
  final QuranAudioState audio;
  final VoidCallback onTogglePlay, onStop, onSpeedTap, onPageNav;

  const _BottomBar({
    required this.juz,
    required this.currentPage,
    required this.totalPages,
    required this.surahNum,
    required this.pagesRead,
    required this.isDark,
    required this.audio,
    required this.onTogglePlay,
    required this.onStop,
    required this.onSpeedTap,
    required this.onPageNav,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark
        ? const Color(0xF00A2818)
        : Colors.white.withOpacity(0.95);
    final textDim = isDark ? Colors.white54 : Colors.black45;
    final border = isDark ? Colors.white10 : Colors.black12;

    // Total pages expected in khatma session (for progress)
    const khatmaPages = 12;
    final readCount = pagesRead.clamp(0, khatmaPages);

    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [bg, Colors.transparent],
              )
            : null,
        color: isDark ? null : bg,
        border: Border(top: BorderSide(color: border)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Progress row ──────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _infoChip('جزء: ${ar(juz)}', textDim),
                  GestureDetector(
                    onTap: onPageNav,
                    child: _infoChip(
                      'صفحة: ${ar(currentPage)} من ${ar(totalPages)}',
                      textDim,
                    ),
                  ),
                  _infoChip(
                    'قرأت ${ar(readCount)} من ${ar(khatmaPages)} صفحات',
                    textDim,
                  ),
                ],
              ),
            ),

            // ── Progress bar ─────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: readCount / khatmaPages,
                  backgroundColor: Colors.white.withOpacity(0.08),
                  valueColor: const AlwaysStoppedAnimation<Color>(_kGreenHdr),
                  minHeight: 3,
                ),
              ),
            ),

            // ── Audio controls row (matches screenshot 9) ─
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 2, 12, 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withOpacity(0.35)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.black12,
                  ),
                ),
                child: Row(
                  children: [
                    // Left icons: person, download, fullscreen
                    _audioIcon(Icons.person_outlined, textDim, () {}),
                    const SizedBox(width: 4),
                    _audioIcon(Icons.download_outlined, textDim, () {}),
                    const SizedBox(width: 4),
                    _audioIcon(Icons.fit_screen_outlined, textDim, () {}),
                    const Spacer(),

                    // Play/pause button
                    GestureDetector(
                      onTap: onTogglePlay,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: audio.isLoading ? Colors.white24 : _kGreenHdr,
                          boxShadow: [
                            BoxShadow(
                              color: _kGreenHdr.withOpacity(0.4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: audio.isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(10),
                                child: TakwaLoadingIndicator(size: 24),
                              )
                            : Icon(
                                audio.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Surah info
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _surahNameShort(surahNum),
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 13,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        Text(
                          '${_surahNameShort(audio.surah)}: ${ar(audio.ayah)}',
                          style: TextStyle(
                            fontFamily: 'NotoNaskhArabic',
                            fontSize: 11,
                            color: textDim,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),

                    // Speed control
                    GestureDetector(
                      onTap: onSpeedTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: textDim),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${audio.speed}x',
                          style: TextStyle(color: textDim, fontSize: 11),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Stop
                    GestureDetector(
                      onTap: onStop,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: Colors.white.withOpacity(0.08),
                        ),
                        child: Icon(
                          Icons.stop_rounded,
                          color: textDim,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(String text, Color color) => Text(
    text,
    style: TextStyle(fontFamily: 'NotoNaskhArabic', fontSize: 11, color: color),
  );

  Widget _audioIcon(IconData icon, Color color, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Icon(icon, color: color, size: 18),
      );

  String _surahNameShort(int surahNum) {
    if (surahNum < 1 || surahNum > kSurahData.length) return 'القرآن';
    return kSurahData[surahNum - 1].nameAr;
  }
}

class _ReadingGuideDialog extends StatelessWidget {
  const _ReadingGuideDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A5234),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('📖', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 8),
                  Text(
                    'دليل القراءة',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24, height: 1),
            // Guide items
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                children: [
                  _GuideItem(
                    emoji: '👆',
                    text: 'اضغط ضغطة واحدة لإظهار أو إخفاء أزرار التحكم',
                  ),
                  SizedBox(height: 10),
                  _GuideItem(
                    emoji: '👆👆',
                    text: 'اضغط مرتين للتكبير والتصغير',
                  ),
                  SizedBox(height: 10),
                  _GuideItem(
                    emoji: '👈',
                    text: 'اسحب يميناً أو يساراً للتنقل بين الصفحات',
                  ),
                  SizedBox(height: 10),
                  _GuideItem(
                    emoji: '📌',
                    text: 'اضغط مطولاً على أي آية لعرض:',
                    subItems: [
                      '⭐ حفظ الآية كمرجع',
                      '📤 مشاركة الآية (نص أو صورة أو فيديو)',
                      '📖 التفسير الميسر',
                      '🌐 الترجمة',
                      '🔊 استماع للآية أو الصفحة أو السورة',
                    ],
                  ),
                  SizedBox(height: 10),
                  _GuideItem(
                    emoji: '🎧',
                    text: 'زر السماعة في الأعلى للاستماع للصفحة كاملة',
                  ),
                  SizedBox(height: 10),
                  _GuideItem(
                    emoji: '🌙',
                    text: 'زر الوضع الليلي لتبديل المظهر',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Got it button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text(
                      'فهمت ✓',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A5234),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideItem extends StatelessWidget {
  final String emoji, text;
  final List<String>? subItems;
  const _GuideItem({required this.emoji, required this.text, this.subItems});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                text,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontFamily: 'NotoNaskhArabic',
                  fontSize: 13,
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
              if (subItems != null)
                ...subItems!.map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(top: 3, right: 8),
                    child: Text(
                      s,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontFamily: 'NotoNaskhArabic',
                        fontSize: 12,
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PageNavigationDialog extends StatefulWidget {
  final int currentPage, totalPages;
  final void Function(int) onNavigate;

  const _PageNavigationDialog({
    required this.currentPage,
    required this.totalPages,
    required this.onNavigate,
  });

  @override
  State<_PageNavigationDialog> createState() => _PageNavigationDialogState();
}

class _PageNavigationDialogState extends State<_PageNavigationDialog> {
  final _ctrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _navigate() {
    final val = int.tryParse(_ctrl.text);
    if (val == null || val < 1 || val > widget.totalPages) {
      setState(
        () => _error = 'يرجى إدخال رقم صحيح بين ١ و ${ar(widget.totalPages)}',
      );
      return;
    }
    widget.onNavigate(val);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2D3E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white38,
                    size: 20,
                  ),
                ),
                const Text(
                  'الانتقال إلى صفحة',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 20),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'أنت الآن في صفحة ${ar(widget.currentPage)}',
              style: const TextStyle(
                fontFamily: 'NotoNaskhArabic',
                fontSize: 13,
                color: Colors.white60,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'أدخل رقم الصفحة (١ - ${ar(widget.totalPages)})',
              style: const TextStyle(
                fontFamily: 'NotoNaskhArabic',
                fontSize: 12,
                color: Colors.white38,
              ),
            ),
            const SizedBox(height: 14),
            // Input
            TextField(
              controller: _ctrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 20,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: '١ - ${ar(widget.totalPages)}',
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Colors.white.withOpacity(0.07),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                errorText: _error,
                errorStyle: const TextStyle(
                  fontFamily: 'NotoNaskhArabic',
                  fontSize: 11,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: const Center(
                        child: Text(
                          'إلغاء',
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 16,
                            color: Colors.white60,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: _navigate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A5234),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1A5234).withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'انتقال',
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AyahOptionsSheet extends StatelessWidget {
  final int surahNum, ayahNum;
  final VoidCallback onPlay;

  const _AyahOptionsSheet({
    required this.surahNum,
    required this.ayahNum,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final surahName = surahNum >= 1 && surahNum <= kSurahData.length
        ? kSurahData[surahNum - 1].nameAr
        : 'القرآن';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF0F1E2D),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'الآية ${ar(ayahNum)} — سورة $surahName',
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 17,
              color: _kGold,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 10),
          _OptionRow(
            emoji: '⭐',
            label: 'حفظ الآية كمرجع',
            onTap: () => Navigator.pop(context),
          ),
          _OptionRow(
            emoji: '📤',
            label: 'مشاركة الآية',
            onTap: () => Navigator.pop(context),
          ),
          _OptionRow(
            emoji: '📖',
            label: 'التفسير الميسر',
            onTap: () => Navigator.pop(context),
          ),
          _OptionRow(
            emoji: '🌐',
            label: 'الترجمة',
            onTap: () => Navigator.pop(context),
          ),
          _OptionRow(emoji: '🔊', label: 'استماع للآية', onTap: onPlay),
        ],
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  final String emoji, label;
  final VoidCallback onTap;
  const _OptionRow({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
        child: Row(
          children: [
            const Icon(Icons.chevron_left, color: Colors.white24, size: 18),
            const Spacer(),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'NotoNaskhArabic',
                fontSize: 15,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Text(emoji, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_fontSize.toInt()}',
                style: const TextStyle(
                  fontFamily: 'NotoNaskhArabic',
                  color: _kGold,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'حجم الخط',
                style: TextStyle(
                  fontFamily: 'NotoNaskhArabic',
                  color: Colors.white60,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          Slider(
            value: _fontSize,
            min: 16,
            max: 36,
            activeColor: _kGold,
            inactiveColor: Colors.white12,
            onChanged: (v) {
              setState(() => _fontSize = v);
              widget.onFontSizeChanged(v);
            },
          ),
          // Preview
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: _fontSize,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 20),
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
