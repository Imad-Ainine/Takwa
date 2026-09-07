import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takwa/core/theme/app_theme.dart';
import 'package:takwa/core/widgets/custom_leading_button.dart';
import 'package:takwa/core/widgets/takwa_loading_indicator.dart';
import 'package:quran_library/quran_library.dart' as ql;
import '../../data/quran_data.dart';
import '../../data/quran_models.dart';
import '../../providers/quran_providers.dart';
import '../../utils/quran_helpers.dart';
import 'mushaf_reader_screen.dart';
import 'package:takwa/l10n/app_localizations.dart';

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

  void _openMushafMode() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MushafReaderScreen(
          initialPage: _currentPage,
          startFromKhatma: widget.startFromKhatma,
        ),
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
                    surahNum: surahNum,
                    isDark: isDark,
                    onBack: () => Navigator.pop(context),
                    onAudio: () => ref
                        .read(quranAudioProvider.notifier)
                        .togglePlay(surahNum, 1),
                    onNightMode: _showSettings,
                    onBookmark: () {},
                    onGuide: _showReadingGuide,
                    onMushafMode: _openMushafMode,
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
      colors: [_kGreenHdr.withValues(alpha: 0.12), Colors.transparent],
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
                    const SizedBox(height: AppSpacing.sm),
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
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final name = isArabic ? surahMeta.nameAr : surahMeta.nameEn;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E3B), Color(0xFF0E3D26)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xs),
        border: Border.all(color: _kGold.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _kGreenHdr.withValues(alpha: 0.3),
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
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: AppSpacing.lg,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  surahMeta.type == 'meccan'
                      ? l10n.quranReaderMeccan
                      : l10n.quranReaderMedinan,
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 12,
                    color: _kGoldLight,
                  ),
                ),
                Text(
                  l10n.quranReaderSurahHeaderTitle(name),
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 22,
                    color: _kGold,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Color(0x40C8A96E), blurRadius: 8)],
                  ),
                ),
                Text(
                  l10n.quranReaderAyahCountBadge(surahMeta.ayahCount),
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
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: AppSpacing.xxl,
      ),
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
        color: isPlaying ? _kGold.withValues(alpha: 0.15) : Colors.transparent,
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
  final int surahNum;
  final bool isDark;
  final VoidCallback onBack,
      onAudio,
      onNightMode,
      onBookmark,
      onGuide,
      onMushafMode;

  const _TopBar({
    required this.surahNum,
    required this.isDark,
    required this.onBack,
    required this.onAudio,
    required this.onNightMode,
    required this.onBookmark,
    required this.onGuide,
    required this.onMushafMode,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final overlay = isDark
        ? const Color(0xD00A2818)
        : Colors.white.withValues(alpha: 0.92);
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
              Tooltip(
                message: l10n.quranReaderMushafModeTooltip,
                child: _TapIcon(
                  icon: Icons.auto_stories_rounded,
                  color: fg,
                  onTap: onMushafMode,
                ),
              ),
              const Spacer(),
              // Surah name
              Text(
                l10n.quranReaderSurahLabel(
                  localizedSurahName(context, surahNum),
                ),
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
      padding: const EdgeInsets.all(AppSpacing.sm),
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
    final l10n = AppLocalizations.of(context)!;
    final bg = isDark
        ? const Color(0xF00A2818)
        : Colors.white.withValues(alpha: 0.95);
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
                  _infoChip(
                    l10n.quranReaderJuzChip(localizedNumeral(context, juz)),
                    textDim,
                  ),
                  GestureDetector(
                    onTap: onPageNav,
                    child: _infoChip(
                      l10n.quranReaderPageOfTotalChip(
                        localizedNumeral(context, currentPage),
                        localizedNumeral(context, totalPages),
                      ),
                      textDim,
                    ),
                  ),
                  _infoChip(
                    l10n.quranReaderReadCountChip(
                      localizedNumeral(context, readCount),
                      localizedNumeral(context, khatmaPages),
                    ),
                    textDim,
                  ),
                ],
              ),
            ),

            // ── Progress bar ─────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: 6,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: readCount / khatmaPages,
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
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
                      ? Colors.black.withValues(alpha: 0.35)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black12,
                  ),
                ),
                child: Row(
                  children: [
                    // Left icons: person, download, fullscreen
                    _audioIcon(Icons.person_outlined, textDim, () {}),
                    const SizedBox(width: AppSpacing.xs),
                    _audioIcon(Icons.download_outlined, textDim, () {}),
                    const SizedBox(width: AppSpacing.xs),
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
                              color: _kGreenHdr.withValues(alpha: 0.4),
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
                          localizedSurahName(context, surahNum),
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 13,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        Text(
                          '${localizedSurahName(context, audio.surah)}: ${localizedNumeral(context, audio.ayah)}',
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
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: textDim),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          '${audio.speed}x',
                          style: TextStyle(color: textDim, fontSize: 11),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),

                    // Stop
                    GestureDetector(
                      onTap: onStop,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                          color: Colors.white.withValues(alpha: 0.08),
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
}

class _ReadingGuideDialog extends StatelessWidget {
  const _ReadingGuideDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppSpacing.xxl),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A5234),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('📖', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    l10n.quranReaderGuideTitle,
                    style: const TextStyle(
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                children: [
                  _GuideItem(emoji: '👆', text: l10n.quranReaderGuideTapToggle),
                  const SizedBox(height: 10),
                  _GuideItem(
                    emoji: '👆👆',
                    text: l10n.quranReaderGuideDoubleTapZoom,
                  ),
                  const SizedBox(height: 10),
                  _GuideItem(
                    emoji: '👈',
                    text: l10n.quranReaderGuideSwipeNavigate,
                  ),
                  const SizedBox(height: 10),
                  _GuideItem(
                    emoji: '📌',
                    text: l10n.quranReaderGuideLongPress,
                    subItems: [
                      l10n.quranReaderGuideSaveAyah,
                      l10n.quranReaderGuideShareAyah,
                      l10n.quranReaderGuideTafsir,
                      l10n.quranReaderGuideTranslation,
                      l10n.quranReaderGuideListen,
                    ],
                  ),
                  const SizedBox(height: 10),
                  _GuideItem(
                    emoji: '🎧',
                    text: l10n.quranReaderGuideAudioButton,
                  ),
                  const SizedBox(height: 10),
                  _GuideItem(
                    emoji: '🌙',
                    text: l10n.quranReaderGuideNightModeButton,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
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
                  child: Center(
                    child: Text(
                      l10n.quranReaderGuideGotIt,
                      style: const TextStyle(
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
        () => _error = AppLocalizations.of(context)!.quranReaderPageJumpError(
          localizedNumeral(context, widget.totalPages),
        ),
      );
      return;
    }
    widget.onNavigate(val);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2D3E),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
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
                Text(
                  l10n.quranReaderGoToPageTitle,
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: AppSpacing.xl),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              l10n.quranReaderCurrentPageLabel(
                localizedNumeral(context, widget.currentPage),
              ),
              style: const TextStyle(
                fontFamily: 'NotoNaskhArabic',
                fontSize: 13,
                color: Colors.white60,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.quranReaderPageInputLabel(
                l10n.quranReaderPageRangeHint(
                  localizedNumeral(context, widget.totalPages),
                ),
              ),
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
                hintText: l10n.quranReaderPageRangeHint(
                  localizedNumeral(context, widget.totalPages),
                ),
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.07),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide.none,
                ),
                errorText: _error,
                errorStyle: const TextStyle(
                  fontFamily: 'NotoNaskhArabic',
                  fontSize: 11,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Center(
                        child: Text(
                          l10n.quranReaderCancelButton,
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 16,
                            color: Colors.white60,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: _navigate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A5234),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1A5234).withValues(alpha: 0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          l10n.quranReaderGoButton,
                          style: const TextStyle(
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
    final l10n = AppLocalizations.of(context)!;
    final surahName = localizedSurahName(context, surahNum);

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
            l10n.quranReaderAyahRefLabel(
              localizedNumeral(context, ayahNum),
              surahName,
            ),
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 17,
              color: _kGold,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 10),
          _OptionRow(
            emoji: '⭐',
            label: l10n.quranReaderSaveAyahOption,
            onTap: () => Navigator.pop(context),
          ),
          _OptionRow(
            emoji: '📤',
            label: l10n.quranReaderShareAyahOption,
            onTap: () => Navigator.pop(context),
          ),
          _OptionRow(
            emoji: '📖',
            label: l10n.quranReaderTafsirOption,
            onTap: () => Navigator.pop(context),
          ),
          _OptionRow(
            emoji: '🌐',
            label: l10n.quranReaderTranslationOption,
            onTap: () => Navigator.pop(context),
          ),
          _OptionRow(
            emoji: '🔊',
            label: l10n.quranReaderListenAyahOption,
            onTap: onPlay,
          ),
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
        padding: const EdgeInsets.symmetric(
          vertical: 11,
          horizontal: AppSpacing.xs,
        ),
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
    final l10n = AppLocalizations.of(context)!;
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
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.quranReaderSettingsTitle,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 22,
              color: _kGold,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                localizedNumeral(context, _fontSize.toInt()),
                style: const TextStyle(
                  fontFamily: 'NotoNaskhArabic',
                  color: _kGold,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                l10n.quranReaderFontSizeLabel,
                style: const TextStyle(
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
            padding: const EdgeInsets.all(AppSpacing.md),
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
          const SizedBox(height: AppSpacing.xl),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              l10n.quranReaderBackgroundStyleLabel,
              style: const TextStyle(
                fontFamily: 'NotoNaskhArabic',
                color: Colors.white60,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: ReaderTheme.values.map((t) {
              final labels = {
                'night': l10n.quranReaderThemeNight,
                'sepia': l10n.quranReaderThemeSepia,
                'white': l10n.quranReaderThemeWhite,
              };
              final selected = widget.theme == t;
              return Expanded(
                child: GestureDetector(
                  onTap: () => widget.onThemeChanged(t),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                    ),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: selected ? _kGold : Colors.white10,
                      borderRadius: BorderRadius.circular(AppRadius.md),
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
