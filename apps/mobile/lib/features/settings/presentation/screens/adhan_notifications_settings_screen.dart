import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:takwa/core/theme/app_theme.dart';
import 'package:takwa/core/widgets/app_bar_widget.dart';
import 'package:takwa/core/widgets/custom_pattern_background.dart';
import 'package:takwa/core/widgets/custom_leading_button.dart';
import 'package:takwa/core/widgets/takwa_loading_indicator.dart';
import 'package:takwa/features/settings/providers/user_preferences_provider.dart';
import 'package:takwa/core/supabase/sync_manager.dart';
import '../widgets/settings_widgets.dart';
import 'silent_mode_settings_screen.dart';
import '../widgets/prayer_selection_sheet.dart';
import 'package:takwa/l10n/app_localizations.dart';

Map<String, String> adhanOptions(AppLocalizations l10n) => {
  'Adhan-Makkah.mp3': l10n.adhanSoundMakkah,
  'Adhan-Madinah.mp3': l10n.adhanSoundMadinah,
  'Adhan-Alaqsa.mp3': l10n.adhanSoundAlaqsa,
  'Adhan-Egypt.mp3': l10n.adhanSoundEgypt,
  'Abdul-Basit.mp3': l10n.adhanSoundAbdulBasit,
  'Minshawi.mp3': l10n.adhanSoundMinshawi,
  'Naghshbandi.mp3': l10n.adhanSoundNaghshbandi,
  'Saber.mp3': l10n.adhanSoundSaber,
  'Al-Hussaini.mp3': l10n.adhanSoundAlHussaini,
  'Bakir-Bash.mp3': l10n.adhanSoundBakirBash,
  'Hafez.mp3': l10n.adhanSoundHafez,
  'Hafiz-Murad.mp3': l10n.adhanSoundHafizMurad,
  'Sharif-Doman.mp3': l10n.adhanSoundSharifDoman,
  'Yusuf-Islam.mp3': l10n.adhanSoundYusufIslam,
};

final adhanPreviewPlayerProvider = Provider.autoDispose((ref) {
  final player = AudioPlayer();
  ref.onDispose(() => player.dispose());
  return player;
});

final currentlyPlayingAdhanProvider = StateProvider<String?>((ref) => null);

class AdhanNotificationSettingsScreen extends ConsumerWidget {
  const AdhanNotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(userPreferencesProvider);
    final isSyncing = ref.watch(isSyncingProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.colors.background,
      // AppBarWidget instead of a one-off SliverAppBar — consistent with
      // the rest of the app's app bars (audit item 29).
      appBar: AppBarWidget(
        leading: const CustomLeadingButton(),
        title: l10n.settingsAdhanNotificationsLabel,
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
                      error: (err, _) => Center(
                        child: Text(l10n.checklistErrorPrefix(err.toString())),
                      ),
                      data: (prefs) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionHeader(
                            icon: '🕌',
                            title: l10n.adhanSettingsAccountSectionTitle,
                          ),
                          SettingsCard(
                            children: [
                              SelectSetting(
                                icon: '⚖️',
                                label: l10n.adhanMadhabLabel,
                                value: prefs.madhab,
                                options: {
                                  'shafi': l10n.madhabShafi,
                                  'hanafi': l10n.madhabHanafi,
                                },
                                onChanged: (v) => ref
                                    .read(userPreferencesProvider.notifier)
                                    .updatePref('madhab', v),
                              ),
                              const SettingsDivider(),
                              SelectSetting(
                                icon: '🌍',
                                label: l10n.adhanCalcMethodLabel,
                                value: prefs.calcMethod,
                                options: {
                                  'Algeria': l10n.calcMethodAlgeria,
                                  'MWL': l10n.calcMethodMWL,
                                  'Egypt': l10n.calcMethodEgypt,
                                  'Karachi': l10n.calcMethodKarachi,
                                  'UmmAlQura': l10n.calcMethodUmmAlQura,
                                  'ISNA': l10n.calcMethodISNA,
                                },
                                onChanged: (v) => ref
                                    .read(userPreferencesProvider.notifier)
                                    .updatePref('calc_method', v),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          SectionHeader(
                            icon: '🔊',
                            title: l10n.adhanSoundSectionTitle,
                          ),
                          SettingsCard(
                            children: [
                              SelectSetting(
                                icon: '🎵',
                                label: l10n.adhanSoundSectionTitle,
                                value: prefs.adhanSound,
                                options: adhanOptions(l10n),
                                itemTrailingBuilder: (ctx, key, isSelected) =>
                                    AdhanSoundPreviewButton(soundPath: key),
                                onChanged: (v) => ref
                                    .read(userPreferencesProvider.notifier)
                                    .updatePref('adhan_sound', v),
                              ),
                              const SettingsDivider(),
                              SelectSetting(
                                icon: '🔈',
                                label: l10n.adhanModeLabel,
                                value: prefs.adhanMode,
                                options: {
                                  'sound': l10n.adhanModeSound,
                                  'vibrate': l10n.adhanModeVibrate,
                                  'silent': l10n.adhanModeSilent,
                                },
                                onChanged: (v) => ref
                                    .read(userPreferencesProvider.notifier)
                                    .updatePref('adhan_mode', v),
                              ),
                              const SettingsDivider(),
                              SliderSetting(
                                icon: '🔊',
                                label: l10n.adhanVolumeLabel,
                                value: prefs.adhanVolumeLevel,
                                onChanged: (v) => ref
                                    .read(userPreferencesProvider.notifier)
                                    .updatePref('adhan_volume_level', v),
                              ),
                              const SettingsDivider(),
                              ToggleSetting(
                                icon: '📳',
                                label: l10n.adhanVibrateTypeLabel,
                                sublabel: l10n.adhanVibrateTypeSublabel,
                                value: prefs.vibrateWithAdhan,
                                onChanged: (v) => ref
                                    .read(userPreferencesProvider.notifier)
                                    .updatePref('vibrate_with_adhan', v),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          SectionHeader(
                            icon: '⚙️',
                            title: l10n.adhanAdvancedSectionTitle,
                          ),
                          SettingsCard(
                            children: [
                              ToggleSetting(
                                icon: '🔇',
                                label: l10n.adhanAutoSilentLabel,
                                sublabel: l10n.adhanAutoSilentSublabel,
                                value: prefs.autoSilentAfterAdhan,
                                onChanged: (v) => ref
                                    .read(userPreferencesProvider.notifier)
                                    .updatePref('auto_silent_after_adhan', v),
                              ),
                              const SettingsDivider(),
                              ActionSetting(
                                icon: '⚙️',
                                label: l10n.adhanSilentModeSettingsLabel,
                                sublabel: l10n.adhanSilentModeSettingsSublabel,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const SilentModeSettingsScreen(),
                                  ),
                                ),
                              ),
                              const SettingsDivider(),
                              ActionSetting(
                                icon: '🕌',
                                label: l10n.adhanEnableInSilentLabel,
                                sublabel: l10n.adhanEnableInSilentSublabel,
                                onTap: () => PrayerSelectionSheet.show(
                                  context: context,
                                  title: l10n.adhanEnableInSilentLabel,
                                  selectedPrayers: prefs.silentAdhanPrayers
                                      .split(','),
                                  onChanged: (prayers) => ref
                                      .read(userPreferencesProvider.notifier)
                                      .updatePref(
                                        'silent_adhan_prayers',
                                        prayers.join(','),
                                      ),
                                ),
                              ),
                              const SettingsDivider(),
                              ActionSetting(
                                icon: '📢',
                                label: l10n.adhanEnableNotifInSilentLabel,
                                sublabel: l10n.adhanEnableNotifInSilentSublabel,
                                onTap: () => PrayerSelectionSheet.show(
                                  context: context,
                                  title: l10n.adhanNotifSilentSheetTitle,
                                  selectedPrayers: prefs.silentNotifPrayers
                                      .split(','),
                                  includeSunrise: true,
                                  onChanged: (prayers) => ref
                                      .read(userPreferencesProvider.notifier)
                                      .updatePref(
                                        'silent_notif_prayers',
                                        prayers.join(','),
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          SectionHeader(
                            icon: '📱',
                            title: l10n.adhanSystemNotifSectionTitle,
                          ),
                          SettingsCard(
                            children: [
                              CheckboxSetting(
                                label: l10n.adhanWakeScreenLabel,
                                sublabel: l10n.adhanWakeScreenSublabel,
                                value: prefs.wakeScreenEnabled,
                                onChanged: (v) => ref
                                    .read(userPreferencesProvider.notifier)
                                    .updatePref('wake_screen_enabled', v),
                              ),
                              const SettingsDivider(),
                              CheckboxSetting(
                                label: l10n.adhanFlipToSilenceLabel,
                                sublabel: l10n.adhanFlipToSilenceSublabel,
                                value: prefs.flipToSilenceEnabled,
                                onChanged: (v) => ref
                                    .read(userPreferencesProvider.notifier)
                                    .updatePref('flip_to_silence_enabled', v),
                              ),
                              const SettingsDivider(),
                              CheckboxSetting(
                                label: l10n.adhanAlarmNotifLabel,
                                sublabel: l10n.adhanAlarmNotifSublabel,
                                value: prefs.adhanAlarmEnabled,
                                onChanged: (v) => ref
                                    .read(userPreferencesProvider.notifier)
                                    .updatePref('adhan_alarm_enabled', v),
                              ),
                              const SettingsDivider(),
                              CheckboxSetting(
                                label: l10n.adhanOngoingNotifLabel,
                                sublabel: l10n.adhanOngoingNotifSublabel,
                                value: prefs.ongoingNotifEnabled,
                                onChanged: (v) => ref
                                    .read(userPreferencesProvider.notifier)
                                    .updatePref('ongoing_notif_enabled', v),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
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

class AdhanSoundPreviewButton extends ConsumerWidget {
  final String soundPath;
  const AdhanSoundPreviewButton({super.key, required this.soundPath});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(adhanPreviewPlayerProvider);
    final playingPath = ref.watch(currentlyPlayingAdhanProvider);
    final isPlaying = playingPath == soundPath;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: IconButton(
        onPressed: () async {
          if (isPlaying) {
            await player.stop();
            ref.read(currentlyPlayingAdhanProvider.notifier).state = null;
          } else {
            await player.stop();
            try {
              await player.setAsset('assets/sounds/$soundPath');
              ref.read(currentlyPlayingAdhanProvider.notifier).state =
                  soundPath;
              await player.play();
              // Reset when finished
              player.processingStateStream.listen((state) {
                if (state == ProcessingState.completed) {
                  if (ref.read(currentlyPlayingAdhanProvider) == soundPath) {
                    ref.read(currentlyPlayingAdhanProvider.notifier).state =
                        null;
                  }
                }
              });
            } catch (e) {
              debugPrint('Error playing adhan preview: $e');
            }
          }
        },
        icon: Icon(
          isPlaying
              ? Icons.stop_circle_rounded
              : Icons.play_circle_fill_rounded,
          color: context.colors.gold,
          size: 32,
        ),
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }
}
