// ═══════════════════════════════════════════════════════════════
//  lib/features/achievements/presentation/widgets/achievement_card.dart
//  محاسبة النفس — Achievement Card (بطاقة الإنجاز)
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:takwa/core/theme/app_theme.dart';
import 'package:takwa/features/achievements/providers/achievements_providers.dart';
import 'package:intl/intl.dart' as intl;

class AchievementCard extends StatelessWidget {
  final AchievementView achievement;
  final VoidCallback onTap;

  const AchievementCard({
    super.key,
    required this.achievement,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isEarned = achievement.isEarned;
    final def = achievement.definition;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isEarned ? colors.card : colors.card.withOpacity(0.5),
          gradient: isEarned ? colors.cardGradient : null,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isEarned
                ? colors.gold.withOpacity(0.4)
                : colors.border.withOpacity(0.6),
            width: isEarned ? 1.5 : 1,
          ),
          boxShadow: isEarned ? context.shadows.card : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Emoji / Badge Icon
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isEarned
                    ? colors.gold.withOpacity(0.12)
                    : colors.border.withOpacity(0.2),
                shape: BoxShape.circle,
                boxShadow: isEarned ? context.shadows.goldGlow : null,
                border: isEarned
                    ? Border.all(color: colors.gold.withOpacity(0.2))
                    : null,
              ),
              child: Opacity(
                opacity: isEarned ? 1.0 : 0.4,
                child: Text(
                  def.emoji,
                  style: const TextStyle(fontSize: 34),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Title
            Text(
              def.titleAr,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: typography.labelLarge.copyWith(
                color: isEarned ? colors.gold : colors.textDim,
                fontWeight: isEarned ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 6),

            // Points Reward (only if earned or descriptive)
            if (isEarned) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.gold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '+${def.pointsReward} نقطة',
                  style: typography.caption.copyWith(
                    color: colors.gold,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                intl.DateFormat('yyyy/MM/dd').format(achievement.earnedAt!),
                style: typography.caption.copyWith(
                  fontSize: 10,
                  color: colors.textSecondary.withOpacity(0.7),
                ),
              ),
            ] else ...[
              Text(
                'قيد الانتظار',
                style: typography.caption.copyWith(
                  color: colors.textDim.withOpacity(0.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
