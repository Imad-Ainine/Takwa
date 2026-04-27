import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takwa/core/theme/app_theme.dart';
import 'package:takwa/core/widgets/custom_pattern_background.dart';
import 'package:takwa/core/widgets/custom_leading_button.dart';
import 'package:takwa/features/settings/providers/user_preferences_provider.dart';
import '../widgets/settings_widgets.dart';
import 'silent_mode_settings_screen.dart';
import '../widgets/prayer_selection_sheet.dart';

const adhanOptions = {
  'Adhan-Makkah.mp3': 'أذان مكة المكرمة',
  'Adhan-Madinah.mp3': 'أذان المدينة المنورة',
  'Adhan-Alaqsa.mp3': 'أذان المسجد الأقصى',
  'Adhan-Egypt.mp3': 'الأذان المصري',
  'Abdul-Basit.mp3': 'عبد الباسط عبد الصمد',
  'Minshawi.mp3': 'محمد صديق المنشاوي',
  'Naghshbandi.mp3': 'سيد النقشبندي',
  'Saber.mp3': 'جامع صابر',
  'Al-Hussaini.mp3': 'الحسيني',
  'Bakir-Bash.mp3': 'بكير باش',
  'Hafez.mp3': 'حافظ',
  'Hafiz-Murad.mp3': 'حافظ مراد',
  'Sharif-Doman.mp3': 'شريف دومان',
  'Yusuf-Islam.mp3': 'يوسف إسلام',
};

class AdhanNotificationSettingsScreen extends ConsumerWidget {
  const AdhanNotificationSettingsScreen({super.key});

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
                  'الأذان والتنبيهات',
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
                              SelectSetting(
                                icon: '⚖️',
                                label: 'المذهب',
                                value: prefs.madhab,
                                options: const {
                                  'shafi': 'شافعي، مالكي، حنبلي',
                                  'hanafi': 'حنفي',
                                },
                                onChanged: (v) => ref
                                    .read(userPreferencesProvider.notifier)
                                    .updatePref('madhab', v),
                              ),
                              const SettingsDivider(),
                              SelectSetting(
                                icon: '🌍',
                                label: 'طريقة الحساب',
                                value: prefs.calcMethod,
                                options: const {
                                  'Algeria': 'الجزائر (وزارة الشؤون الدينية)',
                                  'MWL': 'رابطة العالم الإسلامي',
                                  'Egypt': 'دار الإفتاء المصرية',
                                  'Karachi': 'جامعة كراتشي',
                                  'UmmAlQura': 'أم القرى (مكة المكرمة)',
                                  'ISNA': 'أمريكا الشمالية',
                                },
                                onChanged: (v) => ref
                                    .read(userPreferencesProvider.notifier)
                                    .updatePref('calcMethod', v),
                              ),
                              const SettingsDivider(),
                              SelectSetting(
                                icon: '🎵',
                                label: 'صوت الأذان',
                                value: prefs.adhanSound,
                                options: adhanOptions,
                                onChanged: (v) => ref
                                    .read(userPreferencesProvider.notifier)
                                    .updatePref('adhan_sound', v),
                              ),
                              const SettingsDivider(),
                              SelectSetting(
                                icon: '🔈',
                                label: 'وضع الأذان',
                                value: prefs.adhanMode,
                                options: const {
                                  'sound': 'صوت',
                                  'vibrate': 'اهتزاز',
                                  'silent': 'صامت',
                                },
                                onChanged: (v) => ref
                                    .read(userPreferencesProvider.notifier)
                                    .updatePref('adhan_mode', v),
                              ),
                              const SettingsDivider(),
                              ToggleSetting(
                                icon: '🔇',
                                label: 'التحويل إلى الصامت',
                                sublabel: 'تفعيل وضع الصامت بعد الأذان',
                                value: prefs.autoSilentAfterAdhan,
                                onChanged: (v) => ref
                                    .read(userPreferencesProvider.notifier)
                                    .updatePref('auto_silent_after_adhan', v),
                              ),
                              const SettingsDivider(),
                              ActionSetting(
                                icon: '⚙️',
                                label: 'إعدادات الوضع الصامت',
                                sublabel: 'إدارة خيارات وضع الصامت',
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SilentModeSettingsScreen(),
                                  ),
                                ),
                              ),
                              const SettingsDivider(),
                              ActionSetting(
                                icon: '🕌',
                                label: 'تفعيل الأذان في الوضع الصامت',
                                sublabel: 'تشغيل الأذان حتى وإن كان الجهاز في وضع الصامت',
                                onTap: () => PrayerSelectionSheet.show(
                                  context: context,
                                  title: 'تفعيل الأذان في الوضع الصامت',
                                  selectedPrayers: prefs.silentAdhanPrayers.split(','),
                                  onChanged: (prayers) => ref
                                      .read(userPreferencesProvider.notifier)
                                      .updatePref('silent_adhan_prayers', prayers.join(',')),
                                ),
                              ),
                              const SettingsDivider(),
                              ActionSetting(
                                icon: '📢',
                                label: 'تفعيل التنبيهات في الوضع الصامت',
                                sublabel: 'تشغيل صوت التنبيهات حتى وإن كان الجهاز في وضع الصامت',
                                onTap: () => PrayerSelectionSheet.show(
                                  context: context,
                                  title: 'التنبيهات المفعلة في الوضع الصامت',
                                  selectedPrayers: prefs.silentNotifPrayers.split(','),
                                  includeSunrise: true,
                                  onChanged: (prayers) => ref
                                      .read(userPreferencesProvider.notifier)
                                      .updatePref('silent_notif_prayers', prayers.join(',')),
                                ),
                              ),
                              const SettingsDivider(),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Text('🔊', style: TextStyle(fontSize: 18)),
                                        const SizedBox(width: 12),
                                        Text(
                                          'مستوى الصوت',
                                          style: TextStyle(
                                            fontFamily: 'NotoNaskhArabic',
                                            fontSize: 13,
                                            color: context.colors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Slider(
                                      value: prefs.adhanVolume,
                                      onChanged: (v) => ref
                                          .read(userPreferencesProvider.notifier)
                                          .updatePref('adhan_volume_level', v),
                                      activeColor: context.colors.gold,
                                      inactiveColor: context.colors.border,
                                    ),
                                  ],
                                ),
                              ),
                              const SettingsDivider(),
                              CheckboxSetting(
                                label: 'تشغيل الشاشة أثناء الأذان',
                                sublabel: 'إبقاء الشاشة مفعلة عند تشغيل الأذان',
                                value: prefs.wakeScreenEnabled,
                                onChanged: (v) => ref
                                    .read(userPreferencesProvider.notifier)
                                    .updatePref('wake_screen_enabled', v),
                              ),
                              const SettingsDivider(),
                              CheckboxSetting(
                                label: 'ايقاف الأذان عند قلب الجهاز',
                                sublabel: 'اقلب الهاتف على وجهه لإسكات صوت الأذان',
                                value: prefs.flipToSilenceEnabled,
                                onChanged: (v) => ref
                                    .read(userPreferencesProvider.notifier)
                                    .updatePref('flip_to_silence_enabled', v),
                              ),
                              const SettingsDivider(),
                              ToggleSetting(
                                icon: '📳',
                                label: 'نوع الاهتزاز',
                                sublabel: 'اهتزاز مصاحب للأذان',
                                value: prefs.vibrateWithAdhan,
                                onChanged: (v) => ref
                                    .read(userPreferencesProvider.notifier)
                                    .updatePref('vibrate_with_adhan', v),
                              ),
                              const SettingsDivider(),
                              CheckboxSetting(
                                label: 'إشعار الأذان بالجرس المنبه',
                                sublabel: 'التنبيه حتى في وضع الصامت',
                                value: prefs.adhanAlarmEnabled,
                                onChanged: (v) => ref
                                    .read(userPreferencesProvider.notifier)
                                    .updatePref('adhan_alarm_enabled', v),
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
