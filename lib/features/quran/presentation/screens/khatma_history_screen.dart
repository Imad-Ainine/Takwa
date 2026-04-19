// ═══════════════════════════════════════════════════════════════
//  lib/features/quran/presentation/screens/khatma_history_screen.dart
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../data/quran_models.dart';
import '../../providers/quran_providers.dart';
import '../../utils/quran_helpers.dart';

class KhatmaHistoryScreen extends ConsumerWidget {
  const KhatmaHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(khatmaHistoryProvider);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: const Color.fromARGB(46, 4, 1, 35),
            foregroundColor: Colors.white,
            pinned: true,
            title: Text(
              'تاريخ الختمات',
              style: GoogleFonts.amiri(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          historyAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: kGoldChip)),
            ),
            error: (e, _) => const SliverFillRemaining(
              child: Center(
                child: Text('خطأ', style: TextStyle(color: Colors.white)),
              ),
            ),
            data: (history) {
              if (history.isEmpty) {
                return SliverFillRemaining(child: _buildEmpty());
              }
              return SliverPadding(
                padding: const EdgeInsets.all(18),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _KhatmaHistoryCard(session: history[i]),
                    childCount: history.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.menu_book_outlined, size: 72, color: Colors.white24),
          const SizedBox(height: 20),
          Text(
            'لا توجد ختمات مكتملة بعد',
            style: GoogleFonts.amiri(fontSize: 20, color: Colors.white54),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ ختمتك الأولى من الشاشة الرئيسية',
            style: GoogleFonts.outfit(fontSize: 13, color: Colors.white38),
          ),
        ],
      ),
    );
  }
}

class _KhatmaHistoryCard extends StatelessWidget {
  final KhatmaSession session;
  const _KhatmaHistoryCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMMM yyyy', 'ar');
    final startStr = dateFormat.format(session.startDate);
    final endStr = session.completedDate != null
        ? dateFormat.format(session.completedDate!)
        : 'جارية';
    final duration = (session.completedDate ?? DateTime.now())
        .difference(session.startDate)
        .inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: session.isCompleted
                      ? kGoldChip.withOpacity(0.2)
                      : kGreenMid.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  session.isCompleted ? 'مكتملة' : 'جارية',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: session.isCompleted ? kGoldChip : Colors.greenAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                session.label,
                style: GoogleFonts.amiri(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: session.progress,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(
                session.isCompleted ? kGoldChip : kGreenMid,
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _info(Icons.calendar_today_rounded, 'بدأت: $startStr'),
              const Spacer(),
              _info(Icons.flag_rounded, 'انتهت: $endStr'),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _info(
                Icons.auto_stories_rounded,
                '${ar(session.pagesRead)} / ${ar(KhatmaSession.totalPages)} صفحة',
              ),
              const Spacer(),
              _info(Icons.timer_rounded, '${ar(duration)} يوم'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _info(IconData icon, String text) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 13, color: Colors.white38),
      const SizedBox(width: 5),
      Text(
        text,
        style: GoogleFonts.outfit(fontSize: 11, color: Colors.white54),
      ),
    ],
  );
}
