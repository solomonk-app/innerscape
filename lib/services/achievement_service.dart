import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement.dart';
import '../models/mood_entry.dart';
import '../models/time_capsule.dart';
import '../models/tag_definitions.dart';
import 'storage_service.dart';

class AchievementService {
  static final AchievementService _instance = AchievementService._();
  factory AchievementService() => _instance;
  AchievementService._();

  /// Evaluate all achievements and return newly earned ones.
  Future<List<AchievementDefinition>> evaluateAndAward({
    required List<MoodEntry> entries,
    required int streak,
    required List<TimeCapsule> capsules,
  }) async {
    final storage = await StorageService.getInstance();
    final earned = await storage.getAchievements();
    final earnedIds = earned.map((e) => e.achievementId).toSet();

    final prefs = await SharedPreferences.getInstance();
    final breathworkDone = prefs.getBool('breathwork_completed') ?? false;
    final conversationDone = prefs.getBool('conversation_started') ?? false;
    final digestDone = prefs.getBool('digest_viewed') ?? false;

    final newlyEarned = <AchievementDefinition>[];

    for (final def in allAchievements) {
      if (earnedIds.contains(def.id)) continue;
      if (_checkCondition(def.id, entries, streak, capsules,
          breathworkDone, conversationDone, digestDone)) {
        newlyEarned.add(def);
        earned.add(EarnedAchievement(
          achievementId: def.id,
          earnedAt: DateTime.now(),
        ));
      }
    }

    if (newlyEarned.isNotEmpty) {
      await storage.saveAchievements(earned);
    }

    return newlyEarned;
  }

  bool _checkCondition(
    String id,
    List<MoodEntry> entries,
    int streak,
    List<TimeCapsule> capsules,
    bool breathworkDone,
    bool conversationDone,
    bool digestDone,
  ) {
    switch (id) {
      // Entries
      case 'first_checkin':
        return entries.isNotEmpty;
      case 'entries_10':
        return entries.length >= 10;
      case 'entries_30':
        return entries.length >= 30;
      case 'entries_100':
        return entries.length >= 100;
      case 'journal_writer':
        return entries.any((e) => e.text.length >= 500);

      // Streaks
      case 'streak_3':
        return streak >= 3;
      case 'streak_7':
        return streak >= 7;
      case 'streak_14':
        return streak >= 14;
      case 'streak_30':
        return streak >= 30;

      // Features
      case 'first_capsule':
        return capsules.isNotEmpty;
      case 'capsule_opened':
        return capsules.any((c) => c.isOpened);
      case 'first_breathwork':
        return breathworkDone;
      case 'first_conversation':
        return conversationDone;
      case 'first_digest':
        return digestDone;

      // Mood
      case 'mood_variety':
        final moods = entries.map((e) => e.mood).toSet();
        return moods.length >= 6;
      case 'tag_explorer':
        final categoryNames =
            tagCategories.map((c) => c.name).toSet();
        return entries.any((entry) {
          final usedCategories = <String>{};
          for (final tag in entry.tags) {
            for (final cat in tagCategories) {
              if (cat.tags.contains(tag)) {
                usedCategories.add(cat.name);
              }
            }
          }
          return usedCategories.length >= categoryNames.length;
        });

      default:
        return false;
    }
  }

  /// Get all earned achievements.
  Future<List<EarnedAchievement>> getEarned() async {
    final storage = await StorageService.getInstance();
    return storage.getAchievements();
  }

  /// Mark all unseen achievements as seen.
  Future<void> markAllSeen() async {
    final storage = await StorageService.getInstance();
    final earned = await storage.getAchievements();
    bool changed = false;
    for (int i = 0; i < earned.length; i++) {
      if (!earned[i].seen) {
        earned[i] = earned[i].copyWith(seen: true);
        changed = true;
      }
    }
    if (changed) {
      await storage.saveAchievements(earned);
    }
  }

  /// Get progress fraction (0.0-1.0) for a specific achievement.
  double getProgress(
    String id,
    List<MoodEntry> entries,
    int streak,
    List<TimeCapsule> capsules,
  ) {
    switch (id) {
      case 'first_checkin':
        return entries.isNotEmpty ? 1.0 : 0.0;
      case 'entries_10':
        return (entries.length / 10).clamp(0.0, 1.0);
      case 'entries_30':
        return (entries.length / 30).clamp(0.0, 1.0);
      case 'entries_100':
        return (entries.length / 100).clamp(0.0, 1.0);
      case 'streak_3':
        return (streak / 3).clamp(0.0, 1.0);
      case 'streak_7':
        return (streak / 7).clamp(0.0, 1.0);
      case 'streak_14':
        return (streak / 14).clamp(0.0, 1.0);
      case 'streak_30':
        return (streak / 30).clamp(0.0, 1.0);
      case 'mood_variety':
        return (entries.map((e) => e.mood).toSet().length / 6).clamp(0.0, 1.0);
      default:
        return 0.0;
    }
  }
}
