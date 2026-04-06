import 'dart:math';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:uuid/uuid.dart';
import '../models/daily_challenge.dart';
import '../models/mood_entry.dart';
import 'storage_service.dart';
import 'ai_service.dart';

class ChallengeService {
  static final ChallengeService _instance = ChallengeService._();
  factory ChallengeService() => _instance;
  ChallengeService._();

  static const List<Map<String, String>> _fallbackChallenges = [
    {
      'title': 'Gratitude Moment',
      'description': 'Write down three things you\'re grateful for today.',
      'emoji': '\u{1F64F}',
    },
    {
      'title': 'Mindful Walk',
      'description': 'Take a 10-minute walk and notice 5 things you see.',
      'emoji': '\u{1F6B6}',
    },
    {
      'title': 'Reach Out',
      'description': 'Send a kind message to someone you haven\'t talked to recently.',
      'emoji': '\u{1F4AC}',
    },
    {
      'title': 'Deep Breathing',
      'description': 'Try 5 minutes of box breathing: inhale 4s, hold 4s, exhale 4s, hold 4s.',
      'emoji': '\u{1FAE7}',
    },
    {
      'title': 'Joy Recall',
      'description': 'Close your eyes and relive a happy memory for 2 minutes.',
      'emoji': '\u{1F60A}',
    },
    {
      'title': 'Digital Pause',
      'description': 'Put your phone away for 30 minutes and be fully present.',
      'emoji': '\u{1F4F5}',
    },
    {
      'title': 'Body Check',
      'description': 'Do a 5-minute body scan from head to toe, noticing any tension.',
      'emoji': '\u{1F9D8}',
    },
    {
      'title': 'Creative Expression',
      'description': 'Doodle, hum a tune, or write a few lines of poetry.',
      'emoji': '\u{1F3A8}',
    },
    {
      'title': 'Nature Connection',
      'description': 'Step outside and spend 5 minutes just observing nature.',
      'emoji': '\u{1F33F}',
    },
    {
      'title': 'Self-Compassion',
      'description': 'Write yourself a short, kind letter as if writing to a friend.',
      'emoji': '\u{1F49B}',
    },
  ];

  /// Get today's challenge, generating a new one if needed.
  Future<DailyChallenge> getTodayChallenge() async {
    final storage = await StorageService.getInstance();
    final challenges = await storage.getChallenges();
    final today = DateTime.now();

    // Check if we already have a challenge for today
    final existing = challenges.cast<DailyChallenge?>().firstWhere(
      (c) =>
          c!.date.year == today.year &&
          c.date.month == today.month &&
          c.date.day == today.day,
      orElse: () => null,
    );
    if (existing != null) return existing;

    // Generate a new challenge
    final entries = await storage.getEntries();
    final recentTitles = challenges
        .take(7)
        .map((c) => c.title)
        .toList();

    DailyChallenge challenge;
    try {
      challenge = await _generateAIChallenge(entries, recentTitles);
    } catch (e) {
      debugPrint('ChallengeService: AI generation failed: $e');
      challenge = _generateFallbackChallenge(recentTitles);
    }

    // Store and prune old challenges (keep last 30 days)
    challenges.insert(0, challenge);
    final cutoff = today.subtract(const Duration(days: 30));
    challenges.removeWhere((c) => c.date.isBefore(cutoff));
    await storage.saveChallenges(challenges);

    return challenge;
  }

  Future<DailyChallenge> _generateAIChallenge(
    List<MoodEntry> entries,
    List<String> recentTitles,
  ) async {
    final result = await AiService.generateDailyChallenge(
      recentEntries: entries,
      recentChallengeTitles: recentTitles,
    );

    return DailyChallenge(
      id: const Uuid().v4(),
      title: result['title']!,
      description: result['description']!,
      emoji: result['emoji'] ?? '\u{1F3AF}',
      date: DateTime.now(),
    );
  }

  DailyChallenge _generateFallbackChallenge(List<String> recentTitles) {
    final available = _fallbackChallenges
        .where((c) => !recentTitles.contains(c['title']))
        .toList();
    final pick = available.isNotEmpty
        ? available[Random().nextInt(available.length)]
        : _fallbackChallenges[Random().nextInt(_fallbackChallenges.length)];

    return DailyChallenge(
      id: const Uuid().v4(),
      title: pick['title']!,
      description: pick['description']!,
      emoji: pick['emoji']!,
      date: DateTime.now(),
    );
  }

  /// Mark a challenge as completed.
  Future<void> completeChallenge(String id, {String? reflection}) async {
    final storage = await StorageService.getInstance();
    final challenges = await storage.getChallenges();
    final index = challenges.indexWhere((c) => c.id == id);
    if (index >= 0) {
      challenges[index] = challenges[index].copyWith(
        isCompleted: true,
        reflection: reflection,
        completedAt: DateTime.now(),
      );
      await storage.saveChallenges(challenges);
    }
  }

  /// Get challenge stats for insights.
  Map<String, int> getStats(List<DailyChallenge> challenges) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDate = DateTime(weekStart.year, weekStart.month, weekStart.day);

    final weekCompleted = challenges
        .where((c) =>
            c.isCompleted &&
            c.date.isAfter(weekStartDate.subtract(const Duration(seconds: 1))))
        .length;
    final totalCompleted = challenges.where((c) => c.isCompleted).length;

    return {
      'weekCompleted': weekCompleted,
      'totalCompleted': totalCompleted,
    };
  }
}
