// ═══════════════════════════════════════════════════════════════
//  lib/features/achievements/presentation/screens/achievements_screen.dart
//  محاسبة النفس — Achievements Screen (شاشة الإنجازات)
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muhasabah/core/theme/app_theme.dart';
import 'package:muhasabah/features/achievements/domain/models/achievement_definition.dart';
import 'package:muhasabah/features/achievements/presentation/widgets/achievement_card.dart';
import 'package:muhasabah/features/achievements/providers/achievements_providers.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(achievementsProvider);
    final colors = context.colors;
    final typography = context.typography;

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context, ref),

          achievementsAsync.when(
            data: (list) => _buildContent(context, list),
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, s) => SliverFillRemaining(
              child: Center(child: Text('حدث خطأ ما: $e')),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final earnedCount = ref.watch(earnedAchievementsCountProvider);
    final totalCount = AchievementDefinition.all.length;
    final progress = totalCount > 0 ? earnedCount / totalCount : 0.0;

    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      centerTitle: true,
      backgroundColor: colors.teal,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'إنجازاتي',
        style: GoogleFonts.notoNaskhArabic(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [colors.teal, colors.teal.withOpacity(0.8)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Level / Total Earned
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    // Level Icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.gold,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colors.gold.withOpacity(0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.military_tech,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Progress Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'التقدم المحرز',
                                style: typography.bodyMedium.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '$earnedCount / $totalCount',
                                style: typography.labelLarge.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              color: colors.gold,
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<AchievementView> list) {
    const categories = AchievementCategory.values;

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final cat = categories[index];
        final catItems = list
            .where((a) => a.definition.category == cat)
            .toList();
        if (catItems.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      color: context.colors.teal,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getCategoryTitle(cat),
                    style: context.typography.headingMedium.copyWith(fontSize: 18),
                  ),
                ],
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemCount: catItems.length,
              itemBuilder: (context, i) {
                return AchievementCard(
                  achievement: catItems[i],
                  onTap: () => _showAchievementDetails(context, catItems[i]),
                );
              },
            ),
          ],
        );
      }, childCount: categories.length),
    );
  }

  String _getCategoryTitle(AchievementCategory cat) {
    switch (cat) {
      case AchievementCategory.daily:
        return 'إنجازات يومية';
      case AchievementCategory.milestone:
        return 'محطات رئيسية';
      case AchievementCategory.ibadah:
        return 'العبادات والذكر';
      case AchievementCategory.special:
        return 'إنجازات خاصة';
    }
  }

  void _showAchievementDetails(BuildContext context, AchievementView a) {
    final colors = context.colors;
    final def = a.definition;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(def.emoji, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              def.titleAr,
              style: context.typography.headingLarge,
            ),
            const SizedBox(height: 8),
            Text(
              def.descAr,
              textAlign: TextAlign.center,
              style: context.typography.bodyLarge.copyWith(
                color: colors.textDim,
              ),
            ),
            const SizedBox(height: 24),
            if (a.isEarned) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: colors.goldDim,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: colors.gold),
                    const SizedBox(width: 8),
                    Text(
                      'تم التحقيق في ${_formatDate(a.earnedAt)}',
                      style: context.typography.labelMedium.copyWith(
                        color: colors.gold,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Text(
                'استمر لمضاعفة جهودك وتحقيق هذا الإنجاز!',
                style: context.typography.caption.copyWith(color: colors.gold),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.year}/${date.month}/${date.day}';
  }
}
