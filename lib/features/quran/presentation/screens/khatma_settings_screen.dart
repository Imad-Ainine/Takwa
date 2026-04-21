// ═══════════════════════════════════════════════════════════════
//  lib/features/quran/presentation/screens/khatma_settings_screen.dart
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/quran_models.dart';
import '../../providers/quran_providers.dart';
import 'package:takwa/core/widgets/custom_leading_button.dart';
import '../../utils/quran_helpers.dart';

class KhatmaSettingsScreen extends ConsumerWidget {
  const KhatmaSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quranStateProvider);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: const Color.fromARGB(46, 4, 1, 35),
            foregroundColor: Colors.white,
            pinned: true,
            leading: const CustomLeadingButton(),
            title: Text(
              'الإعدادات',
              style: GoogleFonts.amiri(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
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
                  _sectionHeader('إعدادات القراءة'),
                  const SizedBox(height: 14),

                  // Font size
                  _settingsCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.format_size_rounded,
                              color: kGoldChip,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'حجم الخط',
                              style: GoogleFonts.amiri(
                                fontSize: 17,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${state.fontSize.toInt()}',
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                color: kGoldChip,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: state.fontSize,
                          min: 14,
                          max: 34,
                          activeColor: kGoldChip,
                          inactiveColor: Colors.white12,
                          onChanged: (v) => ref
                              .read(quranStateProvider.notifier)
                              .setFontSize(v),
                        ),
                        // Preview
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ',
                              style: GoogleFonts.amiriQuran(
                                fontSize: state.fontSize,
                                color: Colors.white,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.palette_rounded,
                              color: kGoldChip,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'مظهر القراءة',
                              style: GoogleFonts.amiri(
                                fontSize: 17,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
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
                                    horizontal: 4,
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: bg,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: selected
                                          ? kGoldChip
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
                                      const SizedBox(height: 4),
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
                  const SizedBox(height: 24),
                  _sectionHeader('إعدادات الختمة'),
                  const SizedBox(height: 14),

                  // Daily target
                  _settingsCard(
                    child: Column(
                      children: [
                        _tileRow(
                          Icons.today_rounded,
                          'الهدف اليومي',
                          '${ar(5)} صفحات',
                        ),
                        const Divider(color: Colors.white10, height: 20),
                        _tileRow(
                          Icons.notifications_rounded,
                          'تذكير يومي',
                          '',
                          trailing: Switch(
                            value: true,
                            activeColor: kGoldChip,
                            onChanged: (_) {},
                          ),
                        ),
                        const Divider(color: Colors.white10, height: 20),
                        _tileRow(Icons.mic_rounded, 'القارئ', 'الشيخ المنشاوي'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  _sectionHeader('معلومات التطبيق'),
                  const SizedBox(height: 14),
                  _settingsCard(
                    child: Column(
                      children: [
                        _tileRow(Icons.info_outline, 'الإصدار', '١.٠.٠'),
                        const Divider(color: Colors.white10, height: 20),
                        _tileRow(
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

  Widget _sectionHeader(String title) => Padding(
    padding: const EdgeInsets.only(right: 4),
    child: Text(
      title,
      style: GoogleFonts.amiri(
        fontSize: 16,
        color: Colors.white54,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Widget _settingsCard({required Widget child}) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.07),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withOpacity(0.1)),
    ),
    child: child,
  );

  Widget _tileRow(
    IconData icon,
    String label,
    String value, {
    Widget? trailing,
  }) => Row(
    children: [
      Icon(icon, color: kGoldChip, size: 20),
      const SizedBox(width: 12),
      Text(
        label,
        style: GoogleFonts.outfit(fontSize: 14, color: Colors.white70),
      ),
      const Spacer(),
      if (trailing != null)
        trailing
      else
        Text(
          value,
          style: GoogleFonts.outfit(fontSize: 13, color: Colors.white38),
        ),
    ],
  );
}
