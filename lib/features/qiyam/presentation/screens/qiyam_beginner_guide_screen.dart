import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_pattern_background.dart';
import '../../../../core/widgets/custom_leading_button.dart';

class QiyamBeginnerGuideScreen extends StatelessWidget {
  const QiyamBeginnerGuideScreen({super.key});

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
                      _buildIntroHeader(context),
                      const SizedBox(height: 24),
                      _buildTipSection(
                        context,
                        title: 'ابدأ بالقليل',
                        content:
                            'لا تشق على نفسك في البداية، ابدأ بركعتين فقط بعد صلاة العشاء، ثم زد تدريجياً.',
                        icon: Icons.lightbulb_outline,
                      ),
                      _buildTipSection(
                        context,
                        title: 'التبكير في النوم',
                        content:
                            'النوم مبكراً هو المفتاح الذهبي للاستيقاظ بنشاط في وقت السحر.',
                        icon: Icons.bedtime_outlined,
                      ),
                      _buildTipSection(
                        context,
                        title: 'وضوء وبسملة',
                        content:
                            'توضأ قبل النوم واقرأ الأذكار، فذلك يعين الروح على القيام.',
                        icon: Icons.water_drop_outlined,
                      ),
                      _buildTipSection(
                        context,
                        title: 'اجعلها عادة',
                        content:
                            'الاستمرارية أهم من الكثرة، "أحب الأعمال إلى الله أدومها وإن قل".',
                        icon: Icons.repeat,
                      ),
                      const SizedBox(height: 32),
                      _buildQASection(context),
                      const SizedBox(height: 32),
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
            'دليل المبتدئين',
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

  Widget _buildIntroHeader(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.rocket_launch, size: 60, color: context.colors.gold),
        const SizedBox(height: 16),
        Text(
          'خطوتك الأولى في قيام الليل',
          style: context.typography.displayMedium.copyWith(
            fontSize: 24,
            color: context.colors.gold,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'لا تقلق إذا كنت في البداية، فكل قائم لليل بدأ بخطوة بسيطة. إليك خارطة الطريق.',
          style: context.typography.bodyLarge.copyWith(
            color: context.colors.textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTipSection(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.border),
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
                        const SizedBox(height: 4),
                        Text(
                          content,
                          style: context.typography.caption.copyWith(
                            color: context.colors.textDim,
                            fontSize: 14,
                          ),
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

  Widget _buildQASection(BuildContext context) {
    final questions = [
      {
        'q': 'هل يجب النوم قبل القيام؟',
        'a': 'لا يشترط، ولكن ما كان بعد نوم يسمى "تهجداً".',
      },
      {
        'q': 'ما هو أقل عدد للركعات؟',
        'a': 'ركعة واحدة (الوتر)، وأفضلها إحدى عشرة ركعة.',
      },
      {'q': 'متى يبدأ وقت القيام؟', 'a': 'من بعد صلاة العشاء وحتى أذان الفجر.'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'أسئلة شائعة',
          style: context.typography.displayMedium.copyWith(
            fontSize: 20,
            color: context.colors.gold,
          ),
        ),
        const SizedBox(height: 16),
        ...questions.map(
          (qa) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.gold.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.colors.gold.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  qa['q']!,
                  style: context.typography.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.gold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  qa['a']!,
                  style: context.typography.bodyLarge.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
