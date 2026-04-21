import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takwa/core/providers/database_providers.dart';
import 'package:takwa/core/theme/app_theme.dart';
import 'package:takwa/core/widgets/primary_button.dart';

/// Map from human-readable icon key to IconData.
/// Used to persist and restore icons from the database.
const Map<String, IconData> kReminderIcons = {
  'favorite_rounded': Icons.favorite_rounded,
  'mosque_rounded': Icons.mosque_rounded,
  'book_rounded': Icons.book_rounded,
  'water_drop_rounded': Icons.water_drop_rounded,
  'volunteer_activism_rounded': Icons.volunteer_activism_rounded,
  'wb_sunny_rounded': Icons.wb_sunny_rounded,
  'nightlight_round': Icons.nightlight_round,
  'self_improvement_rounded': Icons.self_improvement_rounded,
};

class AddReminderBottomSheet extends ConsumerStatefulWidget {
  const AddReminderBottomSheet({super.key});

  @override
  ConsumerState<AddReminderBottomSheet> createState() =>
      _AddReminderBottomSheetState();
}

class _AddReminderBottomSheetState
    extends ConsumerState<AddReminderBottomSheet> {
  final _titleController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedIconKey = 'favorite_rounded';

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: context.colors.gold,
              onPrimary: context.colors.background,
              surface: context.colors.card,
              onSurface: context.colors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    // Store time as padded 24h "HH:mm"
    final hour = _selectedTime.hour.toString().padLeft(2, '0');
    final minute = _selectedTime.minute.toString().padLeft(2, '0');
    final timeStr = '$hour:$minute';

    try {
      await ref
          .read(remindersDaoProvider)
          .addReminder(title: title, iconName: _selectedIconKey, time: timeStr);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('حدث خطأ أثناء الحفظ: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: context.colors.border)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.colors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: context.colors.tealGoldGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.notifications_active_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'إضافة تذكير جديد',
                      style: context.typography.headingMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // ── عنوان التذكير ──
                Text('عنوان التذكير', style: context.typography.labelLarge),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  style: context.typography.bodyMedium,
                  textDirection: TextDirection.rtl,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'يرجى إدخال عنوان للتذكير';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'مثال: صلاة الضحى، قراءة ورد يومي...',
                    hintStyle: context.typography.bodyMedium.copyWith(
                      color: context.colors.textDim,
                    ),
                    prefixIcon: Icon(
                      Icons.edit_rounded,
                      size: 18,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── وقت التذكير ──
                Text('وقت التذكير', style: context.typography.labelLarge),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _selectTime(context),
                  borderRadius: AppRadius.input,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.card2,
                      borderRadius: AppRadius.input,
                      border: Border.all(color: context.colors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          color: context.colors.gold,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _selectedTime.format(context),
                          style: context.typography.bodyLarge.copyWith(
                            color: context.colors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.chevron_left_rounded,
                          color: context.colors.textDim,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── اختر الأيقونة ──
                Text('أيقونة التذكير', style: context.typography.labelLarge),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: kReminderIcons.entries.map((entry) {
                    final isSelected = _selectedIconKey == entry.key;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIconKey = entry.key),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: isSelected ? null : context.colors.card2,
                          gradient: isSelected
                              ? context.colors.tealGoldGradient
                              : null,
                          borderRadius: BorderRadius.circular(16),
                          border: isSelected
                              ? null
                              : Border.all(color: context.colors.border),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: context.colors.teal.withOpacity(0.3),
                                    blurRadius: 12,
                                    spreadRadius: 0,
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Icon(
                            entry.value,
                            color: isSelected
                                ? Colors.white
                                : context.colors.textSecondary,
                            size: 24,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 36),

                // ── Buttons ──
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        label: 'إلغاء',
                        isOutline: true,
                        onTap: () async => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: PrimaryButton(label: 'إضافة', onTap: _save),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
