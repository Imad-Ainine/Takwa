// ═══════════════════════════════════════════════════════════════
//  lib/features/quran/presentation/screens/quran_reader_screen.dart
// ═══════════════════════════════════════════════════════════════

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:takwa/features/quran/utils/quran_utils.dart';
import 'package:just_audio/just_audio.dart';
import 'package:takwa/features/quran/data/quran_data.dart';
import '../../../../core/theme/ramadan_theme.dart';
import '../../../../core/providers/database_providers.dart';
import '../../providers/quran_providers.dart';

enum ReaderMode { reading, tahajjud, tafseer, translation }

class QuranReaderScreen extends ConsumerStatefulWidget {
  final SurahMeta surah;
  final int initialAyah;

  const QuranReaderScreen({
    super.key,
    required this.surah,
    this.initialAyah = 1,
  });

  @override
  ConsumerState<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends ConsumerState<QuranReaderScreen>
    with TickerProviderStateMixin {
  ReaderMode _mode = ReaderMode.reading;
  final ScrollController _scrollCtrl = ScrollController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _audioBtnCtrl;
  late AnimationController _bgAnimCtrl;

  int _activeAyah = 1;
  bool _showAyahOptions = false;
  int _selectedAyahForOptions = 1;

  // Auto-scroll logic
  bool _isAutoScrolling = false;
  double _scrollSpeed = 30.0; // pixels per second (speed)
  final ScrollController _tahajjudScrollCtrl = ScrollController();
  Timer? _autoScrollTimer;

  void _toggleAutoScroll() {
    setState(() {
      _isAutoScrolling = !_isAutoScrolling;
      if (_isAutoScrolling) {
        _startAutoScroll();
      } else {
        _stopAutoScroll();
      }
    });
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 50), (
      timer,
    ) {
      if (!_tahajjudScrollCtrl.hasClients) return;

      // Calculate delta based on speed (pixels per second)
      // 50ms = 0.05 seconds. Delta = speed * 0.05
      double delta = _scrollSpeed * 0.05;
      double newOffset = _tahajjudScrollCtrl.offset + delta;

      if (newOffset >= _tahajjudScrollCtrl.position.maxScrollExtent) {
        _stopAutoScroll();
        setState(() => _isAutoScrolling = false);
      } else {
        _tahajjudScrollCtrl.jumpTo(newOffset);
      }
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  @override
  void initState() {
    super.initState();
    _activeAyah = widget.initialAyah;
    _audioBtnCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _bgAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Save last read on entry
    Future.microtask(() => _saveLastRead());
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _audioPlayer.dispose();
    _audioBtnCtrl.dispose();
    _bgAnimCtrl.dispose();
    super.dispose();
  }

  void _saveLastRead() {
    ref
        .read(quranLastReadProvider.notifier)
        .save(
          QuranBookmark(
            surahNum: widget.surah.number,
            ayahNum: _activeAyah,
            page: widget.surah.startPage, // Basic approx
            surahName: widget.surah.nameAr,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final isRamadan = ref.watch(ramadanModeProvider).value ?? false;
    final style = AdaptiveStyle(context, isRamadan);
    final isNight = ref.watch(quranNightModeProvider);
    final fontSize = ref.watch(quranFontSizeProvider);

    final textColor = isNight ? Colors.white : style.text;
    final accentColor = style.gold;
    final bgColor = isNight ? const Color(0xFF0D121D) : style.bg;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Background Painter
          Positioned.fill(
            child: CustomPaint(painter: _ReaderBgPainter(nightMode: isNight)),
          ),

          SafeArea(
            child: Column(
              children: [
                _ReaderTopBar(
                  surah: widget.surah,
                  onPop: () => Navigator.pop(context),
                  onNightToggle: () => ref
                      .read(quranNightModeProvider.notifier)
                      .update((v) => !v),
                  nightMode: isNight,
                  accentColor: accentColor,
                  styleByMode: style,
                ),
                _ModeTabs(
                  current: _mode,
                  onChanged: (m) => setState(() => _mode = m),
                  accentColor: accentColor,
                  textColor: textColor,
                ),
                Expanded(
                  child: _buildCurrentView(style, isNight, fontSize, bgColor),
                ),
                _StatusBar(
                  page: widget.surah.startPage, // Simplified
                  totalPages: 604,
                  surah: widget.surah,
                  accentColor: accentColor,
                  bgColor: bgColor,
                ),
              ],
            ),
          ),

          // Floating Overlays
          if (_mode == ReaderMode.tahajjud)
            Positioned(
              bottom: 100,
              left: 40,
              right: 40,
              child: _QuranControlBar(
                isPlaying: _isAutoScrolling,
                speed: _scrollSpeed,
                accentColor: accentColor,
                bgColor: bgColor,
                onTogglePlay: _toggleAutoScroll,
                onSpeedUp: () => setState(
                  () => _scrollSpeed = (_scrollSpeed + 10).clamp(10.0, 200.0),
                ),
                onSpeedDown: () => setState(
                  () => _scrollSpeed = (_scrollSpeed - 10).clamp(10.0, 200.0),
                ),
              ),
            ),

          if (_showAyahOptions)
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: _AyahOptionsBar(
                ayahNum: _selectedAyahForOptions,
                surahName: widget.surah.nameAr,
                accentColor: accentColor,
                bgColor: bgColor,
                onClose: () => setState(() => _showAyahOptions = false),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCurrentView(
    AdaptiveStyle s,
    bool isNight,
    double fontSize,
    Color bgColor,
  ) {
    final textColor = isNight ? Colors.white : s.text;
    final accentColor = s.gold;

    switch (_mode) {
      case ReaderMode.reading:
        return _ReadingView(
          surah: widget.surah,
          fontSize: fontSize,
          textColor: textColor,
          accentColor: accentColor,
          activeAyah: _activeAyah,
          onAyahTap: (n) => setState(() {
            _activeAyah = n;
            _selectedAyahForOptions = n;
            _showAyahOptions = true;
          }),
        );
      case ReaderMode.tahajjud:
        return _TahajjudView(
          surah: widget.surah,
          fontSize: fontSize + 4,
          textColor: textColor,
          accentColor: accentColor,
          activeAyah: _activeAyah,
          scrollCtrl: _tahajjudScrollCtrl,
          onAyahTap: (n) => setState(() => _activeAyah = n),
        );
      case ReaderMode.tafseer:
        return _TafseerView(
          surah: widget.surah,
          textColor: textColor,
          accentColor: accentColor,
          bgColor: bgColor,
          fontSize: fontSize,
        );
      case ReaderMode.translation:
        return _TranslationView(
          surah: widget.surah,
          textColor: textColor,
          accentColor: accentColor,
          bgColor: bgColor,
          fontSize: fontSize,
        );
    }
  }

  void _showFontSizeDialog(AdaptiveStyle s) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('تغيير حجم الخط', style: s.amiri(20)),
            const SizedBox(height: 20),
            Consumer(
              builder: (context, ref, _) {
                final size = ref.watch(quranFontSizeProvider);
                return Slider(
                  value: size,
                  min: 16,
                  max: 42,
                  activeColor: s.gold,
                  onChanged: (v) =>
                      ref.read(quranFontSizeProvider.notifier).state = v,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  READER SUB-VIEWS
// ═══════════════════════════════════════════════════════════════

class _ReadingView extends StatelessWidget {
  final SurahMeta surah;
  final double fontSize;
  final Color textColor, accentColor;
  final int activeAyah;
  final Function(int) onAyahTap;

  const _ReadingView({
    required this.surah,
    required this.fontSize,
    required this.textColor,
    required this.accentColor,
    required this.activeAyah,
    required this.onAyahTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      children: [
        _buildMushafHeader(context),
        const SizedBox(height: 30),
        _AyahsText(
          surahNum: surah.number,
          ayahCount: surah.ayahCount,
          fontSize: fontSize,
          textColor: textColor,
          accentColor: accentColor,
          activeAyah: activeAyah,
          onAyahTap: onAyahTap,
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildMushafHeader(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: const Size(double.infinity, 80),
          painter: _HeaderCornerPainter(accentColor),
        ),
        CustomPaint(
          size: const Size(double.infinity, 80),
          painter: _HeaderCornerPainter(accentColor, flip: true),
        ),
        CustomPaint(
          size: const Size(double.infinity, 80),
          painter: _HeaderCornerPainter(accentColor, bottom: true),
        ),
        CustomPaint(
          size: const Size(double.infinity, 80),
          painter: _HeaderCornerPainter(accentColor, flip: true, bottom: true),
        ),
        Column(
          children: [
            Text(
              surah.nameAr,
              style: GoogleFonts.amiri(
                fontSize: 32,
                color: accentColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (surah.number != 1 && surah.number != 9)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  QuranUtils.getBasmala(),
                  style: GoogleFonts.amiri(
                    fontSize: 24,
                    color: textColor.withOpacity(0.9),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _AyahsText extends StatelessWidget {
  final int surahNum, ayahCount, activeAyah;
  final double fontSize;
  final Color textColor, accentColor;
  final Function(int) onAyahTap;

  const _AyahsText({
    required this.surahNum,
    required this.ayahCount,
    required this.fontSize,
    required this.textColor,
    required this.accentColor,
    required this.activeAyah,
    required this.onAyahTap,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        runSpacing: 10,
        children: List.generate(ayahCount, (i) {
          final n = i + 1;
          final text = QuranUtils.getVerse(surahNum, n);
          final isSelected = activeAyah == n;

          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onAyahTap(n);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? accentColor.withOpacity(0.12) : null,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.amiri(
                        fontSize: fontSize,
                        color: textColor,
                        height: 2.0,
                        shadows: isSelected
                            ? [
                                Shadow(
                                  color: accentColor.withOpacity(0.3),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  _VerseMarker(
                    number: n,
                    accentColor: accentColor,
                    isSelected: isSelected,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _TahajjudView extends StatelessWidget {
  final SurahMeta surah;
  final double fontSize;
  final Color textColor, accentColor;
  final int activeAyah;
  final ScrollController scrollCtrl;
  final Function(int) onAyahTap;

  const _TahajjudView({
    required this.surah,
    required this.fontSize,
    required this.textColor,
    required this.accentColor,
    required this.activeAyah,
    required this.scrollCtrl,
    required this.onAyahTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollCtrl,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),

      itemCount: surah.ayahCount,
      itemBuilder: (context, i) {
        final n = i + 1;
        final text = QuranUtils.getVerse(surah.number, n);
        final isSelected = activeAyah == n;

        return GestureDetector(
          onTap: () => onAyahTap(n),
          child: Container(
            margin: const EdgeInsets.only(bottom: 40),
            child: Column(
              children: [
                Text(
                  text,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.amiri(
                    fontSize: fontSize,
                    color: isSelected ? accentColor : textColor,
                    height: 2.5,
                  ),
                ),
                const SizedBox(height: 12),
                _VerseMarker(
                  number: n,
                  accentColor: accentColor,
                  isSelected: isSelected,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TafseerView extends StatelessWidget {
  final SurahMeta surah;
  final Color textColor, accentColor, bgColor;
  final double fontSize;

  const _TafseerView({
    required this.surah,
    required this.textColor,
    required this.accentColor,
    required this.bgColor,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: surah.ayahCount,
      itemBuilder: (_, i) {
        final n = i + 1;
        final text = QuranUtils.getVerse(surah.number, n);
        // Using mock tafseer for now as per legacy code
        final tafseer = "تفسير الآية رقم $n من سورة ${surah.nameAr}...";

        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 2),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                border: Border.all(color: accentColor.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _VerseMarker(
                    number: n,
                    accentColor: accentColor,
                    isSelected: false,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      text,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      style: GoogleFonts.amiri(
                        fontSize: fontSize,
                        color: textColor,
                        height: 2.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.05),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
                border: Border(
                  left: BorderSide(
                    color: accentColor.withOpacity(0.3),
                    width: 3,
                  ),
                  right: BorderSide(color: accentColor.withOpacity(0.2)),
                  bottom: BorderSide(color: accentColor.withOpacity(0.2)),
                ),
              ),
              child: Text(
                tafseer,
                textDirection: TextDirection.rtl,
                style: GoogleFonts.notoNaskhArabic(
                  fontSize: 13,
                  color: textColor.withOpacity(0.8),
                  height: 1.8,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TranslationView extends StatelessWidget {
  final SurahMeta surah;
  final Color textColor, accentColor, bgColor;
  final double fontSize;

  const _TranslationView({
    required this.surah,
    required this.textColor,
    required this.accentColor,
    required this.bgColor,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: surah.ayahCount,
      itemBuilder: (_, i) {
        final n = i + 1;
        final text = QuranUtils.getVerse(surah.number, n);
        // Using mock translation
        final translation =
            "This is a translation for verse $n of ${surah.nameEn}...";

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: accentColor.withOpacity(0.15)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _VerseMarker(
                      number: n,
                      accentColor: accentColor,
                      isSelected: false,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        text,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: GoogleFonts.amiri(
                          fontSize: fontSize,
                          color: textColor,
                          height: 2.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 1,
                color: accentColor.withOpacity(0.1),
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  '$n. $translation',
                  style: GoogleFonts.notoNaskhArabic(
                    fontSize: 13,
                    color: textColor.withOpacity(0.7),
                    height: 1.7,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  UI COMPONENTS
// ═══════════════════════════════════════════════════════════════

class _ReaderTopBar extends StatelessWidget {
  final SurahMeta surah;
  final VoidCallback onPop, onNightToggle;
  final bool nightMode;
  final Color accentColor;
  final AdaptiveStyle styleByMode;

  const _ReaderTopBar({
    required this.surah,
    required this.onPop,
    required this.onNightToggle,
    required this.nightMode,
    required this.accentColor,
    required this.styleByMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      decoration: BoxDecoration(
        color: nightMode
            ? const Color(0xFF1E2533)
            : Colors.white.withOpacity(0.9),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onPop,
            icon: Icon(Icons.arrow_back_ios_new, color: accentColor, size: 20),
          ),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(surah.nameAr, style: styleByMode.amiri(18)),
              Text(
                '${surah.ayahCount} آية',
                style: styleByMode.naskh(9, color: styleByMode.textSec),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: onNightToggle,
            icon: Icon(
              nightMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: accentColor,
              size: 22,
            ),
          ),
          _ReaderMenu(accentColor: accentColor, styleByMode: styleByMode),
        ],
      ),
    );
  }
}

class _ReaderMenu extends StatelessWidget {
  final Color accentColor;
  final AdaptiveStyle styleByMode;
  const _ReaderMenu({required this.accentColor, required this.styleByMode});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: Icon(Icons.more_vert_rounded, color: accentColor),
      color: styleByMode.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (_) => [
        _popItem(Icons.bookmark_rounded, 'الفواصل'),
        _popItem(Icons.settings_rounded, 'الإعدادات'),
        _popItem(Icons.share_rounded, 'مشاركة التطبيق'),
      ],
    );
  }

  PopupMenuItem _popItem(IconData icon, String label) => PopupMenuItem(
    child: Row(
      children: [
        Icon(icon, size: 18, color: accentColor),
        const SizedBox(width: 12),
        Text(label, style: styleByMode.naskh(13)),
      ],
    ),
  );
}

class _ModeTabs extends StatelessWidget {
  final ReaderMode current;
  final ValueChanged<ReaderMode> onChanged;
  final Color accentColor, textColor;

  const _ModeTabs({
    required this.current,
    required this.onChanged,
    required this.accentColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: ReaderMode.values.map((m) {
          final isSel = current == m;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onChanged(m);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: isSel
                      ? LinearGradient(
                          colors: [accentColor, accentColor.withOpacity(0.7)],
                        )
                      : null,
                  boxShadow: isSel
                      ? [
                          BoxShadow(
                            color: accentColor.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  _modeName(m),
                  style: GoogleFonts.notoNaskhArabic(
                    fontSize: 11,
                    color: isSel ? Colors.white : textColor.withOpacity(0.6),
                    fontWeight: isSel ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _modeName(ReaderMode m) {
    switch (m) {
      case ReaderMode.reading:
        return 'قراءة';
      case ReaderMode.tahajjud:
        return 'تهجد';
      case ReaderMode.tafseer:
        return 'تفسير';
      case ReaderMode.translation:
        return 'ترجمة';
    }
  }
}

class _VerseMarker extends StatelessWidget {
  final int number;
  final Color accentColor;
  final bool isSelected;
  const _VerseMarker({
    required this.number,
    required this.accentColor,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(28, 28),
      painter: _VerseMarkerPainter(color: accentColor, isSelected: isSelected),
      child: Container(
        padding: const EdgeInsets.only(top: 2),
        alignment: Alignment.center,
        child: Text(
          _toArabic(number),
          style: GoogleFonts.amiri(
            fontSize: number > 99 ? 8 : 10,
            color: accentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _QuranControlBar extends StatelessWidget {
  final bool isPlaying;
  final double speed;
  final Color accentColor, bgColor;
  final VoidCallback onTogglePlay, onSpeedUp, onSpeedDown;

  const _QuranControlBar({
    required this.isPlaying,
    required this.speed,
    required this.accentColor,
    required this.bgColor,
    required this.onTogglePlay,
    required this.onSpeedUp,
    required this.onSpeedDown,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.95),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: accentColor.withOpacity(0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ControlBtn(
            onTap: onSpeedUp,
            color: accentColor,
            child: Icon(Icons.add_rounded, color: accentColor, size: 28),
          ),
          const SizedBox(width: 20),
          _ControlBtn(
            onTap: onTogglePlay,
            color: accentColor,
            isPrimary: true,
            child: Icon(
              isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
              color: bgColor,
              size: 32,
            ),
          ),
          const SizedBox(width: 20),
          _ControlBtn(
            onTap: onSpeedDown,
            color: accentColor,
            child: Icon(Icons.remove_rounded, color: accentColor, size: 28),
          ),
          const SizedBox(width: 15),
          Text(
            '${(speed / 10).toStringAsFixed(1)}x',
            style: GoogleFonts.notoNaskhArabic(
              fontSize: 12,
              color: accentColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlBtn extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color color;
  final bool isPrimary;

  const _ControlBtn({
    required this.child,
    required this.onTap,
    required this.color,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        width: isPrimary ? 64 : 48,
        height: isPrimary ? 64 : 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isPrimary ? color : color.withOpacity(0.1),
          border: isPrimary ? null : Border.all(color: color.withOpacity(0.3)),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _AyahOptionsBar extends StatelessWidget {
  final int ayahNum;
  final String surahName;
  final Color accentColor, bgColor;
  final VoidCallback onClose;

  const _AyahOptionsBar({
    required this.ayahNum,
    required this.surahName,
    required this.accentColor,
    required this.bgColor,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final options = [
      (Icons.play_arrow_rounded, 'تشغيل'),
      (Icons.bookmark_add_rounded, 'إشارة'),
      (Icons.share_rounded, 'مشاركة'),
      (Icons.copy_rounded, 'نسخ'),
      (Icons.menu_book_rounded, 'تفسير'),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 12),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onClose,
            child: Icon(
              Icons.close_rounded,
              size: 16,
              color: accentColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$surahName: ${_toArabic(ayahNum)}',
            style: GoogleFonts.amiri(fontSize: 13, color: accentColor),
          ),
          const Spacer(),
          ...options.map(
            (o) => GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(o.$1, size: 18, color: accentColor.withOpacity(0.8)),
                    Text(
                      o.$2,
                      style: GoogleFonts.notoNaskhArabic(
                        fontSize: 8,
                        color: accentColor.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  final int page, totalPages;
  final SurahMeta surah;
  final Color accentColor, bgColor;

  const _StatusBar({
    required this.page,
    required this.totalPages,
    required this.surah,
    required this.accentColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(top: BorderSide(color: accentColor.withOpacity(0.12))),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Stack(
              children: [
                Container(height: 2, color: accentColor.withOpacity(0.1)),
                FractionallySizedBox(
                  widthFactor: (page / totalPages).clamp(0.0, 1.0),
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [accentColor, accentColor.withOpacity(0.6)],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الحزب ...',
                style: GoogleFonts.notoNaskhArabic(
                  fontSize: 10,
                  color: accentColor.withOpacity(0.5),
                ),
              ),
              Text(
                '${_toArabic(page)} من ${_toArabic(totalPages)}',
                style: GoogleFonts.notoNaskhArabic(
                  fontSize: 11,
                  color: accentColor.withOpacity(0.7),
                ),
              ),
              Text(
                'الجزء ${_toArabic(surah.juzNumber)}',
                style: GoogleFonts.notoNaskhArabic(
                  fontSize: 10,
                  color: accentColor.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  PAINTERS
// ═══════════════════════════════════════════════════════════════

class _ReaderBgPainter extends CustomPainter {
  final bool nightMode;
  _ReaderBgPainter({required this.nightMode});

  @override
  void paint(Canvas canvas, Size size) {
    if (!nightMode) return;
    final rng = math.Random(7);
    final p = Paint()..color = const Color(0x12D4A843);
    for (int i = 0; i < 40; i++) {
      canvas.drawCircle(
        Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height),
        0.6,
        p,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ReaderBgPainter o) => o.nightMode != nightMode;
}

class _HeaderCornerPainter extends CustomPainter {
  final Color color;
  final bool flip, bottom;
  const _HeaderCornerPainter(
    this.color, {
    this.flip = false,
    this.bottom = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    if (flip) {
      canvas.scale(-1, 1);
      canvas.translate(-size.width, 0);
    }
    if (bottom) {
      canvas.scale(1, -1);
      canvas.translate(0, -size.height);
    }

    final p = Paint()
      ..color = color.withOpacity(0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(0, 0), Offset(size.width, 0), p);
    canvas.drawLine(const Offset(0, 0), Offset(0, size.height), p);
    canvas.drawCircle(
      const Offset(4, 4),
      2,
      Paint()..color = color.withOpacity(0.5),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _HeaderCornerPainter o) => false;
}

class _VerseMarkerPainter extends CustomPainter {
  final Color color;
  final bool isSelected;
  _VerseMarkerPainter({required this.color, required this.isSelected});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final p = Paint()
      ..color = color.withOpacity(isSelected ? 0.3 : 0.15)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(c, r, p);
    final sp = Paint()
      ..color = color.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (int i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      canvas.drawCircle(
        Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a)),
        1.5,
        Paint()..color = color.withOpacity(0.5),
      );
    }
  }

  @override
  bool shouldRepaint(_VerseMarkerPainter o) => o.isSelected != isSelected;
}

String _toArabic(int n) {
  const d = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  return n.toString().split('').map((c) => d[int.parse(c)]).join();
}
