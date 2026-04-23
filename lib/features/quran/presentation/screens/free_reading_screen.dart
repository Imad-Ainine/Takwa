// ═══════════════════════════════════════════════════════════════
//  lib/features/quran/presentation/screens/free_reading_screen.dart
//  Free Reading with Surah / Review / Index / Juz / Rub tabs
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_library/quran_library.dart' as ql;
import 'package:takwa/core/widgets/custom_leading_button.dart';
import 'package:takwa/features/quran/data/quran_models.dart';
import '../../providers/quran_providers.dart';
import '../../utils/quran_helpers.dart';
import '../../data/quran_data.dart';
import 'quran_reader_screen.dart';

const _kBg = Color(0xFF08121E);
const _kCard = Color(0xFF0F1E2D);
const _kGreen = Color(0xFF1A5234);
const _kGold = Color(0xFFC8A96E);
const _kBorder = Color(0xFF1E3040);

class FreeReadingScreen extends ConsumerStatefulWidget {
  const FreeReadingScreen({super.key});
  @override
  ConsumerState<FreeReadingScreen> createState() => _FreeReadingScreenState();
}

class _FreeReadingScreenState extends ConsumerState<FreeReadingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _search = TextEditingController();
  String _query = '';

  // Tabs in RTL order (displayed right-to-left)
  static const _tabs = ['سورة', 'مراجعة', 'فهرس', 'جزء', 'ربع'];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: _tabs.length, vsync: this);
    _tab.addListener(() => setState(() {}));
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
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            if (_tab.index == 0 || _tab.index == 2) _buildSearchBar(),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  _SurahTab(query: _query, onTap: _goToSurah),
                  _ReviewTab(onTap: _goToSurah),
                  _IndexTab(
                    query: _query,
                    lastRead: ref.watch(quranLastReadProvider),
                    onTap: _goToPage,
                  ),
                  _JuzTab(onTap: _goToJuz),
                  _RubTab(onTap: _goToPage),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(18, 14, 18, 0),
      child: Row(
        children: [
          CustomLeadingButton(),
          Spacer(),
          Text(
            'القراءة الحرة',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Spacer(),
          SizedBox(width: 28),
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
        isScrollable: false,
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        indicatorColor: Colors.white,
        indicatorWeight: 2,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white38,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(
          fontFamily: 'Amiri',
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Amiri',
          fontSize: 14,
        ),
        tabs: _tabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: TextField(
        controller: _search,
        onChanged: (v) => setState(() => _query = v),
        textDirection: TextDirection.rtl,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: _tab.index == 0
              ? 'ابحث عن سورة أو آية أو صفحة'
              : 'ابحث في السور',
          hintStyle: const TextStyle(
            color: Colors.white30,
            fontFamily: 'NotoNaskhArabic',
            fontSize: 13,
          ),
          prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
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

  void _goToPage(int page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => QuranReaderScreen(initialPage: page)),
    );
  }

  void _goToJuz(int juzNum) {
    final start = juzStarts[juzNum - 1];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuranReaderScreen(initialSurah: start.$1),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SURAH TAB
// ─────────────────────────────────────────────────────────────
class _SurahTab extends StatelessWidget {
  final String query;
  final void Function(int) onTap;
  const _SurahTab({required this.query, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final surahs = ql.QuranLibrary.quranCtrl.surahsList;
    final filtered = query.isEmpty
        ? surahs
        : surahs
              .where(
                (s) =>
                    s.name.contains(query) ||
                    s.englishName.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: filtered.length,
      itemBuilder: (_, i) {
        final s = filtered[i];
        return _SurahRow(s: s, onTap: () => onTap(s.number));
      },
    );
  }
}

class _SurahRow extends StatelessWidget {
  final dynamic s;
  final VoidCallback onTap;
  const _SurahRow({required this.s, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final surahNum = s.number as int;
    final colors = [
      _kGold,
      const Color(0xFF3AAFA9),
      const Color(0xFF4CAF7D),
      const Color(0xFF9B59B6),
    ];
    final c = colors[(surahNum - 1) % colors.length];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: _kBorder.withOpacity(0.4))),
        ),
        child: Row(
          children: [
            // Arrow
            const Icon(Icons.chevron_left, color: Colors.white30, size: 20),
            const SizedBox(width: 8),
            // Arabic calligraphic name (left side)
            Expanded(
              child: Text(
                s.name as String,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 22,
                  color: c,
                  fontWeight: FontWeight.w400,
                ),
                textDirection: TextDirection.rtl,
              ),
            ),
            const SizedBox(width: 14),
            // Surah info (right side)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  s.englishName as String,
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${s.ayahsNumber as int} آية',
                  style: const TextStyle(
                    fontFamily: 'NotoNaskhArabic',
                    fontSize: 12,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            // Number badge
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
                  ar(surahNum),
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 12,
                    color: c,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// REVIEW TAB (مراجعة)
// ─────────────────────────────────────────────────────────────
class _ReviewTab extends StatelessWidget {
  final void Function(int) onTap;
  const _ReviewTab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Show Juz list with beginning ayah text for review
    final surahs = ql.QuranLibrary.quranCtrl.surahs;

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      itemCount: kJuzData.length,
      itemBuilder: (_, i) {
        final juz = kJuzData[i];
        final surahIdx = juz.startSurah - 1;
        if (surahIdx >= surahs.length) return const SizedBox();
        final surah = surahs[surahIdx];
        final ayahIdx = (juz.startAyah - 1).clamp(0, surah.ayahs.length - 1);
        final ayah = surah.ayahs[ayahIdx];
        final previewText = ayah.text.length > 80
            ? '${ayah.text.substring(0, 80)}...'
            : ayah.text;

        return GestureDetector(
          onTap: () => onTap(juz.startSurah),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _kCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _kBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.chevron_left, color: Colors.white30, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        surah.arabicName,
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        previewText,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 14,
                          color: Colors.white54,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF1A3A28),
                  ),
                  child: Center(
                    child: Text(
                      ar(i + 1),
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 11,
                        color: Color(0xFF4CAF7D),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// INDEX / FIHRIS TAB (فهرس)
// ─────────────────────────────────────────────────────────────
class _IndexTab extends StatelessWidget {
  final String query;
  final QuranBookmark? lastRead;
  final void Function(int) onTap;
  const _IndexTab({
    required this.query,
    required this.lastRead,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Last read banner
        GestureDetector(
          onTap: lastRead != null ? () => onTap(lastRead!.page) : null,
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFD07010),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                lastRead != null
                    ? 'آخر قراءة: ${lastRead!.surahName} - صفحة ${ar(lastRead!.page)}'
                    : 'آخر قراءة: لا يوجد',
                style: const TextStyle(
                  fontFamily: 'NotoNaskhArabic',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.9,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 604,
            itemBuilder: (_, i) {
              final page = i + 1;
              if (query.isNotEmpty &&
                  !ar(page).contains(query) &&
                  !'$page'.contains(query)) {
                return const SizedBox();
              }
              return GestureDetector(
                onTap: () => onTap(page),
                child: Container(
                  decoration: BoxDecoration(
                    color: _kCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _kBorder),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        ar(page),
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 20,
                          color: Color(0xFF3AAFA9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'صفحة',
                        style: TextStyle(
                          fontFamily: 'NotoNaskhArabic',
                          fontSize: 10,
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// JUZ TAB (جزء)
// ─────────────────────────────────────────────────────────────
class _JuzTab extends StatelessWidget {
  final void Function(int) onTap;
  const _JuzTab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final surahs = ql.QuranLibrary.quranCtrl.surahs;

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      itemCount: kJuzData.length,
      itemBuilder: (_, i) {
        final juz = kJuzData[i];
        final surahIdx = juz.startSurah - 1;
        if (surahIdx >= surahs.length) return const SizedBox();
        final surah = surahs[surahIdx];
        final ayahIdx = (juz.startAyah - 1).clamp(0, surah.ayahs.length - 1);
        final ayah = surah.ayahs[ayahIdx];
        final preview = ayah.text.length > 90
            ? '${ayah.text.substring(0, 90)}...'
            : ayah.text;

        return GestureDetector(
          onTap: () => onTap(i + 1),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _kCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _kBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.chevron_left, color: Colors.white30, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        surah.arabicName,
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        preview,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 14,
                          color: Colors.white54,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFD07010).withOpacity(0.2),
                    border: Border.all(
                      color: const Color(0xFFD07010).withOpacity(0.4),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      ar(i + 1),
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 12,
                        color: Color(0xFFE0A030),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// RUB / HIZB TAB (ربع)
// ─────────────────────────────────────────────────────────────
class _RubTab extends StatelessWidget {
  final void Function(int) onTap;
  const _RubTab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final surahs = ql.QuranLibrary.quranCtrl.surahs;

    // Build hizb groups (60 hizbs, each with 4 quarters)
    final hizbGroups = <int, List<Map<String, dynamic>>>{};
    for (int h = 1; h <= 30; h++) {
      final juzIdx = h - 1;
      if (juzIdx >= kJuzData.length) continue;
      final juz = kJuzData[juzIdx];
      final surahIdx = juz.startSurah - 1;
      if (surahIdx >= surahs.length) continue;
      final surah = surahs[surahIdx];

      hizbGroups[h] = [];
      for (int q = 1; q <= 4; q++) {
        final ayahIdx = ((surah.ayahs.length / 4) * (q - 1)).toInt().clamp(
          0,
          surah.ayahs.length - 1,
        );
        final ayah = surah.ayahs[ayahIdx];
        final preview = ayah.text.length > 50
            ? '${ayah.text.substring(0, 50)}...'
            : ayah.text;
        hizbGroups[h]!.add({
          'surahName': surah.arabicName,
          'preview': preview,
          'page': kSurahData[surahIdx].startPage,
          'quarter': q,
        });
      }
    }

    final keys = hizbGroups.keys.toList()..sort();

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      itemCount: keys.length,
      itemBuilder: (_, i) {
        final hizb = keys[i];
        final quarters = hizbGroups[hizb]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'حزب $hizb',
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 16,
                  color: Colors.white54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...quarters.asMap().entries.map((e) {
              final q = e.value;
              final idx = e.key;
              final progress = (idx + 1) / 4;
              return GestureDetector(
                onTap: () => onTap(q['page'] as int),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _kCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _kBorder),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Progress circle
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 2.5,
                              backgroundColor: _kBorder,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                idx == 0
                                    ? Colors.white38
                                    : idx == 1
                                    ? const Color(0xFF3AAFA9)
                                    : idx == 2
                                    ? Colors.white54
                                    : Colors.white,
                              ),
                            ),
                            Text(
                              idx == 0
                                  ? '¼'
                                  : idx == 1
                                  ? '½'
                                  : idx == 2
                                  ? '¾'
                                  : '1',
                              style: TextStyle(
                                fontSize: 10,
                                color: idx == 3 ? Colors.white : Colors.white38,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              q['surahName'] as String,
                              style: const TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              q['preview'] as String,
                              textDirection: TextDirection.rtl,
                              style: const TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 13,
                                color: Colors.white38,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
