// ═══════════════════════════════════════════════════════════════
//  lib/features/quran/presentation/screens/khatma_history_screen.dart
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:takwa/core/widgets/custom_leading_button.dart';
import '../../providers/quran_providers.dart';
import '../../utils/quran_helpers.dart';

const _kBg = Color(0xFF08121E);
const _kCard = Color(0xFF0F1E2D);
const _kGreen = Color(0xFF1A5234);
const _kGold = Color(0xFFC8A96E);
const _kBorder = Color(0xFF1E3040);

class KhatmaHistoryScreen extends ConsumerStatefulWidget {
  const KhatmaHistoryScreen({super.key});
  @override
  ConsumerState<KhatmaHistoryScreen> createState() =>
      _KhatmaHistoryScreenState();
}

class _KhatmaHistoryScreenState extends ConsumerState<KhatmaHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  String? _toastMsg;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final completed = ref.watch(khatmaCompletedProvider);
    final cancelled = ref.watch(khatmaCancelledProvider);

    final completedCount = completed.value?.length ?? 0;
    final cancelledCount = cancelled.value?.length ?? 0;

    return Scaffold(
      backgroundColor: _kBg,
      bottomSheet: _toastMsg != null ? _buildToast() : null,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(completedCount, cancelledCount),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  _buildCompletedList(completed),
                  _buildCancelledList(cancelled),
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
            'تاريخ الختمات',
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

  Widget _buildTabBar(int completedCount, int cancelledCount) {
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
        indicatorWeight: 2,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white38,
        dividerColor: Colors.transparent,
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_outline, size: 16),
                const SizedBox(width: 6),
                Text(
                  'مكتملة ومنتهية ($completedCount)',
                  style: const TextStyle(
                    fontFamily: 'NotoNaskhArabic',
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.archive_outlined, size: 16),
                const SizedBox(width: 6),
                Text(
                  'ملغاة ($cancelledCount)',
                  style: const TextStyle(
                    fontFamily: 'NotoNaskhArabic',
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedList(AsyncValue<List<KhatmaSessionEx>> async) {
    return async.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(color: _kGreen)),
      error: (_, __) => const Center(
        child: Text('خطأ', style: TextStyle(color: Colors.white)),
      ),
      data: (list) {
        if (list.isEmpty) {
          return _buildEmpty(
            icon: Icons.history_rounded,
            title: 'لا توجد ختمات مكتملة أو منتهية',
            subtitle: 'ابدأ ختمة جديدة لتظهر هنا عند اكتمالها أو إنهائها',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (_, i) => _KhatmaCard(session: list[i], onDelete: null),
        );
      },
    );
  }

  Widget _buildCancelledList(AsyncValue<List<KhatmaSessionEx>> async) {
    return async.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(color: _kGreen)),
      error: (_, __) => const Center(
        child: Text('خطأ', style: TextStyle(color: Colors.white)),
      ),
      data: (list) {
        if (list.isEmpty) {
          return _buildEmpty(
            icon: Icons.archive_outlined,
            title: 'لا توجد ختمات ملغاة',
            subtitle: 'الختمات الملغاة ستظهر هنا',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (_, i) => _KhatmaCard(
            session: list[i],
            onDelete: () => _showDeleteConfirm(list[i]),
          ),
        );
      },
    );
  }

  Widget _buildEmpty({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 72, color: Colors.white.withOpacity(0.15)),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'NotoNaskhArabic',
              fontSize: 18,
              color: Colors.white38,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              subtitle,
              style: const TextStyle(
                fontFamily: 'NotoNaskhArabic',
                fontSize: 13,
                color: Colors.white24,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(KhatmaSessionEx session) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _kCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _kBorder),
        ),
        title: const Text(
          'حذف الختمة',
          textAlign: TextAlign.right,
          style: TextStyle(fontFamily: 'Amiri', color: Colors.white),
        ),
        content: const Text(
          'هل تريد حذف هذه الختمة نهائياً؟',
          textAlign: TextAlign.right,
          style: TextStyle(
            fontFamily: 'NotoNaskhArabic',
            color: Colors.white60,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showToast('تم حذف الختمة بنجاح');
              ref.invalidate(khatmaCancelledProvider);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showToast(String msg) {
    setState(() => _toastMsg = msg);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _toastMsg = null);
    });
  }

  Widget _buildToast() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: _kGreen,
      child: Text(
        _toastMsg ?? '',
        textAlign: TextAlign.right,
        style: const TextStyle(
          fontFamily: 'NotoNaskhArabic',
          fontSize: 14,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _KhatmaCard extends StatelessWidget {
  final KhatmaSessionEx session;
  final VoidCallback? onDelete;
  const _KhatmaCard({required this.session, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('d/M/yyyy');
    final days =
        (session.completedDate ?? session.cancelledDate ?? DateTime.now())
            .difference(session.startDate)
            .inDays +
        1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              if (onDelete != null)
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.redAccent,
                      size: 16,
                    ),
                  ),
                ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: session.isCompleted
                      ? _kGold.withOpacity(0.18)
                      : Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  session.isCompleted ? 'مكتملة' : 'ملغاة',
                  style: TextStyle(
                    fontFamily: 'NotoNaskhArabic',
                    fontSize: 12,
                    color: session.isCompleted ? _kGold : Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                session.label,
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: session.progress,
              backgroundColor: Colors.white.withOpacity(0.08),
              valueColor: AlwaysStoppedAnimation<Color>(
                session.isCompleted ? _kGold : Colors.white24,
              ),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _info(Icons.timer_rounded, '${ar(days)} يوم'),
              _info(
                Icons.auto_stories_rounded,
                '${ar(session.pagesRead)} / ${ar(KhatmaSessionEx.totalPages)} صفحة',
              ),
              _info(
                Icons.calendar_today_rounded,
                fmt.format(session.startDate),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _info(IconData icon, String text) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 12, color: Colors.white30),
      const SizedBox(width: 4),
      Text(
        text,
        style: const TextStyle(
          fontFamily: 'NotoNaskhArabic',
          fontSize: 11,
          color: Colors.white38,
        ),
      ),
    ],
  );
}
