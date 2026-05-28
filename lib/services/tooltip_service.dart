import 'package:shared_preferences/shared_preferences.dart';

class TooltipService {
  static final TooltipService _instance = TooltipService._();
  factory TooltipService() => _instance;
  TooltipService._();

  static const String _prefix = 'tooltip_seen_';

  // Tooltip keys
  static const String firstCheckinMood = 'first_checkin_mood';
  static const String firstAiInsight = 'first_ai_insight';
  static const String firstInsightsTab = 'first_insights_tab';

  Future<bool> hasSeenTooltip(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_prefix$key') ?? false;
  }

  Future<void> markTooltipSeen(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefix$key', true);
  }

  Future<void> resetAllTooltips() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = [firstCheckinMood, firstAiInsight, firstInsightsTab];
    for (final key in keys) {
      await prefs.remove('$_prefix$key');
    }
  }
}
