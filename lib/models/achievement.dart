enum AchievementCategory { entries, streak, features, mood }

enum AchievementTier { bronze, silver, gold }

class AchievementDefinition {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final AchievementCategory category;
  final AchievementTier tier;

  const AchievementDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.category,
    required this.tier,
  });
}

class EarnedAchievement {
  final String achievementId;
  final DateTime earnedAt;
  final bool seen;

  EarnedAchievement({
    required this.achievementId,
    required this.earnedAt,
    this.seen = false,
  });

  Map<String, dynamic> toJson() => {
        'achievementId': achievementId,
        'earnedAt': earnedAt.toIso8601String(),
        'seen': seen,
      };

  factory EarnedAchievement.fromJson(Map<String, dynamic> json) =>
      EarnedAchievement(
        achievementId: json['achievementId'] as String,
        earnedAt: DateTime.parse(json['earnedAt'] as String),
        seen: json['seen'] as bool? ?? false,
      );

  EarnedAchievement copyWith({bool? seen}) => EarnedAchievement(
        achievementId: achievementId,
        earnedAt: earnedAt,
        seen: seen ?? this.seen,
      );
}

const List<AchievementDefinition> allAchievements = [
  // Entries
  AchievementDefinition(
    id: 'first_checkin',
    title: 'First Step',
    description: 'Complete your first check-in',
    emoji: '\u2728',
    category: AchievementCategory.entries,
    tier: AchievementTier.bronze,
  ),
  AchievementDefinition(
    id: 'entries_10',
    title: 'Getting Started',
    description: 'Log 10 mood entries',
    emoji: '\u{1F4DD}',
    category: AchievementCategory.entries,
    tier: AchievementTier.bronze,
  ),
  AchievementDefinition(
    id: 'entries_30',
    title: 'Consistent Soul',
    description: 'Log 30 mood entries',
    emoji: '\u{1F4D6}',
    category: AchievementCategory.entries,
    tier: AchievementTier.silver,
  ),
  AchievementDefinition(
    id: 'entries_100',
    title: 'Centurion',
    description: 'Log 100 mood entries',
    emoji: '\u{1F3DB}',
    category: AchievementCategory.entries,
    tier: AchievementTier.gold,
  ),
  AchievementDefinition(
    id: 'journal_writer',
    title: 'Wordsmith',
    description: 'Write a journal entry with 500+ characters',
    emoji: '\u270D\uFE0F',
    category: AchievementCategory.entries,
    tier: AchievementTier.bronze,
  ),

  // Streaks
  AchievementDefinition(
    id: 'streak_3',
    title: 'Budding Habit',
    description: 'Reach a 3-day streak',
    emoji: '\u{1F331}',
    category: AchievementCategory.streak,
    tier: AchievementTier.bronze,
  ),
  AchievementDefinition(
    id: 'streak_7',
    title: 'Week Warrior',
    description: 'Reach a 7-day streak',
    emoji: '\u{1F525}',
    category: AchievementCategory.streak,
    tier: AchievementTier.bronze,
  ),
  AchievementDefinition(
    id: 'streak_14',
    title: 'Fortnight Force',
    description: 'Reach a 14-day streak',
    emoji: '\u26A1',
    category: AchievementCategory.streak,
    tier: AchievementTier.silver,
  ),
  AchievementDefinition(
    id: 'streak_30',
    title: 'Monthly Master',
    description: 'Reach a 30-day streak',
    emoji: '\u{1F451}',
    category: AchievementCategory.streak,
    tier: AchievementTier.gold,
  ),

  // Features
  AchievementDefinition(
    id: 'first_capsule',
    title: 'Time Traveler',
    description: 'Create your first time capsule',
    emoji: '\u{1F48C}',
    category: AchievementCategory.features,
    tier: AchievementTier.bronze,
  ),
  AchievementDefinition(
    id: 'capsule_opened',
    title: 'Letter from the Past',
    description: 'Open a time capsule',
    emoji: '\u{1F4EC}',
    category: AchievementCategory.features,
    tier: AchievementTier.silver,
  ),
  AchievementDefinition(
    id: 'first_breathwork',
    title: 'Deep Breather',
    description: 'Complete a breathwork session',
    emoji: '\u{1FAE7}',
    category: AchievementCategory.features,
    tier: AchievementTier.bronze,
  ),
  AchievementDefinition(
    id: 'first_conversation',
    title: 'Heart to Heart',
    description: 'Start an AI conversation',
    emoji: '\u{1F4AC}',
    category: AchievementCategory.features,
    tier: AchievementTier.bronze,
  ),
  AchievementDefinition(
    id: 'first_digest',
    title: 'Weekly Reflection',
    description: 'View your first weekly digest',
    emoji: '\u{1F4CA}',
    category: AchievementCategory.features,
    tier: AchievementTier.bronze,
  ),

  // Mood
  AchievementDefinition(
    id: 'mood_variety',
    title: 'Full Spectrum',
    description: 'Use all 6 mood levels',
    emoji: '\u{1F308}',
    category: AchievementCategory.mood,
    tier: AchievementTier.silver,
  ),
  AchievementDefinition(
    id: 'tag_explorer',
    title: 'Context Master',
    description: 'Use tags from all 3 categories in one entry',
    emoji: '\u{1F3F7}\uFE0F',
    category: AchievementCategory.mood,
    tier: AchievementTier.bronze,
  ),
];
