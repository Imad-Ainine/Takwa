import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takwa/core/database/app_database.dart';
import 'package:takwa/core/providers/database_providers.dart';
import 'package:takwa/core/theme/app_theme.dart';
import 'package:takwa/core/widgets/custom_leading_button.dart';
import 'package:takwa/core/supabase/sync_manager.dart';
import 'package:takwa/core/widgets/custom_pattern_background.dart';
import 'package:takwa/features/reminders/presentation/widgets/advice_card.dart';
import 'package:takwa/features/reminders/presentation/widgets/reminder_card.dart';
import 'package:takwa/core/widgets/takwa_loading_indicator.dart';
import 'package:takwa/features/reminders/presentation/widgets/add_reminder_bottom_sheet.dart';

class RemindersListScreen extends ConsumerWidget {
  const RemindersListScreen({super.key});

  void _showAddReminderSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddReminderBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(remindersProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      body: Stack(
        children: [
          const Positioned.fill(
            child: CustomPatternBackground(pattern: BackgroundPattern.adhkar),
          ),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(context),
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildAddReminderButton(context),
                    const SizedBox(height: 28),
                    remindersAsync.when(
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.xxxl),
                          child: TakwaLoadingIndicator(size: 32),
                        ),
                      ),
                      error: (e, _) => Center(
                        child: Text(
                          'حدث خطأ: $e',
                          style: context.typography.bodySmall,
                        ),
                      ),
                      data: (reminders) => reminders.isEmpty
                          ? _buildEmptyState(context)
                          : _buildRemindersList(context, ref, reminders),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                    const AdviceCard(
                      title: 'نصيحة',
                      description:
                          'المداومة على الأذكار اليومية تجلب السكينة والطمأنينة للقلب. احرص على تفعيل التذكيرات لتبقى على اتصال دائم بالله.',
                    ),
                    const SizedBox(height: 48),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      leading: const CustomLeadingButton(),
      title: Text(
        'التذكيرات',
        style: context.typography.headingMedium.copyWith(
          color: context.colors.gold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildAddReminderButton(BuildContext context) {
    return InkWell(
      onTap: () => _showAddReminderSheet(context),
      borderRadius: AppRadius.card,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.xxl,
          horizontal: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: context.colors.card.withOpacity(0.85),
          borderRadius: AppRadius.card,
          border: Border.all(
            color: context.colors.teal.withOpacity(0.35),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.colors.tealDim,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_rounded,
                color: context.colors.teal,
                size: 32,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'إضافة تذكير جديد',
              style: context.typography.headingMedium.copyWith(
                color: context.colors.teal,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'اضغط هنا لإنشاء تذكير مخصص',
              style: context.typography.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
      child: Column(
        children: [
          Icon(
            Icons.notifications_off_rounded,
            size: 64,
            color: context.colors.textDim,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'لا يوجد تذكيرات بعد',
            style: context.typography.headingMedium.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'أضف أول تذكير لك بالضغط على الزر أعلاه',
            style: context.typography.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersList(
    BuildContext context,
    WidgetRef ref,
    List<Reminder> reminders,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('تذكيراتي', style: context.typography.headingMedium),
            const Spacer(),
            TaqwaBadge(
              label: '${reminders.length} تذكير',
              color: context.colors.teal,
              bgColor: context.colors.tealDim,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        ...reminders.map(
          (reminder) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Dismissible(
              key: ValueKey(reminder.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: context.colors.dangerDim,
                  borderRadius: AppRadius.card,
                  border: Border.all(
                    color: context.colors.danger.withOpacity(0.3),
                  ),
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: context.colors.danger,
                ),
              ),
              confirmDismiss: (_) async {
                return await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('حذف التذكير'),
                    content: Text('هل تريد حذف "${reminder.title}"؟'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('إلغاء'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text(
                          'حذف',
                          style: TextStyle(color: context.colors.danger),
                        ),
                      ),
                    ],
                  ),
                );
              },
              onDismissed: (_) {
                ref.read(remindersDaoProvider).deleteReminder(reminder.id);
                ref.read(syncManagerProvider).deleteReminder(reminder.id);
              },
              child: ReminderCard(
                title: reminder.title,
                time: _formatTime(reminder.time),
                iconKey: reminder.iconName,
                isEnabled: reminder.isEnabled,
                onToggle: (val) {
                  ref
                      .read(remindersDaoProvider)
                      .toggleEnabled(reminder.id, val);
                  // Sync updated reminder
                  ref
                      .read(syncManagerProvider)
                      .syncReminder(reminder.copyWith(isEnabled: val));
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Convert 24h "HH:mm" stored time to a localized display string
  String _formatTime(String time24) {
    try {
      final parts = time24.split(':');
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final period = h >= 12 ? 'م' : 'ص';
      final displayH = h % 12 == 0 ? 12 : h % 12;
      return '$displayH:${m.toString().padLeft(2, '0')} $period';
    } catch (_) {
      return time24;
    }
  }
}
