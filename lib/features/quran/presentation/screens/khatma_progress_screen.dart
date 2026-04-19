// ═══════════════════════════════════════════════════════════════
//  lib/features/quran/presentation/screens/khatma_progress_screen.dart
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/quran_models.dart';
import '../../providers/quran_providers.dart';
import '../../utils/quran_helpers.dart';
import '../widgets/quran_widgets.dart';

class KhatmaProgressScreen extends ConsumerWidget {
  const KhatmaProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final khatma = ref.watch(khatmaProvider);
    final historyAsync = ref.watch(khatmaHistoryProvider);

    final pagesRead = khatma?.pagesRead ?? 0;
    final progress = khatma?.progress ?? 0.0;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: const Color.fromARGB(46, 4, 1, 35),
            foregroundColor: Colors.white,
            pinned: true,
            title: Text(
              'تقدم الختمة',
              style: GoogleFonts.amiri(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 30),
                // Progress ring
                KhatmaProgressRing(
                  progress: progress,
                  pagesRead: pagesRead,
                  totalPages: KhatmaSession.totalPages,
                ),
                const SizedBox(height: 8),
                Text(
                  '${(progress * 100).toStringAsFixed(1)}٪ مكتملة',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: kGoldChip,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                // Stats row
                _buildStatsRow(khatma, historyAsync),
                const SizedBox(height: 30),
                // Weekly chart
                _buildWeeklyChart(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(KhatmaSession? khatma, AsyncValue historyAsync) {
    final completedCount = historyAsync.maybeWhen(
      data: (list) =>
          (list as List<KhatmaSession>).where((s) => s.isCompleted).length,
      orElse: () => 0,
    );
    final daysSinceStart = khatma != null
        ? DateTime.now().difference(khatma.startDate).inDays + 1
        : 0;
    final avgPerDay = daysSinceStart > 0
        ? (khatma?.pagesRead ?? 0) / daysSinceStart
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          _StatCard(
            icon: Icons.check_circle_outline,
            label: 'ختمات مكتملة',
            value: ar(completedCount),
            color: kGoldChip,
          ),
          const SizedBox(width: 12),
          _StatCard(
            icon: Icons.local_fire_department_rounded,
            label: 'أيام متواصلة',
            value: ar(daysSinceStart),
            color: Colors.orangeAccent,
          ),
          const SizedBox(width: 12),
          _StatCard(
            icon: Icons.speed_rounded,
            label: 'صفحة/يوم',
            value: avgPerDay.toStringAsFixed(1),
            color: Colors.lightBlueAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    // Simulated 7-day chart
    final values = [3.0, 5.0, 2.0, 7.0, 4.0, 6.0, 3.0];
    final days = [
      'الأحد',
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
    ];
    final max = values.reduce((a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'القراءة الأسبوعية',
            style: GoogleFonts.amiri(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
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
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          color: Colors.white38,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: Duration(milliseconds: 600 + i * 80),
                        width: 16,
                        height: h,
                        decoration: BoxDecoration(
                          color: i == 3 ? kGoldChip : kGreenMid,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        days[i].substring(0, 2),
                        style: GoogleFonts.outfit(
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
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.amiri(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.outfit(fontSize: 10, color: Colors.white54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
