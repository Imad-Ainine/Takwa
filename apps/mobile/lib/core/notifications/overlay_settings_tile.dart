import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takwa/core/notifications/overlay_background_service.dart';
import 'package:takwa/core/widgets/takwa_error_state.dart';
import 'package:takwa/core/widgets/takwa_loading_indicator.dart';
import 'package:takwa/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return prefsAsync.when(
      loading: () => const SizedBox(
        height: 48,
        child: Center(child: TakwaLoadingIndicator()),
      ),
      error: (_, __) => TakwaErrorState(
        compact: true,
        onRetry: () => ref.invalidate(userPreferencesProvider),
      ),
      data: (prefs) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: l10n.overlaySettingsSectionTitle, icon: '📿'),
          SettingsCard(
            children: [
              // ── شاشة الأذان التلقائية ──
              ToggleSetting(
                icon: '🕌',
                label: l10n.overlaySettingAdhanScreenLabel,
                sublabel: l10n.overlaySettingAdhanScreenSublabel,
                value: prefs.adhanScreenEnabled,
                onChanged: (v) => ref
                    .read(userPreferencesProvider.notifier)
                    .updatePref('adhan_screen_enabled', v),
              ),
              const SettingsDivider(),

              // ── صوت الأذان ──
              ToggleSetting(
                icon: '🔊',
                label: l10n.overlaySettingAdhanSoundLabel,
                sublabel: l10n.overlaySettingAdhanSoundSublabel,
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
                label: l10n.overlaySettingPopupsLabel,
                sublabel: l10n.overlaySettingPopupsSublabel,
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
                    vertical: AppSpacing.sm,
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
                      const SizedBox(height: AppSpacing.md),
                      // إحصاء: عدد المرات في اليوم
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.teal.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: context.colors.teal.withValues(alpha: 0.15),
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
                                l10n.overlaySettingDailyCount(
                                  (1440 / prefs.popupIntervalMins).floor(),
                                ),
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
//  SHARED CHILD WIDGETS
// ─────────────────────────────────────────

class _IntervalSelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _IntervalSelector({required this.value, required this.onChanged});

  List<({String label, int mins})> _options(AppLocalizations l10n) => [
    (label: l10n.overlaySettingInterval15Min, mins: 15),
    (label: l10n.overlaySettingInterval20Min, mins: 20),
    (label: l10n.overlaySettingInterval24Min, mins: 24),
    (label: l10n.overlaySettingInterval30Min, mins: 30),
    (label: l10n.overlaySettingInterval1Hour, mins: 60),
    (label: l10n.overlaySettingInterval2Hours, mins: 120),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final options = _options(l10n);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('⏱️', style: TextStyle(fontSize: 16)),
            const SizedBox(width: AppSpacing.sm),
            Text(
              l10n.overlaySettingIntervalHeader,
              style: context.typography.bodySmall.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.colors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((opt) {
            final isSelected = opt.mins == value;
            return GestureDetector(
              onTap: () => onChanged(opt.mins),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.colors.gold.withValues(alpha: 0.12)
                      : context.colors.card.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: isSelected
                        ? context.colors.gold
                        : context.colors.border.withValues(alpha: 0.5),
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
