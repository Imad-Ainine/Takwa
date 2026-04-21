// ═══════════════════════════════════════════════════════════════
//  lib/features/profile/presentation/screens/profile_screen.dart
//  تقوى — Profile Screen
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_leading_button.dart';
import '../../../../core/widgets/custom_pattern_background.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../core/database/daos.dart';
import '../../../../core/supabase/supabase_providers.dart';
import '../../../../core/supabase/supabase_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final statsAsync = ref.watch(monthStatsProvider);
    final streakAsync = ref.watch(currentStreakProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      body: Stack(
        children: [
          // Background Pattern
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
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Profile Header Card
                      _buildProfileHeader(context, profileAsync),
                      const SizedBox(height: 24),

                      // Stats Row
                      _buildStatsGrid(context, statsAsync, streakAsync),
                      const SizedBox(height: 24),

                      // Quick Actions / Menu
                      _buildProfileMenu(context),

                      const SizedBox(height: 40),

                      // Logout Button
                      _buildLogoutButton(context),

                      const SizedBox(height: 32),
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
        'الملف الشخصي',
        style: context.typography.headingMedium.copyWith(
          color: context.colors.gold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    AsyncValue<Map<String, dynamic>?> profileAsync,
  ) {
    return profileAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text(
          'خطأ في تحميل البيانات',
          style: context.typography.bodySmall,
        ),
      ),
      data: (profile) {
        final username = profile?['username'] ?? 'مستخدم تقوى';
        final avatar = profile?['avatar_emoji'] ?? '🌙';

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: context.decorations.goldCard.copyWith(
            color: context.colors.card.withOpacity(0.8),
          ),
          child: Column(
            children: [
              // Avatar with glow
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.colors.goldDim,
                  border: Border.all(
                    color: context.colors.gold.withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: context.colors.gold.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(avatar, style: const TextStyle(fontSize: 48)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                username,
                style: context.typography.headingLarge.copyWith(
                  fontSize: 24,
                  color: context.colors.gold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                profile?['email'] ?? '',
                style: context.typography.caption.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              const TaqwaBadge(label: 'عضو مجتهد'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsGrid(
    BuildContext context,
    AsyncValue<MonthStats> statsAsync,
    AsyncValue<int> streakAsync,
  ) {
    return Row(
      children: [
        Expanded(
          child: statsAsync.when(
            data: (s) => _StatCard(
              label: 'نقاط التقوى',
              value: '${s.totalPoints}',
              icon: '🌟',
              color: context.colors.gold,
            ),
            loading: () => const SizedBox(height: 100),
            error: (_, _) => const SizedBox(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: streakAsync.when(
            data: (s) => _StatCard(
              label: 'أيام متواصلة',
              value: '$s',
              icon: '🔥',
              color: context.colors.success,
            ),
            loading: () => const SizedBox(height: 100),
            error: (_, _) => const SizedBox(),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileMenu(BuildContext context) {
    return Column(
      children: [
        _MenuTile(
          icon: Icons.emoji_events_outlined,
          title: 'الإنجازات',
          onTap: () => Navigator.pushNamed(context, '/achievements'),
        ),
        _MenuTile(
          icon: Icons.history_rounded,
          title: 'سجل المحاسبة',
          onTap: () => Navigator.pushNamed(context, '/checklist'),
        ),
        _MenuTile(
          icon: Icons.settings_outlined,
          title: 'إعدادات الحساب',
          onTap: () => Navigator.pushNamed(context, '/settings'),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return PrimaryButton(
      onTap: () async {
        final proceed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('تسجيل الخروج'),
            content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('خروج'),
              ),
            ],
          ),
        );

        if (proceed == true) {
          await SupabaseService.signOut();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          }
        }
      },
      icon: Icons.logout_rounded,
      label: 'تسجيل الخروج',
      isOutline: true,
      baseColor: Colors.redAccent,
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value, icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: context.decorations.card.copyWith(
        color: context.colors.card.withOpacity(0.9),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            value,
            style: context.typography.taqwaScore.copyWith(
              color: color,
              fontSize: 22,
            ),
          ),
          Text(
            label,
            style: context.typography.caption.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: context.decorations.card.copyWith(
        color: context.colors.card.withOpacity(0.6),
      ),
      child: ListTile(
        onTap: onTap,
        dense: true,
        leading: Icon(icon, color: context.colors.gold, size: 22),
        title: Text(title, style: context.typography.labelLarge),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: context.colors.textDim,
        ),
      ),
    );
  }
}
