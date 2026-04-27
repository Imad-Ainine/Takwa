import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takwa/core/theme/app_theme.dart';
import 'package:takwa/core/widgets/custom_pattern_background.dart';
import 'package:takwa/core/widgets/custom_leading_button.dart';
import 'package:takwa/features/settings/providers/user_preferences_provider.dart';
import '../widgets/settings_widgets.dart';

class SilentModeSettingsScreen extends ConsumerWidget {
  const SilentModeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(userPreferencesProvider);

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
              SliverAppBar(
                backgroundColor: Colors.transparent,
                pinned: true,
                leading: const CustomLeadingButton(),
                title: Text(
                  'إعدادات الوضع الصامت',
                  style: context.typography.headingMedium.copyWith(
                    color: context.colors.gold,
                  ),
                ),
                centerTitle: true,
                elevation: 0,
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    prefsAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Center(child: Text('Error: $err')),
                      data: (prefs) => Column(
                        children: [
                          SettingsCard(
                            children: [
                              ToggleSetting(
                                icon: '🔇',
                                label: 'تفعيل وضع الصامت',
                                sublabel: 'ننصح بتفعيل هذه الخاصية إذا كان الأذان لا يشتغل بشكل منتظم في هاتفكم',
                                value: prefs.silentModeEnabled,
                                onChanged: (v) => ref
                                    .read(userPreferencesProvider.notifier)
                                    .updatePref('silent_mode_enabled', v),
                              ),
                              const SettingsDivider(),
                              ToggleSetting(
                                icon: '📳',
                                label: 'إهتزاز',
                                sublabel: 'تفعيل الإهتزاز أثناء الوضع الصامت',
                                value: prefs.silentVibrationEnabled,
                                onChanged: (v) => ref
                                    .read(userPreferencesProvider.notifier)
                                    .updatePref('silent_vibration_enabled', v),
                              ),
                              const SettingsDivider(),
                              SelectSetting(
                                icon: '🔔',
                                label: 'التنبيه عند التحويل',
                                value: prefs.silentModeAlertStyle,
                                options: const {
                                  'none': 'بدون تنبيه',
                                  'vibrate': 'اهتزاز فقط',
                                  'tone': 'نغمة بدون اهتزاز',
                                  'toneVibrate': 'نغمة مع اهتزاز',
                                },
                                onChanged: (v) => ref
                                    .read(userPreferencesProvider.notifier)
                                    .updatePref('silent_mode_alert_style', v),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
