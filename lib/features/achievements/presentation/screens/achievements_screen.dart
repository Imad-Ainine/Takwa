// ═══════════════════════════════════════════════════════════════
//  lib/features/achievements/presentation/screens/achievements_screen.dart
//  — Achievements Screen (شاشة الإنجازات)
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takwa/core/theme/app_theme.dart';
import 'package:takwa/features/achievements/domain/models/achievement_definition.dart';
import 'package:takwa/features/achievements/presentation/widgets/achievement_card.dart';
import 'package:takwa/features/achievements/providers/achievements_providers.dart';
import 'package:takwa/core/widgets/custom_pattern_background.dart';
import 'package:takwa/core/widgets/primary_button.dart';

class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key});

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entryCtrl;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;
  static const _sectionCount = 5; // Header + 4 categories

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnims = List.generate(_sectionCount, (i) {
      final s = i * 0.12, e = (s + 0.40).clamp(0.0, 1.0);
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _entryCtrl,
          curve: Interval(s, e, curve: Curves.easeOut),
        ),
      );
    });

    _slideAnims = List.generate(_sectionCount, (i) {
      final s = i * 0.12, e = (s + 0.40).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.08),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _entryCtrl,
          curve: Interval(s, e, curve: Curves.easeOutCubic),
        ),
      );
    });

    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  Widget _anim(int i, Widget child) => FadeTransition(
    opacity: _fadeAnims[i.clamp(0, _sectionCount - 1)],
    child: SlideTransition(
      position: _slideAnims[i.clamp(0, _sectionCount - 1)],
      child: child,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final achievementsAsync = ref.watch(achievementsProvider);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
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
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final colors = context.colors;
    final earnedCount = ref.watch(earnedAchievementsCountProvider);
    final totalCount = AchievementDefinition.all.length;
    final progress = totalCount > 0 ? earnedCount / totalCount : 0.0;

    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors.card.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.arrow_back_ios_new, color: colors.gold, size: 18),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'إنجازاتي',
        style: context.typography.headingLarge.copyWith(
          color: colors.gold,
          fontWeight: FontWeight.w700,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colors.gold.withOpacity(0.15),
                colors.background.withOpacity(0),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _anim(
                0,
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: colors.cardGradient,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: colors.gold.withOpacity(0.2)),
                    boxShadow: context.shadows.card,
                  ),
                  child: Row(
                    children: [
                      // Level Icon
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: colors.goldGradient,
                          shape: BoxShape.circle,
                          boxShadow: context.shadows.goldGlow,
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
                                  style: context.typography.labelLarge.copyWith(
                                    color: colors.gold,
                                  ),
                                ),
                                Text(
                                  '$earnedCount / $totalCount',
                                  style: context.typography.labelLarge.copyWith(
                                    color: colors.gold,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Stack(
                                children: [
                                  Container(height: 8, color: colors.border),
                                  FractionallySizedBox(
                                    widthFactor: progress,
                                    child: Container(
                                      height: 8,
                                      decoration: BoxDecoration(
                                        gradient: colors.goldGradient,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
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
              ),
              const SizedBox(height: 10),
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

        return _anim(
          index + 1,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        gradient: context.colors.goldGradient,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _getCategoryTitle(cat),
                      style: context.typography.headingMedium.copyWith(
                        fontSize: 18,
                        color: context.colors.gold,
                      ),
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
          ),
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
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(
            top: BorderSide(color: colors.gold.withOpacity(0.3), width: 1.5),
          ),
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
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colors.goldDim,
                shape: BoxShape.circle,
                boxShadow: context.shadows.goldGlow,
              ),
              child: Text(def.emoji, style: const TextStyle(fontSize: 64)),
            ),
            const SizedBox(height: 24),
            Text(
              def.titleAr,
              textAlign: TextAlign.center,
              style: context.typography.headingLarge.copyWith(
                color: colors.gold,
                fontSize: 26,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              def.descAr,
              textAlign: TextAlign.center,
              style: context.typography.bodyLarge.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            if (a.isEarned) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: colors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colors.success.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_rounded, color: colors.success),
                    const SizedBox(width: 10),
                    Text(
                      'تم التحقيق في ${_formatDate(a.earnedAt)}',
                      style: context.typography.labelMedium.copyWith(
                        color: colors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: colors.gold.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colors.gold.withOpacity(0.2)),
                ),
                child: Text(
                  'استمر لمضاعفة جهودك وتحقيق هذا الإنجاز! ✨',
                  textAlign: TextAlign.center,
                  style: context.typography.labelMedium.copyWith(
                    color: colors.gold,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'فهمت',
              onTap: () async => Navigator.pop(context),
            ),
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
