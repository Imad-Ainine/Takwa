import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:takwa/core/widgets/takwa_loading_indicator.dart';
import 'package:takwa/core/widgets/custom_leading_button.dart';
import '../../data/quran_models.dart';
import '../../providers/quran_providers.dart';
import '../../utils/quran_helpers.dart';
import 'package:takwa/core/theme/ramadan_theme.dart';
import 'package:takwa/core/providers/database_providers.dart';
import 'package:takwa/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
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
            _buildHeader(style, l10n),
            _buildTabBar(style, l10n, completedCount, cancelledCount),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  _buildCompletedList(style, l10n, completed),
                  _buildCancelledList(style, l10n, cancelled),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AdaptiveStyle style, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
      child: Row(
        children: [
          const CustomLeadingButton(),
          const Spacer(),
          Text(
            l10n.khatmaHistoryTitle,
            style: style.amiri(22, color: style.text, weight: FontWeight.bold),
          ),
          const Spacer(),
          const SizedBox(width: 28),
        ],
      ),
    );
  }

  Widget _buildTabBar(
    AdaptiveStyle style,
    AppLocalizations l10n,
    int completedCount,
    int cancelledCount,
  ) {
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
                  l10n.khatmaHistoryCompletedTab(completedCount.toString()),
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
                  l10n.khatmaHistoryCancelledTab(cancelledCount.toString()),
                  style: style.naskh(13, weight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedList(
    AdaptiveStyle style,
    AppLocalizations l10n,
    AsyncValue<List<KhatmaSessionEx>> async,
  ) {
    return async.when(
      loading: () => const Center(child: TakwaLoadingIndicator()),
      error: (_, __) => Center(
        child: Text(l10n.khatmaHistoryError, style: style.naskh(14, color: style.text)),
      ),
      data: (list) {
        if (list.isEmpty) {
          return _buildEmpty(
            style: style,
            icon: Icons.history_rounded,
            title: l10n.khatmaHistoryEmptyCompletedTitle,
            subtitle: l10n.khatmaHistoryEmptyCompletedSubtitle,
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: list.length,
          itemBuilder: (_, i) =>
              _KhatmaCard(session: list[i], onDelete: null, style: style),
        );
      },
    );
  }

  Widget _buildCancelledList(
    AdaptiveStyle style,
    AppLocalizations l10n,
    AsyncValue<List<KhatmaSessionEx>> async,
  ) {
    return async.when(
      loading: () => const Center(child: TakwaLoadingIndicator()),
      error: (_, __) => Center(
        child: Text(l10n.khatmaHistoryError, style: style.naskh(14, color: style.text)),
      ),
      data: (list) {
        if (list.isEmpty) {
          return _buildEmpty(
            style: style,
            icon: Icons.archive_outlined,
            title: l10n.khatmaHistoryEmptyCancelledTitle,
            subtitle: l10n.khatmaHistoryEmptyCancelledSubtitle,
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.lg),
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
          Icon(icon, size: 72, color: style.textDim.withValues(alpha: 0.15)),
          const SizedBox(height: AppSpacing.xl),
          Text(
            title,
            style: style.naskh(18, color: style.textDim),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              subtitle,
              style: style.naskh(13, color: style.textSec.withValues(alpha: 0.5)),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(AdaptiveStyle style, KhatmaSessionEx session) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: style.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: style.border),
        ),
        title: Text(
          l10n.khatmaHistoryDeleteTitle,
          textAlign: TextAlign.right,
          style: style.amiri(20, color: style.text, weight: FontWeight.bold),
        ),
        content: Text(
          l10n.khatmaHistoryDeleteConfirm,
          textAlign: TextAlign.right,
          style: style.naskh(14, color: style.textSec),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.adhkarCancelButton,
              style: style.naskh(14, color: style.textDim),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showToast(l10n.khatmaHistoryDeletedToast);
              ref.invalidate(khatmaCancelledProvider);
            },
            child: Text(
              l10n.adhkarDeleteTooltip,
              style: const TextStyle(color: Colors.redAccent),
            ),
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: 14,
      ),
      color: style.gold.withValues(alpha: 0.9),
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
  const _KhatmaCard({
    required this.session,
    required this.onDelete,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final fmt = DateFormat('d/M/yyyy');
    final days =
        (session.completedDate ?? session.cancelledDate ?? DateTime.now())
            .difference(session.startDate)
            .inDays +
        1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: style.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
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
                      color: Colors.redAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
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
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: session.isCompleted
                      ? style.gold.withValues(alpha: 0.18)
                      : Colors.redAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  session.isCompleted
                      ? l10n.khatmaHistoryStatusCompleted
                      : l10n.khatmaHistoryStatusCancelled,
                  style: style.naskh(
                    12,
                    color: session.isCompleted ? style.gold : Colors.redAccent,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                session.label,
                style: style.amiri(
                  18,
                  color: style.text,
                  weight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: session.progress,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
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
              _buildInfo(
                style,
                Icons.timer_rounded,
                l10n.khatmaHistoryDaysLabel(localizedNumeral(context, days)),
              ),
              _buildInfo(
                style,
                Icons.auto_stories_rounded,
                l10n.khatmaHistoryPagesProgress(
                  localizedNumeral(context, session.pagesRead),
                  localizedNumeral(context, KhatmaSessionEx.totalPages),
                ),
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
      const SizedBox(width: AppSpacing.xs),
      Text(text, style: style.naskh(11, color: style.textSec)),
    ],
  );
}
