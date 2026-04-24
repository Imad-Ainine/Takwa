// ═══════════════════════════════════════════════════════════════
//  lib/features/quran/presentation/screens/khatma_progress_screen.dart
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/quran_models.dart';
import '../../providers/quran_providers.dart';
import 'package:takwa/core/widgets/custom_leading_button.dart';
import '../../utils/quran_helpers.dart';
import '../widgets/quran_widgets.dart';
import 'package:takwa/core/theme/ramadan_theme.dart';
import 'package:takwa/core/providers/database_providers.dart';

class KhatmaProgressScreen extends ConsumerWidget {
  const KhatmaProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRamadan = ref.watch(ramadanModeProvider).value ?? false;
    final style = AdaptiveStyle(context, isRamadan);

    final khatma = ref.watch(khatmaProvider);
    final historyAsync = ref.watch(khatmaHistoryProvider);

    final pagesRead = khatma?.pagesRead ?? 0;
    final progress = khatma?.progress ?? 0.0;

    return Scaffold(
      backgroundColor: style.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: style.isRamadan ? style.bg : const Color.fromARGB(46, 4, 1, 35),
            foregroundColor: style.text,
            pinned: true,
            leading: const CustomLeadingButton(),
            title: Text(
              'تقدم الختمة',
              style: style.amiri(22, color: style.text, weight: FontWeight.bold),
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
                  style: style,
                  color: style.gold,
                ),
                const SizedBox(height: 12),
                Text(
                  '${(progress * 100).toStringAsFixed(1)}٪ مكتملة',
                  style: style.naskh(16, color: style.gold, weight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                // Stats row
                _buildStatsRow(style, khatma, historyAsync),
                const SizedBox(height: 30),
                // Weekly chart
                _buildWeeklyChart(style),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(AdaptiveStyle style, KhatmaSession? khatma, AsyncValue historyAsync) {
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
            style: style,
            icon: Icons.check_circle_outline,
            label: 'ختمات مكتملة',
            value: ar(completedCount),
            color: style.gold,
          ),
          const SizedBox(width: 12),
          _StatCard(
            style: style,
            icon: Icons.local_fire_department_rounded,
            label: 'أيام متواصلة',
            value: ar(daysSinceStart),
            color: Colors.orangeAccent,
          ),
          const SizedBox(width: 12),
          _StatCard(
            style: style,
            icon: Icons.speed_rounded,
            label: 'صفحة/يوم',
            value: avgPerDay.toStringAsFixed(1),
            color: Colors.lightBlueAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(AdaptiveStyle style) {
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
            style: style.amiri(18, color: style.text, weight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: style.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: style.border),
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
                        style: style.naskh(10, color: style.textDim),
                      ),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: Duration(milliseconds: 600 + i * 80),
                        width: 16,
                        height: h,
                        decoration: BoxDecoration(
                          color: i == 3 ? style.gold : style.gold.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        days[i].substring(0, 2),
                        style: style.naskh(10, color: style.textDim),
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
  final AdaptiveStyle style;
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: style.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: style.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: style.amiri(20, color: style.text, weight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: style.naskh(10, color: style.textSec),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
