// ═══════════════════════════════════════════════════════════════
//  lib/features/quran/presentation/screens/khatma_progress_screen.dart
// ═══════════════════════════════════════════════════════════════

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takwa/features/quran/data/quran_models.dart';
import '../../providers/quran_providers.dart';
import '../../utils/quran_helpers.dart';
import 'package:takwa/core/widgets/custom_leading_button.dart';

const _kBg = Color(0xFF08121E);
const _kCard = Color(0xFF0F1E2D);
const _kGreen = Color(0xFF1A5234);
const _kGold = Color(0xFFC8A96E);
const _kBorder = Color(0xFF1E3040);

class KhatmaProgressSettingsScreen extends ConsumerWidget {
  const KhatmaProgressSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final khatma = ref.watch(khatmaExProvider);
    final pagesRead = khatma?.pagesRead ?? 0;
    final progress = khatma?.progress ?? 0.0;

    return Scaffold(
      backgroundColor: _kBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: _kBg,
            foregroundColor: _kGold,
            pinned: true,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.chevron_right, color: _kGold, size: 28),
            ),
            title: const Text(
              'تقدم الختمة',
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 24),
                _ProgressRing(progress: progress, pagesRead: pagesRead),
                const SizedBox(height: 8),
                Text(
                  '${(progress * 100).toStringAsFixed(1)}٪ مكتملة',
                  style: const TextStyle(
                    fontFamily: 'NotoNaskhArabic',
                    fontSize: 16,
                    color: _kGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                _buildStatsRow(khatma),
                const SizedBox(height: 24),
                _buildChart(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(KhatmaSessionEx? khatma) {
    final days = khatma != null
        ? DateTime.now().difference(khatma.startDate).inDays + 1
        : 0;
    final avgPerDay = days > 0
        ? (khatma!.pagesRead / days).toStringAsFixed(1)
        : '0';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          _StatCard(
            icon: Icons.timer_rounded,
            label: 'أيام',
            value: ar(days),
            color: _kGold,
          ),
          const SizedBox(width: 12),
          _StatCard(
            icon: Icons.auto_stories_rounded,
            label: 'صفحة مقروءة',
            value: ar(khatma?.pagesRead ?? 0),
            color: const Color(0xFF3AAFA9),
          ),
          const SizedBox(width: 12),
          _StatCard(
            icon: Icons.speed_rounded,
            label: 'صفحة/يوم',
            value: avgPerDay,
            color: const Color(0xFF4CAF7D),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    final values = [3.0, 5.0, 2.0, 7.0, 4.0, 6.0, 3.0];
    final days = ['أح', 'إث', 'ثل', 'أر', 'خم', 'جم', 'سب'];
    final max = values.reduce((a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            'القراءة الأسبوعية',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _kCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _kBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final h = (values[i] / max) * 100;
                return Expanded(
                  child: Column(
                    children: [
                      Text(
                        ar(values[i].toInt()),
                        style: const TextStyle(
                          fontFamily: 'NotoNaskhArabic',
                          fontSize: 10,
                          color: Colors.white38,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: Duration(milliseconds: 500 + i * 80),
                        width: 14,
                        height: h,
                        decoration: BoxDecoration(
                          color: i == 3 ? _kGold : _kGreen,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        days[i],
                        style: const TextStyle(
                          fontFamily: 'NotoNaskhArabic',
                          fontSize: 10,
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  final double progress;
  final int pagesRead;
  const _ProgressRing({required this.progress, required this.pagesRead});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(160, 160),
            painter: _RingPainter(progress),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ar(pagesRead),
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(
                'من ٦٠٤ صفحة',
                style: TextStyle(
                  fontFamily: 'NotoNaskhArabic',
                  fontSize: 11,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  const _RingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2, r = (size.width - 16) / 2;
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = Colors.white.withOpacity(0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10,
    );
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        -pi / 2,
        2 * pi * progress,
        false,
        Paint()
          ..shader = const LinearGradient(
            colors: [_kGold, Color(0xFFE4C98A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress;
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
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

// ─────────────────────────────────────────────────────────────
//  SETTINGS SCREEN
// ─────────────────────────────────────────────────────────────
class KhatmaExtendedSettingsScreen extends ConsumerWidget {
  const KhatmaExtendedSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quranStateProvider);

    return Scaffold(
      backgroundColor: _kBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          const SliverAppBar(
            backgroundColor: _kBg,
            foregroundColor: _kGold,
            pinned: true,
            leading: CustomLeadingButton(),
            title: Text(
              'الإعدادات',
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _sectionLabel('إعدادات القراءة'),
                  const SizedBox(height: 14),
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'حجم الخط',
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 17,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Slider(
                          value: state.fontSize,
                          min: 14,
                          max: 34,
                          activeColor: _kGold,
                          inactiveColor: Colors.white12,
                          onChanged: (v) => ref
                              .read(quranStateProvider.notifier)
                              .setFontSize(v),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ',
                              style: TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: state.fontSize,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'مظهر القراءة',
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 17,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            for (final theme in [
                              ('ليلي', ReaderTheme.night),
                              ('عاجي', ReaderTheme.sepia),
                              ('فاتح', ReaderTheme.white),
                            ])
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => ref
                                      .read(quranStateProvider.notifier)
                                      .setTheme(theme.$2),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: state.theme == theme.$2
                                          ? _kGold.withOpacity(0.2)
                                          : Colors.white10,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: state.theme == theme.$2
                                            ? _kGold
                                            : Colors.transparent,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        theme.$1,
                                        style: TextStyle(
                                          fontFamily: 'Amiri',
                                          fontSize: 14,
                                          color: state.theme == theme.$2
                                              ? _kGold
                                              : Colors.white54,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _sectionLabel('إعدادات الختمة'),
                  const SizedBox(height: 14),
                  _card(
                    child: Column(
                      children: [
                        _settingRow(
                          Icons.mic_rounded,
                          'القارئ',
                          'الشيخ المنشاوي',
                        ),
                        const Divider(color: Color(0xFF1E3040), height: 20),
                        _settingRow(
                          Icons.notifications_rounded,
                          'تذكير يومي',
                          '',
                          trailing: Switch(
                            value: false,
                            activeColor: _kGreen,
                            onChanged: (_) {},
                          ),
                        ),
                      ],
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

  Widget _sectionLabel(String t) => Text(
    t,
    style: const TextStyle(
      fontFamily: 'Amiri',
      fontSize: 16,
      color: Colors.white54,
      fontWeight: FontWeight.bold,
    ),
  );

  Widget _card({required Widget child}) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _kCard,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _kBorder),
    ),
    child: child,
  );

  Widget _settingRow(
    IconData icon,
    String label,
    String value, {
    Widget? trailing,
  }) => Row(
    children: [
      if (trailing != null) trailing,
      const Spacer(),
      Text(
        label,
        style: const TextStyle(
          fontFamily: 'NotoNaskhArabic',
          fontSize: 14,
          color: Colors.white70,
        ),
      ),
      const SizedBox(width: 8),
      Icon(icon, color: _kGold, size: 18),
      const SizedBox(width: 8),
      if (value.isNotEmpty)
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'NotoNaskhArabic',
            fontSize: 13,
            color: Colors.white38,
          ),
        ),
    ],
  );
}
