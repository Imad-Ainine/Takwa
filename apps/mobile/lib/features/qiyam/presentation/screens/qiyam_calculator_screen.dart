import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_pattern_background.dart';
import '../../../../core/widgets/custom_leading_button.dart';
import '../../../../core/notifications/notifications_service.dart';

class QiyamCalculatorScreen extends ConsumerWidget {
  const QiyamCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayersAsync = ref.watch(prayerTimesProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      body: Stack(
        children: [
          const Positioned.fill(
            child: CustomPatternBackground(pattern: BackgroundPattern.adhkar),
          ),
          SafeArea(
            child: prayersAsync.when(
              data: (prayers) => _buildContent(context, prayers),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('خطأ في تحميل الأوقات: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<PrayerTimeInfo> prayers) {
    final maghrib = prayers.firstWhere((p) => p.name == 'maghrib').time;
    final fajr = prayers.firstWhere((p) => p.name == 'fajr').time;

    // Total night duration (Maghrib to Fajr)
    // If Fajr is before Maghrib (same day), move Fajr to tomorrow
    var fajrAdjusted = fajr;
    if (fajr.isBefore(maghrib)) {
      fajrAdjusted = fajr.add(const Duration(days: 1));
    }

    final totalNight = fajrAdjusted.difference(maghrib);
    final midnight = maghrib.add(totalNight ~/ 2);
    final lastThirdStart = fajrAdjusted.subtract(totalNight ~/ 3);

    return Column(
      children: [
        _buildAppTopBar(context),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildTimeCard(
                  context,
                  title: 'منتصف الليل الشرعي',
                  time: midnight,
                  subtitle: 'ينتهي فيه وقت العشاء الاختياري',
                  icon: Icons.brightness_3,
                  color: context.colors.teal,
                ),
                const SizedBox(height: 16),
                _buildTimeCard(
                  context,
                  title: 'بداية الثلث الأخير',
                  time: lastThirdStart,
                  subtitle: 'أفضل وقت لصلاة القيام والوتر',
                  icon: Icons.auto_awesome,
                  color: context.colors.gold,
                  isHighlight: true,
                ),
                const SizedBox(height: 24),
                _buildinfoSection(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const CustomLeadingButton(),
          const SizedBox(width: 12),
          Text(
            'حاسبة الليل',
            style: context.typography.displayMedium.copyWith(
              fontSize: 22,
              color: context.colors.gold,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCard(
    BuildContext context, {
    required String title,
    required DateTime time,
    required String subtitle,
    required IconData icon,
    required Color color,
    bool isHighlight = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHighlight ? color.withOpacity(0.5) : context.colors.border,
          width: isHighlight ? 2 : 1,
        ),
        boxShadow: isHighlight
            ? [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            const Positioned.fill(
              child: CustomPatternBackground(
                pattern: BackgroundPattern.crystalFacets,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: context.typography.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: context.typography.caption.copyWith(
                            color: context.colors.textDim,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatTime(time),
                    style: context.typography.displayMedium.copyWith(
                      fontSize: 20,
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildinfoSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.gold.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.gold.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(Icons.info_outline, color: context.colors.gold),
          const SizedBox(height: 12),
          Text(
            'عن أبي هريرة رضي الله عنه أن رسول الله ﷺ قال: "ينزل ربنا تبارك وتعالى كل ليلة إلى السماء الدنيا حين يبقى ثلث الليل الآخر يقول: من يدعوني فأستجيب له، من يسألني فأعطيه، من يستغفرني فأغفر له"',
            style: context.typography.quranicVerse.copyWith(
              fontSize: 14,
              color: context.colors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour < 12 ? 'ص' : 'م';
    return '$h:$m $ampm';
  }
}
