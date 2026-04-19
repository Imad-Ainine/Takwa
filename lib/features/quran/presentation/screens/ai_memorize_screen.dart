// ═══════════════════════════════════════════════════════════════
//  lib/features/quran/presentation/screens/ai_memorize_screen.dart
//  تحفيظ ذكي — AI Quran Memorization Screen
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_library/quran_library.dart' as ql;
import '../../utils/quran_helpers.dart';

class AiMemorizeScreen extends ConsumerStatefulWidget {
  const AiMemorizeScreen({super.key});
  @override
  ConsumerState<AiMemorizeScreen> createState() => _AiMemorizeScreenState();
}

class _AiMemorizeScreenState extends ConsumerState<AiMemorizeScreen>
    with TickerProviderStateMixin {
  int _selectedSurah = 0; // index
  int _currentAyah = 0;
  int _revealedWords = 0;
  bool _showingAnswer = false;
  int _score = 0;
  int _attempts = 0;
  late AnimationController _bounceCtrl;
  late Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bounce = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.elasticOut));
    _bounceCtrl.forward();
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  void _nextAyah() {
    final surah = ql.QuranLibrary.quranCtrl.surahs[_selectedSurah];
    setState(() {
      _currentAyah = (_currentAyah + 1) % surah.ayahs.length;
      _revealedWords = 0;
      _showingAnswer = false;
    });
    _bounceCtrl.forward(from: 0);
  }

  void _revealWord() {
    final text = ql
        .QuranLibrary
        .quranCtrl
        .surahs[_selectedSurah]
        .ayahs[_currentAyah]
        .text;
    final wordCount = text.split(' ').length;
    if (_revealedWords < wordCount) {
      setState(() => _revealedWords++);
    }
  }

  void _markCorrect() {
    setState(() {
      _score++;
      _attempts++;
    });
    _nextAyah();
  }

  void _markWrong() {
    setState(() {
      _attempts++;
    });
    _nextAyah();
  }

  @override
  Widget build(BuildContext context) {
    final surahs = ql.QuranLibrary.quranCtrl.surahs;
    final surah = surahs[_selectedSurah];
    final ayah = surah.ayahs[_currentAyah];
    final words = ayah.text.split(' ');
    final pct = _attempts > 0 ? (_score / _attempts * 100).toInt() : 0;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── AppBar ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white70,
                        size: 18,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      Text(
                        'تحفيظ ذكي',
                        style: GoogleFonts.amiri(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'حفظ القرآن بالذكاء الاصطناعي',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  _scoreChip(pct),
                ],
              ),
            ),

            // ── Surah Picker ──────────────────────────────
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: surahs.length,
                itemBuilder: (_, i) {
                  final sel = i == _selectedSurah;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedSurah = i;
                      _currentAyah = 0;
                      _revealedWords = 0;
                      _showingAnswer = false;
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: sel ? kGoldChip : Colors.white10,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: sel ? kGoldChip : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        surahs[i].arabicName,
                        style: GoogleFonts.amiri(
                          fontSize: 14,
                          color: sel ? kGreenDark : Colors.white60,
                          fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // ── Ayah Card ─────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ScaleTransition(
                  scale: _bounce,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.12)),
                    ),
                    child: Column(
                      children: [
                        // Ayah number badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: kGoldChip.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                surah.arabicName,
                                style: GoogleFonts.amiri(
                                  fontSize: 13,
                                  color: kGoldChip,
                                ),
                              ),
                            ),
                            Text(
                              'آية ${ar(ayah.ayahNumber)}',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: Colors.white38,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Masked text
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 6,
                            runSpacing: 8,
                            children: words.asMap().entries.map((e) {
                              final revealed =
                                  _showingAnswer || e.key < _revealedWords;
                              return AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Text(
                                  revealed ? e.value : '___',
                                  key: ValueKey('$revealed${e.key}'),
                                  style: GoogleFonts.amiriQuran(
                                    fontSize: 22,
                                    color: revealed
                                        ? Colors.white
                                        : kGoldChip.withOpacity(0.4),
                                    height: 1.8,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const Spacer(),
                        // Reveal progress
                        LinearProgressIndicator(
                          value: words.isEmpty
                              ? 0
                              : _revealedWords / words.length,
                          backgroundColor: Colors.white12,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            kGoldChip,
                          ),
                          minHeight: 4,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 16),
                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: _actionBtn(
                                'اكشف كلمة',
                                Icons.remove_red_eye_rounded,
                                kGreenMid,
                                _revealWord,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _actionBtn(
                                'أظهر الجواب',
                                Icons.lightbulb_rounded,
                                kOlive,
                                () => setState(() {
                                  _showingAnswer = true;
                                  _revealedWords = words.length;
                                }),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Bottom Controls ───────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: _answerBtn(
                      'لم أعرف',
                      Colors.redAccent.withOpacity(0.2),
                      Colors.redAccent,
                      _markWrong,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _answerBtn(
                      'عرفت ✓',
                      kGreenMid.withOpacity(0.4),
                      Colors.greenAccent,
                      _markCorrect,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scoreChip(int pct) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: kGoldChip.withOpacity(0.2),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: kGoldChip.withOpacity(0.4)),
    ),
    child: Text(
      '${ar(pct)}٪',
      style: GoogleFonts.outfit(
        fontSize: 14,
        color: kGoldChip,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Widget _actionBtn(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.amiri(fontSize: 14, color: color)),
        ],
      ),
    ),
  );

  Widget _answerBtn(String label, Color bg, Color fg, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: fg.withOpacity(0.4)),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.amiri(
                fontSize: 17,
                color: fg,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
}
