// ═══════════════════════════════════════════════════════════════
//  lib/features/achievements/providers/achievements_providers.dart
//  محاسبة النفس — Achievements Providers (مزودو بيانات الإنجازات)
// ═══════════════════════════════════════════════════════════════

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muhasabah/core/providers/database_providers.dart';
import 'package:muhasabah/features/achievements/domain/models/achievement_definition.dart';

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
  await statsDao.checkAndGrantAchievements();

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
