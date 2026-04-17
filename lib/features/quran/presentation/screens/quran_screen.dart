// ═══════════════════════════════════════════════════════════════
//  lib/features/quran/presentation/screens/quran_screen.dart
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_library/quran_library.dart' as ql;
import '../../providers/quran_providers.dart';
import '../../utils/quran_helpers.dart';
import '../../utils/quran_painters.dart';
import '../widgets/quran_widgets.dart';
import 'quran_reader_screen.dart';

class QuranScreen extends ConsumerStatefulWidget {
  const QuranScreen({super.key});
  @override
  ConsumerState<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends ConsumerState<QuranScreen>
    with TickerProviderStateMixin {
  late TabController _tab;
  late AnimationController _anim;
  final _search = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _tab.dispose();
    _anim.dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kNight,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => CustomPaint(
              painter: QuranBgPainter(_anim.value),
              size: Size.infinite,
            ),
          ),
          SafeArea(
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
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final lastRead = ref.watch(quranLastReadProvider);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'القرآن الكريم',
                style: GoogleFonts.amiri(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: kGold,
                ),
              ),
              Text(
                'نور لقلبك وحياة لروحك',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: Colors.white70,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          if (lastRead != null)
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                slideRoute(const QuranReaderScreen()),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: kGold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kGold.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.history, color: kGold, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'متابعة القراءة',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: kGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: kBorder.withOpacity(0.3),
          border: Border.all(color: kBorder),
          borderRadius: BorderRadius.circular(16),
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
            contentPadding: EdgeInsets.all(16),
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: TabBar(
        controller: _tab,
        indicatorColor: kGold,
        indicatorWeight: 3,
        labelColor: kGold,
        unselectedLabelColor: Colors.white38,
        dividerColor: Colors.transparent,
        tabs: [
          Tab(
            child: Text(
              'السور',
              style: GoogleFonts.amiri(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Tab(
            child: Text(
              'الأجزاء',
              style: GoogleFonts.amiri(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahList() {
    final surahs = ql.QuranLibrary.quranCtrl.surahsList
        .where(
          (s) =>
              s.name.contains(_query) ||
              s.englishName.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: surahs.length,
      itemBuilder: (_, i) => QuranSurahRow(
        s: surahs[i],
        onTap: () {
          ref.read(quranStateProvider.notifier).setSurah(surahs[i].number);
          ref.read(quranStateProvider.notifier).setAyah(1);
          Navigator.push(context, slideRoute(const QuranReaderScreen()));
        },
      ),
    );
  }

  Widget _buildJuzList() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: 30,
      itemBuilder: (_, i) => QuranJuzCard(
        n: i + 1,
        name: arWord(i + 1),
        progress: 0.0,
        onTap: () {
          final start = juzStarts[i];
          ref.read(quranStateProvider.notifier).setSurah(start.$1);
          ref.read(quranStateProvider.notifier).setAyah(start.$2);
          Navigator.push(context, slideRoute(const QuranReaderScreen()));
        },
      ),
    );
  }
}
