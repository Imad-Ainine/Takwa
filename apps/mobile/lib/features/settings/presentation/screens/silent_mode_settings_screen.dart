import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takwa/core/theme/app_theme.dart';
import 'package:takwa/core/widgets/app_bar_widget.dart';
import 'package:takwa/core/widgets/custom_pattern_background.dart';
import 'package:takwa/core/widgets/custom_leading_button.dart';
import 'package:takwa/core/widgets/takwa_loading_indicator.dart';
import 'package:takwa/features/settings/providers/user_preferences_provider.dart';
import 'package:takwa/core/supabase/sync_manager.dart';
import '../widgets/settings_widgets.dart';
import 'package:takwa/l10n/app_localizations.dart';

class SilentModeSettingsScreen extends ConsumerWidget {
  const SilentModeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final prefsAsync = ref.watch(userPreferencesProvider);
    final isSyncing = ref.watch(isSyncingProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      // AppBarWidget instead of a one-off SliverAppBar — consistent with
      // the rest of the app's app bars (audit item 29).
      appBar: AppBarWidget(
        leading: const CustomLeadingButton(),
        title: l10n.silentModeSettingsTitle,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 16),
              child: SyncStatusIndicator(isSyncing: isSyncing),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: CustomPatternBackground(pattern: BackgroundPattern.adhkar),
          ),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    prefsAsync.when(
                      loading: () =>
                          const Center(child: TakwaLoadingIndicator(size: 40)),
                      error: (err, _) =>
                          Center(child: Text(l10n.checklistErrorPrefix('$err'))),
                      data: (prefs) => Column(
                        children: [
                          SettingsCard(
                            children: [
                              ToggleSetting(
                                icon: '🔇',
                                label: l10n.silentModeEnableLabel,
                                sublabel: l10n.silentModeEnableSublabel,
                                value: prefs.silentModeEnabled,
                                onChanged: (v) => ref
                                    .read(userPreferencesProvider.notifier)
                                    .updatePref('silent_mode_enabled', v),
                              ),
                              const SettingsDivider(),
                              ToggleSetting(
                                icon: '📳',
                                label: l10n.silentModeVibrationLabel,
                                sublabel: l10n.silentModeVibrationSublabel,
                                value: prefs.silentVibrationEnabled,
                                onChanged: (v) => ref
                                    .read(userPreferencesProvider.notifier)
                                    .updatePref('silent_vibration_enabled', v),
                              ),
                              const SettingsDivider(),
                              SelectSetting(
                                icon: '🔔',
                                label: l10n.silentModeAlertStyleLabel,
                                value: prefs.silentModeAlertStyle,
                                options: {
                                  'none': l10n.silentModeAlertNone,
                                  'vibrate': l10n.silentModeAlertVibrateOnly,
                                  'tone': l10n.silentModeAlertToneOnly,
                                  'toneVibrate': l10n.silentModeAlertToneVibrate,
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
