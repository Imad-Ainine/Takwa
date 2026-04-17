// ═══════════════════════════════════════════════════════════════
//  lib/features/achievements/domain/models/achievement_definition.dart
//  تقوى — Achievement Definitions (تعريفات الإنجازات)
// ═══════════════════════════════════════════════════════════════

enum AchievementCategory { daily, milestone, ibadah, special }

class AchievementDefinition {
  final String id;
  final String titleAr;
  final String descAr;
  final String emoji;
  final int pointsReward;
  final AchievementCategory category;

  const AchievementDefinition({
    required this.id,
    required this.titleAr,
    required this.descAr,
    required this.emoji,
    this.pointsReward = 0,
    required this.category,
  });

  static const List<AchievementDefinition> all = [
    // --- Daily Achievements ---
    AchievementDefinition(
      id: 'daily_muhasaba',
      titleAr: 'المحاسب المجتهد',
      descAr: 'أكملت محاسبة النفس لهذا اليوم',
      emoji: '📝',
      pointsReward: 10,
      category: AchievementCategory.daily,
    ),
    AchievementDefinition(
      id: 'morning_adhkar',
      titleAr: 'نور الصباح',
      descAr: 'أكملت أذكار الصباح بالكامل',
      emoji: '🌅',
      pointsReward: 5,
      category: AchievementCategory.daily,
    ),
    AchievementDefinition(
      id: 'evening_adhkar',
      titleAr: 'تحصين المساء',
      descAr: 'أكملت أذكار المساء بالكامل',
      emoji: '🌙',
      pointsReward: 5,
      category: AchievementCategory.daily,
    ),

    // --- Milestones ---
    AchievementDefinition(
      id: 'streak_3',
      titleAr: 'البداية الطيبة',
      descAr: 'حافظت على المحاسبة لثلاثة أيام متواصلة',
      emoji: '🌱',
      pointsReward: 20,
      category: AchievementCategory.milestone,
    ),
    AchievementDefinition(
      id: 'streak_7',
      titleAr: 'الأسبوع المثالي',
      descAr: 'سبعة أيام من الالتزام والمحاسبة',
      emoji: '🌿',
      pointsReward: 50,
      category: AchievementCategory.milestone,
    ),
    AchievementDefinition(
      id: 'streak_30',
      titleAr: 'المجاهد المثابر',
      descAr: 'ثلاثون يوماً من مراقبة النفس والتقوى',
      emoji: '⚔️',
      pointsReward: 200,
      category: AchievementCategory.milestone,
    ),
    AchievementDefinition(
      id: 'points_100',
      titleAr: 'مئة خطوة',
      descAr: 'جمعت أول 100 نقطة تقوى',
      emoji: '🎖️',
      pointsReward: 50,
      category: AchievementCategory.milestone,
    ),
    AchievementDefinition(
      id: 'points_1000',
      titleAr: 'فارس التقوى',
      descAr: 'بلغت 1000 نقطة في مسيرتك',
      emoji: '🏆',
      pointsReward: 500,
      category: AchievementCategory.milestone,
    ),

    // --- Ibadah ---
    AchievementDefinition(
      id: 'quran_juz',
      titleAr: 'أهل القرآن',
      descAr: 'ختمت جزءاً كاملاً من كتاب الله',
      emoji: '📖',
      pointsReward: 100,
      category: AchievementCategory.ibadah,
    ),
    AchievementDefinition(
      id: 'fajr_on_time',
      titleAr: 'في ذمة الله',
      descAr: 'صليت الفجر في وقته لثلاثة أيام متتالية',
      emoji: '🕌',
      pointsReward: 30,
      category: AchievementCategory.ibadah,
    ),
    AchievementDefinition(
      id: 'fasting_nafl',
      titleAr: 'باب الريان',
      descAr: 'أكملت صيام النفل الأول لك',
      emoji: '🌙',
      pointsReward: 40,
      category: AchievementCategory.ibadah,
    ),
    AchievementDefinition(
      id: 'tasbeeh_100',
      titleAr: 'الذاكر الشاكر',
      descAr: 'سبحت الله 100 مرة في يوم واحد',
      emoji: '📿',
      pointsReward: 20,
      category: AchievementCategory.ibadah,
    ),

    // --- Special ---
    AchievementDefinition(
      id: 'first_sadaqah',
      titleAr: 'اليد المعطية',
      descAr: 'أخرجت أول صدقة لك عبر التطبيق',
      emoji: '💰',
      pointsReward: 30,
      category: AchievementCategory.special,
    ),
    AchievementDefinition(
      id: 'ramadan_knight',
      titleAr: 'فارس رمضان',
      descAr: 'أكملت 10 أيام من رمضان في المحاسبة',
      emoji: '✨',
      pointsReward: 100,
      category: AchievementCategory.special,
    ),
  ];
}
