import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_pattern_background.dart';
import '../../../../core/widgets/custom_leading_button.dart';
import '../../../../core/widgets/custom_time_picker.dart';

class QiyamSleepCalculatorScreen extends StatefulWidget {
  const QiyamSleepCalculatorScreen({super.key});

  @override
  State<QiyamSleepCalculatorScreen> createState() =>
      _QiyamSleepCalculatorScreenState();
}

class _QiyamSleepCalculatorScreenState
    extends State<QiyamSleepCalculatorScreen> {
  TimeOfDay _wakeupTime = const TimeOfDay(hour: 4, minute: 30);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Stack(
        children: [
          const Positioned.fill(
            child: CustomPatternBackground(pattern: BackgroundPattern.adhkar),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context),
                        const SizedBox(height: 32),
                        _buildWakeupSelector(context),
                        const SizedBox(height: 32),
                        Text(
                          'أفضل أوقات النوم:',
                          style: context.typography.displayMedium.copyWith(
                            fontSize: 20,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ..._buildCycleCards(context),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          const CustomLeadingButton(),
          const Spacer(),
          Text(
            'حاسبة النوم الذكية',
            style: context.typography.displayMedium.copyWith(
              fontSize: 20,
              color: context.colors.gold,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 40), // Placeholder for symmetry
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text(
            'استيقظ نشيطاً لقيام الليل',
            style: context.typography.displayMedium.copyWith(
              fontSize: 24,
              color: context.colors.gold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'تعتمد الحاسبة على دورات النوم (90 دقيقة) لتحديد أفضل وقت للنوم حتى تستيقظ في قمة نشاطك.',
            style: context.typography.bodyLarge.copyWith(
              color: context.colors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildWakeupSelector(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: context.colors.gold.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: context.colors.gold.withOpacity(0.05),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              'متى تريد الاستيقاظ؟',
              style: context.typography.bodyLarge.copyWith(
                color: context.colors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () async {
                final picked = await showCustomTimePicker(
                  context: context,
                  initialTime: _wakeupTime,
                );
                if (picked != null) {
                  setState(() => _wakeupTime = picked);
                }
              },
              child: InkWell(
                onTap: () async {
                  final TimeOfDay? picked = await showCustomTimePicker(
                    context: context,
                    initialTime: _wakeupTime,
                  );
                  if (picked != null) {
                    setState(() {
                      _wakeupTime = picked;
                    });
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.colors.gold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: context.colors.gold.withOpacity(0.5),
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Positioned.fill(
                          child: CustomPatternBackground(
                            pattern: BackgroundPattern.adhkar,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 16,
                          ),
                          child: Text(
                            '${_wakeupTime.hour.toString().padLeft(2, '0')}:${_wakeupTime.minute.toString().padLeft(2, '0')}',
                            style: context.typography.displayLarge.copyWith(
                              fontSize: 42,
                              color: context.colors.gold,
                              letterSpacing: 2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCycleCards(BuildContext context) {
    final cycles = [
      {'label': '9 ساعات (مثالي)', 'hours': 9.0, 'color': Colors.green},
      {'label': '7.5 ساعات (ممتاز)', 'hours': 7.5, 'color': Colors.lightGreen},
      {'label': '6 ساعات (جيد)', 'hours': 6.0, 'color': Colors.orange},
      {'label': '4.5 ساعات (كافٍ)', 'hours': 4.5, 'color': Colors.deepOrange},
      {'label': '1.5 ساعة (غفوة)', 'hours': 1.5, 'color': Colors.red},
    ];

    return cycles.map((cycle) {
      final hours = cycle['hours'] as double;
      final color = cycle['color'] as Color;
      final sleepTime = _calculateSleepTime(hours);

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: context.colors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Stack(
              children: [
                const Positioned.fill(
                  child: CustomPatternBackground(
                    pattern: BackgroundPattern.adhkar,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          cycle['label'] as String,
                          style: context.typography.caption.copyWith(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatTime(sleepTime),
                            style: context.typography.displayMedium.copyWith(
                              fontSize: 22,
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'يجب أن تنام الساعة',
                            style: context.typography.caption.copyWith(
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  DateTime _calculateSleepTime(double hours) {
    final now = DateTime.now();
    var wakeup = DateTime(
      now.year,
      now.month,
      now.day,
      _wakeupTime.hour,
      _wakeupTime.minute,
    );

    // If wakeup is before now, it's for tomorrow
    if (wakeup.isBefore(now)) {
      wakeup = wakeup.add(const Duration(days: 1));
    }

    // Subtract sleep duration + 15 mins for falling asleep
    final totalMinutes = (hours * 60).toInt() + 15;
    return wakeup.subtract(Duration(minutes: totalMinutes));
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    return '$ampm $h:$m';
  }
}
