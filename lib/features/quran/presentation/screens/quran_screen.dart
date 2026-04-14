// ═══════════════════════════════════════════════════════════════
//  lib/features/quran/presentation/screens/quran_screen.dart
// ═══════════════════════════════════════════════════════════════

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/ramadan_theme.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../core/routes/app_routes.dart';
import '../../data/quran_data.dart';
import '../../providers/quran_providers.dart';

class QuranScreen extends ConsumerStatefulWidget {
  const QuranScreen({super.key});

  @override
  ConsumerState<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends ConsumerState<QuranScreen>
    with TickerProviderStateMixin {
  late TabController _tabCtrl;
  late AnimationController _bgAnimCtrl;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _bgAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _bgAnimCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRamadan = ref.watch(ramadanModeProvider).value ?? false;
    final style = AdaptiveStyle(context, isRamadan);

    return Scaffold(
      backgroundColor: style.bg,
      body: Stack(
        children: [
          // Background Pattern
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgAnimCtrl,
              builder: (context, child) => RepaintBoundary(
                child: CustomPaint(
                  painter: _QuranBgPainter(
                    t: _bgAnimCtrl.value,
                    isRamadan: isRamadan,
                    goldColor: style.gold,
                    nightColor: style.bg,
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildAppBar(style),
                Expanded(
                  child: NestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) => [
                      SliverToBoxAdapter(child: _buildLastReadCard(style)),
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _TabHeaderDelegate(
                          child: Container(
                            color: style.bg,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            child: _buildSearchBar(style),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(child: _buildTabBar(style)),
                    ],
                    body: TabBarView(
                      controller: _tabCtrl,
                      children: [_buildSurahList(style), _buildJuzList(style)],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(AdaptiveStyle s) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new, color: s.gold, size: 20),
          ),
          const SizedBox(width: 8),
          Text('القرآن الكريم', style: s.amiri(24)),
          const Spacer(),
          const RamadanToggle(),
        ],
      ),
    );
  }

  Widget _buildLastReadCard(AdaptiveStyle s) {
    final lastRead = ref.watch(quranLastReadProvider);
    final progress = ref.watch(quranProgressProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(24),
      decoration: s.heroDeco,
      child: Stack(
        children: [
          // Decorative Icon
          Positioned(
            left: -20,
            bottom: -20,
            child: Opacity(
              opacity: 0.1,
              child: Icon(Icons.menu_book, size: 120, color: s.bg),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.bookmark_added,
                    color: s.bg.withOpacity(0.8),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'آخر قراءة',
                    style: s.naskh(14, color: s.bg.withOpacity(0.8)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                lastRead?.surahName ?? 'ابدأ القراءة',
                style: s.amiri(26, color: s.bg),
              ),
              const SizedBox(height: 4),
              Text(
                lastRead != null
                    ? 'الآية رقم: ${lastRead.ayahNum}'
                    : 'لم تبدأ بعد',
                style: s.naskh(14, color: s.bg.withOpacity(0.7)),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: s.bg.withOpacity(0.2),
                        color: s.bg,
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: s.naskh(12, color: s.bg, weight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AdaptiveStyle s) {
    return Container(
      decoration: BoxDecoration(
        color: s.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: s.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _searchQuery = v),
        textAlign: TextAlign.right,
        style: s.naskh(14),
        decoration: InputDecoration(
          hintText: 'ابحث عن سورة أو جزء...',
          hintStyle: s.naskh(14, color: s.textDim),
          prefixIcon: Icon(Icons.search, color: s.gold),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(AdaptiveStyle s) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TabBar(
        controller: _tabCtrl,
        indicatorColor: s.gold,
        indicatorWeight: 3,
        labelColor: s.gold,
        unselectedLabelColor: s.textSec,
        labelStyle: s.amiri(18, weight: FontWeight.w700),
        unselectedLabelStyle: s.amiri(18),
        tabs: const [
          Tab(text: 'السور'),
          Tab(text: 'الأجزاء'),
        ],
      ),
    );
  }

  Widget _buildSurahList(AdaptiveStyle s) {
    final filtered = kSurahData.where((surah) {
      return surah.nameAr.contains(_searchQuery) ||
          surah.nameEn.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final surah = filtered[index];
        return _buildSurahItem(surah, s);
      },
    );
  }

  Widget _buildSurahItem(SurahMeta surah, AdaptiveStyle s) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.quranReader,
          arguments: {'surah': surah, 'initialAyah': 1},
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: s.cardDeco,
        child: Row(
          children: [
            // Surah Number
            SizedBox(
              width: 44,
              height: 44,
              child: CustomPaint(
                painter: _SurahNumberPainter(
                  number: surah.number,
                  color: s.gold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Surah Names
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(surah.nameAr, style: s.amiri(20)),
                  Text(
                    '${surah.type == 'meccan' ? 'مكية' : 'مدنية'} • ${surah.ayahCount} آية',
                    style: s.naskh(12, color: s.textSec),
                  ),
                ],
              ),
            ),
            Text(
              surah.nameEn,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: s.gold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJuzList(AdaptiveStyle s) {
    final filtered = kJuzData.where((juz) {
      return 'الجزء ${juz.juzNumber}'.contains(_searchQuery) ||
          juz.surahName.contains(_searchQuery);
    }).toList();

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final juz = filtered[index];
        return _buildJuzItem(juz, s);
      },
    );
  }

  Widget _buildJuzItem(JuzMeta juz, AdaptiveStyle s) {
    // In a real app, you'd track Juz progress. For now, using a static mock or calculated value.
    final progress = (juz.juzNumber / 30).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        // Navigate to start of Juz
        final surah = kSurahData.firstWhere(
          (ser) => ser.number == juz.startSurah,
        );
        Navigator.pushNamed(
          context,
          Routes.quranReader,
          arguments: {'surah': surah, 'initialAyah': juz.startAyah},
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: s.cardDeco,
        child: Row(
          children: [
            // Juz Progress Ring
            SizedBox(
              width: 44,
              height: 44,
              child: CustomPaint(
                painter: _JuzRingPainter(
                  progress: progress,
                  color: s.gold,
                  borderColor: s.border,
                ),
                child: Center(
                  child: Text(
                    _toArabic(juz.juzNumber),
                    style: s.amiri(12, weight: FontWeight.w700),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الجزء ${_toArabicWord(juz.juzNumber)}',
                      style: s.amiri(20)),
                  Text(
                    'يبدأ من سورة ${juz.surahName} • آية ${juz.startAyah}',
                    style: s.naskh(11, color: s.textSec),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: s.gold, size: 16),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  PAINTERS & HELPERS
// ═══════════════════════════════════════════════════════════════

class _QuranBgPainter extends CustomPainter {
  final double t;
  final bool isRamadan;
  final Color goldColor;
  final Color nightColor;

  _QuranBgPainter({
    required this.t,
    required this.isRamadan,
    required this.goldColor,
    required this.nightColor,
  });

  static final _rng = math.Random(19);
  static List<Offset>? _stars;

  @override
  void paint(Canvas canvas, Size size) {
    if (isRamadan) {
      RamadanBgPainter(
        animT: t,
        brightness: Brightness.dark,
      ).paint(canvas, size);
      return;
    }

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = nightColor,
    );

    _stars ??= List.generate(
      50,
      (_) => Offset(
        _rng.nextDouble() * size.width,
        _rng.nextDouble() * size.height * 0.5,
      ),
    );
    for (int i = 0; i < _stars!.length; i++) {
      final op = 0.04 + 0.1 * ((math.sin(t * 2 * math.pi + i) + 1) / 2);
      canvas.drawCircle(
        _stars![i],
        0.9,
        Paint()..color = goldColor.withOpacity(op),
      );
    }

    // Decorative arch at top
    final archPath = Path();
    archPath.moveTo(0, 0);
    archPath.lineTo(size.width, 0);
    archPath.lineTo(size.width, 60);
    archPath.quadraticBezierTo(size.width * 0.75, 90, size.width * 0.5, 80);
    archPath.quadraticBezierTo(size.width * 0.25, 70, 0, 60);
    archPath.close();

    canvas.drawPath(
      archPath,
      Paint()
        ..shader = LinearGradient(
          colors: [
            goldColor.withOpacity(0.06),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, size.width, 90)),
    );

    // Geometric star pattern
    final p = Paint()
      ..color = goldColor.withOpacity(0.04)
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;
    const s = 52.0;
    for (double x = 0; x < size.width + s; x += s) {
      for (double y = 80; y < size.height + s; y += s) {
        _drawGeomStar(canvas, Offset(x, y), s * 0.28, p);
      }
    }
  }

  void _drawGeomStar(Canvas canvas, Offset c, double r, Paint p) {
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final a = i * math.pi / 4 - math.pi / 8;
      final rr = i.isEven ? r : r * 0.42;
      final pt = Offset(c.dx + rr * math.cos(a), c.dy + rr * math.sin(a));
      i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
    }
    path.close();
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_QuranBgPainter old) => old.t != t || old.isRamadan != isRamadan;
}

class _SurahNumberPainter extends CustomPainter {
  final int number;
  final Color color;
  _SurahNumberPainter({required this.number, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 1;

    canvas.drawCircle(c, r, Paint()..color = color.withOpacity(0.08));
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = color.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    for (int i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      canvas.drawCircle(
        Offset(c.dx + (r - 4) * math.cos(a), c.dy + (r - 4) * math.sin(a)),
        1.2,
        Paint()..color = color.withOpacity(0.4),
      );
    }

    final tp = TextPainter(
      text: TextSpan(
        text: _toArabic(number),
        style: GoogleFonts.amiri(
          fontSize: number > 99 ? 9 : 11,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.rtl,
    )..layout();
    tp.paint(canvas, Offset(c.dx - tp.width / 2, c.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(_SurahNumberPainter old) => old.number != number || old.color != color;
}

class _JuzRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color borderColor;

  _JuzRingPainter({
    required this.progress,
    required this.color,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 3;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5,
    );
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_JuzRingPainter old) => old.progress != progress;
}

String _toArabic(int n) {
  const d = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  return n.toString().split('').map((c) => d[int.parse(c)]).join();
}

String _toArabicWord(int n) {
  const words = [
    'الأول', 'الثاني', 'الثالث', 'الرابع', 'الخامس',
    'السادس', 'السابع', 'الثامن', 'التاسع', 'العاشر',
    'الحادي عشر', 'الثاني عشر', 'الثالث عشر', 'الرابع عشر', 'الخامس عشر',
    'السادس عشر', 'السابع عشر', 'الثامن عشر', 'التاسع عشر', 'العشرون',
    'الحادي والعشرون', 'الثاني والعشرون', 'الثالث والعشرون', 'الرابع والعشرون',
    'الخامس والعشرون', 'السادس والعشرون', 'السابع والعشرون', 'الثامن والعشرون',
    'التاسع والعشرون', 'الثلاثون'
  ];
  return n > 0 && n <= 30 ? words[n - 1] : '$n';
}

class _TabHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _TabHeaderDelegate({required this.child});

  @override
  Widget build(_, __, ___) => child;
  @override
  double get maxExtent => 70;
  @override
  double get minExtent => 70;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
