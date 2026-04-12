// ═══════════════════════════════════════════════════════════════
//  lib/features/achievements/presentation/widgets/achievement_card.dart
//  محاسبة النفس — Achievement Card (بطاقة الإنجاز)
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:muhasabah/core/theme/app_theme.dart';
import 'package:muhasabah/features/achievements/providers/achievements_providers.dart';
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
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isEarned ? colors.card : colors.card.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isEarned
                ? colors.gold.withOpacity(0.4)
                : colors.border.withOpacity(0.5),
            width: isEarned ? 1.5 : 1,
          ),
          boxShadow: isEarned
              ? [
                  BoxShadow(
                    color: colors.gold.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Emoji / Badge Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isEarned
                    ? colors.goldDim
                    : colors.border.withOpacity(0.2),
                shape: BoxShape.circle,
                border: isEarned
                    ? Border.all(color: colors.gold.withOpacity(0.2))
                    : null,
              ),
              child: Opacity(
                opacity: isEarned ? 1.0 : 0.3,
                child: Text(def.emoji, style: const TextStyle(fontSize: 32)),
              ),
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              def.titleAr,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: typography.labelLarge.copyWith(
                color: isEarned ? colors.textPrimary : colors.textDim,
                fontWeight: isEarned ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 4),

            // Points Reward (only if earned or descriptive)
            if (isEarned) ...[
              Text(
                '+${def.pointsReward} نقطة',
                style: typography.caption.copyWith(
                  color: colors.gold,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                intl.DateFormat('yyyy/MM/dd').format(achievement.earnedAt!),
                style: typography.caption.copyWith(
                  fontSize: 9,
                  color: colors.textDim.withOpacity(0.6),
                ),
              ),
            ] else ...[
              Text(
                'مغلق',
                style: typography.caption.copyWith(
                  color: colors.textDim.withOpacity(0.5),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
