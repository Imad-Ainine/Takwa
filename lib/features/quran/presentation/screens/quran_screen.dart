// ═══════════════════════════════════════════════════════════════
//  lib/features/quran/presentation/screens/quran_screen.dart
//  Khatma Hub — matches reference screenshots
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/quran_providers.dart';
import '../../utils/quran_helpers.dart';
import 'create_khatma_screen.dart';
import 'khatma_history_screen.dart';
import 'khatma_progress_screen.dart';
import 'khatma_settings_screen.dart';
import 'ai_memorize_screen.dart';
import 'quran_reader_screen.dart';
import 'free_reading_screen.dart';

const _kBg = Color(0xFF08121E);
const _kCard = Color(0xFF0F1E2D);
const _kGreenDark = Color(0xFF1A5234);
const _kGreenMid = Color(0xFF236644);
const _kGold = Color(0xFFC8A96E);
const _kGoldLight = Color(0xFFD4B483);
const _kBorder = Color(0xFF1E3040);

class QuranScreen extends ConsumerStatefulWidget {
  const QuranScreen({super.key});
  @override
  ConsumerState<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends ConsumerState<QuranScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final khatma = ref.watch(khatmaExProvider);
    final dailyVerse = ref.watch(dailyVerseProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _kBg,
        body: FadeTransition(
          opacity: CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildTopBar()),
              SliverToBoxAdapter(child: _buildDatePill()),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverToBoxAdapter(child: _buildVerseCard(dailyVerse)),
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
              SliverToBoxAdapter(child: _buildKhatmaButton(khatma)),
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
              SliverToBoxAdapter(child: _buildFreeReadingButton()),
              const SliverToBoxAdapter(child: SizedBox(height: 18)),
              SliverToBoxAdapter(child: _buildGrid()),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
        child: Row(
          children: [
            // History icon
            _iconBtn(
              Icons.history_rounded,
              () => _push(const KhatmaHistoryScreen()),
            ),
            const Spacer(),
            // Center: title
            Column(
              children: [
                const Text(
                  'ختمة',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _kGold.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _kGold.withOpacity(0.45)),
                  ),
                  child: const Text(
                    'القرآن الكريم',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 13,
                      color: _kGold,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Quran icon button
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _kGold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _kGold.withOpacity(0.35)),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: _kGold,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: Icon(icon, color: Colors.white60, size: 22),
    ),
  );

  Widget _buildDatePill() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _kBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              color: Colors.white38,
              size: 14,
            ),
            const SizedBox(width: 8),
            Text(
              hijriDateString(),
              style: const TextStyle(
                fontFamily: 'NotoNaskhArabic',
                fontSize: 13,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerseCard(Map<String, dynamic> verse) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                _surahChip(verse['surahName'] as String),
                const Spacer(),
                _tinyBtn(Icons.share_rounded, () {}),
                const SizedBox(width: 6),
                _tinyBtn(Icons.refresh_rounded, () => setState(() {})),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Text(
              verse['text'] as String,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 20,
                color: Colors.white,
                height: 2.0,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _push(
                    QuranReaderScreen(
                      initialSurah: verse['surahNumber'] as int,
                    ),
                  ),
                  child: const Icon(
                    Icons.chevron_left,
                    color: Colors.white38,
                    size: 22,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'آية ${ar(verse['ayahNumber'] as int)}',
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '»»',
                        style: TextStyle(color: Colors.white30, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _surahChip(String name) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: BoxDecoration(
      color: _kGold.withOpacity(0.2),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _kGold.withOpacity(0.4)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.auto_awesome, color: _kGold, size: 12),
        const SizedBox(width: 5),
        Text(
          name,
          style: const TextStyle(
            fontFamily: 'Amiri',
            fontSize: 14,
            color: _kGold,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );

  Widget _tinyBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: Colors.white60, size: 16),
    ),
  );

  Widget _buildKhatmaButton(KhatmaSessionEx? khatma) {
    final hasActive = khatma != null && khatma.isActive;
    return GestureDetector(
      onTap: () {
        if (hasActive) {
          _push(
            QuranReaderScreen(
              startFromKhatma: true,
              initialPage: khatma.currentPage,
            ),
          );
        } else {
          _push(const CreateKhatmaScreen());
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 18),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: _kGreenDark,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _kGreenDark.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            _circleBtn(
              Icons.chevron_left,
              Colors.white.withOpacity(0.15),
              Colors.white70,
              () => _push(const KhatmaHistoryScreen()),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                children: [
                  Text(
                    hasActive ? 'متابعة الختمة' : 'ابدأ ختمة جديدة',
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    hasActive
                        ? 'أكمل القراءة من صفحة ${ar(khatma.currentPage)}'
                        : 'حدد خيارات الختمة التي تناسبك',
                    style: const TextStyle(
                      fontFamily: 'NotoNaskhArabic',
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            _circleBtn(
              hasActive ? Icons.play_arrow_rounded : Icons.add,
              Colors.white.withOpacity(0.2),
              Colors.white,
              () => hasActive
                  ? _push(
                      QuranReaderScreen(
                        startFromKhatma: true,
                        initialPage: khatma.currentPage,
                      ),
                    )
                  : _push(const CreateKhatmaScreen()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFreeReadingButton() {
    return GestureDetector(
      onTap: () => _push(const FreeReadingScreen()),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 18),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: _kGreenMid,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _kGreenMid.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            _circleBtn(
              Icons.chevron_left,
              Colors.white.withOpacity(0.15),
              Colors.white70,
              () => _push(const FreeReadingScreen()),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                children: [
                  Text(
                    'قراءة حرة',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'اقرأ القرآن الكريم بحرية',
                    style: TextStyle(
                      fontFamily: 'NotoNaskhArabic',
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            _circleBtn(
              Icons.menu_book_rounded,
              Colors.white.withOpacity(0.2),
              Colors.white,
              () => _push(const FreeReadingScreen()),
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

  Widget _buildGrid() {
    final items = [
      _GridItem(
        icon: Icons.history_rounded,
        title: 'تاريخ الختمات',
        subtitle: 'الختمات المكتملة',
        color: const Color(0xFF7A6833),
        onTap: () => _push(const KhatmaHistoryScreen()),
      ),
      _GridItem(
        icon: Icons.bar_chart_rounded,
        title: 'تقدم الختمة',
        subtitle: 'إحصائيات القراءة',
        color: const Color(0xFF1A5C3A),
        onTap: () => _push(const KhatmaProgressScreen()),
      ),
      _GridItem(
        icon: Icons.settings_rounded,
        title: 'الإعدادات',
        subtitle: 'تخصيص التطبيق',
        color: const Color(0xFF7A6833),
        onTap: () => _push(const KhatmaSettingsScreen()),
      ),
      _GridItem(
        isAi: true,
        title: 'تحفيظ ذكي',
        subtitle: 'حفظ القرآن بالذكاء الاصطناعي',
        color: const Color(0xFF1A4060),
        onTap: () => _push(const AiMemorizeScreen()),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
        children: items.map(_buildGridItem).toList(),
      ),
    );
  }

  Widget _buildGridItem(_GridItem item) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _kBorder),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: item.color,
                borderRadius: BorderRadius.circular(14),
              ),
              child: item.isAi
                  ? const Center(
                      child: Text(
                        'AI',
                        style: TextStyle(
                          fontFamily: 'NotoNaskhArabic',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Icon(item.icon, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              item.title,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              item.subtitle,
              style: const TextStyle(
                fontFamily: 'NotoNaskhArabic',
                fontSize: 10,
                color: Colors.white54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _push(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}

class _GridItem {
  final IconData? icon;
  final String title, subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool isAi;
  const _GridItem({
    this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.isAi = false,
  });
}
