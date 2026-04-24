// ═══════════════════════════════════════════════════════════════
//  lib/features/quran/presentation/screens/quran_screen.dart
//  Khatma Hub — matches reference screenshots
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takwa/core/providers/database_providers.dart';
import 'package:takwa/core/theme/ramadan_theme.dart';
import 'package:takwa/core/widgets/custom_leading_button.dart';
import 'package:takwa/core/widgets/custom_pattern_background.dart';
import '../../providers/quran_providers.dart';
import '../../utils/quran_helpers.dart';
import 'create_khatma_screen.dart';
import 'khatma_history_screen.dart';
import 'khatma_progress_screen.dart';
import 'khatma_settings_screen.dart';
import 'ai_memorize_screen.dart';
import 'quran_reader_screen.dart';
import 'free_reading_screen.dart';

// Styles are handled by AdaptiveStyle

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
    final isRamadan = ref.watch(ramadanModeProvider).value ?? false;
    final style = AdaptiveStyle(context, isRamadan);
    final khatma = ref.watch(khatmaExProvider);
    final dailyVerse = ref.watch(dailyVerseProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: style.bg,
        body: Stack(
          children: [
            const CustomPatternBackground(pattern: BackgroundPattern.duas),
            FadeTransition(
              opacity: CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _buildTopBar(style)),
                  SliverToBoxAdapter(child: _buildDatePill(style)),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverToBoxAdapter(child: _buildVerseCard(dailyVerse, style)),
                  const SliverToBoxAdapter(child: SizedBox(height: 10)),
                  SliverToBoxAdapter(child: _buildKhatmaButton(khatma, style)),
                  const SliverToBoxAdapter(child: SizedBox(height: 10)),
                  SliverToBoxAdapter(child: _buildFreeReadingButton(style)),
                  const SliverToBoxAdapter(child: SizedBox(height: 18)),
                  SliverToBoxAdapter(child: _buildGrid(style)),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(AdaptiveStyle style) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
        child: Row(
          children: [
            // History icon
            const CustomLeadingButton(),
            const Spacer(),
            // Center: title
            Column(
              children: [
                Text('ختمة', style: style.amiri(28, color: style.text)),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: style.gold.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: style.gold.withOpacity(0.45)),
                  ),
                  child: Text(
                    'القرآن الكريم',
                    style: style.amiri(13, color: style.gold),
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
                color: style.gold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: style.gold.withOpacity(0.35)),
              ),
              child: Icon(Icons.menu_book_rounded, color: style.gold, size: 22),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap, AdaptiveStyle style) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: style.text.withOpacity(0.07),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: style.border),
          ),
          child: Icon(icon, color: style.textSec, size: 22),
        ),
      );

  Widget _buildDatePill(AdaptiveStyle style) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: style.text.withOpacity(0.06),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: style.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today_rounded, color: style.textDim, size: 14),
            const SizedBox(width: 8),
            Text(
              hijriDateString(),
              style: style.naskh(13, color: style.textSec),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerseCard(Map<String, dynamic> verse, AdaptiveStyle style) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: style.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: style.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                _surahChip(verse['surahName'] as String, style),
                const Spacer(),
                _tinyBtn(Icons.share_rounded, () {}, style),
                const SizedBox(width: 6),
                _tinyBtn(Icons.refresh_rounded, () => setState(() {}), style),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Text(
              verse['text'] as String,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: style.amiri(20, color: style.text, height: 2.0),
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
                  child: Icon(
                    Icons.chevron_left,
                    color: style.textDim,
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
                    color: style.text.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'آية ${ar(verse['ayahNumber'] as int)}',
                        style: style.amiri(13, color: style.textSec),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '»»',
                        style: TextStyle(color: style.textDim, fontSize: 11),
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

  Widget _surahChip(String name, AdaptiveStyle style) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: BoxDecoration(
      color: style.gold.withOpacity(0.2),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: style.gold.withOpacity(0.4)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.auto_awesome, color: style.gold, size: 12),
        const SizedBox(width: 5),
        Text(
          name,
          style: style.amiri(14, color: style.gold, weight: FontWeight.bold),
        ),
      ],
    ),
  );

  Widget _tinyBtn(IconData icon, VoidCallback onTap, AdaptiveStyle style) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: style.text.withOpacity(0.07),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: style.textSec, size: 16),
        ),
      );

  Widget _buildKhatmaButton(KhatmaSessionEx? khatma, AdaptiveStyle style) {
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
          color: style.isRamadan ? style.gold.withOpacity(0.9) : style.teal,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (style.isRamadan ? style.gold : style.teal).withOpacity(
                0.4,
              ),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            _circleBtn(
              Icons.chevron_left,
              style.text.withOpacity(0.15),
              style.textSec,
              () => _push(const KhatmaHistoryScreen()),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                children: [
                  Text(
                    hasActive ? 'متابعة الختمة' : 'ابدأ ختمة جديدة',
                    style: style.amiri(
                      19,
                      color: Colors.white,
                      weight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    hasActive
                        ? 'أكمل القراءة من صفحة ${ar(khatma.currentPage)}'
                        : 'حدد خيارات الختمة التي تناسبك',
                    style: style.naskh(
                      12,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            _circleBtn(
              hasActive ? Icons.play_arrow_rounded : Icons.add,
              style.text.withOpacity(0.2),
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

  Widget _buildFreeReadingButton(AdaptiveStyle style) {
    return GestureDetector(
      onTap: () => _push(const FreeReadingScreen()),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 18),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: style.isRamadan
              ? style.goldDim
              : style.success.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (style.isRamadan ? style.goldDim : style.success)
                  .withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            _circleBtn(
              Icons.chevron_left,
              style.text.withOpacity(0.15),
              style.textSec,
              () => _push(const FreeReadingScreen()),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                children: [
                  Text(
                    'قراءة حرة',
                    style: style.amiri(
                      19,
                      color: Colors.white,
                      weight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'اقرأ القرآن الكريم بحرية',
                    style: style.naskh(
                      12,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            _circleBtn(
              Icons.menu_book_rounded,
              style.text.withOpacity(0.2),
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

  Widget _buildGrid(AdaptiveStyle style) {
    final items = [
      _GridItem(
        icon: Icons.history_rounded,
        title: 'تاريخ الختمات',
        subtitle: 'الختمات المكتملة',
        color: style.isRamadan
            ? style.gold.withOpacity(0.7)
            : const Color(0xFF7A6833),
        onTap: () => _push(const KhatmaHistoryScreen()),
      ),
      _GridItem(
        icon: Icons.bar_chart_rounded,
        title: 'تقدم الختمة',
        subtitle: 'إحصائيات القراءة',
        color: style.isRamadan
            ? style.goldDark.withOpacity(0.7)
            : const Color(0xFF1A5C3A),
        onTap: () => _push(const KhatmaProgressScreen()),
      ),
      _GridItem(
        icon: Icons.settings_rounded,
        title: 'الإعدادات',
        subtitle: 'تخصيص التطبيق',
        color: style.isRamadan
            ? style.gold.withOpacity(0.7)
            : const Color(0xFF7A6833),
        onTap: () => _push(const KhatmaSettingsScreen()),
      ),
      _GridItem(
        isAi: true,
        title: 'تحفيظ ذكي',
        subtitle: 'حفظ القرآن بالذكاء الاصطناعي',
        color: style.isRamadan
            ? style.teal.withOpacity(0.7)
            : const Color(0xFF1A4060),
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
        children: items.map((item) => _buildGridItem(item, style)).toList(),
      ),
    );
  }

  Widget _buildGridItem(_GridItem item, AdaptiveStyle style) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: style.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: style.border),
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
                  ? Center(
                      child: Text(
                        'AI',
                        style: style.naskh(
                          18,
                          color: Colors.white,
                          weight: FontWeight.bold,
                        ),
                      ),
                    )
                  : Icon(item.icon, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              item.title,
              style: style.amiri(
                15,
                color: style.text,
                weight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              item.subtitle,
              style: style.naskh(10, color: style.textSec),
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
