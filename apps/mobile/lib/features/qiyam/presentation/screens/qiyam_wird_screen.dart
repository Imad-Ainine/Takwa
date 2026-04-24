import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_pattern_background.dart';
import '../../../../core/widgets/custom_leading_button.dart';

class QiyamWirdScreen extends StatelessWidget {
  const QiyamWirdScreen({super.key});

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
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildSectionHeader(context, 'أذكار ما قبل القيام'),
                      const WirdCardWidget(
                        title: 'الاستغفار',
                        content:
                            'أستغفر الله العظيم الذي لا إله إلا هو الحي القيوم وأتوب إليه',
                        count: 100,
                      ),
                      const WirdCardWidget(
                        title: 'التسبيح',
                        content: 'سبحان الله وبحمده، سبحان الله العظيم',
                        count: 100,
                      ),
                      const SizedBox(height: 16),
                      _buildSectionHeader(context, 'أدعية مأثورة في السحر'),
                      const WirdCardWidget(
                        title: 'دعاء النبي ﷺ',
                        content:
                            'اللهم لك الحمد، أنت نور السماوات والأرض ومن فيهن، ولك الحمد، أنت قيم السماوات والأرض ومن فيهن، ولك الحمد، أنت ملك السماوات والأرض ومن فيهن، ولك الحمد، أنت الحق، ووعدك حق، ولقاؤك حق، وقولك حق، والجنة حق، والنار حق، والنبيون حق، ومحمد ﷺ حق، والساعة حق.',
                        count: 1,
                      ),
                      const WirdCardWidget(
                        title: 'سيد الاستغفار',
                        content:
                            'اللهم أنت ربي لا إله إلا أنت، خلقتني وأنا عبدك، وأنا على عهدك ووعدك ما استطعت، أعوذ بك من شر ما صنعت، أبوء لك بنعمتك علي، وأبوء بذنبي فاغفر لي فإنه لا يغفر الذنوب إلا أنت.',
                        count: 1,
                      ),
                      const SizedBox(height: 16),
                      _buildSectionHeader(context, 'سورة الملك (المنجية)'),
                      _buildActionCard(
                        context,
                        title: 'قراءة سورة الملك',
                        subtitle: 'تشفع لصاحبها وتنجي من عذاب القبر',
                        icon: Icons.menu_book,
                        onTap: () {
                          // Navigate to Quran reader for Surah Al-Mulk (67)
                        },
                      ),
                    ],
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
            'ورد القيام',
            style: context.typography.displayMedium.copyWith(
              fontSize: 22,
              color: context.colors.gold,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: context.colors.gold,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: context.typography.displayMedium.copyWith(
              fontSize: 18,
              color: context.colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: context.colors.gold.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.colors.gold.withOpacity(0.2)),
          ),
          child: Stack(
            children: [
              const Positioned.fill(
                child: CustomPatternBackground(
                  pattern: BackgroundPattern.adhkar,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.colors.gold.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: context.colors.gold),
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
                    Icon(Icons.chevron_right, color: context.colors.gold),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WirdCardWidget extends StatefulWidget {
  final String title;
  final String content;
  final int count;

  const WirdCardWidget({
    super.key,
    required this.title,
    required this.content,
    required this.count,
  });

  @override
  State<WirdCardWidget> createState() => _WirdCardWidgetState();
}

class _WirdCardWidgetState extends State<WirdCardWidget> {
  int _currentCount = 0;

  void _increment() {
    if (_currentCount < widget.count) {
      HapticFeedback.lightImpact();
      setState(() {
        _currentCount++;
      });
    } else {
      HapticFeedback.heavyImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = _currentCount >= widget.count;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted
              ? context.colors.gold.withOpacity(0.5)
              : context.colors.border,
          width: isCompleted ? 2 : 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            const Positioned.fill(
              child: CustomPatternBackground(pattern: BackgroundPattern.adhkar),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.title,
                        style: context.typography.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.colors.gold,
                        ),
                      ),
                      if (widget.count > 1)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: context.colors.gold.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${widget.count} مرة',
                            style: context.typography.caption.copyWith(
                              color: context.colors.gold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.content,
                    style: context.typography.quranicVerse.copyWith(
                      fontSize: 18,
                      color: context.colors.textPrimary,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _increment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCompleted
                          ? context.colors.gold.withOpacity(0.2)
                          : context.colors.gold.withOpacity(0.1),
                      foregroundColor: context.colors.gold,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isCompleted
                              ? context.colors.gold
                              : context.colors.gold.withOpacity(0.3),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isCompleted ? Icons.check_circle : Icons.touch_app,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isCompleted
                              ? 'تم الورد بنجاح'
                              : (_currentCount == 0
                                    ? 'اضغط للعد'
                                    : '$_currentCount / ${widget.count}'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
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
}
