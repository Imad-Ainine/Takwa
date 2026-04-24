// ═══════════════════════════════════════════════════════════════
//  lib/core/notifications/overlay_settings_tile.dart
//  تقوى — Overlay & Notification Settings Widget
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';
import 'overlay_background_service.dart';

// ─────────────────────────────────────────
//  OVERLAY SETTINGS PROVIDER
// ─────────────────────────────────────────
class OverlaySettings {
  final bool overlayEnabled;
  final bool adhanSoundEnabled;
  final bool adhanScreenEnabled;
  final int popupIntervalMins;

  const OverlaySettings({
    this.overlayEnabled = true,
    this.adhanSoundEnabled = true,
    this.adhanScreenEnabled = true,
    this.popupIntervalMins = 24,
  });
}

class OverlaySettingsNotifier extends AsyncNotifier<OverlaySettings> {
  @override
  Future<OverlaySettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    return OverlaySettings(
      overlayEnabled: prefs.getBool('overlay_popups_enabled') ?? true,
      adhanSoundEnabled: prefs.getBool('adhan_sound_enabled') ?? true,
      adhanScreenEnabled: prefs.getBool('adhan_screen_enabled') ?? true,
      popupIntervalMins: prefs.getInt('popup_interval_minutes') ?? 24,
    );
  }

  Future<void> setOverlayEnabled(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('overlay_popups_enabled', v);
    OverlayBackgroundService.updateSettings(overlayEnabled: v);
    state = AsyncData((await future).copyWith(overlayEnabled: v));
  }

  Future<void> setAdhanSound(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('adhan_sound_enabled', v);
    OverlayBackgroundService.updateSettings(adhanSoundEnabled: v);
    state = AsyncData((await future).copyWith(adhanSoundEnabled: v));
  }

  Future<void> setAdhanScreen(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('adhan_screen_enabled', v);
    state = AsyncData((await future).copyWith(adhanScreenEnabled: v));
  }

  Future<void> setPopupInterval(int mins) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('popup_interval_minutes', mins);
    OverlayBackgroundService.updateSettings(popupIntervalMins: mins);
    state = AsyncData((await future).copyWith(popupIntervalMins: mins));
  }
}

extension _SettingsCopy on OverlaySettings {
  OverlaySettings copyWith({
    bool? overlayEnabled,
    bool? adhanSoundEnabled,
    bool? adhanScreenEnabled,
    int? popupIntervalMins,
  }) => OverlaySettings(
    overlayEnabled: overlayEnabled ?? this.overlayEnabled,
    adhanSoundEnabled: adhanSoundEnabled ?? this.adhanSoundEnabled,
    adhanScreenEnabled: adhanScreenEnabled ?? this.adhanScreenEnabled,
    popupIntervalMins: popupIntervalMins ?? this.popupIntervalMins,
  );
}

final overlaySettingsProvider =
    AsyncNotifierProvider<OverlaySettingsNotifier, OverlaySettings>(
      OverlaySettingsNotifier.new,
    );

// ─────────────────────────────────────────
//  OVERLAY SETTINGS SECTION
// ─────────────────────────────────────────
class OverlayNotificationSettings extends ConsumerWidget {
  const OverlayNotificationSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(overlaySettingsProvider);

    return settingsAsync.when(
      loading: () => const SizedBox(
        height: 48,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox(),
      data: (settings) => Column(
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
            value: settings.adhanScreenEnabled,
            onChanged: (v) =>
                ref.read(overlaySettingsProvider.notifier).setAdhanScreen(v),
          ),

          // ── صوت الأذان ──
          _SettingTile(
            icon: '🔊',
            title: 'صوت الأذان',
            subtitle: 'تشغيل صوت الأذان تلقائياً عند دخول الوقت',
            value: settings.adhanSoundEnabled,
            onChanged: (v) =>
                ref.read(overlaySettingsProvider.notifier).setAdhanSound(v),
          ),

          // ── نوافذ الأذكار المنبثقة ──
          _SettingTile(
            icon: '📿',
            title: 'نوافذ الأذكار والأدعية',
            subtitle: 'يُظهر أذكاراً وأدعيةً بشكل منبثق على الشاشة',
            value: settings.overlayEnabled,
            onChanged: (v) =>
                ref.read(overlaySettingsProvider.notifier).setOverlayEnabled(v),
          ),

          // ── فترة الظهور ──
          if (settings.overlayEnabled) ...[
            const SizedBox(height: 8),
            _IntervalSelector(
              value: settings.popupIntervalMins,
              onChanged: (v) => ref
                  .read(overlaySettingsProvider.notifier)
                  .setPopupInterval(v),
            ),
          ],

          const SizedBox(height: 8),
          // إحصاء: عدد المرات في اليوم
          if (settings.overlayEnabled)
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
                      'ستظهر النوافذ ~${(1440 / settings.popupIntervalMins).floor()} مرة يومياً',
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
