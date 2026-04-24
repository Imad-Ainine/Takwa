import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_pattern_background.dart';
import '../../../../core/widgets/custom_leading_button.dart';

class QiyamSunnahGuideScreen extends StatelessWidget {
  const QiyamSunnahGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Stack(
        children: [
          const Positioned.fill(
            child: CustomPatternBackground(pattern: BackgroundPattern.asma),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildGuideHeader(context),
                      const SizedBox(height: 24),
                      _buildStepCard(
                        context,
                        number: '1',
                        title: 'النية والإخلاص',
                        content:
                            'أن ينوي العبد قيام الليل تقرباً لله عز وجل، ويفضل أن ينام على طهارة.',
                      ),
                      _buildStepCard(
                        context,
                        number: '2',
                        title: 'الاستفتاح بركعتين خفيفتين',
                        content:
                            'كان النبي ﷺ إذا قام من الليل افتتح صلاته بركعتين خفيفتين، لتنشيط الجسد.',
                      ),
                      _buildStepCard(
                        context,
                        number: '3',
                        title: 'كيفية الصلاة (مثنى مثنى)',
                        content:
                            'صلاة الليل مثنى مثنى، أي يسلم بعد كل ركعتين، ويطيل الركوع والسجود حسب الاستطاعة.',
                      ),
                      _buildStepCard(
                        context,
                        number: '4',
                        title: 'القراءة بتدبر',
                        content:
                            'يستحب أن تكون القراءة بترتيل وتدبر، ويسأل الله عند آية الرحمة، ويتعوذ عند آية العذاب.',
                      ),
                      _buildStepCard(
                        context,
                        number: '5',
                        title: 'ختم القيام بالوتر',
                        content:
                            'يختم المصلي قيامه بركعة واحدة توتر له ما صلى، لقوله ﷺ: "اجعلوا آخر صلاتكم بالليل وتراً".',
                      ),
                      const SizedBox(height: 24),
                      _buildQuoteSection(context),
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
            'طريقة القيام والتهجد',
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

  Widget _buildGuideHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colors.gold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.colors.gold.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 40),
          const SizedBox(height: 16),
          Text(
            'هدي النبي ﷺ في قيام الليل',
            style: context.typography.displayMedium.copyWith(
              fontSize: 20,
              color: context.colors.gold,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'دليل شامل لتعلم كيفية صلاة التهجد كما وردت عن الرسول ﷺ والصحابة الكرام.',
            style: context.typography.bodyLarge.copyWith(
              color: context.colors.textPrimary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(
    BuildContext context, {
    required String number,
    required String title,
    required String content,
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
              child: CustomPatternBackground(
                pattern: BackgroundPattern.curvedPetals,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: context.colors.gold,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        number,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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
                            color: context.colors.gold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          content,
                          style: context.typography.bodyLarge.copyWith(
                            color: context.colors.textSecondary,
                            height: 1.6,
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

  Widget _buildQuoteSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.teal.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.teal.withOpacity(0.2)),
      ),
      child: Text(
        'عن عائشة رضي الله عنها قالت: "كان النبي ﷺ يصلي من الليل إحدى عشرة ركعة، يوتر منها بواحدة".',
        style: context.typography.bodyLarge.copyWith(
          color: context.colors.textSecondary,
          height: 1.5,
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
