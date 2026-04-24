// ═══════════════════════════════════════════════════════════════
//  lib/features/quran/presentation/screens/ai_memorize_screen.dart
//  Smart Memorization — Pages & Surahs tabs
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takwa/core/widgets/custom_leading_button.dart';
import 'package:quran_library/quran_library.dart' as ql;
import 'package:takwa/core/theme/ramadan_theme.dart';
import 'package:takwa/core/providers/database_providers.dart';
import '../../utils/quran_helpers.dart';
import '../../data/quran_data.dart';
import 'quran_reader_screen.dart';

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
    final isRamadan = ref.watch(ramadanModeProvider).value ?? false;
    final style = AdaptiveStyle(context, isRamadan);

    return Scaffold(
      backgroundColor: style.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(style),
            _buildTabBar(style),
            _buildSearch(style),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: KeyedSubtree(
                  key: ValueKey(_tab.index),
                  child: _tab.index == 0
                      ? _buildPagesGrid(style)
                      : _buildSurahList(style),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AdaptiveStyle style) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
      child: Row(
        children: [
          const CustomLeadingButton(),
          const Spacer(),
          Text(
            'التحفيظ الذكي',
            style: style.amiri(22, color: style.text, weight: FontWeight.bold),
          ),
          const Spacer(),
          const SizedBox(width: 28),
        ],
      ),
    );
  }

  Widget _buildTabBar(AdaptiveStyle style) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: style.border)),
      ),
      child: TabBar(
        controller: _tab,
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        indicatorColor: style.gold,
        indicatorWeight: 2.5,
        labelColor: style.gold,
        unselectedLabelColor: style.textSec.withOpacity(0.5),
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

  Widget _buildSearch(AdaptiveStyle style) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      decoration: BoxDecoration(
        color: style.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: style.border),
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _query = v),
        textDirection: TextDirection.rtl,
        keyboardType: _tab.index == 0
            ? TextInputType.number
            : TextInputType.text,
        style: TextStyle(color: style.text),
        decoration: InputDecoration(
          hintText: _tab.index == 0
              ? 'أدخل رقم الصفحة (1-604)'
              : 'ابحث في السور',
          hintStyle: style.naskh(13, color: style.textSec.withOpacity(0.5)),
          suffixIcon: Icon(Icons.search, color: style.textSec.withOpacity(0.5), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildPagesGrid(AdaptiveStyle style) {
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
        return _PageItem(page: page, style: style, onTap: () => _goToPage(page));
      },
    );
  }

  Widget _buildSurahList(AdaptiveStyle style) {
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
          style.gold,
          style.teal,
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
                bottom: BorderSide(color: style.border.withOpacity(0.4)),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.chevron_left, color: style.textSec.withOpacity(0.3), size: 20),
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
                      style: style.amiri(12, color: c, weight: FontWeight.bold),
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
                        style: style.amiri(18, color: style.text, weight: FontWeight.bold),
                      ),
                      Text(
                        '${ar(s.ayahsNumber)} آية',
                        style: style.naskh(12, color: style.textSec.withOpacity(0.6)),
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
  final AdaptiveStyle style;
  final VoidCallback onTap;
  const _PageItem({required this.page, required this.style, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: style.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: style.border),
        ),
        child: Center(
          child: Text(
            ar(page),
            style: style.amiri(22, color: style.text, weight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
