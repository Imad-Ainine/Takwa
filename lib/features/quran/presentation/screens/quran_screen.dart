// ═══════════════════════════════════════════════════════════════
//  lib/features/quran/presentation/screens/quran_screen.dart
//  Khatma Hub — matches the reference Khatma app UI
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_library/quran_library.dart' as ql;
import '../../providers/quran_providers.dart';
import '../../utils/quran_helpers.dart';
import '../widgets/quran_widgets.dart';
import 'quran_reader_screen.dart';
import 'khatma_history_screen.dart';
import 'khatma_progress_screen.dart';
import 'khatma_settings_screen.dart';
import 'ai_memorize_screen.dart';

class QuranScreen extends ConsumerStatefulWidget {
  const QuranScreen({super.key});
  @override
  ConsumerState<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends ConsumerState<QuranScreen>
    with TickerProviderStateMixin {
  late final AnimationController _bgAnim;
  late final AnimationController _enterAnim;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _bgAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _enterAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _enterAnim, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enterAnim, curve: Curves.easeOutCubic));
    _enterAnim.forward();
  }

  @override
  void dispose() {
    _bgAnim.dispose();
    _enterAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final khatma = ref.watch(khatmaProvider);
    final dailyVerse = ref.watch(dailyVerseProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: AnimatedBuilder(
          animation: _bgAnim,
          builder: (_, child) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.lerp(
                    const Color(0xFF0A3020),
                    const Color(0xFF0F4530),
                    _bgAnim.value,
                  )!,
                  Color.lerp(
                    const Color.fromARGB(255, 5, 13, 59),
                    const Color.fromARGB(255, 3, 10, 30),
                    _bgAnim.value,
                  )!,
                  const Color(0xFF071810),
                ],
                stops: const [0, 0.55, 1],
              ),
            ),
            child: child,
          ),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: _buildBody(khatma, dailyVerse),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(dynamic khatma, Map<String, dynamic> dailyVerse) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildAppBar()),
        SliverToBoxAdapter(child: _buildDatePill()),
        const SliverToBoxAdapter(child: SizedBox(height: 10)),
        SliverToBoxAdapter(
          child: DailyVerseCard(
            verse: dailyVerse,
            onRefresh: () => setState(() {}),
            onShare: () => _shareVerse(dailyVerse),
            onNavigate: () =>
                Navigator.push(context, slideRoute(const QuranReaderScreen())),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverToBoxAdapter(
          child: KhatmaActionCard(
            title: 'متابعة الختمة',
            subtitle: khatma != null
                ? 'أكمل القراءة من الصفحة ${ar(khatma.currentPage)}'
                : 'ابدأ ختمتك الأولى',
            color: kGreenCard,
            actionIcon: Icons.play_arrow_rounded,
            onTap: () {
              if (khatma == null) {
                ref.read(khatmaProvider.notifier).startNew();
              }
              Navigator.push(
                context,
                slideRoute(const QuranReaderScreen(startFromKhatma: true)),
              );
            },
            onBack: () =>
                Navigator.push(context, fadeRoute(const QuranReaderScreen())),
          ),
        ),
        SliverToBoxAdapter(
          child: KhatmaActionCard(
            title: 'قراءة حرة',
            subtitle: 'اقرأ القرآن الكريم بحرية',
            color: kGreenMid,
            actionIcon: Icons.menu_book_rounded,
            onTap: () => _showSurahPicker(),
            onBack: () => _showSurahPicker(),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        SliverToBoxAdapter(child: _buildGrid()),
        const SliverToBoxAdapter(child: SizedBox(height: 30)),
      ],
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 6),
      child: Row(
        children: [
          // History icon
          GestureDetector(
            onTap: () =>
                Navigator.push(context, fadeRoute(const KhatmaHistoryScreen())),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.history_rounded,
                color: Colors.white70,
                size: 22,
              ),
            ),
          ),
          const Spacer(),
          // Title
          Column(
            children: [
              Text(
                'ختمة',
                style: GoogleFonts.amiri(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: kGoldChip.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kGoldChip.withOpacity(0.5)),
                ),
                child: Text(
                  'القرآن الكريم',
                  style: GoogleFonts.amiri(fontSize: 12, color: kGoldChip),
                ),
              ),
            ],
          ),
          const Spacer(),
          // Quran icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: kGoldChip.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kGoldChip.withOpacity(0.4)),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: kGoldChip,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePill() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              color: Colors.white54,
              size: 14,
            ),
            const SizedBox(width: 8),
            Text(
              hijriDateString(),
              style: GoogleFonts.outfit(fontSize: 13, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        children: [
          FeatureGridItem(
            icon: Icons.history_rounded,
            title: 'تاريخ الختمات',
            subtitle: 'الختمات المكتملة',
            iconBg: kOlive,
            onTap: () =>
                Navigator.push(context, fadeRoute(const KhatmaHistoryScreen())),
          ),
          FeatureGridItem(
            icon: Icons.bar_chart_rounded,
            title: 'تقدم الختمة',
            subtitle: 'إحصائيات القراءة',
            iconBg: kGreenDark,
            onTap: () => Navigator.push(
              context,
              fadeRoute(const KhatmaProgressScreen()),
            ),
          ),
          FeatureGridItem(
            icon: Icons.settings_rounded,
            title: 'الإعدادات',
            subtitle: 'تخصيص التطبيق',
            iconBg: kOlive,
            onTap: () => Navigator.push(
              context,
              fadeRoute(const KhatmaSettingsScreen()),
            ),
          ),
          FeatureGridItem(
            icon: Icons.auto_awesome,
            title: 'تحفيظ ذكي',
            subtitle: 'حفظ القرآن بالذكاء الاصطناعي',
            iconBg: const Color(0xFF1A4060),
            onTap: () =>
                Navigator.push(context, fadeRoute(const AiMemorizeScreen())),
            useAiLabel: true,
          ),
        ],
      ),
    );
  }

  void _shareVerse(Map<String, dynamic> verse) {
    // Simple share action placeholder
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'جاري المشاركة...',
          style: GoogleFonts.amiri(color: Colors.white),
        ),
        backgroundColor: kGreenCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSurahPicker() {
    Navigator.push(context, fadeRoute(const _SurahPickerScreen()));
  }
}

// ─────────────────────────────────────────────────────────────
// Surah List Picker (free reading)
// ─────────────────────────────────────────────────────────────
class _SurahPickerScreen extends ConsumerStatefulWidget {
  const _SurahPickerScreen();
  @override
  ConsumerState<_SurahPickerScreen> createState() => _SurahPickerState();
}

class _SurahPickerState extends ConsumerState<_SurahPickerScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  final _search = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kNight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearch(),
            _buildTabs(),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [_buildSurahList(), _buildJuzList()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
    child: Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.close, color: Colors.white70, size: 20),
          ),
        ),
        const SizedBox(width: 14),
        Text(
          'قراءة حرة',
          style: GoogleFonts.amiri(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: kGold,
          ),
        ),
      ],
    ),
  );

  Widget _buildSearch() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
    child: Container(
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: _search,
        onChanged: (v) => setState(() => _query = v),
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: 'ابحث عن سورة...',
          hintStyle: TextStyle(color: Colors.white38),
          prefixIcon: Icon(Icons.search, color: kGold, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(14),
        ),
      ),
    ),
  );

  Widget _buildTabs() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: TabBar(
      controller: _tab,
      indicatorColor: kGold,
      labelColor: kGold,
      unselectedLabelColor: Colors.white38,
      dividerColor: Colors.transparent,
      tabs: [
        Tab(
          child: Text(
            'السور',
            style: GoogleFonts.amiri(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ),
        Tab(
          child: Text(
            'الأجزاء',
            style: GoogleFonts.amiri(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );

  Widget _buildSurahList() {
    final surahs = ql.QuranLibrary.quranCtrl.surahsList
        .where(
          (s) =>
              s.name.contains(_query) ||
              s.englishName.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList();
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 30),
      itemCount: surahs.length,
      itemBuilder: (_, i) => QuranSurahRow(
        s: surahs[i],
        onTap: () {
          // Navigate to the reader and jump to this surah's start page
          Navigator.push(
            context,
            slideRoute(QuranReaderScreen(initialSurah: surahs[i].number)),
          );
        },
      ),
    );
  }

  Widget _buildJuzList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 30,
      itemBuilder: (_, i) => QuranJuzCard(
        n: i + 1,
        name: arWord(i + 1),
        progress: 0.0,
        onTap: () {
          // juzStarts holds (surahNum, ayahNum); navigate to that surah
          final start = juzStarts[i];
          Navigator.push(
            context,
            slideRoute(QuranReaderScreen(initialSurah: start.$1)),
          );
        },
      ),
    );
  }
}
