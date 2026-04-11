// ═══════════════════════════════════════════════════════════════
//  lib/features/settings/presentation/screens/about_me_screen.dart
//  محاسبة النفس — About Me (عن المبرمج)
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muhasabah/core/theme/app_theme.dart';
import 'package:muhasabah/core/widgets/custom_pattern_background.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutMeScreen extends StatelessWidget {
  const AboutMeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Stack(
        children: [
          const CustomPatternBackground(pattern: BackgroundPattern.geometric),
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
                      _buildSectionTitle(context, 'عن المطور', 'About Developer'),
                      const SizedBox(height: 12),
                      _buildBioCard(context),
                      const SizedBox(height: 24),
                      _buildSectionTitle(
                        context,
                        'المهارات التقنية',
                        'Technical Skills',
                      ),
                      const SizedBox(height: 12),
                      _buildSkillsGrid(context),
                      const SizedBox(height: 24),
                      _buildSectionTitle(context, 'تواصل معي', 'Connect With Me'),
                      const SizedBox(height: 12),
                      _buildSocialLinks(context),
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
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: context.colors.gold,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'عن المطور',
        style: context.typography.headingMedium.copyWith(color: context.colors.gold),
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
            'عماد الدين عينين',
            style: GoogleFonts.amiri(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            color: context.colors.textPrimary,
            ),
          ),
          // English Name
          Text(
            'Imadeddine Ainine',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: context.colors.goldLight,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          // Badge
          const TaqwaBadge(label: 'Fullstack Developer'),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String arabic, String english) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          arabic,
          style: context.typography.headingMedium.copyWith(color: context.colors.teal),
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

  Widget _buildBioCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: context.decorations.card.copyWith(
        color: context.colors.card.withOpacity(0.85),
      ),
      child: Text(
        'مطور برمجيات شغوف ببناء تطبيقات الهاتف والمواقع الإلكترونية بأحدث التقنيات. أهتم بجودة الكود وتجربة المستخدم، وأسعى دوماً لتقديم حلول تقنية مبتكرة تخدم المجتمع المسلم.',
        style: context.typography.bodyMedium.copyWith(height: 1.8),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildSkillsGrid(BuildContext context) {
    final skills = [
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

  Widget _buildSocialIcon(BuildContext context, IconData icon, String tooltip, {String? url}) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: () async {
          HapticFeedback.lightImpact();
          if (url != null) {
            final uri = Uri.parse(url);
            try {
              // Try launching directly as canLaunchUrl can be unreliable on some devices/versions
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

  Widget _buildFooter(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(height: 1, width: 80, color: context.colors.border),
          const SizedBox(height: 20),
          Text(
            'ادعوا لي من خالص دعائكم',
            style: context.typography.headingMedium.copyWith(color: context.colors.gold),
          ),
          const SizedBox(height: 12),
          Text(
            'صنع بكل حب للأمة الإسلامية',
            style: context.typography.caption.copyWith(color: context.colors.textDim),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('❤️', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 6),
              Text(
                '© 2026 - Imadeddine Ainine',
                style: GoogleFonts.poppins(
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
