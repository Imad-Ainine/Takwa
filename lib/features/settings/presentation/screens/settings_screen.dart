// ═══════════════════════════════════════════════════════════════
//  lib/features/settings/presentation/screens/settings_screen.dart
//  محاسبة النفس — Settings Screen (شاشة الإعدادات)
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:muhasabah/core/theme/app_theme.dart';
import 'package:muhasabah/core/providers/database_providers.dart';
import 'package:muhasabah/core/providers/theme_provider.dart';
import 'package:muhasabah/core/notifications/notifications_service.dart';

import '../widgets/location_picker_sheet.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // local state mirrors DB
  bool _prayerReminder = true;
  bool _muhasabaReminder = true;
  bool _morningAdhkar = true;
  bool _eveningAdhkar = true;
  bool _wakeUpFajr = false;
  bool _ramadanMode = false;
  String _madhab = 'shafi';
  String _method = 'MWL';
  TimeOfDay _muhasabaTime = const TimeOfDay(hour: 21, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final s = ref.read(settingsDaoProvider);

    final prayerReminder = await s.getBool('prayerReminder', defaultVal: true);
    final muhasabaReminder = await s.getBool(
      'eveningMuhasabaReminder',
      defaultVal: true,
    );
    final morningAdhkar = await s.getBool(
      'morningAdhkarReminder',
      defaultVal: true,
    );
    final eveningAdhkar = await s.getBool(
      'eveningAdhkarReminder',
      defaultVal: true,
    );
    final wakeUpFajr = await s.getBool('wakeUpBeforeFajr', defaultVal: false);
    final ramadanMode = await s.getBool('ramadanMode', defaultVal: false);
    final madhab = await s.get('madhab') ?? 'shafi';
    final method = await s.get('calcMethod') ?? 'MWL';
    final tStr = await s.get('eveningReminderTime') ?? '21:00';
    final parts = tStr.split(':');
    final muhasabaTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    if (mounted) {
      setState(() {
        _prayerReminder = prayerReminder;
        _muhasabaReminder = muhasabaReminder;
        _morningAdhkar = morningAdhkar;
        _eveningAdhkar = eveningAdhkar;
        _wakeUpFajr = wakeUpFajr;
        _ramadanMode = ramadanMode;
        _madhab = madhab;
        _method = method;
        _muhasabaTime = muhasabaTime;
      });
    }
  }

  Future<void> _save(String key, dynamic value) async {
    final s = ref.read(settingsDaoProvider);
    if (value is bool) {
      await s.setBool(key, value);
    } else {
      await s.set(key, value.toString());
    }
    // إعادة جدولة الإشعارات
    await NotificationsManager.reschedule(ref);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              pinned: true,
              title: Text(
                'الإعدادات',
                style: context.typography.headingMedium.copyWith(
                  color: context.colors.gold,
                ),
              ),
              centerTitle: true,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 8),

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
                        value: _prayerReminder,
                        onChanged: (v) {
                          setState(() => _prayerReminder = v);
                          _save('prayerReminder', v);
                        },
                      ),
                      _Divider(),
                      _ToggleSetting(
                        icon: '🌙',
                        label: 'الاستيقاظ قبل الفجر',
                        sublabel: 'تنبيه قبل ١٥ دقيقة من الفجر',
                        value: _wakeUpFajr,
                        onChanged: (v) {
                          setState(() => _wakeUpFajr = v);
                          _save('wakeUpBeforeFajr', v);
                        },
                      ),
                      _Divider(),
                      _ToggleSetting(
                        icon: '☀️',
                        label: 'أذكار الصباح',
                        sublabel: 'تذكير يومي الساعة ٦:٣٠ ص',
                        value: _morningAdhkar,
                        onChanged: (v) {
                          setState(() => _morningAdhkar = v);
                          _save('morningAdhkarReminder', v);
                        },
                      ),
                      _Divider(),
                      _ToggleSetting(
                        icon: '🌆',
                        label: 'أذكار المساء',
                        sublabel: 'تذكير يومي الساعة ٥:٠٠ م',
                        value: _eveningAdhkar,
                        onChanged: (v) {
                          setState(() => _eveningAdhkar = v);
                          _save('eveningAdhkarReminder', v);
                        },
                      ),
                      _Divider(),
                      _ToggleSetting(
                        icon: '📝',
                        label: 'محاسبة مسائية',
                        sublabel: 'تذكير يومي للمحاسبة',
                        value: _muhasabaReminder,
                        onChanged: (v) {
                          setState(() => _muhasabaReminder = v);
                          _save('eveningMuhasabaReminder', v);
                        },
                      ),
                      if (_muhasabaReminder) ...[
                        _Divider(),
                        _TimeSetting(
                          icon: '⏰',
                          label: 'وقت المحاسبة',
                          time: _muhasabaTime,
                          onChanged: (t) async {
                            setState(() => _muhasabaTime = t);
                            final str =
                                '${t.hour.toString().padLeft(2, "0")}:${t.minute.toString().padLeft(2, "0")}';
                            await _save('eveningReminderTime', str);
                          },
                        ),
                      ],
                    ],
                  ),
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
                          ref.read(themeModeProvider.notifier).setTheme(mode);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── وضع رمضان ──
                  const _SectionHeader(title: 'وضع رمضان', icon: '🌙'),
                  _SettingsCard(
                    children: [
                      _ToggleSetting(
                        icon: '🌙',
                        label: 'وضع رمضان',
                        sublabel: 'تفعيل المميزات الرمضانية',
                        value: _ramadanMode,
                        onChanged: (v) {
                          setState(() => _ramadanMode = v);
                          _save('ramadanMode', v);
                        },
                        accentColor: context.colors.gold,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── أوقات الصلاة ──
                  const _SectionHeader(title: 'حساب أوقات الصلاة', icon: '🕌'),
                  _SettingsCard(
                    children: [
                      _SelectSetting(
                        icon: '📐',
                        label: 'المذهب الفقهي',
                        value: _madhab,
                        options: const {
                          'shafi': 'شافعي / مالكي / حنبلي',
                          'hanafi': 'حنفي',
                        },
                        onChanged: (v) {
                          setState(() => _madhab = v);
                          _save('madhab', v);
                        },
                      ),
                      _Divider(),
                      _SelectSetting(
                        icon: '🌍',
                        label: 'طريقة الحساب',
                        value: _method,
                        options: const {
                          'MWL': 'رابطة العالم الإسلامي',
                          'Egypt': 'دار الإفتاء المصرية',
                          'Karachi': 'جامعة كراتشي',
                          'UmmAlQura': 'أم القرى (مكة المكرمة)',
                          'ISNA': 'أمريكا الشمالية',
                        },
                        onChanged: (v) {
                          setState(() => _method = v);
                          _save('calcMethod', v);
                        },
                      ),
                      _Divider(),
                      _ActionSetting(
                        icon: '📍',
                        label: 'تحديث الموقع الجغرافي',
                        sublabel: 'للحصول على أدق أوقات الصلاة',
                        onTap: () => LocationPickerSheet.show(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── معلومات ──
                  const _SectionHeader(title: 'التطبيق', icon: 'ℹ️'),
                  _SettingsCard(
                    children: [
                      _ActionSetting(
                        icon: '🔔',
                        label: 'اختبار الإشعارات',
                        sublabel: 'تأكد من عمل الإشعارات',
                        onTap: _testNotification,
                      ),
                      _Divider(),
                      _ActionSetting(
                        icon: '👨‍💻',
                        label: 'عن المطور',
                        sublabel: 'تعرف على مبرمج التطبيق',
                        onTap: () => Navigator.pushNamed(context, '/about-me'),
                      ),
                      _Divider(),
                      _ActionSetting(
                        icon: '🗑️',
                        label: 'إعادة ضبط الإعدادات',
                        sublabel: 'حذف جميع الإعدادات',
                        onTap: _resetSettings,
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
                          style: GoogleFonts.amiri(
                            fontSize: 14,
                            color: context.colors.gold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'محاسبة النفس — v1.0.0',
                          style: GoogleFonts.notoNaskhArabic(
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
      ),
    );
  }

  Future<void> _testNotification() async {
    await NotificationsService.showAchievementNotif(
      title: 'اختبار الإشعار',
      body: 'الإشعارات تعمل بشكل صحيح',
      emoji: '✅',
      points: 0,
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
          style: GoogleFonts.amiri(fontSize: 18, color: context.colors.danger),
        ),
        content: Text(
          'هل تريد حذف جميع الإعدادات؟',
          style: GoogleFonts.notoNaskhArabic(
            fontSize: 13,
            color: context.colors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'إلغاء',
              style: GoogleFonts.notoNaskhArabic(
                fontSize: 13,
                color: context.colors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'حذف',
              style: GoogleFonts.notoNaskhArabic(
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
          style: GoogleFonts.amiri(
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
                  style: GoogleFonts.notoNaskhArabic(
                    fontSize: 13,
                    color: context.colors.textPrimary,
                  ),
                ),
                Text(
                  sublabel,
                  style: GoogleFonts.notoNaskhArabic(
                    fontSize: 10,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              onChanged(v);
            },
            activeColor: accentColor ?? context.colors.teal,
            activeTrackColor: (accentColor ?? context.colors.teal).withOpacity(
              0.3,
            ),
            inactiveTrackColor: context.colors.border,
            inactiveThumbColor: context.colors.textDim,
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
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: ColorScheme.dark(primary: context.colors.gold),
            ),
            child: child!,
          ),
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
                style: GoogleFonts.notoNaskhArabic(
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
                style: GoogleFonts.notoNaskhArabic(
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
                    style: GoogleFonts.notoNaskhArabic(
                      fontSize: 13,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  Text(
                    options[value] ?? value,
                    style: GoogleFonts.notoNaskhArabic(
                      fontSize: 10,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_left_rounded,
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
              style: GoogleFonts.amiri(
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
                          style: GoogleFonts.notoNaskhArabic(
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
                    style: GoogleFonts.notoNaskhArabic(
                      fontSize: 13,
                      color: color,
                    ),
                  ),
                  Text(
                    sublabel,
                    style: GoogleFonts.notoNaskhArabic(
                      fontSize: 10,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_left_rounded,
              size: 18,
              color: context.colors.textDim,
            ),
          ],
        ),
      ),
    );
  }
}
