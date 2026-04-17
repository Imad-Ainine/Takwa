// ═══════════════════════════════════════════════════════════════
//  lib/features/quran/presentation/widgets/quran_widgets.dart
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_library/quran_library.dart' as ql;
import '../../utils/quran_helpers.dart';
import '../../utils/quran_painters.dart';

class QuranSurahRow extends StatelessWidget {
  final ql.SurahNamesModel s; final VoidCallback onTap;
  const QuranSurahRow({super.key, required this.s, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = surahColor(s.number);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: kBorder.withOpacity(0.5), width: 0.5))),
        child: Row(
          children: [
            CustomPaint(size: const Size(42, 42), painter: SurahBadgePainter(s.number, c)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.englishName, style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white)),
                  const SizedBox(height: 2),
                  Text('${s.revelationType == 'Meccan' ? 'مكية' : 'مدنية'} • ${s.ayahsNumber} آية',
                    style: GoogleFonts.outfit(fontSize: 12, color: Colors.white70, letterSpacing: 0.5)),
                ],
              ),
            ),
            Text(s.name, style: GoogleFonts.amiri(fontSize: 22, fontWeight: FontWeight.bold, color: c)),
          ],
        ),
      ),
    );
  }
}

class QuranJuzCard extends StatelessWidget {
  final int n; final String name; final double progress; final VoidCallback onTap;
  const QuranJuzCard({super.key, required this.n, required this.name, required this.progress, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = surahColor(n);
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kBorder.withOpacity(0.3), border: Border.all(color: kBorder), borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(size: const Size(48, 48), painter: JuzRingPainter(progress, c)),
                Text(ar(n), style: GoogleFonts.amiri(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الجزء $name', style: GoogleFonts.amiri(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text('${(progress * 100).toInt()}% مكتمل', style: GoogleFonts.outfit(fontSize: 12, color: Colors.white70)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}

class AyahBlock extends StatelessWidget {
  final ql.AyahModel a; final double fontSize; final bool isPlaying; final VoidCallback onPlay;
  const AyahBlock({super.key, required this.a, required this.fontSize, required this.isPlaying, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    final c = isPlaying ? kGold : Colors.white.withOpacity(0.9);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(a.text,
            textAlign: TextAlign.center,
            style: GoogleFonts.amiriQuran(fontSize: fontSize, color: c, height: 1.8)),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onPlay,
            child: CustomPaint(size: const Size(28, 28), painter: VerseMarkerPaint(a.ayahNumber, isPlaying ? kGold : kBorder.withOpacity(0.8))),
          ),
        ],
      ),
    );
  }
}
