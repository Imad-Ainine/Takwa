// ═══════════════════════════════════════════════════════════════
//  lib/core/notifications/overlay_settings_tile.dart
//  تقوى — Overlay & Notification Settings Widget
//  Settings are stored in SQLite and synced to Supabase via
//  userPreferencesProvider. The old overlaySettingsProvider
//  (SharedPreferences) has been removed.
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_theme.dart';
import '../../features/settings/providers/user_preferences_provider.dart';
import 'overlay_background_service.dart';

import '../../core/widgets/takwa_loading_indicator.dart';

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
          // ── عنوان القسم ──
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
            child: Text(
              'الأذكار والإشعارات',
              style: context.typography.headingMedium.copyWith(
                fontSize: 16,
                color: context.colors.gold,
              ),
            ),
          ),

          // ── شاشة الأذان التلقائية ──
          _SettingTile(
            icon: '🕌',
            title: 'شاشة الأذان التلقائية',
            subtitle: 'يُظهر شاشة الأذان عند دخول وقت الصلاة',
            value: prefs.adhanScreenEnabled,
            onChanged: (v) => ref
                .read(userPreferencesProvider.notifier)
                .updatePref('adhan_screen_enabled', v),
          ),

          // ── صوت الأذان ──
          _SettingTile(
            icon: '🔊',
            title: 'صوت الأذان',
            subtitle: 'تشغيل صوت الأذان تلقائياً عند دخول الوقت',
            value: prefs.adhanSoundEnabled,
            onChanged: (v) {
              ref
                  .read(userPreferencesProvider.notifier)
                  .updatePref('adhan_sound_enabled', v);
              OverlayBackgroundService.updateSettings(adhanSoundEnabled: v);
            },
          ),

          // ── نوافذ الأذكار المنبثقة ──
          _SettingTile(
            icon: '📿',
            title: 'نوافذ الأذكار والأدعية',
            subtitle: 'يُظهر أذكاراً وأدعيةً بشكل منبثق على الشاشة',
            value: prefs.overlayEnabled,
            onChanged: (v) {
              ref
                  .read(userPreferencesProvider.notifier)
                  .updatePref('overlay_popups_enabled', v);
              OverlayBackgroundService.updateSettings(overlayEnabled: v);
            },
          ),

          // ── فترة الظهور ──
          if (prefs.overlayEnabled) ...[
            const SizedBox(height: 8),
            _IntervalSelector(
              value: prefs.popupIntervalMins,
              onChanged: (v) {
                ref
                    .read(userPreferencesProvider.notifier)
                    .updatePref('popup_interval_minutes', v);
                OverlayBackgroundService.updateSettings(popupIntervalMins: v);
              },
            ),
          ],

          const SizedBox(height: 8),

          // إحصاء: عدد المرات في اليوم
          if (prefs.overlayEnabled)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: context.colors.teal.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: context.colors.teal.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Text('📊', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ستظهر النوافذ ~${(1440 / prefs.popupIntervalMins).floor()} مرة يومياً',
                      style: context.typography.caption.copyWith(
                        color: context.colors.teal,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
//  SHARED CHILD WIDGETS (unchanged)
// ─────────────────────────────────────────

class _SettingTile extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.border),
      ),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: value ? context.colors.goldDim : context.colors.card,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(icon, style: const TextStyle(fontSize: 18)),
        ),
        title: Text(
          title,
          style: context.typography.bodySmall.copyWith(
            fontSize: 13,
            color: context.colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: context.typography.caption.copyWith(fontSize: 11),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: context.colors.gold,
          activeTrackColor: context.colors.gold.withOpacity(0.3),
          inactiveTrackColor: context.colors.border,
          inactiveThumbColor: context.colors.textDim,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    );
  }
}

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
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
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
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _options.map((opt) {
              final isSelected = opt.mins == value;
              return GestureDetector(
                onTap: () => onChanged(opt.mins),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? context.colors.gold.withOpacity(0.15)
                        : context.colors.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? context.colors.gold
                          : context.colors.border,
                    ),
                  ),
                  child: Text(
                    opt.label,
                    style: context.typography.caption.copyWith(
                      fontSize: 11,
                      color: isSelected
                          ? context.colors.gold
                          : context.colors.textSecondary,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
