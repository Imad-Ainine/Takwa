// ═══════════════════════════════════════════════════════════════
//  lib/features/quran/presentation/screens/khatma_history_screen.dart
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:takwa/core/widgets/custom_leading_button.dart';
import '../../providers/quran_providers.dart';
import '../../utils/quran_helpers.dart';
import 'package:takwa/core/theme/ramadan_theme.dart';
import 'package:takwa/core/providers/database_providers.dart';

// Styles are managed via AdaptiveStyle

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
    final isRamadan = ref.watch(ramadanModeProvider).value ?? false;
    final style = AdaptiveStyle(context, isRamadan);

    final completed = ref.watch(khatmaCompletedProvider);
    final cancelled = ref.watch(khatmaCancelledProvider);

    final completedCount = completed.value?.length ?? 0;
    final cancelledCount = cancelled.value?.length ?? 0;

    return Scaffold(
      backgroundColor: style.bg,
      bottomSheet: _toastMsg != null ? _buildToast(style) : null,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(style),
            _buildTabBar(style, completedCount, cancelledCount),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  _buildCompletedList(style, completed),
                  _buildCancelledList(style, cancelled),
                ],
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
            'تاريخ الختمات',
            style: style.amiri(22, color: style.text, weight: FontWeight.bold),
          ),
          const Spacer(),
          const SizedBox(width: 28),
        ],
      ),
    );
  }

  Widget _buildTabBar(AdaptiveStyle style, int completedCount, int cancelledCount) {
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
        indicatorWeight: 2,
        labelColor: style.gold,
        unselectedLabelColor: style.textDim,
        dividerColor: Colors.transparent,
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_outline, size: 16),
                const SizedBox(width: 6),
                Text(
                  'مكتملة ($completedCount)',
                  style: style.naskh(13, weight: FontWeight.bold),
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
                  style: style.naskh(13, weight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedList(AdaptiveStyle style, AsyncValue<List<KhatmaSessionEx>> async) {
    return async.when(
      loading: () =>
          Center(child: CircularProgressIndicator(color: style.gold)),
      error: (_, __) => Center(
        child: Text('خطأ', style: style.naskh(14, color: style.text)),
      ),
      data: (list) {
        if (list.isEmpty) {
          return _buildEmpty(
            style: style,
            icon: Icons.history_rounded,
            title: 'لا توجد ختمات مكتملة أو منتهية',
            subtitle: 'ابدأ ختمة جديدة لتظهر هنا عند اكتمالها أو إنهائها',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (_, i) => _KhatmaCard(session: list[i], onDelete: null, style: style),
        );
      },
    );
  }

  Widget _buildCancelledList(AdaptiveStyle style, AsyncValue<List<KhatmaSessionEx>> async) {
    return async.when(
      loading: () =>
          Center(child: CircularProgressIndicator(color: style.gold)),
      error: (_, __) => Center(
        child: Text('خطأ', style: style.naskh(14, color: style.text)),
      ),
      data: (list) {
        if (list.isEmpty) {
          return _buildEmpty(
            style: style,
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
            onDelete: () => _showDeleteConfirm(style, list[i]),
            style: style,
          ),
        );
      },
    );
  }

  Widget _buildEmpty({
    required AdaptiveStyle style,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 72, color: style.textDim.withOpacity(0.15)),
          const SizedBox(height: 20),
          Text(
            title,
            style: style.naskh(18, color: style.textDim),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              subtitle,
              style: style.naskh(13, color: style.textSec.withOpacity(0.5)),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(AdaptiveStyle style, KhatmaSessionEx session) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: style.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: style.border),
        ),
        title: Text(
          'حذف الختمة',
          textAlign: TextAlign.right,
          style: style.amiri(20, color: style.text, weight: FontWeight.bold),
        ),
        content: Text(
          'هل تريد حذف هذه الختمة نهائياً؟',
          textAlign: TextAlign.right,
          style: style.naskh(14, color: style.textSec),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: style.naskh(14, color: style.textDim)),
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

  Widget _buildToast(AdaptiveStyle style) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: style.gold.withOpacity(0.9),
      child: Text(
        _toastMsg ?? '',
        textAlign: TextAlign.right,
        style: style.naskh(14, color: Colors.white, weight: FontWeight.bold),
      ),
    );
  }
}

class _KhatmaCard extends StatelessWidget {
  final KhatmaSessionEx session;
  final VoidCallback? onDelete;
  final AdaptiveStyle style;
  const _KhatmaCard({required this.session, required this.onDelete, required this.style});

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
        color: style.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: style.border),
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
                      ? style.gold.withOpacity(0.18)
                      : Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  session.isCompleted ? 'مكتملة' : 'ملغاة',
                  style: style.naskh(12, 
                    color: session.isCompleted ? style.gold : Colors.redAccent,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                session.label,
                style: style.amiri(18, color: style.text, weight: FontWeight.bold),
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
                session.isCompleted ? style.gold : style.textDim,
              ),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfo(style, Icons.timer_rounded, '${ar(days)} يوم'),
              _buildInfo(
                style,
                Icons.auto_stories_rounded,
                '${ar(session.pagesRead)} / ${ar(KhatmaSessionEx.totalPages)} صفحة',
              ),
              _buildInfo(
                style,
                Icons.calendar_today_rounded,
                fmt.format(session.startDate),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfo(AdaptiveStyle style, IconData icon, String text) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 12, color: style.textDim),
      const SizedBox(width: 4),
      Text(
        text,
        style: style.naskh(11, color: style.textSec),
      ),
    ],
  );
}
