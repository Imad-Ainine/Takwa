// ═══════════════════════════════════════════════════════════════
//  lib/features/quran/presentation/screens/ai_memorize_screen.dart
//  Smart Memorization — Pages & Surahs tabs
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_library/quran_library.dart' as ql;
import '../../utils/quran_helpers.dart';
import '../../data/quran_data.dart';
import 'quran_reader_screen.dart';

const _kBg = Color(0xFF08121E);
const _kCard = Color(0xFF0F1E2D);
const _kGreen = Color(0xFF1A5234);
const _kGold = Color(0xFFC8A96E);
const _kBorder = Color(0xFF1E3040);
const _kTeal = Color(0xFF3AAFA9);

class AiMemorizeScreen extends ConsumerStatefulWidget {
  const AiMemorizeScreen({super.key});
  @override
  ConsumerState<AiMemorizeScreen> createState() => _AiMemorizeScreenState();
}

class _AiMemorizeScreenState extends ConsumerState<AiMemorizeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tab.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            _buildSearch(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: KeyedSubtree(
                  key: ValueKey(_tab.index),
                  child: _tab.index == 0
                      ? _buildPagesGrid()
                      : _buildSurahList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.chevron_right, color: _kGold, size: 28),
          ),
          const Spacer(),
          const Text(
            'التحفيظ الذكي',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 28),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _kBorder)),
      ),
      child: TabBar(
        controller: _tab,
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        indicatorColor: Colors.white,
        indicatorWeight: 2.5,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white38,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.format_list_bulleted_rounded, size: 18),
                SizedBox(width: 6),
                Text(
                  'الصفحات',
                  style: TextStyle(fontFamily: 'Amiri', fontSize: 16),
                ),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.menu_book_rounded, size: 18),
                SizedBox(width: 6),
                Text(
                  'السور',
                  style: TextStyle(fontFamily: 'Amiri', fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _query = v),
        textDirection: TextDirection.rtl,
        keyboardType: _tab.index == 0
            ? TextInputType.number
            : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: _tab.index == 0
              ? 'أدخل رقم الصفحة (1-604)'
              : 'ابحث في السور',
          hintStyle: const TextStyle(
            color: Colors.white30,
            fontFamily: 'NotoNaskhArabic',
            fontSize: 13,
          ),
          suffixIcon: const Icon(Icons.search, color: Colors.white30, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildPagesGrid() {
    final filteredPages = <int>[];
    for (int i = 1; i <= 604; i++) {
      if (_query.isEmpty || ar(i).contains(_query) || '$i'.contains(_query)) {
        filteredPages.add(i);
      }
    }

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.0,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: filteredPages.length,
      itemBuilder: (_, i) {
        final page = filteredPages[i];
        return _PageItem(page: page, onTap: () => _goToPage(page));
      },
    );
  }

  Widget _buildSurahList() {
    final surahs = ql.QuranLibrary.quranCtrl.surahsList;
    final filtered = _query.isEmpty
        ? surahs
        : surahs
              .where(
                (s) =>
                    s.name.contains(_query) ||
                    s.englishName.toLowerCase().contains(_query.toLowerCase()),
              )
              .toList();

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: filtered.length,
      itemBuilder: (_, i) {
        final s = filtered[i];
        final colors = [
          _kGold,
          _kTeal,
          const Color(0xFF4CAF7D),
          const Color(0xFF9B59B6),
          const Color(0xFFE07070),
        ];
        final c = colors[(s.number - 1) % colors.length];
        final meta = kSurahData.firstWhere(
          (sm) => sm.number == s.number,
          orElse: () => const SurahMeta(
            number: 1,
            nameAr: '',
            nameEn: '',
            ayahCount: 0,
            juzNumber: 1,
            startPage: 1,
            type: 'meccan',
          ),
        );

        return GestureDetector(
          onTap: () => _goToSurah(s.number),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: _kBorder.withOpacity(0.4)),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.chevron_left, color: Colors.white30, size: 20),
                const SizedBox(width: 10),
                // Badge number on left
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: c.withOpacity(0.12),
                    border: Border.all(color: c.withOpacity(0.4)),
                  ),
                  child: Center(
                    child: Text(
                      ar(s.number),
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 12,
                        color: c,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        meta.nameAr.isNotEmpty ? meta.nameAr : s.englishName,
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${ar(s.ayahsNumber)} آية',
                        style: const TextStyle(
                          fontFamily: 'NotoNaskhArabic',
                          fontSize: 12,
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _goToPage(int page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => QuranReaderScreen(initialPage: page)),
    );
  }

  void _goToSurah(int surahNum) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuranReaderScreen(initialSurah: surahNum),
      ),
    );
  }
}

class _PageItem extends StatelessWidget {
  final int page;
  final VoidCallback onTap;
  const _PageItem({required this.page, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kBorder),
        ),
        child: Center(
          child: Text(
            ar(page),
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
