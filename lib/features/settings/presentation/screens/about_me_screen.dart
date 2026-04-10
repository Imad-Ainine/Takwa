// ═══════════════════════════════════════════════════════════════
//  lib/features/settings/presentation/screens/about_me_screen.dart
//  محاسبة النفس — About Me (عن المبرمج)
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muhasabah/core/theme/app_theme.dart';
import 'package:muhasabah/core/widgets/geometric_background.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutMeScreen extends StatelessWidget {
  const AboutMeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.night,
      body: Stack(
        children: [
          const GeometricBackground(
            opacity: 0.1,
            strokeWidth: 0.8,
            spacing: 32,
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
                      _buildProfileHeader(),
                      const SizedBox(height: 24),
                      _buildSectionTitle('عن المطور', 'About Developer'),
                      const SizedBox(height: 12),
                      _buildBioCard(),
                      const SizedBox(height: 24),
                      _buildSectionTitle(
                        'المهارات التقنية',
                        'Technical Skills',
                      ),
                      const SizedBox(height: 12),
                      _buildSkillsGrid(),
                      const SizedBox(height: 24),
                      _buildSectionTitle('تواصل معي', 'Connect With Me'),
                      const SizedBox(height: 12),
                      _buildSocialLinks(),
                      const SizedBox(height: 40),
                      _buildFooter(),
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
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.gold,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'عن المطور',
        style: AppTypography.headingMedium.copyWith(color: AppColors.gold),
      ),
      centerTitle: true,
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: AppDecorations.goldCard.copyWith(
        color: AppColors.card.withOpacity(0.85),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gold, width: 3),
              boxShadow: AppShadows.goldGlow,
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
              color: AppColors.textPrimary,
            ),
          ),
          // English Name
          Text(
            'Imadeddine Ainine',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: AppColors.goldLight,
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

  Widget _buildSectionTitle(String arabic, String english) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          arabic,
          style: AppTypography.headingMedium.copyWith(color: AppColors.teal),
        ),
        Text(
          english,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textDim,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBioCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.card.copyWith(
        color: AppColors.card.withOpacity(0.85),
      ),
      child: Text(
        'مطور برمجيات شغوف ببناء تطبيقات الهاتف والمواقع الإلكترونية بأحدث التقنيات. أهتم بجودة الكود وتجربة المستخدم، وأسعى دوماً لتقديم حلول تقنية مبتكرة تخدم المجتمع المسلم.',
        style: AppTypography.bodyMedium.copyWith(height: 1.8),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildSkillsGrid() {
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
                color: AppColors.card2,
                borderRadius: AppRadius.chip,
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                skill,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildSocialLinks() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialIcon(
              Icons.code_rounded,
              'GitHub',
              url: 'https://github.com/Imad-Ainine',
            ),
            const SizedBox(width: 16),
            _buildSocialIcon(
              Icons.business_center_rounded,
              'LinkedIn',
              url: 'https://www.linkedin.com/in/imadeddine-ainine',
            ),
            const SizedBox(width: 16),
            _buildSocialIcon(
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
              Icons.mail_outline_rounded,
              'Email',
              url: 'mailto:imad.ainine11@gmail.com',
            ),
            const SizedBox(width: 16),
            _buildSocialIcon(
              Icons.phone_android_rounded,
              'Phone',
              url: 'tel:+213773843669',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon, String tooltip, {String? url}) {
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
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, color: AppColors.gold, size: 24),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: [
          Container(height: 1, width: 80, color: AppColors.border),
          const SizedBox(height: 20),
          Text(
            'ادعوا لي من خالص دعائكم',
            style: AppTypography.headingMedium.copyWith(color: AppColors.gold),
          ),
          const SizedBox(height: 12),
          Text(
            'صنع بكل حب للأمة الإسلامية',
            style: AppTypography.caption.copyWith(color: AppColors.textDim),
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
                  color: AppColors.textDim,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
