import 'package:flutter/material.dart';
import 'package:takwa/core/theme/app_theme.dart';
import 'package:takwa/core/widgets/custom_leading_button.dart';
import 'package:takwa/core/widgets/custom_pattern_background.dart';

class TermsPrivacyScreen extends StatelessWidget {
  const TermsPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Stack(
        children: [
          const Positioned.fill(
            child: CustomPatternBackground(pattern: BackgroundPattern.adhkar),
          ),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileHeader(context),
                      const SizedBox(height: AppSpacing.xxl),
                      _buildSectionTitle(
                        context,
                        'شروط الاستخدام',
                        'Terms of Service',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildTermsContent(context),
                      const SizedBox(height: AppSpacing.xxl),
                      _buildSectionTitle(
                        context,
                        'سياسة الخصوصية',
                        'Privacy Policy',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildPrivacyContent(context),
                      const SizedBox(height: 40),
                      _buildFooter(context),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      leading: const CustomLeadingButton(),
      title: Text(
        'الشروط والخصوصية',
        style: context.typography.headingMedium.copyWith(
          color: context.colors.gold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: context.decorations.goldCard.copyWith(
        color: context.colors.card.withOpacity(0.85),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colors.gold.withOpacity(0.15),
            ),
            child: Icon(
              Icons.gavel_rounded,
              color: context.colors.gold,
              size: 40,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'تطبيق تقوى',
            style: context.typography.headingLarge.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: context.colors.textPrimary,
            ),
          ),
          Text(
            'الشروط وسياسة الخصوصية',
            style: context.typography.labelMedium.copyWith(
              fontSize: 14,
              color: context.colors.goldLight,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String arabic,
    String english,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          arabic,
          style: context.typography.headingMedium.copyWith(
            color: context.colors.teal,
          ),
        ),
        Text(
          english,
          style: context.typography.caption.copyWith(
            fontSize: 12,
            color: context.colors.textDim,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTermsContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: context.decorations.card.copyWith(
        color: context.colors.card.withOpacity(0.85),
      ),
      child: Text(
        'أهلاً بك في تطبيق "تقوى". باستخدامك لهذا التطبيق، فإنك توافق على شروط وأحكام الاستخدام الموضحة. نهدف من خلال هذا التطبيق لتقديم خدمات إسلامية من أذكار، مواقيت الصلاة، والقيم الإسلامية بما ينفع أمتنا الإسلامية. يرجى استخدام التطبيق وفق الغرض المخصص له، وعدم إساءة استخدام الخدمات أو المحتوى.',
        style: context.typography.bodyMedium.copyWith(height: 1.8),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildPrivacyContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: context.decorations.card.copyWith(
        color: context.colors.card.withOpacity(0.85),
      ),
      child: Text(
        'نحن نحترم خصوصيتك ونهتم بحماية بياناتك الشخصية. التطبيق قد يحتاج إلى الوصول لموقعك الجغرافي فقط لتحديد أوقات الصلاة بدقة. لا نقوم بمشاركة أو بيع بياناتك الشخصية لأي جهة خارجية. بياناتك تُستخدم محلياً داخل جهازك لتوفير تجربة مستخدم أفضل.',
        style: context.typography.bodyMedium.copyWith(height: 1.8),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(height: 1, width: 80, color: context.colors.border),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'شكراً لثقتكم بتطبيق تقوى',
            style: context.typography.headingMedium.copyWith(
              color: context.colors.gold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'نسأل الله أن ينفعنا وإياكم بما فيه الخير',
            style: context.typography.caption.copyWith(
              color: context.colors.textDim,
            ),
          ),
        ],
      ),
    );
  }
}
