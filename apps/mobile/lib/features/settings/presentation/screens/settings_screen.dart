
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:takwa/core/theme/app_theme.dart';
import 'package:takwa/core/providers/theme_provider.dart';
import 'package:takwa/core/notifications/notifications_service.dart';
import 'package:takwa/core/widgets/custom_pattern_background.dart';
import 'package:takwa/core/widgets/custom_leading_button.dart';
import 'package:takwa/core/widgets/takwa_loading_indicator.dart';
import 'package:takwa/core/notifications/overlays/adhan_overlay_screen.dart';
import 'package:takwa/core/supabase/supabase_config.dart';
import 'package:takwa/core/supabase/sync_manager.dart';
import 'package:takwa/core/providers/auth_providers.dart';
import 'package:takwa/core/routes/app_routes.dart';
import 'package:takwa/core/notifications/overlay_settings_tile.dart';
import 'package:takwa/features/settings/providers/user_preferences_provider.dart';
import 'package:takwa/features/settings/presentation/widgets/settings_widgets.dart';
import 'dart:async';
import 'adhan_notifications_settings_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Future<void> _updatePref(
    String key,
    dynamic value, {
    NotificationCategory category = NotificationCategory.all,
  }) async {
    await ref.read(userPreferencesProvider.notifier).updatePref(key, value, category: category);
  }

  @override
  Widget build(BuildContext context) {
    final prefsAsync = ref.watch(userPreferencesProvider);
    final isSyncing = ref.watch(isSyncingProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: Stack(
          children: [
            // Background Pattern
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
                    'الإعدادات',
                    style: context.typography.headingMedium.copyWith(
                      color: context.colors.gold,
                    ),
                  ),
                  actions: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SyncStatusIndicator(isSyncing: isSyncing),
                      ),
                    ),
                  ],
                  centerTitle: true,
                  elevation: 0,
                  surfaceTintColor: Colors.transparent,
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 8),

                      prefsAsync.when(
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: TakwaLoadingIndicator(size: 32),
                          ),
                        ),
                        error: (err, st) => Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Text('Error loading settings: $err'),
                          ),
                        ),
                        data: (prefs) => Column(
                          children: [
                            // ── التذكيرات ──
                            const SectionHeader(
                              title: 'إعدادات الأذان و التنبيهات',
                              icon: '🔔',
                            ),
                            SettingsCard(
                              children: [
                                ActionSetting(
                                  icon: '🕌',
                                  label: 'الأذان والتنبيهات',
                                  sublabel:
                                      'تخصيص الأذان، الوضع الصامت، والتنبيهات',
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const AdhanNotificationSettingsScreen(),
                                    ),
                                  ),
                                ),
                                const SettingsDivider(),
                                ToggleSetting(
                                  icon: '🌙',
                                  label: 'الاستيقاظ قبل الفجر',
                                  sublabel: 'تنبيه بصوت الأذان في الوقت المحدد',
                                  value: prefs.wakeUpBeforeFajr,
                                  onChanged: (v) =>
                                      _updatePref('wake_up_before_fajr', v, category: NotificationCategory.prayer),
                                ),
                                if (prefs.wakeUpBeforeFajr) ...[
                                  const SettingsDivider(),
                                  TimeSetting(
                                    icon: '⏰',
                                    label: 'وقت الاستيقاظ',
                                    time: prefs.wakeUpTime,
                                    onChanged: (t) async {
                                      final str =
                                          '${t.hour.toString().padLeft(2, "0")}:${t.minute.toString().padLeft(2, "0")}';
                                      await _updatePref('wake_up_time', str, category: NotificationCategory.prayer);
                                    },
                                  ),
                                ],
                                const SettingsDivider(),
                                ToggleSetting(
                                  icon: '☀️',
                                  label: 'أذكار الصباح',
                                  sublabel: 'تذكير يومي الساعة ٦:٣٠ ص',
                                  value: prefs.morningAdhkarReminder,
                                  onChanged: (v) =>
                                      _updatePref('morning_adhkar_reminder', v),
                                ),
                                const SettingsDivider(),
                                ToggleSetting(
                                  icon: '🌆',
                                  label: 'أذكار المساء',
                                  sublabel: 'تذكير يومي الساعة ٥:٠٠ م',
                                  value: prefs.eveningAdhkarReminder,
                                  onChanged: (v) =>
                                      _updatePref('evening_adhkar_reminder', v),
                                ),
                                const SettingsDivider(),
                                ToggleSetting(
                                  icon: '📝',
                                  label: 'محاسبة مسائية',
                                  sublabel: 'تذكير يومي للمحاسبة',
                                  value: prefs.muhasabaReminder,
                                  onChanged: (v) =>
                                      _updatePref('muhasaba_reminder', v, category: NotificationCategory.reminders),
                                ),
                                const SettingsDivider(),
                                ToggleSetting(
                                  icon: '🤲',
                                  label: 'الأدعية اليومية',
                                  sublabel: 'نفحات من الأدعية النبوية',
                                  value: prefs.dailyDuasOn,
                                  onChanged: (v) =>
                                      _updatePref('daily_duas_on', v),
                                ),
                                const SettingsDivider(),
                                ToggleSetting(
                                  icon: '🕌',
                                  label: 'سنن الجمعة',
                                  sublabel: 'تذكير بسورة الكهف والجمعة',
                                  value: prefs.specialRemindersOn,
                                  onChanged: (v) =>
                                      _updatePref('special_reminders_on', v),
                                ),
                                const SettingsDivider(),
                                ToggleSetting(
                                  icon: '🥘',
                                  label: 'تنبيهات الصيام',
                                  sublabel: 'الاثنين والخميس والأيام البيض',
                                  value: prefs.fastingRemindersOn,
                                  onChanged: (v) =>
                                      _updatePref('fasting_reminders_on', v),
                                ),
                                if (prefs.muhasabaReminder) ...[
                                  const SettingsDivider(),
                                  TimeSetting(
                                    icon: '⏰',
                                    label: 'وقت المحاسبة',
                                    time: prefs.muhasabaTime,
                                    onChanged: (t) async {
                                      final str =
                                          '${t.hour.toString().padLeft(2, "0")}:${t.minute.toString().padLeft(2, "0")}';
                                      await _updatePref(
                                        'evening_reminder_time',
                                        str,
                                        category: NotificationCategory.reminders,
                                      );
                                    },
                                  ),
                                ],
                              ],
                            ),
                            const OverlayNotificationSettings(),

                            // ── المظهر ──
                            const SectionHeader(title: 'المظهر', icon: '🎨'),
                            SettingsCard(
                              children: [
                                SelectSetting(
                                  icon: '🌓',
                                  label: 'وضع المظهر',
                                  value: ref.watch(themeModeProvider).name,
                                  options: const {
                                    'system': 'تلقائي (حسب النظام)',
                                    'light': 'الوضع الفاتح',
                                    'dark': 'الوضع الداكن',
                                  },
                                  onChanged: (v) {
                                    final mode = ThemeMode.values.firstWhere(
                                      (e) => e.name == v,
                                    );
                                    ref
                                        .read(themeModeProvider.notifier)
                                        .setTheme(mode);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // ── وضع رمضان ──
                            const SectionHeader(title: 'وضع رمضان', icon: '🌙'),
                            SettingsCard(
                              children: [
                                ToggleSetting(
                                  icon: '🌙',
                                  label: 'وضع رمضان',
                                  sublabel: 'تفعيل المميزات الرمضانية',
                                  value: prefs.ramadanMode,
                                  onChanged: (v) =>
                                      _updatePref('ramadan_mode', v),
                                  accentColor: context.colors.gold,
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),

                      // ── معلومات ──
                      const SectionHeader(title: 'التطبيق', icon: 'ℹ️'),
                      SettingsCard(
                        children: [
                          ActionSetting(
                            icon: '🔔',
                            label: 'اختبار الإشعارات والنافذة',
                            sublabel: 'تأكد من عمل الإشعارات والنوافذ العائمة',
                            onTap: _showTestMenu,
                          ),
                          const SettingsDivider(),
                          ActionSetting(
                            icon: '💎',
                            label: 'الاشتراك',
                            sublabel: 'دعم المشروع والاستمرار',
                            onTap: () => Navigator.pushNamed(
                              context,
                              Routes.subscription,
                            ),
                          ),
                          const SettingsDivider(),
                          ActionSetting(
                            icon: '👨‍💻',
                            label: 'عن المطور',
                            sublabel: 'تعرف على مبرمج التطبيق',
                            onTap: () =>
                                Navigator.pushNamed(context, '/about-me'),
                          ),
                          const SettingsDivider(),
                          ActionSetting(
                            icon: '📜',
                            label: 'الشروط والخصوصية',
                            sublabel: 'شروط الدخول والخصوصية',
                            onTap: () => Navigator.pushNamed(context, '/terms'),
                          ),
                          if (ref.watch(authStatusProvider) ==
                              AuthStatus.authenticated)
                            ActionSetting(
                              icon: '🚪',
                              label: 'تسجيل الخروج',
                              sublabel: 'الخروج من الحساب أو وضع الزائر',
                              onTap: _handleLogout,
                              isDestructive: true,
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // App version
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'بسم الله الرحمن الرحيم',
                              style: TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 14,
                                color: context.colors.gold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'تقوى — v1.0.0',
                              style: TextStyle(
                                fontFamily: 'NotoNaskhArabic',
                                fontSize: 11,
                                color: context.colors.textDim,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 80),
                    ]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTestMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'اختبار الإشعارات',
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 18,
                color: context.colors.gold,
              ),
            ),
            const SizedBox(height: 14),
            ActionSetting(
              icon: '🔔',
              label: 'إشعار عادي',
              sublabel: 'إشعار النظام التقليدي',
              onTap: () {
                Navigator.pop(context);
                NotificationsService.showAchievementNotif(
                  title: 'اختبار الإشعار',
                  body: 'الإشعارات تعمل بشكل صحيح',
                  emoji: '✅',
                  points: 0,
                );
              },
            ),
            const SettingsDivider(),
            ActionSetting(
              icon: '🕌',
              label: 'أذان الصلاة',
              sublabel: 'شاشة الأذان الكاملة مع الصوت',
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AdhanOverlayScreen(
                      prayerName: 'العصر',
                      autoPlay: true,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _resetSettings() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.colors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: context.colors.border),
        ),
        title: Text(
          'إعادة الضبط',
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 18,
            color: context.colors.danger,
          ),
        ),
        content: Text(
          'هل تريد حذف جميع الإعدادات؟',
          style: TextStyle(
            fontFamily: 'NotoNaskhArabic',
            fontSize: 13,
            color: context.colors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'إلغاء',
              style: TextStyle(
                fontFamily: 'NotoNaskhArabic',
                fontSize: 13,
                color: context.colors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'حذف',
              style: TextStyle(
                fontFamily: 'NotoNaskhArabic',
                fontSize: 13,
                color: context.colors.danger,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) await NotificationsService.cancelAll();
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.colors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: context.colors.border),
        ),
        title: Text(
          'تسجيل الخروج',
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 18,
            color: context.colors.danger,
          ),
        ),
        content: Text(
          'هل أنت متأكد من رغبتك في تسجيل الخروج؟',
          style: TextStyle(
            fontFamily: 'NotoNaskhArabic',
            fontSize: 13,
            color: context.colors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'إلغاء',
              style: TextStyle(
                fontFamily: 'NotoNaskhArabic',
                fontSize: 13,
                color: context.colors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'خروج',
              style: TextStyle(
                fontFamily: 'NotoNaskhArabic',
                fontSize: 13,
                color: context.colors.danger,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // 1. Reset guest mode state
      ref.read(guestModeProvider.notifier).state = false;

      // 2. Sign out from Supabase (Google/Email)
      await ref.read(supabaseServiceProvider).signOut();

      // 3. Navigate to splash/login
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    }
  }
}

// ── End of SettingsScreen ──
