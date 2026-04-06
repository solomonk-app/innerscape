import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mood_entry.dart';
import '../models/time_capsule.dart';
import '../models/weekly_digest.dart';
import '../models/achievement.dart';
import '../models/daily_challenge.dart';

class StorageService {
  static const String _entriesKey = 'mood_entries';
  static const String _capsulesKey = 'time_capsules';
  static const String _digestsKey = 'weekly_digests';
  static const String _onboardingKey = 'has_seen_onboarding';
  static const String _achievementsKey = 'earned_achievements';
  static const String _challengesKey = 'daily_challenges';
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
}
