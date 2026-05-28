import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mood_entry.dart';
import '../models/time_capsule.dart';
import '../models/weekly_digest.dart';
import '../models/achievement.dart';
import '../models/daily_challenge.dart';
import '../models/journal_plan.dart';
import '../models/eisenhower_entry.dart';
import '../models/prompt_completion.dart';

class StorageService {
  static const String _entriesKey = 'mood_entries';
  static const String _capsulesKey = 'time_capsules';
  static const String _digestsKey = 'weekly_digests';
  static const String _onboardingKey = 'has_seen_onboarding';
  static const String _achievementsKey = 'earned_achievements';
  static const String _challengesKey = 'daily_challenges';
  static const String _insightFeedbackKey = 'insight_feedback';
  static const String _planProgressKey = 'journal_plan_progress';
  static const String _eisenhowerKey = 'eisenhower_entries';
  static const String _promptCompletionsKey = 'prompt_completions';
  static StorageService? _instance;
  static Future<StorageService>? _initFuture;
  late SharedPreferences _prefs;

  StorageService._();

  static Future<StorageService> getInstance() {
    _initFuture ??= _create();
    return _initFuture!;
  }

  static Future<StorageService> _create() async {
    final instance = StorageService._();
    instance._prefs = await SharedPreferences.getInstance();
    _instance = instance;
    return instance;
  }

  // ─── Mood Entries ───

  Future<List<MoodEntry>> getEntries() async {
    final String? data = _prefs.getString(_entriesKey);
    if (data == null) return [];
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((e) => MoodEntry.fromJson(e)).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  Future<void> saveEntry(MoodEntry entry) async {
    final entries = await getEntries();
    entries.add(entry);
    final jsonList = entries.map((e) => e.toJson()).toList();
    await _prefs.setString(_entriesKey, jsonEncode(jsonList));
  }

  Future<void> updateEntry(MoodEntry entry) async {
    final entries = await getEntries();
    final index = entries.indexWhere((e) => e.id == entry.id);
    if (index >= 0) {
      entries[index] = entry;
      final jsonList = entries.map((e) => e.toJson()).toList();
      await _prefs.setString(_entriesKey, jsonEncode(jsonList));
    }
  }

  Future<void> clearAll() async {
    await _prefs.remove(_entriesKey);
    await _prefs.remove(_capsulesKey);
    await _prefs.remove(_digestsKey);
    await _prefs.remove(_achievementsKey);
    await _prefs.remove(_challengesKey);
    await _prefs.remove('breathwork_completed');
    await _prefs.remove('conversation_started');
    await _prefs.remove('digest_viewed');
    await _prefs.remove(_insightFeedbackKey);
    await _prefs.remove(_planProgressKey);
    await _prefs.remove(_eisenhowerKey);
    await _prefs.remove(_promptCompletionsKey);
  }

  int calculateStreak(List<MoodEntry> entries) {
    if (entries.isEmpty) return 0;
    int count = 0;
    final today = DateTime.now();
    for (int i = 0; i <= 30; i++) {
      final checkDate = DateTime(today.year, today.month, today.day - i);
      final hasEntry = entries.any((e) =>
          e.timestamp.year == checkDate.year &&
          e.timestamp.month == checkDate.month &&
          e.timestamp.day == checkDate.day);
      if (hasEntry) {
        count++;
      } else if (i > 0) {
        break;
      }
    }
    return count;
  }

  // ─── Time Capsules ───

  Future<List<TimeCapsule>> getCapsules() async {
    final String? data = _prefs.getString(_capsulesKey);
    if (data == null) return [];
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((e) => TimeCapsule.fromJson(e)).toList()
      ..sort((a, b) => a.unlocksAt.compareTo(b.unlocksAt));
  }

  Future<void> saveCapsule(TimeCapsule capsule) async {
    final capsules = await getCapsules();
    capsules.add(capsule);
    await _saveCapsules(capsules);
  }

  Future<void> updateCapsule(TimeCapsule capsule) async {
    final capsules = await getCapsules();
    final index = capsules.indexWhere((c) => c.id == capsule.id);
    if (index >= 0) {
      capsules[index] = capsule;
      await _saveCapsules(capsules);
    }
  }

  Future<void> _saveCapsules(List<TimeCapsule> capsules) async {
    final jsonList = capsules.map((c) => c.toJson()).toList();
    await _prefs.setString(_capsulesKey, jsonEncode(jsonList));
  }

  // ─── Weekly Digests ───

  Future<List<WeeklyDigest>> getDigests() async {
    final String? data = _prefs.getString(_digestsKey);
    if (data == null) return [];
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((e) => WeeklyDigest.fromJson(e)).toList()
      ..sort((a, b) => b.weekStart.compareTo(a.weekStart)); // newest first
  }

  Future<void> saveDigest(WeeklyDigest digest) async {
    final digests = await getDigests();
    digests.add(digest);
    final jsonList = digests.map((d) => d.toJson()).toList();
    await _prefs.setString(_digestsKey, jsonEncode(jsonList));
  }

  // ─── Onboarding ───

  bool get hasSeenOnboarding => _prefs.getBool(_onboardingKey) ?? false;

  Future<void> setOnboardingSeen() async {
    await _prefs.setBool(_onboardingKey, true);
  }

  Future<bool> hasDigestForWeek(DateTime weekStart) async {
    final digests = await getDigests();
    return digests.any((d) =>
        d.weekStart.year == weekStart.year &&
        d.weekStart.month == weekStart.month &&
        d.weekStart.day == weekStart.day);
  }

  // ─── Achievements ───

  Future<List<EarnedAchievement>> getAchievements() async {
    final String? data = _prefs.getString(_achievementsKey);
    if (data == null) return [];
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((e) => EarnedAchievement.fromJson(e)).toList();
  }

  Future<void> saveAchievements(List<EarnedAchievement> achievements) async {
    final jsonList = achievements.map((a) => a.toJson()).toList();
    await _prefs.setString(_achievementsKey, jsonEncode(jsonList));
  }

  // ─── Insight Feedback ───

  Future<void> saveInsightFeedback(String entryId, bool isPositive) async {
    final data = _prefs.getString(_insightFeedbackKey);
    final Map<String, dynamic> map =
        data != null ? Map<String, dynamic>.from(jsonDecode(data)) : {};
    map[entryId] = isPositive;
    await _prefs.setString(_insightFeedbackKey, jsonEncode(map));
  }

  Future<bool?> getInsightFeedback(String entryId) async {
    final data = _prefs.getString(_insightFeedbackKey);
    if (data == null) return null;
    final Map<String, dynamic> map = Map<String, dynamic>.from(jsonDecode(data));
    return map[entryId] as bool?;
  }

  // ─── Daily Challenges ───

  Future<List<DailyChallenge>> getChallenges() async {
    final String? data = _prefs.getString(_challengesKey);
    if (data == null) return [];
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((e) => DailyChallenge.fromJson(e)).toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // newest first
  }

  Future<void> saveChallenges(List<DailyChallenge> challenges) async {
    final jsonList = challenges.map((c) => c.toJson()).toList();
    await _prefs.setString(_challengesKey, jsonEncode(jsonList));
  }

  // ─── Journal Plan Progress ───

  Future<List<JournalPlanProgress>> getPlanProgress() async {
    final String? data = _prefs.getString(_planProgressKey);
    if (data == null) return [];
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList
        .map((e) => JournalPlanProgress.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> savePlanProgress(List<JournalPlanProgress> progress) async {
    final jsonList = progress.map((p) => p.toJson()).toList();
    await _prefs.setString(_planProgressKey, jsonEncode(jsonList));
  }

  // ─── Eisenhower Entries ───

  Future<List<EisenhowerEntry>> getEisenhowerEntries() async {
    final String? data = _prefs.getString(_eisenhowerKey);
    if (data == null) return [];
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList
        .map((e) => EisenhowerEntry.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> saveEisenhowerEntry(EisenhowerEntry entry) async {
    final entries = await getEisenhowerEntries();
    final index = entries.indexWhere((e) => e.id == entry.id);
    if (index >= 0) {
      entries[index] = entry;
    } else {
      entries.add(entry);
    }
    final jsonList = entries.map((e) => e.toJson()).toList();
    await _prefs.setString(_eisenhowerKey, jsonEncode(jsonList));
  }

  Future<void> deleteEisenhowerEntry(String id) async {
    final entries = await getEisenhowerEntries();
    entries.removeWhere((e) => e.id == id);
    final jsonList = entries.map((e) => e.toJson()).toList();
    await _prefs.setString(_eisenhowerKey, jsonEncode(jsonList));
  }

  // ─── Prompt Completions ───

  Future<List<PromptCompletion>> getPromptCompletions() async {
    final String? data = _prefs.getString(_promptCompletionsKey);
    if (data == null) return [];
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList
        .map((e) => PromptCompletion.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
  }

  Future<void> addPromptCompletion(PromptCompletion completion) async {
    final completions = await getPromptCompletions();
    completions.add(completion);
    final jsonList = completions.map((c) => c.toJson()).toList();
    await _prefs.setString(_promptCompletionsKey, jsonEncode(jsonList));
  }

  Future<bool> isPromptCompleted(String promptKey) async {
    final completions = await getPromptCompletions();
    return completions.any((c) => c.promptKey == promptKey);
  }

  Future<PromptCompletion?> latestCompletionFor(String promptKey) async {
    final completions = await getPromptCompletions();
    for (final c in completions) {
      if (c.promptKey == promptKey) return c;
    }
    return null;
  }
}
