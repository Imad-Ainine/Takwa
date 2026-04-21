// ═══════════════════════════════════════════════════════════════
//  lib/features/settings/presentation/screens/terms_privacy_screen.dart
//  تقوى — Terms & Privacy (الشروط والخصوصية)
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
            child: CustomPatternBackground(
              pattern: BackgroundPattern.geometric,
            ),
          ),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileHeader(context),
                      const SizedBox(height: 24),
                      _buildSectionTitle(
                        context,
                        'شروط الاستخدام',
                        'Terms of Service',
                      ),
                      const SizedBox(height: 12),
                      _buildTermsContent(context),
                      const SizedBox(height: 24),
                      _buildSectionTitle(
                        context,
                        'سياسة الخصوصية',
                        'Privacy Policy',
                      ),
                      const SizedBox(height: 12),
                      _buildPrivacyContent(context),
                      const SizedBox(height: 40),
                      _buildFooter(context),
                      const SizedBox(height: 16),
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
      padding: const EdgeInsets.all(24),
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
          const SizedBox(height: 16),
          Text(
            'تطبيق تقوى',
            style: GoogleFonts.amiri(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: context.colors.textPrimary,
            ),
          ),
          Text(
            'الشروط وسياسة الخصوصية',
            style: GoogleFonts.poppins(
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
          style: GoogleFonts.poppins(
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
      padding: const EdgeInsets.all(20),
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
      padding: const EdgeInsets.all(20),
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
          const SizedBox(height: 20),
          Text(
            'شكراً لثقتكم بتطبيق تقوى',
            style: context.typography.headingMedium.copyWith(
              color: context.colors.gold,
            ),
          ),
          const SizedBox(height: 12),
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
