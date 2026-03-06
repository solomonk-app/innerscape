import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mood_entry.dart';
import '../models/time_capsule.dart';
import '../models/weekly_digest.dart';

class StorageService {
  static const String _entriesKey = 'mood_entries';
  static const String _capsulesKey = 'time_capsules';
  static const String _digestsKey = 'weekly_digests';
  static StorageService? _instance;
  late SharedPreferences _prefs;

  StorageService._();

  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      _instance = StorageService._();
      _instance!._prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
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

  Future<bool> hasDigestForWeek(DateTime weekStart) async {
    final digests = await getDigests();
    return digests.any((d) =>
        d.weekStart.year == weekStart.year &&
        d.weekStart.month == weekStart.month &&
        d.weekStart.day == weekStart.day);
  }
}
