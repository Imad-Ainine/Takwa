import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takwa/core/database/app_database.dart';
import 'package:takwa/core/providers/database_providers.dart';
import 'package:takwa/core/supabase/sync_manager.dart';
import 'package:takwa/core/theme/app_theme.dart';
import 'package:takwa/core/routes/app_routes.dart';

final activePositiveIbadahProvider = StreamProvider(
  (ref) => ref.watch(customIbadahDaoProvider).watchActiveIbadat(true),
);
final activeNegativeIbadahProvider = StreamProvider(
  (ref) => ref.watch(customIbadahDaoProvider).watchActiveIbadat(false),
);
final allPositiveIbadahProvider = StreamProvider(
  (ref) => ref.watch(customIbadahDaoProvider).watchAllIbadat(true),
);
final allNegativeIbadahProvider = StreamProvider(
  (ref) => ref.watch(customIbadahDaoProvider).watchAllIbadat(false),
);
final customLogsProvider = StreamProvider.family(
  (ref, DateTime date) =>
      ref.watch(customIbadahDaoProvider).watchLogsForDate(date),
);

class CustomIbadahGroup extends ConsumerWidget {
  final DailyRecord? record;
  const CustomIbadahGroup({super.key, required this.record});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (record == null) return const SizedBox.shrink();

    final positiveAsync = ref.watch(activePositiveIbadahProvider);
    final negativeAsync = ref.watch(activeNegativeIbadahProvider);
    final logsAsync = ref.watch(customLogsProvider(record!.date));

    final positiveIbadat = positiveAsync.valueOrNull ?? [];
    final negativeIbadat = negativeAsync.valueOrNull ?? [];
    final logs = logsAsync.valueOrNull ?? [];

    if (positiveIbadat.isEmpty && negativeIbadat.isEmpty) {
      return _buildCard(
        context,
        icon: '✨',
        title: 'عاداتي وإضافاتي',
        children: [
          Center(
            child: TextButton.icon(
              onPressed: () => _manageCustomIbadah(context),
              icon: const Icon(Icons.add_circle_outline, size: 20),
              label: const Text(
                'إضافة وتخصيص عاداتك',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return _buildCard(
      context,
      icon: '✨',
      title: 'عاداتي وإضافاتي',
      trailingWidget: InkWell(
        onTap: () => _manageCustomIbadah(context),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: Icon(Icons.settings, size: 18, color: context.colors.textDim),
        ),
      ),
      children: [
        if (positiveIbadat.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, right: 4),
            child: Text(
              'العادات الإيجابية',
              style: context.typography.caption.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: context.colors.gold,
              ),
            ),
          ),
          ...positiveIbadat.map((item) {
            final log = logs.where((l) => l.ibadahId == item.id).firstOrNull;
            return _CustomIbadahRow(
              ibadah: item,
              log: log,
              recordId: record!.id,
              recordDate: record!.date,
            );
          }),
        ],
        if (negativeIbadat.isNotEmpty) ...[
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, right: 4),
            child: Text(
              'العادات السلبية (محظورات مخصصة)',
              style: context.typography.caption.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: context.colors.danger,
              ),
            ),
          ),
          ...negativeIbadat.map((item) {
            final log = logs.where((l) => l.ibadahId == item.id).firstOrNull;
            return _CustomIbadahRow(
              ibadah: item,
              log: log,
              recordId: record!.id,
              recordDate: record!.date,
            );
          }),
        ],
      ],
    );
  }

  void _manageCustomIbadah(BuildContext context) {
    Navigator.of(context).pushNamed(Routes.manageCustomIbadah);
  }

  Widget _buildCard(
    BuildContext context, {
    required String icon,
    required String title,
    Widget? trailingWidget,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: context.typography.headingMedium.copyWith(
                    fontSize: 15,
                  ),
                ),
              ),
              if (trailingWidget != null) trailingWidget,
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ...children,
        ],
      ),
    );
  }
}

class _CustomIbadahRow extends ConsumerStatefulWidget {
  final CustomIbadahData ibadah;
  final CustomIbadahLogData? log;
  final int recordId;
  final DateTime recordDate;

  const _CustomIbadahRow({
    required this.ibadah,
    required this.log,
    required this.recordId,
    required this.recordDate,
  });

  @override
  ConsumerState<_CustomIbadahRow> createState() => _CustomIbadahRowState();
}

class _CustomIbadahRowState extends ConsumerState<_CustomIbadahRow> {
  bool _committed = false;
  int _count = 0;

  @override
  void initState() {
    super.initState();
    if (widget.log != null) {
      _committed = widget.log!.done;
      _count = widget.log!.count;
    }
  }

  @override
  void didUpdateWidget(covariant _CustomIbadahRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update internal state if the log is non-null.
    // This prevents the UI from flickering to 'unchecked' while the stream is loading.
    if (widget.log != null) {
      _committed = widget.log!.done;
      _count = widget.log!.count;
    }
  }

  Future<void> _toggle() async {
    HapticFeedback.selectionClick();
    final newVal = !_committed;
    setState(() {
      _committed = newVal;
      if (!newVal) {
        _count = 0;
      } else if (_count == 0) {
        _count = 1;
      }
    });

    await ref
        .read(customIbadahDaoProvider)
        .logIbadah(widget.ibadah.id, widget.recordDate, _committed, _count);
    await ref
        .read(syncManagerProvider)
        .syncCustomIbadahLog(
          CustomIbadahLogData(
            id: widget.log?.id ?? 0,
            ibadahId: widget.ibadah.id,
            recordId: widget.recordId,
            date: widget.recordDate,
            done: _committed,
            count: _count,
          ),
        );
    // update record points?
    // Wait, CustomIbadah needs a recalc points too
  }

  Future<void> _increment() async {
    if (!_committed) return;
    HapticFeedback.selectionClick();
    setState(() => _count++);
    await ref
        .read(customIbadahDaoProvider)
        .logIbadah(widget.ibadah.id, widget.recordDate, _committed, _count);
    await ref
        .read(syncManagerProvider)
        .syncCustomIbadahLog(
          CustomIbadahLogData(
            id: widget.log?.id ?? 0,
            ibadahId: widget.ibadah.id,
            recordId: widget.recordId,
            date: widget.recordDate,
            done: _committed,
            count: _count,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final isPos = widget.ibadah.isPositive;
    final color = isPos ? context.colors.success : context.colors.danger;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: _committed ? color.withOpacity(0.07) : context.colors.card,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: _committed ? color.withOpacity(0.25) : context.colors.border,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _toggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.xs),
                color: _committed ? color : Colors.transparent,
                border: Border.all(
                  color: _committed ? color : context.colors.border,
                  width: 1.8,
                ),
              ),
              child: _committed
                  ? Center(
                      child: Text(
                        isPos ? '✓' : '✗',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Text(widget.ibadah.emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.ibadah.nameAr,
                  style: context.typography.bodyMedium.copyWith(
                    fontSize: 13,
                    color: _committed ? color : context.colors.textPrimary,
                    fontWeight: _committed ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          if (_committed) ...[
            GestureDetector(
              onTap: isPos ? null : _increment,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isPos) ...[
                      const SizedBox(width: 2),
                      Icon(Icons.add, size: 10, color: color),
                      const SizedBox(width: AppSpacing.xs),
                    ],
                    Text(
                      '$_count',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
