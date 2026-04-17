// ═══════════════════════════════════════════════════════════════
//  lib/features/duas/presentation/screens/duas_screen.dart
//  تقوى — شاشة الأدعية
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:takwa/core/theme/ramadan_theme.dart';

import 'package:takwa/core/widgets/custom_pattern_background.dart';
import 'package:takwa/core/providers/database_providers.dart';

// ─────────────────────────────────────────
//  MODELS
// ─────────────────────────────────────────
enum DuaCategory {
  morning,
  distress,
  guidance,
  forgiveness,
  rizq,
  health,
  parents,
  travel,
  rain,
  general,
}

class DuaItem {
  final int id;
  final String arabic;
  final String meaning;
  final String occasion;
  final String source;
  final String emoji;
  final DuaCategory category;
  bool isFav;

  DuaItem({
    required this.id,
    required this.arabic,
    required this.meaning,
    required this.occasion,
    required this.source,
    required this.emoji,
    required this.category,
    this.isFav = false,
  });
}

// ─────────────────────────────────────────
//  DATA
// ─────────────────────────────────────────
final kDuasData = <DuaCategory, List<DuaItem>>{
  DuaCategory.distress: [
    DuaItem(
      id: 1,
      emoji: '🌊',
      arabic:
          'حَسْبِيَ اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ',
      meaning: 'حسبي الله ولا إله إلا هو، عليه توكلت وهو رب العرش العظيم',
      occasion: 'عند الهم والكرب',
      source: 'التوبة: ١٢٩',
      category: DuaCategory.distress,
    ),
    DuaItem(
      id: 2,
      emoji: '🤲',
      arabic:
          'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ، وَأَعُوذُ بِكَ مِنَ الْعَجْزِ وَالْكَسَلِ',
      meaning: 'اللهم أعوذ بك من الهم والحزن والعجز والكسل',
      occasion: 'دعاء الكرب والضيق',
      source: 'البخاري',
      category: DuaCategory.distress,
    ),
    DuaItem(
      id: 3,
      emoji: '💧',
      arabic:
          'لَا إِلَٰهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ',
      meaning: 'دعاء يونس عليه السلام في بطن الحوت',
      occasion: 'عند الشدة والضيق الشديد',
      source: 'الأنبياء: ٨٧',
      category: DuaCategory.distress,
    ),
  ],
  DuaCategory.guidance: [
    DuaItem(
      id: 10,
      emoji: '🌟',
      arabic:
          'رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي وَاحْلُلْ عُقْدَةً مِّن لِّسَانِي يَفْقَهُوا قَوْلِي',
      meaning: 'ربي افتح لي صدري ويسر أمري واحلل عقدة لساني يفهموا كلامي',
      occasion: 'قبل الخطابة والحديث',
      source: 'طه: ٢٥-٢٨',
      category: DuaCategory.guidance,
    ),
    DuaItem(
      id: 11,
      emoji: '🧭',
      arabic: 'اللَّهُمَّ أَلْهِمْنِي رُشْدِي وَأَعِذْنِي مِنْ شَرِّ نَفْسِي',
      meaning: 'اللهم ألهمني الرشد وأعذني من شر نفسي',
      occasion: 'طلب الهداية والسداد',
      source: 'الترمذي — حسن',
      category: DuaCategory.guidance,
    ),
  ],
  DuaCategory.forgiveness: [
    DuaItem(
      id: 20,
      emoji: '🌿',
      arabic:
          'رَبِّ اغْفِرْ لِي وَتُبْ عَلَيَّ إِنَّكَ أَنتَ التَّوَّابُ الرَّحِيمُ',
      meaning: 'ربي اغفر لي وتب علي إنك أنت التواب الرحيم',
      occasion: 'سيد الاستغفار — يومياً',
      source: 'أبو داود',
      category: DuaCategory.forgiveness,
    ),
    DuaItem(
      id: 21,
      emoji: '✨',
      arabic:
          'اللَّهُمَّ اغْفِرْ لِي مَا قَدَّمْتُ وَمَا أَخَّرْتُ، وَمَا أَسْرَرْتُ وَمَا أَعْلَنْتُ',
      meaning: 'اللهم اغفر لي ما قدمت وما أخرت وما أسررت وما أعلنت',
      occasion: 'في السجود وآخر الليل',
      source: 'مسلم',
      category: DuaCategory.forgiveness,
    ),
  ],
  DuaCategory.rizq: [
    DuaItem(
      id: 30,
      emoji: '🌾',
      arabic:
          'اللَّهُمَّ اكْفِنِي بِحَلَالِكَ عَنْ حَرَامِكَ وَأَغْنِنِي بِفَضْلِكَ عَمَّنْ سِوَاكَ',
      meaning: 'اللهم اكفني بالحلال عن الحرام وأغنني بفضلك عمن سواك',
      occasion: 'دعاء الرزق الحلال',
      source: 'الترمذي — حسن',
      category: DuaCategory.rizq,
    ),
    DuaItem(
      id: 31,
      emoji: '💎',
      arabic:
          'اللَّهُمَّ رَبَّنَا أَنزِلْ عَلَيْنَا مَائِدَةً مِّنَ السَّمَاءِ تَكُونُ لَنَا عِيدًا',
      meaning: 'ربنا أنزل علينا رزقاً من عندك يكون لنا عيداً',
      occasion: 'طلب الرزق الكريم',
      source: 'المائدة: ١١٤',
      category: DuaCategory.rizq,
    ),
  ],
  DuaCategory.health: [
    DuaItem(
      id: 40,
      emoji: '🫀',
      arabic:
          'اللَّهُمَّ عَافِنِي فِي بَدَنِي، اللَّهُمَّ عَافِنِي فِي سَمْعِي، اللَّهُمَّ عَافِنِي فِي بَصَرِي',
      meaning: 'اللهم عافني في بدني وسمعي وبصري',
      occasion: 'دعاء العافية يومياً',
      source: 'أبو داود',
      category: DuaCategory.health,
    ),
    DuaItem(
      id: 41,
      emoji: '🌱',
      arabic:
          'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ',
      meaning: 'اللهم إني أسألك العافية في الدنيا والآخرة',
      occasion: 'دعاء العافية الشامل',
      source: 'ابن ماجه — صحيح',
      category: DuaCategory.health,
    ),
  ],
  DuaCategory.parents: [
    DuaItem(
      id: 50,
      emoji: '❤️',
      arabic: 'رَّبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا',
      meaning: 'ربي ارحم والديّ كما ربياني وأنا صغير',
      occasion: 'الدعاء للوالدين — يومياً',
      source: 'الإسراء: ٢٤',
      category: DuaCategory.parents,
    ),
    DuaItem(
      id: 51,
      emoji: '🤍',
      arabic:
          'رَبِّ اغْفِرْ لِي وَلِوَالِدَيَّ وَلِلْمُؤْمِنِينَ يَوْمَ يَقُومُ الْحِسَابُ',
      meaning: 'ربي اغفر لي ولوالديّ وللمؤمنين يوم الحساب',
      occasion: 'الدعاء للوالدين والمؤمنين',
      source: 'إبراهيم: ٤١',
      category: DuaCategory.parents,
    ),
  ],
  DuaCategory.travel: [
    DuaItem(
      id: 60,
      emoji: '✈️',
      arabic:
          'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَٰذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَىٰ رَبِّنَا لَمُنقَلِبُونَ',
      meaning: 'سبحان الذي سخر لنا هذا وإنا إلى ربنا لمنقلبون',
      occasion: 'دعاء ركوب السيارة والطائرة',
      source: 'الزخرف: ١٣',
      category: DuaCategory.travel,
    ),
  ],
  DuaCategory.general: [
    DuaItem(
      id: 70,
      emoji: '🌍',
      arabic:
          'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
      meaning: 'ربنا آتنا في الدنيا حسنة وفي الآخرة حسنة وقنا عذاب النار',
      occasion: 'أفضل الأدعية — يومياً',
      source: 'البقرة: ٢٠١',
      category: DuaCategory.general,
    ),
    DuaItem(
      id: 71,
      emoji: '🙏',
      arabic: 'اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي',
      meaning: 'اللهم إنك عفو تحب العفو فاعف عني',
      occasion: 'في ليلة القدر وكل وقت',
      source: 'الترمذي — صحيح',
      category: DuaCategory.general,
    ),
  ],
};

const _categoryMeta = {
  DuaCategory.morning: ('🌅', 'الصباح'),
  DuaCategory.distress: ('🌊', 'الكرب'),
  DuaCategory.guidance: ('🌟', 'الهداية'),
  DuaCategory.forgiveness: ('🌿', 'المغفرة'),
  DuaCategory.rizq: ('🌾', 'الرزق'),
  DuaCategory.health: ('🫀', 'الصحة'),
  DuaCategory.parents: ('❤️', 'الوالدين'),
  DuaCategory.travel: ('✈️', 'السفر'),
  DuaCategory.rain: ('🌧️', 'الاستسقاء'),
  DuaCategory.general: ('🤲', 'عامة'),
};

// ─────────────────────────────────────────
//  PROVIDERS
// ─────────────────────────────────────────
final _duaSearchProvider = StateProvider<String>((ref) => '');
final _selectedCatProvider = StateProvider<DuaCategory?>((ref) => null);
final _favDuasProvider = StateNotifierProvider<_FavNotifier, Set<int>>(
  (ref) => _FavNotifier(),
);

class _FavNotifier extends StateNotifier<Set<int>> {
  _FavNotifier() : super({});
  void toggle(int id) {
    state = state.contains(id) ? ({...state}..remove(id)) : {...state, id};
  }
}

// ═══════════════════════════════════════════════════════════════
//  DUAS SCREEN
// ═══════════════════════════════════════════════════════════════
class DuasScreen extends ConsumerStatefulWidget {
  const DuasScreen({super.key});
  @override
  ConsumerState<DuasScreen> createState() => _DuasScreenState();
}

class _DuasScreenState extends ConsumerState<DuasScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entryCtrl;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<DuaItem> get _filteredDuas {
    final query = ref.read(_duaSearchProvider).trim().toLowerCase();
    final cat = ref.read(_selectedCatProvider);
    final favs = ref.read(_favDuasProvider);

    final all = kDuasData.values.expand((l) => l).toList();

    return all.where((d) {
      final matchCat = cat == null || d.category == cat;
      final matchFav = cat == null || d.isFav == favs.contains(d.id);
      final matchQ =
          query.isEmpty ||
          d.arabic.contains(query) ||
          d.meaning.toLowerCase().contains(query) ||
          d.occasion.toLowerCase().contains(query);
      return matchCat && matchQ;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isRamadan = ref.watch(ramadanModeProvider).value ?? false;
    final style = AdaptiveStyle(context, isRamadan);
    ref.watch(_duaSearchProvider);
    ref.watch(_selectedCatProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: style.bg,
        body: Stack(
          children: [
            const Positioned.fill(
              child: CustomPatternBackground(pattern: BackgroundPattern.duas),
            ),

            Column(
              children: [
                _DuasTopBar(style: style, searchCtrl: _searchCtrl),
                _CategoryFilter(style: style),
                Expanded(
                  child: _DuasList(
                    duas: _filteredDuas,
                    style: style,
                    entryCtrl: _entryCtrl,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DuasTopBar extends ConsumerWidget {
  final AdaptiveStyle style;
  final TextEditingController searchCtrl;
  const _DuasTopBar({required this.style, required this.searchCtrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الأدعية المأثورة',
                        style: style.amiri(22, color: style.gold),
                      ),
                      Text(
                        'من الكتاب والسنة',
                        style: style.naskh(11, color: style.textSec),
                      ),
                    ],
                  ),
                ),
                // Favs filter
                Consumer(
                  builder: (_, ref, __) {
                    final hasFav = ref.watch(_selectedCatProvider) == null;
                    return GestureDetector(
                      onTap: () {
                        /* show favs */
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: style.goldDim,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: style.gold.withOpacity(0.3),
                          ),
                        ),
                        child: const Center(
                          child: Text('🤍', style: TextStyle(fontSize: 18)),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Search
            Container(
              decoration: BoxDecoration(
                color: style.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: style.border),
              ),
              child: TextField(
                controller: searchCtrl,
                textDirection: TextDirection.rtl,
                style: style.naskh(13),
                onChanged: (v) =>
                    ref.read(_duaSearchProvider.notifier).state = v,
                decoration: InputDecoration(
                  hintText: 'ابحث في الأدعية...',
                  hintStyle: style.naskh(12, color: style.textSec),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: style.textSec,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
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

class _CategoryFilter extends ConsumerWidget {
  final AdaptiveStyle style;
  const _CategoryFilter({required this.style});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(_selectedCatProvider);
    const cats = DuaCategory.values;

    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        reverse: true,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: cats.length + 1,
        itemBuilder: (_, i) {
          if (i == 0) {
            final isAll = selected == null;
            return _FilterChip(
              label: '🤲 الكل',
              isActive: isAll,
              style: style,
              onTap: () => ref.read(_selectedCatProvider.notifier).state = null,
            );
          }
          final cat = cats[i - 1];
          final meta = _categoryMeta[cat]!;
          return _FilterChip(
            label: '${meta.$1} ${meta.$2}',
            isActive: selected == cat,
            style: style,
            onTap: () => ref.read(_selectedCatProvider.notifier).state =
                selected == cat ? null : cat,
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final AdaptiveStyle style;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.style,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(colors: [style.gold, style.teal])
              : null,
          color: isActive ? null : style.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? style.gold : style.border),
        ),
        child: Text(
          label,
          style: style.naskh(
            12,
            color: isActive ? style.bg : style.textSec,
            weight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _DuasList extends ConsumerWidget {
  final List<DuaItem> duas;
  final AdaptiveStyle style;
  final AnimationController entryCtrl;

  const _DuasList({
    required this.duas,
    required this.style,
    required this.entryCtrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (duas.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔍', style: TextStyle(fontSize: 36)),
            const SizedBox(height: 10),
            Text('لا توجد نتائج', style: style.amiri(16)),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: duas.length,
      itemBuilder: (_, i) {
        final d = i * 0.06;
        return FadeTransition(
          opacity: Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(
              parent: entryCtrl,
              curve: Interval(
                d.clamp(0, 0.8),
                (d + 0.4).clamp(0, 1.0),
                curve: Curves.easeOut,
              ),
            ),
          ),
          child: _DuaCard(dua: duas[i], style: style),
        );
      },
    );
  }
}

class _DuaCard extends ConsumerStatefulWidget {
  final DuaItem dua;
  final AdaptiveStyle style;
  const _DuaCard({required this.dua, required this.style});

  @override
  ConsumerState<_DuaCard> createState() => _DuaCardState();
}

class _DuaCardState extends ConsumerState<_DuaCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.style;
    final favs = ref.watch(_favDuasProvider);
    final isFav = favs.contains(widget.dua.id);

    return GestureDetector(
      onTap: () {
        setState(() => _expanded = !_expanded);
        HapticFeedback.selectionClick();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          gradient: _expanded
              ? LinearGradient(
                  colors: [s.gold.withOpacity(0.12), s.teal.withOpacity(0.06)],
                )
              : null,
          color: _expanded ? null : s.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _expanded ? s.gold.withOpacity(0.4) : s.border,
            width: _expanded ? 1.5 : 1,
          ),
          boxShadow: _expanded
              ? [BoxShadow(color: s.gold.withOpacity(0.1), blurRadius: 12)]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Text(widget.dua.emoji, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.dua.occasion,
                      style: s.naskh(12, color: s.textSec),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref.read(_favDuasProvider.notifier).toggle(widget.dua.id);
                    },
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        isFav
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        key: ValueKey(isFav),
                        color: isFav ? Colors.red.shade400 : s.textSec,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: widget.dua.arabic));
                      HapticFeedback.mediumImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'تم النسخ ✓',
                            style: GoogleFonts.notoNaskhArabic(fontSize: 12),
                          ),
                          backgroundColor: s.teal,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                    child: Icon(Icons.copy_rounded, size: 16, color: s.textSec),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Arabic text
              Text(
                widget.dua.arabic,
                textAlign: TextAlign.center,
                style: s
                    .amiri(19, color: s.text, weight: FontWeight.w400)
                    .copyWith(height: 2.0),
              ),

              // Meaning + source (collapsed)
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 250),
                crossFadeState: _expanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: const SizedBox.shrink(),
                secondChild: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(height: 1, color: s.border),
                    const SizedBox(height: 10),
                    Text(
                      widget.dua.meaning,
                      textAlign: TextAlign.center,
                      style: s
                          .naskh(12, color: s.textSec)
                          .copyWith(height: 1.8),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: s.goldDim,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: s.gold.withOpacity(0.2)),
                          ),
                          child: Text(
                            widget.dua.source,
                            style: s.naskh(
                              11,
                              color: s.gold,
                              weight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),
              Align(
                alignment: Alignment.center,
                child: AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: s.textSec,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
