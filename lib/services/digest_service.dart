import 'package:uuid/uuid.dart';
import '../models/weekly_digest.dart';
import 'ai_service.dart';
import 'storage_service.dart';

class DigestService {
  /// Check if it's time to generate a digest (Sunday + no digest for this week)
  static Future<bool> shouldGenerateDigest() async {
    final now = DateTime.now();
    if (now.weekday != DateTime.sunday) return false;

    final weekStart = _getWeekStart(now);
    final storage = await StorageService.getInstance();
    return !(await storage.hasDigestForWeek(weekStart));
  }

  /// Generate the weekly digest
  static Future<WeeklyDigest?> generateDigest() async {
    final storage = await StorageService.getInstance();
    final entries = await storage.getEntries();
    if (entries.isEmpty) return null;

    final now = DateTime.now();
    final weekStart = _getWeekStart(now);
    final weekEnd = weekStart.add(const Duration(days: 6));

    // Get this week's entries
    final weekEntries = entries.where((e) {
      return !e.timestamp.isBefore(weekStart) &&
          e.timestamp.isBefore(weekEnd.add(const Duration(days: 1)));
    }).toList();

    if (weekEntries.isEmpty) return null;

    // Get last week's entries for comparison
    final lastWeekStart = weekStart.subtract(const Duration(days: 7));
    final lastWeekEntries = entries.where((e) {
      return !e.timestamp.isBefore(lastWeekStart) &&
          e.timestamp.isBefore(weekStart);
    }).toList();

    // Calculate stats
    final avgMood = weekEntries.fold<int>(0, (s, e) => s + e.mood) /
        weekEntries.length;

    // Best and worst days
    final dayMoods = <int, List<int>>{};
    for (final e in weekEntries) {
      dayMoods.putIfAbsent(e.timestamp.weekday, () => []).add(e.mood);
    }

    int bestDay = weekEntries.first.timestamp.weekday;
    double bestMood = 0;
    int worstDay = weekEntries.first.timestamp.weekday;
    double worstMood = 7;

    for (final entry in dayMoods.entries) {
      final avg = entry.value.fold<int>(0, (s, v) => s + v) / entry.value.length;
      if (avg > bestMood) {
        bestMood = avg;
        bestDay = entry.key;
      }
      if (avg < worstMood) {
        worstMood = avg;
        worstDay = entry.key;
      }
    }

    // Generate AI content
    final content = await AiService.getWeeklyDigest(
      weekEntries: weekEntries,
      lastWeekEntries: lastWeekEntries,
    );

    final digest = WeeklyDigest(
      id: const Uuid().v4(),
      weekStart: weekStart,
      weekEnd: weekEnd,
      generatedAt: now,
      content: content,
      averageMood: avgMood,
      entryCount: weekEntries.length,
      bestDay: bestDay,
      worstDay: worstDay,
      bestMood: bestMood,
      worstMood: worstMood,
    );

    await storage.saveDigest(digest);
    return digest;
  }

  /// Get the most recent digest
  static Future<WeeklyDigest?> getLatestDigest() async {
    final storage = await StorageService.getInstance();
    final digests = await storage.getDigests();
    return digests.isNotEmpty ? digests.first : null;
  }

  /// Get Monday of the given week
  static DateTime _getWeekStart(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return DateTime(monday.year, monday.month, monday.day);
  }
}
