import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/quran_models.dart';
import '../../providers/quran_providers.dart';
import 'package:takwa/core/widgets/custom_leading_button.dart';
import '../../utils/quran_helpers.dart';
import 'package:takwa/core/providers/database_providers.dart';
import 'package:takwa/core/theme/ramadan_theme.dart';

class KhatmaSettingsScreen extends ConsumerWidget {
  const KhatmaSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRamadan = ref.watch(ramadanModeProvider).value ?? false;
    final style = AdaptiveStyle(context, isRamadan);
    final state = ref.watch(quranStateProvider);

    return Scaffold(
      backgroundColor: style.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: style.isRamadan
                ? style.bg
                : const Color.fromARGB(46, 4, 1, 35),
            foregroundColor: style.text,
            pinned: true,
            leading: const CustomLeadingButton(),
            title: Text(
              'الإعدادات',
              style: style.amiri(
                22,
                color: style.text,
                weight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _sectionHeader(style, 'إعدادات القراءة'),
                  const SizedBox(height: 14),

                  // Font size
                  _settingsCard(
                    style: style,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.format_size_rounded,
                              color: style.gold,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'حجم الخط',
                              style: style.amiri(
                                17,
                                color: style.text,
                                weight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              ar(state.fontSize.toInt()),
                              style: style.naskh(
                                15,
                                color: style.gold,
                                weight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: state.fontSize,
                          min: 14,
                          max: 34,
                          activeColor: style.gold,
                          inactiveColor: style.gold.withOpacity(0.1),
                          onChanged: (v) => ref
                              .read(quranStateProvider.notifier)
                              .setFontSize(v),
                        ),
                        // Preview
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: style.card,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ',
                              style: style.amiri(
                                state.fontSize,
                                color: style.text,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Theme
                  _settingsCard(
                    style: style,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.palette_rounded,
                              color: style.gold,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'مظهر القراءة',
                              style: style.amiri(
                                17,
                                color: style.text,
                                weight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: ReaderTheme.values.map((t) {
                            final lbl =
                                {
                                  'night': 'ليلي',
                                  'sepia': 'عاجي',
                                  'white': 'فاتح',
                                }[t.name] ??
                                t.name;
                            final bg = {
                              'night': const Color(0xFF0D1117),
                              'sepia': const Color(0xFFF4ECD8),
                              'white': Colors.white,
                            }[t.name]!;
                            final selected = state.theme == t;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => ref
                                    .read(quranStateProvider.notifier)
                                    .setTheme(t),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.xs,
                                  ),
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: bg,
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.md,
                                    ),
                                    border: Border.all(
                                      color: selected
                                          ? style.gold
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.brightness_medium_rounded,
                                        size: 22,
                                        color: {
                                          'night': Colors.white60,
                                          'sepia': Colors.brown,
                                          'white': Colors.blueGrey,
                                        }[t.name],
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        lbl,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: t == ReaderTheme.white
                                              ? Colors.black87
                                              : Colors.white70,
                                          fontWeight: selected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  _sectionHeader(style, 'إعدادات الختمة'),
                  const SizedBox(height: 14),

                  // Daily target
                  _settingsCard(
                    style: style,
                    child: Column(
                      children: [
                        _tileRow(
                          style,
                          Icons.today_rounded,
                          'الهدف اليومي',
                          '${ar(5)} صفحات',
                        ),
                        Divider(
                          color: style.gold.withOpacity(0.05),
                          height: 20,
                        ),
                        _tileRow(
                          style,
                          Icons.notifications_rounded,
                          'تذكير يومي',
                          '',
                          trailing: Switch(
                            value: true,
                            activeColor: style.gold,
                            onChanged: (_) {},
                          ),
                        ),
                        Divider(
                          color: style.gold.withOpacity(0.05),
                          height: 20,
                        ),
                        _tileRow(
                          style,
                          Icons.mic_rounded,
                          'القارئ',
                          'الشيخ المنشاوي',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),
                  _sectionHeader(style, 'معلومات التطبيق'),
                  const SizedBox(height: 14),
                  _settingsCard(
                    style: style,
                    child: Column(
                      children: [
                        _tileRow(style, Icons.info_outline, 'الإصدار', '١.٠.٠'),
                        Divider(
                          color: style.gold.withOpacity(0.05),
                          height: 20,
                        ),
                        _tileRow(
                          style,
                          Icons.star_outline_rounded,
                          'تقييم التطبيق',
                          '',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(AdaptiveStyle style, String title) => Padding(
    padding: const EdgeInsets.only(right: 4),
    child: Text(
      title,
      style: style.amiri(
        16,
        color: style.text.withOpacity(0.5),
        weight: FontWeight.bold,
      ),
    ),
  );

  Widget _settingsCard({required AdaptiveStyle style, required Widget child}) =>
      Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: style.card,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: style.gold.withOpacity(0.1)),
        ),
        child: child,
      );

  Widget _tileRow(
    AdaptiveStyle style,
    IconData icon,
    String label,
    String value, {
    Widget? trailing,
  }) => Row(
    children: [
      Icon(icon, color: style.gold, size: 20),
      const SizedBox(width: AppSpacing.md),
      Text(label, style: style.naskh(14, color: style.text.withOpacity(0.7))),
      const Spacer(),
      if (trailing != null)
        trailing
      else
        Text(value, style: style.naskh(13, color: style.text.withOpacity(0.4))),
    ],
  );
}
