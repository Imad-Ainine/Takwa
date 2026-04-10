// ═══════════════════════════════════════════════════════════════
//  lib/onboarding_screen.dart — شاشة التعريف
// ═══════════════════════════════════════════════════════════════

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:muhasabah/core/theme/app_theme.dart';
import 'package:muhasabah/app/main_shell.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muhasabah/core/providers/database_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageCtrl = PageController();
  int _currentPage = 0;
  late final AnimationController _bgCtrl;

  static const _pages = [
    _PageData(
      emoji: '🤲',
      title: 'محاسبة النفس',
      hadith: '«الكيِّسُ مَن دانَ نفسَه وعمِلَ لِما بعدَ الموتِ»',
      hadithSource: 'رواه الترمذي',
      subtitle: 'حاسب نفسك قبل أن تُحاسَب',
      color: Color(0xFFC8A96E),
    ),
    _PageData(
      emoji: '📿',
      title: 'تتبّع عباداتك',
      hadith: '«أحبُّ الأعمالِ إلى اللهِ أدومُها وإن قَلّ»',
      hadithSource: 'متفق عليه',
      subtitle: 'صلاة • قرآن • أذكار • صيام • صدقة',
      color: Color(0xFF3AAFA9),
    ),
    _PageData(
      emoji: '📊',
      title: 'إحصائيات وتقارير',
      hadith: '«إنَّ اللهَ يُحبُّ إذا عَمِلَ أحدُكم عملًا أن يُتقنَه»',
      hadithSource: 'رواه البيهقي',
      subtitle: 'راقب تقدّمك يوميًا وابنِ عادات صالحة',
      color: Color(0xFF7D5FFF),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _bgCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _goToApp();
    }
  }

  void _goToApp() async {
    await ref.read(settingsDaoProvider).set('onboardingDone', 'true');
    if (mounted) {
      ref.invalidate(onboardingDoneProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];

    return Scaffold(
      backgroundColor: AppColors.night,
      body: Stack(
        children: [
          // ── Animated Background ──
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgCtrl,
              builder: (_, __) => CustomPaint(
                painter: _OrbPainter(
                  progress: _bgCtrl.value,
                  color: page.color,
                ),
              ),
            ),
          ),

          // ── Content ──
          SafeArea(
            child: Column(
              children: [
                // Skip
                Align(
                  alignment: Alignment.topLeft,
                  child: TextButton(
                    onPressed: _goToApp,
                    child: Text(
                      'تخطّ',
                      style: GoogleFonts.notoNaskhArabic(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

                // Pages
                Expanded(
                  child: PageView.builder(
                    controller: _pageCtrl,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemCount: _pages.length,
                    itemBuilder: (_, i) => _OnboardingPage(data: _pages[i]),
                  ),
                ),

                // Indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == i ? 22 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == i
                            ? page.color
                            : AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [page.color, page.color.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: page.color.withOpacity(0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _next,
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              _currentPage == _pages.length - 1
                                  ? 'ابدأ الآن 🚀'
                                  : 'التالي ←',
                              style: GoogleFonts.notoNaskhArabic(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Page Widget ────────────────────────────────────────────────
class _OnboardingPage extends StatelessWidget {
  final _PageData data;
  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Emoji
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: data.color.withOpacity(0.3), width: 2),
            ),
            child: Center(
              child: Text(data.emoji, style: const TextStyle(fontSize: 52)),
            ),
          ),
          const SizedBox(height: 28),

          // Title
          Text(
            data.title,
            style: GoogleFonts.amiri(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: data.color,
            ),
          ),
          const SizedBox(height: 16),

          // Subtitle
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.notoNaskhArabic(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 28),

          // Hadith card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: data.color.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Text(
                  data.hadith,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.amiri(
                    fontSize: 17,
                    color: AppColors.textPrimary,
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data.hadithSource,
                  style: GoogleFonts.notoNaskhArabic(
                    fontSize: 11,
                    color: data.color,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data ───────────────────────────────────────────────────────
class _PageData {
  final String emoji;
  final String title;
  final String hadith;
  final String hadithSource;
  final String subtitle;
  final Color color;
  const _PageData({
    required this.emoji,
    required this.title,
    required this.hadith,
    required this.hadithSource,
    required this.subtitle,
    required this.color,
  });
}

// ── Background Painter ─────────────────────────────────────────
class _OrbPainter extends CustomPainter {
  final double progress;
  final Color color;
  const _OrbPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.3;
    final r = size.width * 0.7;
    final angle = progress * 2 * math.pi;

    void orb(double dx, double dy, double radius, double opacity) {
      canvas.drawCircle(
        Offset(cx + dx, cy + dy),
        radius,
        Paint()
          ..shader =
              RadialGradient(
                colors: [color.withOpacity(opacity), Colors.transparent],
              ).createShader(
                Rect.fromCircle(
                  center: Offset(cx + dx, cy + dy),
                  radius: radius,
                ),
              ),
      );
    }

    orb(math.cos(angle) * 40, math.sin(angle) * 40, r * 0.55, 0.12);
    orb(
      math.cos(angle + math.pi) * 30,
      math.sin(angle + math.pi) * 30,
      r * 0.4,
      0.08,
    );
  }

  @override
  bool shouldRepaint(_OrbPainter old) =>
      old.progress != progress || old.color != color;
}
