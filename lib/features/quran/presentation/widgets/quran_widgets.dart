// ═══════════════════════════════════════════════════════════════
//  lib/features/quran/presentation/widgets/quran_widgets.dart
// ═══════════════════════════════════════════════════════════════

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_library/quran_library.dart' as ql;
import '../../utils/quran_helpers.dart';
import '../../utils/quran_painters.dart';

// ─────────────────────────────────────────────────────────────
// Daily Verse Card  (home hub)
// ─────────────────────────────────────────────────────────────
class DailyVerseCard extends StatelessWidget {
  final Map<String, dynamic> verse;
  final VoidCallback onRefresh;
  final VoidCallback onShare;
  final VoidCallback onNavigate;

  const DailyVerseCard({
    super.key,
    required this.verse,
    required this.onRefresh,
    required this.onShare,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Surah label row
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
              child: Row(
                children: [
                  _surahChip(verse['surahName'] as String),
                  const Spacer(),
                  _iconBtn(Icons.share_rounded, onShare),
                  const SizedBox(width: 4),
                  _iconBtn(Icons.refresh_rounded, onRefresh),
                ],
              ),
            ),
            // Ayah text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                verse['text'] as String,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: GoogleFonts.amiriQuran(
                  fontSize: 19,
                  color: Colors.white,
                  height: 2.0,
                ),
              ),
            ),
            // Bottom row
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: onNavigate,
                    child: const Icon(
                      Icons.chevron_left,
                      color: Colors.white54,
                      size: 22,
                    ),
                  ),
                  const Spacer(),
                  _ayahBadge(verse['ayahNumber'] as int),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _surahChip(String name) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: BoxDecoration(
      color: kGoldChip.withOpacity(0.25),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: kGoldChip.withOpacity(0.5)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.auto_awesome, color: kGoldChip, size: 13),
        const SizedBox(width: 5),
        Text(
          name,
          style: GoogleFonts.amiri(
            fontSize: 14,
            color: kGoldChip,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );

  Widget _iconBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: Colors.white70, size: 17),
    ),
  );

  Widget _ayahBadge(int ayah) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'آية ${ar(ayah)}',
          style: GoogleFonts.amiri(fontSize: 13, color: Colors.white70),
        ),
        const SizedBox(width: 4),
        const Text('»»', style: TextStyle(color: Colors.white38, fontSize: 11)),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────
// Khatma Action Card  (the two big green buttons)
// ─────────────────────────────────────────────────────────────
class KhatmaActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final IconData actionIcon;
  final VoidCallback onTap;
  final VoidCallback? onBack;

  const KhatmaActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.actionIcon,
    required this.onTap,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Back arrow button
            if (onBack != null)
              _circleBtn(
                Icons.chevron_left,
                Colors.white.withOpacity(0.2),
                Colors.white,
                onBack!,
              ),
            const SizedBox(width: 12),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.amiri(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Action icon button
            _circleBtn(
              actionIcon,
              Colors.white.withOpacity(0.25),
              Colors.white,
              onTap,
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleBtn(IconData icon, Color bg, Color fg, VoidCallback f) =>
      GestureDetector(
        onTap: f,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(icon, color: fg, size: 22),
        ),
      );
}

// ─────────────────────────────────────────────────────────────
// Feature Grid Item  (2×2 grid on hub)
// ─────────────────────────────────────────────────────────────
class FeatureGridItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconBg;
  final VoidCallback onTap;
  final bool useAiLabel;

  const FeatureGridItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconBg,
    required this.onTap,
    this.useAiLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: useAiLabel
                  ? Center(
                      child: Text(
                        'AI',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.amiri(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.outfit(fontSize: 11, color: Colors.white54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Khatma Progress Ring
// ─────────────────────────────────────────────────────────────
class KhatmaProgressRing extends StatelessWidget {
  final double progress; // 0.0 → 1.0
  final int pagesRead;
  final int totalPages;

  const KhatmaProgressRing({
    super.key,
    required this.progress,
    required this.pagesRead,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(160, 160),
            painter: _RingPainter(progress),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ar(pagesRead),
                style: GoogleFonts.amiri(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'من ${ar(totalPages)} صفحة',
                style: GoogleFonts.outfit(fontSize: 12, color: Colors.white60),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = (size.width - 16) / 2;
    final track = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    final fill = Paint()
      ..shader = const LinearGradient(
        colors: [kGoldChip, kGoldL],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(Offset(cx, cy), r, track);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -pi / 2,
      2 * pi * progress,
      false,
      fill,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────────────────────
// Surah Row (existing, kept)
// ─────────────────────────────────────────────────────────────
class QuranSurahRow extends StatelessWidget {
  final ql.SurahNamesModel s;
  final VoidCallback onTap;
  const QuranSurahRow({super.key, required this.s, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = surahColor(s.number);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: kBorder.withOpacity(0.5), width: 0.5),
          ),
        ),
        child: Row(
          children: [
            CustomPaint(
              size: const Size(42, 42),
              painter: SurahBadgePainter(s.number, c),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.englishName,
                    style: GoogleFonts.outfit(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${s.revelationType == 'Meccan' ? 'مكية' : 'مدنية'} • ${s.ayahsNumber} آية',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Colors.white70,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              s.name,
              style: GoogleFonts.amiri(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: c,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Juz Card (existing, kept)
// ─────────────────────────────────────────────────────────────
class QuranJuzCard extends StatelessWidget {
  final int n;
  final String name;
  final double progress;
  final VoidCallback onTap;
  const QuranJuzCard({
    super.key,
    required this.n,
    required this.name,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = surahColor(n);
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kBorder.withOpacity(0.3),
          border: Border.all(color: kBorder),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(48, 48),
                  painter: JuzRingPainter(progress, c),
                ),
                Text(
                  ar(n),
                  style: GoogleFonts.amiri(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الجزء $name',
                    style: GoogleFonts.amiri(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}% مكتمل',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
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

// ─────────────────────────────────────────────────────────────
// Ayah Block (existing, kept + enhanced highlight)
// ─────────────────────────────────────────────────────────────
class AyahBlock extends StatelessWidget {
  final ql.AyahModel a;
  final double fontSize;
  final bool isPlaying;
  final VoidCallback onPlay;
  const AyahBlock({
    super.key,
    required this.a,
    required this.fontSize,
    required this.isPlaying,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final c = isPlaying ? kGold : Colors.white.withOpacity(0.92);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      decoration: BoxDecoration(
        color: isPlaying ? kGold.withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              a.text,
              textAlign: TextAlign.center,
              style: GoogleFonts.amiriQuran(
                fontSize: fontSize,
                color: c,
                height: 1.8,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onPlay,
              child: CustomPaint(
                size: const Size(28, 28),
                painter: VerseMarkerPaint(
                  a.ayahNumber,
                  isPlaying ? kGold : kBorder.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
