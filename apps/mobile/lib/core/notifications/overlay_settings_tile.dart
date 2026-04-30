
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takwa/core/notifications/overlay_background_service.dart';
import 'package:takwa/core/widgets/takwa_loading_indicator.dart';

import '../theme/app_theme.dart';
import '../../features/settings/providers/user_preferences_provider.dart';
import '../../features/settings/presentation/widgets/settings_widgets.dart';

// ─────────────────────────────────────────
//  OVERLAY SETTINGS SECTION
// ─────────────────────────────────────────
class OverlayNotificationSettings extends ConsumerWidget {
  const OverlayNotificationSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(userPreferencesProvider);

    return prefsAsync.when(
      loading: () => const SizedBox(
        height: 48,
        child: Center(child: TakwaLoadingIndicator()),
      ),
      error: (_, __) => const SizedBox(),
      data: (prefs) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'الأذكار والإشعارات', icon: '📿'),
          SettingsCard(
            children: [
              // ── شاشة الأذان التلقائية ──
              ToggleSetting(
                icon: '🕌',
                label: 'شاشة الأذان التلقائية',
                sublabel: 'يُظهر شاشة الأذان عند دخول وقت الصلاة',
                value: prefs.adhanScreenEnabled,
                onChanged: (v) => ref
                    .read(userPreferencesProvider.notifier)
                    .updatePref('adhan_screen_enabled', v),
              ),
              const SettingsDivider(),

              // ── صوت الأذان ──
              ToggleSetting(
                icon: '🔊',
                label: 'صوت الأذان',
                sublabel: 'تشغيل صوت الأذان تلقائياً عند دخول الوقت',
                value: prefs.adhanSoundEnabled,
                onChanged: (v) {
                  ref
                      .read(userPreferencesProvider.notifier)
                      .updatePref('adhan_sound_enabled', v);
                  OverlayBackgroundService.updateSettings(adhanSoundEnabled: v);
                },
              ),
              const SettingsDivider(),

              // ── نوافذ الأذكار المنبثقة ──
              ToggleSetting(
                icon: '📿',
                label: 'نوافذ الأذكار والأدعية',
                sublabel: 'يُظهر أذكاراً وأدعيةً بشكل منبثق على الشاشة',
                value: prefs.overlayEnabled,
                onChanged: (v) {
                  ref
                      .read(userPreferencesProvider.notifier)
                      .updatePref('overlay_popups_enabled', v);
                  OverlayBackgroundService.updateSettings(overlayEnabled: v);
                },
              ),
              if (prefs.overlayEnabled) ...[
                const SettingsDivider(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  child: Column(
                    children: [
                      _IntervalSelector(
                        value: prefs.popupIntervalMins,
                        onChanged: (v) {
                          ref
                              .read(userPreferencesProvider.notifier)
                              .updatePref('popup_interval_minutes', v);
                          OverlayBackgroundService.updateSettings(
                            popupIntervalMins: v,
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      // إحصاء: عدد المرات في اليوم
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.teal.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: context.colors.teal.withOpacity(0.15),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '📊',
                              style: TextStyle(
                                fontSize: 14,
                                color: context.colors.teal,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'ستظهر النوافذ ~${(1440 / prefs.popupIntervalMins).floor()} مرة يومياً',
                                style: context.typography.caption.copyWith(
                                  color: context.colors.teal,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
//  SHARED CHILD WIDGETS (unchanged)
// ─────────────────────────────────────────

class _IntervalSelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _IntervalSelector({required this.value, required this.onChanged});

  static const _options = [
    (label: 'كل 15 دقيقة (~96/يوم)', mins: 15),
    (label: 'كل 20 دقيقة (~72/يوم)', mins: 20),
    (label: 'كل 24 دقيقة (~60/يوم)', mins: 24),
    (label: 'كل 30 دقيقة (~48/يوم)', mins: 30),
    (label: 'كل ساعة (~24/يوم)', mins: 60),
    (label: 'كل ساعتين (~12/يوم)', mins: 120),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('⏱️', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              'معدل ظهور الأذكار',
              style: context.typography.bodySmall.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.colors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _options.map((opt) {
            final isSelected = opt.mins == value;
            return GestureDetector(
              onTap: () => onChanged(opt.mins),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.colors.gold.withOpacity(0.12)
                      : context.colors.card.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? context.colors.gold
                        : context.colors.border.withOpacity(0.5),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  opt.label,
                  style: context.typography.caption.copyWith(
                    fontSize: 11,
                    color: isSelected
                        ? context.colors.gold
                        : context.colors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
