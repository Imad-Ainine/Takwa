// ═══════════════════════════════════════════════════════════════
//  lib/features/settings/presentation/screens/settings_screen.dart
//  تقوى — Settings Screen (شاشة الإعدادات)
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:takwa/core/theme/app_theme.dart';
import 'package:takwa/core/providers/theme_provider.dart';
import 'package:takwa/core/notifications/notifications_service.dart';
import 'package:takwa/core/widgets/custom_pattern_background.dart';
import 'package:takwa/core/widgets/custom_leading_button.dart';
import 'package:takwa/core/widgets/primary_switch.dart';
import 'package:takwa/features/prayer/presentation/screens/adhan_overlay_screen.dart';
import 'package:takwa/core/supabase/supabase_service.dart';
import 'package:takwa/core/supabase/sync_manager.dart';
import 'package:takwa/core/providers/auth_providers.dart';
import 'package:takwa/core/routes/app_routes.dart';
import 'package:takwa/core/notifications/overlay_settings_tile.dart';
import 'package:takwa/features/settings/providers/user_preferences_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';

import '../widgets/location_picker_sheet.dart';
import 'package:takwa/core/widgets/custom_time_picker.dart';

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

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Future<void> _updatePref(String key, dynamic value) async {
    await ref.read(userPreferencesProvider.notifier).updatePref(key, value);
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
                    if (isSyncing)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Center(
                          child: SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: context.colors.gold,
                            ),
                          ),
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
                            child: CircularProgressIndicator(),
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
                            const _SectionHeader(
                              title: 'التذكيرات والإشعارات',
                              icon: '🔔',
                            ),
                            _SettingsCard(
                              children: [
                                _ToggleSetting(
                                  icon: '🕌',
                                  label: 'تذكيرات أوقات الصلاة',
                                  sublabel: 'إشعار عند كل أذان',
                                  value: prefs.prayerReminder,
                                  onChanged: (v) =>
                                      _updatePref('prayerReminder', v),
                                ),
                                _Divider(),
                                _ToggleSetting(
                                  icon: '🌙',
                                  label: 'الاستيقاظ قبل الفجر',
                                  sublabel: 'تنبيه بصوت الأذان في الوقت المحدد',
                                  value: prefs.wakeUpBeforeFajr,
                                  onChanged: (v) =>
                                      _updatePref('wakeUpBeforeFajr', v),
                                ),
                                if (prefs.wakeUpBeforeFajr) ...[
                                  _Divider(),
                                  _TimeSetting(
                                    icon: '⏰',
                                    label: 'وقت الاستيقاظ',
                                    time: prefs.wakeUpTime,
                                    onChanged: (t) async {
                                      final str =
                                          '${t.hour.toString().padLeft(2, "0")}:${t.minute.toString().padLeft(2, "0")}';
                                      await _updatePref('wakeUpTime', str);
                                    },
                                  ),
                                ],
                                _Divider(),
                                _ToggleSetting(
                                  icon: '☀️',
                                  label: 'أذكار الصباح',
                                  sublabel: 'تذكير يومي الساعة ٦:٣٠ ص',
                                  value: prefs.morningAdhkarReminder,
                                  onChanged: (v) =>
                                      _updatePref('morningAdhkarReminder', v),
                                ),
                                _Divider(),
                                _ToggleSetting(
                                  icon: '🌆',
                                  label: 'أذكار المساء',
                                  sublabel: 'تذكير يومي الساعة ٥:٠٠ م',
                                  value: prefs.eveningAdhkarReminder,
                                  onChanged: (v) =>
                                      _updatePref('eveningAdhkarReminder', v),
                                ),
                                _Divider(),
                                _ToggleSetting(
                                  icon: '📝',
                                  label: 'محاسبة مسائية',
                                  sublabel: 'تذكير يومي للمحاسبة',
                                  value: prefs.muhasabaReminder,
                                  onChanged: (v) =>
                                      _updatePref('eveningMuhasabaReminder', v),
                                ),
                                _Divider(),
                                _ToggleSetting(
                                  icon: '🤲',
                                  label: 'الأدعية اليومية',
                                  sublabel: 'نفحات من الأدعية النبوية',
                                  value: prefs.dailyDuasOn,
                                  onChanged: (v) =>
                                      _updatePref('dailyDuasOn', v),
                                ),
                                _Divider(),
                                _ToggleSetting(
                                  icon: '🕌',
                                  label: 'سنن الجمعة',
                                  sublabel: 'تذكير بسورة الكهف والجمعة',
                                  value: prefs.specialRemindersOn,
                                  onChanged: (v) =>
                                      _updatePref('specialRemindersOn', v),
                                ),
                                _Divider(),
                                _ToggleSetting(
                                  icon: '🥘',
                                  label: 'تنبيهات الصيام',
                                  sublabel: 'الاثنين والخميس والأيام البيض',
                                  value: prefs.fastingRemindersOn,
                                  onChanged: (v) =>
                                      _updatePref('fastingRemindersOn', v),
                                ),
                                if (prefs.muhasabaReminder) ...[
                                  _Divider(),
                                  _TimeSetting(
                                    icon: '⏰',
                                    label: 'وقت المحاسبة',
                                    time: prefs.muhasabaTime,
                                    onChanged: (t) async {
                                      final str =
                                          '${t.hour.toString().padLeft(2, "0")}:${t.minute.toString().padLeft(2, "0")}';
                                      await _updatePref(
                                        'eveningReminderTime',
                                        str,
                                      );
                                    },
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 8),
                            const OverlayNotificationSettings(),
                            const SizedBox(height: 16),

                            // ── المظهر ──
                            const _SectionHeader(title: 'المظهر', icon: '🎨'),
                            _SettingsCard(
                              children: [
                                _SelectSetting(
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
                            const _SectionHeader(
                              title: 'وضع رمضان',
                              icon: '🌙',
                            ),
                            _SettingsCard(
                              children: [
                                _ToggleSetting(
                                  icon: '🌙',
                                  label: 'وضع رمضان',
                                  sublabel: 'تفعيل المميزات الرمضانية',
                                  value: prefs.ramadanMode,
                                  onChanged: (v) =>
                                      _updatePref('ramadanMode', v),
                                  accentColor: context.colors.gold,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // ── أوقات الصلاة ──
                            const _SectionHeader(
                              title: 'حساب أوقات الصلاة',
                              icon: '🕌',
                            ),
                            _SettingsCard(
                              children: [
                                _SelectSetting(
                                  icon: '📐',
                                  label: 'المذهب الفقهي',
                                  value: prefs.madhab,
                                  options: const {
                                    'shafi': 'شافعي / مالكي / حنبلي',
                                    'hanafi': 'حنفي',
                                  },
                                  onChanged: (v) => _updatePref('madhab', v),
                                ),
                                _Divider(),
                                _SelectSetting(
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
                                  onChanged: (v) =>
                                      _updatePref('calcMethod', v),
                                ),
                                _Divider(),
                                _AdhanSelectSetting(
                                  icon: '🎵',
                                  label: 'صوت الأذان',
                                  value: prefs.adhanSound,
                                  options: adhanOptions,
                                  onChanged: (v) =>
                                      _updatePref('adhan_sound', v),
                                ),
                                _Divider(),
                                _ActionSetting(
                                  icon: '📍',
                                  label: 'تحديث الموقع الجغرافي',
                                  sublabel: 'للحصول على أدق أوقات الصلاة',
                                  onTap: () =>
                                      LocationPickerSheet.show(context),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),

                      // ── معلومات ──
                      const _SectionHeader(title: 'التطبيق', icon: 'ℹ️'),
                      _SettingsCard(
                        children: [
                          _ActionSetting(
                            icon: '🔔',
                            label: 'اختبار الإشعارات والنافذة',
                            sublabel: 'تأكد من عمل الإشعارات والنوافذ العائمة',
                            onTap: _showTestMenu,
                          ),
                          _Divider(),
                          _ActionSetting(
                            icon: '💎',
                            label: 'الاشتراك',
                            sublabel: 'دعم المشروع والاستمرار',
                            onTap: () => Navigator.pushNamed(
                              context,
                              Routes.subscription,
                            ),
                          ),
                          _Divider(),
                          _ActionSetting(
                            icon: '👨‍💻',
                            label: 'عن المطور',
                            sublabel: 'تعرف على مبرمج التطبيق',
                            onTap: () =>
                                Navigator.pushNamed(context, '/about-me'),
                          ),
                          _Divider(),
                          _ActionSetting(
                            icon: '📜',
                            label: 'الشروط والخصوصية',
                            sublabel: 'شروط الدخول والخصوصية',
                            onTap: () => Navigator.pushNamed(context, '/terms'),
                          ),
                          if (ref.watch(authStatusProvider) ==
                              AuthStatus.authenticated)
                            _ActionSetting(
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
            _ActionSetting(
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
            _Divider(),
            _ActionSetting(
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
      await SupabaseService.signOut();

      // 3. Navigate to splash/login
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    }
  }
}

// ── Shared Settings Widgets ──
class _SectionHeader extends StatelessWidget {
  final String title, icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8, top: 4),
    child: Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 15,
            color: context.colors.textSecondary,
          ),
        ),
      ],
    ),
  );
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: context.colors.card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: context.colors.border),
    ),
    child: Column(children: children),
  );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    height: 1,
    margin: const EdgeInsets.only(right: 50),
    color: context.colors.border,
  );
}

class _ToggleSetting extends StatelessWidget {
  final String icon, label, sublabel;
  final bool value;
  final void Function(bool) onChanged;
  final Color? accentColor;

  const _ToggleSetting({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.value,
    required this.onChanged,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: (accentColor ?? context.colors.teal).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'NotoNaskhArabic',
                    fontSize: 13,
                    color: context.colors.textPrimary,
                  ),
                ),
                Text(
                  sublabel,
                  style: TextStyle(
                    fontFamily: 'NotoNaskhArabic',
                    fontSize: 10,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          PrimarySwitch(
            value: value,
            onChanged: onChanged,
            accentColor: accentColor,
          ),
        ],
      ),
    );
  }
}

class _TimeSetting extends StatelessWidget {
  final String icon, label;
  final TimeOfDay time;
  final void Function(TimeOfDay) onChanged;

  const _TimeSetting({
    required this.icon,
    required this.label,
    required this.time,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');

    return GestureDetector(
      onTap: () async {
        final picked = await showCustomTimePicker(
          context: context,
          initialTime: time,
        );
        if (picked != null) onChanged(picked);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: context.colors.gold.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'NotoNaskhArabic',
                  fontSize: 13,
                  color: context.colors.textPrimary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: context.colors.goldDim,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: context.colors.gold.withOpacity(0.25),
                ),
              ),
              child: Text(
                '$h:$m',
                style: TextStyle(
                  fontFamily: 'NotoNaskhArabic',
                  fontSize: 14,
                  color: context.colors.gold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectSetting extends StatelessWidget {
  final String icon, label, value;
  final Map<String, String> options;
  final void Function(String) onChanged;

  const _SelectSetting({
    required this.icon,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: context.colors.teal.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'NotoNaskhArabic',
                      fontSize: 13,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  Text(
                    options[value] ?? value,
                    style: TextStyle(
                      fontFamily: 'NotoNaskhArabic',
                      fontSize: 10,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: context.colors.textDim,
            ),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
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
              label,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 18,
                color: context.colors.gold,
              ),
            ),
            const SizedBox(height: 14),
            ...options.entries.map(
              (e) => GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  onChanged(e.key);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: value == e.key
                        ? context.colors.teal.withOpacity(0.12)
                        : context.colors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: value == e.key
                          ? context.colors.teal.withOpacity(0.35)
                          : context.colors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          e.value,
                          style: TextStyle(
                            fontFamily: 'NotoNaskhArabic',
                            fontSize: 13,
                            color: value == e.key
                                ? context.colors.teal
                                : context.colors.textPrimary,
                            fontWeight: value == e.key
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (value == e.key)
                        Icon(
                          Icons.check_circle_rounded,
                          color: context.colors.teal,
                          size: 18,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionSetting extends StatelessWidget {
  final String icon, label, sublabel;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionSetting({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? context.colors.danger
        : context.colors.textPrimary;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color:
                    (isDestructive
                            ? context.colors.danger
                            : context.colors.gold)
                        .withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'NotoNaskhArabic',
                      fontSize: 13,
                      color: color,
                    ),
                  ),
                  Text(
                    sublabel,
                    style: TextStyle(
                      fontFamily: 'NotoNaskhArabic',
                      fontSize: 10,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: context.colors.textDim,
            ),
          ],
        ),
      ),
    );
  }
}

class _AdhanSelectSetting extends StatefulWidget {
  final String icon, label, value;
  final Map<String, String> options;
  final void Function(String) onChanged;

  const _AdhanSelectSetting({
    required this.icon,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  State<_AdhanSelectSetting> createState() => _AdhanSelectSettingState();
}

class _AdhanSelectSettingState extends State<_AdhanSelectSetting> {
  AudioPlayer? _player;
  StreamSubscription<PlayerState>? _playerSub;
  String? _currentlyPlayingKey;

  @override
  void dispose() {
    _playerSub?.cancel();
    _player?.dispose();
    super.dispose();
  }

  Future<void> _stopPreview() async {
    await _playerSub?.cancel();
    _playerSub = null;
    await _player?.stop();
    await _player?.dispose();
    _player = null;
    if (mounted) setState(() => _currentlyPlayingKey = null);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: context.colors.teal.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(widget.icon, style: const TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontFamily: 'NotoNaskhArabic',
                      fontSize: 13,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  Text(
                    widget.options[widget.value] ?? widget.value,
                    style: TextStyle(
                      fontFamily: 'NotoNaskhArabic',
                      fontSize: 10,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: context.colors.textDim,
            ),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    // Snapshot current playing key for the sheet
    String? playingKey = _currentlyPlayingKey;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setStateSheet) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              20,
              16,
              MediaQuery.of(ctx).padding.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
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
                  widget.label,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 18,
                    color: context.colors.gold,
                  ),
                ),
                const SizedBox(height: 14),
                Flexible(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(ctx).size.height * 0.6,
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: widget.options.entries.map((e) {
                          final isSelected = widget.value == e.key;
                          final isPlaying = playingKey == e.key;

                          return GestureDetector(
                            onTap: () async {
                              // Stop any preview first
                              await _playerSub?.cancel();
                              _playerSub = null;
                              await _player?.stop();
                              await _player?.dispose();
                              _player = null;
                              if (mounted) {
                                setState(() => _currentlyPlayingKey = null);
                              }
                              // Save selection
                              widget.onChanged(e.key);
                              if (ctx.mounted) Navigator.pop(ctx);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? context.colors.teal.withOpacity(0.12)
                                    : context.colors.background,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? context.colors.teal.withOpacity(0.35)
                                      : context.colors.border,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      e.value,
                                      style: TextStyle(
                                        fontFamily: 'NotoNaskhArabic',
                                        fontSize: 13,
                                        color: isSelected
                                            ? context.colors.teal
                                            : context.colors.textPrimary,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  // Preview play/stop button
                                  GestureDetector(
                                    onTap: () async {
                                      if (isPlaying) {
                                        // Stop preview
                                        await _playerSub?.cancel();
                                        _playerSub = null;
                                        await _player?.stop();
                                        await _player?.dispose();
                                        _player = null;
                                        playingKey = null;
                                        setStateSheet(() {});
                                        if (mounted) {
                                          setState(
                                            () => _currentlyPlayingKey = null,
                                          );
                                        }
                                      } else {
                                        // Stop current preview first
                                        await _playerSub?.cancel();
                                        _playerSub = null;
                                        await _player?.stop();
                                        await _player?.dispose();
                                        _player = null;

                                        // Start new preview
                                        final ap = AudioPlayer();
                                        _player = ap;
                                        playingKey = e.key;
                                        if (mounted) {
                                          setState(
                                            () => _currentlyPlayingKey = e.key,
                                          );
                                        }
                                        setStateSheet(() {});

                                        await ap.setAsset(
                                          'assets/sounds/${e.key}',
                                        );
                                        _playerSub = ap.playerStateStream
                                            .listen((state) {
                                              if (state.processingState ==
                                                  ProcessingState.completed) {
                                                playingKey = null;
                                                if (mounted) {
                                                  setState(
                                                    () => _currentlyPlayingKey =
                                                        null,
                                                  );
                                                }
                                                if (ctx.mounted) {
                                                  setStateSheet(() {});
                                                }
                                              }
                                            });
                                        await ap.play();
                                      }
                                    },
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: isPlaying
                                            ? context.colors.gold.withOpacity(
                                                0.18,
                                              )
                                            : context.colors.gold.withOpacity(
                                                0.09,
                                              ),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: context.colors.gold
                                              .withOpacity(0.25),
                                        ),
                                      ),
                                      child: Icon(
                                        isPlaying
                                            ? Icons.stop_rounded
                                            : Icons.play_arrow_rounded,
                                        size: 20,
                                        color: context.colors.gold,
                                      ),
                                    ),
                                  ),
                                  if (isSelected) ...[
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: context.colors.teal,
                                      size: 18,
                                    ),
                                  ] else
                                    const SizedBox(width: 26),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ).whenComplete(() async {
      await _stopPreview();
    });
  }
}
