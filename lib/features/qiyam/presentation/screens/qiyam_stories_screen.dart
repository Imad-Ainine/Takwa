import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_pattern_background.dart';

class QiyamStoriesScreen extends StatelessWidget {
  const QiyamStoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Stack(
        children: [
          const Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: CustomPatternBackground(pattern: BackgroundPattern.adhkar),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildAppTopBar(context),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _stories.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) =>
                        _buildStoryCard(context, _stories[index]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new, color: context.colors.gold),
          ),
          const SizedBox(width: 12),
          Text(
            'قصص وعجائب القيام',
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

  Widget _buildStoryCard(BuildContext context, _Story story) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(story.icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  story.title,
                  style: context.typography.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.gold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            story.content,
            style: context.typography.bodyMedium.copyWith(
              color: context.colors.textSecondary,
              height: 1.6,
            ),
          ),
          if (story.reference.isNotEmpty) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '— ${story.reference}',
                style: context.typography.caption.copyWith(
                  color: context.colors.textDim,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Story {
  final String title, content, reference, icon;
  const _Story({
    required this.title,
    required this.content,
    required this.icon,
    this.reference = '',
  });
}

const _stories = [
  _Story(
    title: 'شرف المؤمن',
    icon: '✨',
    content:
        'قال جبريل عليه السلام للنبي ﷺ: "يا محمد، عش ما شئت فإنك ميت، وأحبب من شئت فإنك مفارقه، واعمل ما شئت فإنك مجزي به، واعلم أن شرف المؤمن قيامه بالليل، وعزه استغناؤه عن الناس".',
    reference: 'رواه الحاكم',
  ),
  _Story(
    title: 'سيد التابعين والقيام',
    icon: '🌟',
    content:
        'كان أويس القرني رضي الله عنه إذا أمسى يقول: هذه ليلة الركوع، فيركع حتى يصبح، وكان يقول في ليلة أخرى: هذه ليلة السجود، فيسجد حتى يصبح. قيل له: يا أويس، كيف تطيق هذا؟ قال: إنما هي ليلة واحدة، والجنة تستحق أكثر من ذلك.',
    reference: 'صفة الصفوة',
  ),
  _Story(
    title: 'سهام الليل لا تخطئ',
    icon: '🏹',
    content:
        'كان الإمام الشافعي يقول: "سهام الليل لا تخطئ، ولكن لها أمد وللأمد انقضاء". ويقصد بها دعاء المستيقظ في جوف الليل الموقن بالإجابة.',
    reference: 'ديوان الشافعي',
  ),
  _Story(
    title: 'نور الوجه من القيام',
    icon: '🌙',
    content:
        'سُئل الحسن البصري: ما بال المتهجدين من أحسن الناس وجوهاً؟ فقال: "لأنهم خلوا بالرحمن فألبسهم نوراً من نوره".',
  ),
];
