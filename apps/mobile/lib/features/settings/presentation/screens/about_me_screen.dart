import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:takwa/core/theme/app_theme.dart';
import 'package:takwa/core/widgets/custom_leading_button.dart';
import 'package:takwa/core/widgets/custom_pattern_background.dart';
import 'package:takwa/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutMeScreen extends StatelessWidget {
  const AboutMeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

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
              _buildAppBar(context, l),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileHeader(context, l),
                      const SizedBox(height: 24),
                      _buildSectionTitle(
                        context,
                        l.aboutSectionDeveloper,
                        l.aboutSectionDeveloper,
                      ),
                      const SizedBox(height: 12),
                      _buildBioCard(context, l),
                      const SizedBox(height: 24),
                      _buildSectionTitle(
                        context,
                        l.aboutSectionSkills,
                        l.aboutSectionSkills,
                      ),
                      const SizedBox(height: 12),
                      _buildSkillsGrid(context),
                      const SizedBox(height: 24),
                      _buildSectionTitle(
                        context,
                        l.aboutSectionConnect,
                        l.aboutSectionConnect,
                      ),
                      const SizedBox(height: 12),
                      _buildSocialLinks(context),
                      const SizedBox(height: 40),
                      _buildFooter(context, l),
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

  Widget _buildAppBar(BuildContext context, AppLocalizations l) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      leading: const CustomLeadingButton(),
      title: Text(
        l.aboutScreenTitle,
        style: context.typography.headingMedium.copyWith(
          color: context.colors.gold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildProfileHeader(BuildContext context, AppLocalizations l) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: context.decorations.goldCard.copyWith(
        color: context.colors.card.withOpacity(0.85),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: context.colors.gold, width: 3),
              boxShadow: context.shadows.goldGlow,
              image: const DecorationImage(
                image: AssetImage('assets/images/dev.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 16),
          // Arabic Name
          Text(
            l.aboutDevNameArabic,
            style: context.typography.headingLarge.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: context.colors.textPrimary,
            ),
          ),
          // Latin Name
          Text(
            l.aboutDevNameLatin,
            style: context.typography.headingMedium.copyWith(
              fontSize: 18,
              color: context.colors.goldLight,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          // Badge
          TaqwaBadge(label: l.aboutDevBadge),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String primary,
    String secondary,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          primary,
          style: context.typography.headingMedium.copyWith(
            color: context.colors.teal,
          ),
        ),
        Text(
          secondary,
          style: context.typography.caption.copyWith(
            fontSize: 12,
            color: context.colors.textDim,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBioCard(BuildContext context, AppLocalizations l) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: context.decorations.card.copyWith(
        color: context.colors.card.withOpacity(0.85),
      ),
      child: Text(
        l.aboutBio,
        style: context.typography.bodyMedium.copyWith(height: 1.8),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildSkillsGrid(BuildContext context) {
    const skills = [
      'Flutter',
      'Dart',
      'Node.js',
      'PostgreSQL',
      'Supabase',
      'Firebase',
      'Next.js',
      'React',
      'Git',
      'Clean Architecture',
      'Rest API',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: skills
          .map(
            (skill) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: context.colors.card2,
                borderRadius: AppRadius.chip,
                border: Border.all(color: context.colors.border),
              ),
              child: Text(
                skill,
                style: context.typography.labelMedium.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildSocialLinks(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialIcon(
              context,
              Icons.code_rounded,
              'GitHub',
              url: 'https://github.com/Imad-Ainine',
            ),
            const SizedBox(width: 16),
            _buildSocialIcon(
              context,
              Icons.business_center_rounded,
              'LinkedIn',
              url: 'https://www.linkedin.com/in/imadeddine-ainine',
            ),
            const SizedBox(width: 16),
            _buildSocialIcon(
              context,
              Icons.facebook_rounded,
              'Facebook',
              url: 'https://www.facebook.com/imad.ainine1',
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialIcon(
              context,
              Icons.mail_outline_rounded,
              'Email',
              url: 'mailto:imad.ainine11@gmail.com',
            ),
            const SizedBox(width: 16),
            _buildSocialIcon(
              context,
              Icons.phone_android_rounded,
              'Phone',
              url: 'tel:+213773843669',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialIcon(
    BuildContext context,
    IconData icon,
    String tooltip, {
    String? url,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: () async {
          HapticFeedback.lightImpact();
          if (url != null) {
            final uri = Uri.parse(url);
            try {
              final launched = await launchUrl(
                uri,
                mode: LaunchMode.externalApplication,
              );
              if (!launched) {
                debugPrint('Could not launch $url');
              }
            } catch (e) {
              debugPrint('Error launching $url: $e');
            }
          }
        },
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: context.colors.card,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: context.colors.border),
          ),
          child: Icon(icon, color: context.colors.gold, size: 24),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, AppLocalizations l) {
    return Center(
      child: Column(
        children: [
          Container(height: 1, width: 80, color: context.colors.border),
          const SizedBox(height: 20),
          Text(
            l.aboutFooterDuaRequest,
            style: context.typography.headingMedium.copyWith(
              color: context.colors.gold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l.aboutFooterMadeWithLove,
            style: context.typography.caption.copyWith(
              color: context.colors.textDim,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('❤️', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 6),
              Text(
                l.aboutFooterCopyright,
                style: context.typography.caption.copyWith(
                  fontSize: 11,
                  color: context.colors.textDim,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
