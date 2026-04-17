// ═══════════════════════════════════════════════════════════════
//  lib/features/achievements/providers/achievements_providers.dart
// تقوى — Achievements Providers (مزودو بيانات الإنجازات)
// ═══════════════════════════════════════════════════════════════

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takwa/core/supabase/supabase_service.dart';
import 'package:takwa/core/providers/database_providers.dart';
import 'package:takwa/features/achievements/domain/models/achievement_definition.dart';

class AchievementView {
  final AchievementDefinition definition;
  final bool isEarned;
  final DateTime? earnedAt;

  const AchievementView({
    required this.definition,
    required this.isEarned,
    this.earnedAt,
  });
}

final achievementsProvider = FutureProvider<List<AchievementView>>((ref) async {
  final statsDao = ref.watch(statsDaoProvider);
  final db = ref.watch(appDatabaseProvider);

  // 1. Check and grant new achievements automatically
  final newEarned = await statsDao.checkAndGrantAchievements();
  for (final ach in newEarned) {
    // Note: In providers, we can't pass 'ref' directly to SyncManager if it expects WidgetRef
    // But SyncManager uses ConnectivityProvider which can be read from ProviderRef
    // I will use a custom sync method for providers if needed, or check if ref works.
    // SyncManager.syncAchievement(ref, ach) expects WidgetRef.
    // Let's assume SyncManager can handle ProviderRef or we change its type.
    await SupabaseService.upsertAchievement({
      'type': ach.type,
      'title_ar': ach.titleAr,
      'desc_ar': ach.descAr,
      'emoji': ach.emoji,
      'points_reward': ach.pointsReward,
      'earned_at': ach.earnedAt.toIso8601String(),
    });
  }

  // 2. Fetch earned achievements from DB
  final earnedList = await (db.select(db.achievements)).get();
  final earnedMap = {for (var a in earnedList) a.type: a};

  // 3. Map all definitions to AchievementView
  return AchievementDefinition.all.map((def) {
    final earned = earnedMap[def.id];
    return AchievementView(
      definition: def,
      isEarned: earned != null,
      earnedAt: earned?.earnedAt,
    );
  }).toList();
});

/// إجمالي عدد الإنجازات المحققة
final earnedAchievementsCountProvider = Provider<int>((ref) {
  final all = ref.watch(achievementsProvider).value ?? [];
  return all.where((a) => a.isEarned).length;
});
