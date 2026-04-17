// ═══════════════════════════════════════════════════════════════
//  lib/features/quran/presentation/screens/quran_reader_screen.dart
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_library/quran_library.dart' as ql;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../data/quran_data.dart';
import '../../data/quran_models.dart';
import '../../providers/quran_providers.dart';
import '../../utils/quran_helpers.dart';
import '../widgets/quran_widgets.dart';

class QuranReaderScreen extends ConsumerStatefulWidget {
  const QuranReaderScreen({super.key});
  @override
  ConsumerState<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends ConsumerState<QuranReaderScreen> {
  final ItemScrollController _scroll = ItemScrollController();
  final ItemPositionsListener _listener = ItemPositionsListener.create();

  @override
  void initState() {
    super.initState();
    _listener.itemPositions.addListener(_onScroll);
  }

  void _onScroll() {
    final pos = _listener.itemPositions.value;
    if (pos.isEmpty) return;
    final top = pos.where((p) => p.itemLeadingEdge >= 0).reduce((a, b) => a.itemLeadingEdge < b.itemLeadingEdge ? a : b);
    final s = ref.read(quranStateProvider);
    ref.read(quranStateProvider.notifier).setAyah(top.index + 1);
    ref.read(quranLastReadProvider.notifier).save(QuranBookmark(
      surahNum: s.currentSurah, ayahNum: top.index + 1,
      page: 0, surahName: ql.QuranLibrary.quranCtrl.surahs[s.currentSurah - 1].arabicName,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quranStateProvider);
    final bgColor = state.theme == ReaderTheme.night ? kNight : (state.theme == ReaderTheme.sepia ? const Color(0xFFF4ECD8) : Colors.white);
    final textColor = state.theme == ReaderTheme.night ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          _buildReader(state, textColor),
          if (state.showToolbar) _buildTopBar(state, textColor),
          if (state.showToolbar) _buildBottomBar(state),
        ],
      ),
    );
  }

  Widget _buildReader(QuranReadingState state, Color textColor) {
    final surah = ql.QuranLibrary.quranCtrl.surahs[state.currentSurah - 1];

    return GestureDetector(
      onTap: () => ref.read(quranStateProvider.notifier).toggleToolbar(),
      child: ScrollablePositionedList.builder(
        itemScrollController: _scroll,
        itemPositionsListener: _listener,
        initialScrollIndex: state.currentAyah - 1,
        itemCount: surah.ayahs.length,
        padding: const EdgeInsets.only(top: 120, bottom: 150),
        itemBuilder: (_, i) {
          final audio = ref.watch(quranAudioProvider);
          final isPlaying = audio.isPlaying && audio.surah == state.currentSurah && audio.ayah == i + 1;
          return AyahBlock(
            a: surah.ayahs[i],
            fontSize: state.fontSize,
            isPlaying: isPlaying,
            onPlay: () => ref.read(quranAudioProvider.notifier).togglePlay(state.currentSurah, i + 1),
          );
        },
      ),
    );
  }

  Widget _buildTopBar(QuranReadingState state, Color textColor) {
    final surah = ql.QuranLibrary.quranCtrl.surahs[state.currentSurah - 1];
    return Positioned(
      top: 0, left: 0, right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 50, 10, 15),
        decoration: BoxDecoration(
          color: state.theme == ReaderTheme.night ? kNight.withOpacity(0.95) : Colors.white.withOpacity(0.95),
          border: Border(bottom: BorderSide(color: kBorder.withOpacity(0.2)))),
        child: Row(
          children: [
            IconButton(icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20), onPressed: () => Navigator.pop(context)),
            Expanded(
              child: Column(
                children: [
                  Text(surah.arabicName, style: GoogleFonts.amiri(fontSize: 24, fontWeight: FontWeight.bold, color: kGold)),
                  Text('${surah.revelationType == 'Meccan' ? 'مكية' : 'مدنية'} • ${surah.ayahs.length} آية',
                    style: GoogleFonts.outfit(fontSize: 12, color: textColor.withOpacity(0.5))),
                ],
              ),
            ),
            IconButton(icon: Icon(Icons.settings, color: textColor), onPressed: () => _showSettings(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(QuranReadingState state) {
    final audio = ref.watch(quranAudioProvider);
    return Positioned(
      bottom: 30, left: 24, right: 24,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: kNight, borderRadius: BorderRadius.circular(35),
          boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 15, offset: Offset(0, 5))]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(icon: const Icon(Icons.bookmark_border, color: Colors.white70), onPressed: () {}),
            IconButton(icon: const Icon(Icons.skip_previous, color: Colors.white), onPressed: () {}),
            GestureDetector(
              onTap: () => ref.read(quranAudioProvider.notifier).togglePlay(state.currentSurah, state.currentAyah),
              child: Container(
                width: 45, height: 45, decoration: const BoxDecoration(color: kGold, shape: BoxShape.circle),
                child: Icon(audio.isPlaying ? Icons.pause : Icons.play_arrow, color: kNight),
              ),
            ),
            IconButton(icon: const Icon(Icons.skip_next, color: Colors.white), onPressed: () {}),
            IconButton(icon: const Icon(Icons.share_outlined, color: Colors.white70), onPressed: () {}),
          ],
        ),
      ),
    );
  }

  void _showSettings(QuranReadingState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: kNight, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الإعدادات', style: GoogleFonts.amiri(fontSize: 22, color: kGold, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Text('حجم الخط', style: GoogleFonts.outfit(color: Colors.white70)),
            Slider(
              value: state.fontSize, min: 16, max: 36, activeColor: kGold,
              onChanged: (v) => ref.read(quranStateProvider.notifier).setFontSize(v)),
            const SizedBox(height: 16),
            Text('نمط القراءة', style: GoogleFonts.outfit(color: Colors.white70)),
            const SizedBox(height: 12),
            Row(
              children: ReaderTheme.values.map((t) => Expanded(
                child: GestureDetector(
                  onTap: () => ref.read(quranStateProvider.notifier).setTheme(t),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: state.theme == t ? kGold : kBorder.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(child: Text(t.name.toUpperCase(),
                      style: TextStyle(color: state.theme == t ? kNight : Colors.white70, fontSize: 10, fontWeight: FontWeight.bold))),
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
