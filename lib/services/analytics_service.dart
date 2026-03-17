import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._();
  factory AnalyticsService() => _instance;
  AnalyticsService._();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // --- Check-in ---

  Future<void> logCheckInSubmitted({
    required int mood,
    required int tagCount,
    required bool hasJournalText,
  }) async {
    debugPrint('Analytics: check_in_submitted mood=$mood tags=$tagCount');
    await _analytics.logEvent(
      name: 'check_in_submitted',
      parameters: {
        'mood': mood,
        'tag_count': tagCount,
        'has_journal_text': hasJournalText ? 1 : 0,
      },
    );
  }

  // --- Breathwork ---

  Future<void> logBreathworkStart({required String pattern}) async {
    await _analytics.logEvent(
      name: 'breathwork_start',
      parameters: {'pattern': pattern},
    );
  }

  Future<void> logBreathworkComplete({
    required String pattern,
    required int cycles,
  }) async {
    await _analytics.logEvent(
      name: 'breathwork_complete',
      parameters: {'pattern': pattern, 'cycles': cycles},
    );
  }

  // --- Time Capsule ---

  Future<void> logTimeCapsuleCreate({required String duration}) async {
    await _analytics.logEvent(
      name: 'time_capsule_create',
      parameters: {'duration': duration},
    );
  }

  Future<void> logTimeCapsuleOpen() async {
    await _analytics.logEvent(name: 'time_capsule_open');
  }

  // --- Weekly Digest ---

  Future<void> logWeeklyDigestView() async {
    await _analytics.logEvent(name: 'weekly_digest_view');
  }

  // --- AI Conversation ---

  Future<void> logAiConversationStart() async {
    debugPrint('Analytics: ai_conversation_start');
    await _analytics.logEvent(name: 'ai_conversation_start');
  }

  // --- Ads ---

  Future<void> logInterstitialShown() async {
    await _analytics.logEvent(name: 'interstitial_shown');
  }

  Future<void> logRewardedComplete() async {
    await _analytics.logEvent(name: 'rewarded_complete');
  }

  // --- Reminder ---

  Future<void> logReminderChanged({
    required bool enabled,
    String? time,
  }) async {
    await _analytics.logEvent(
      name: 'reminder_changed',
      parameters: {
        'enabled': enabled ? 1 : 0,
        if (time != null) 'time': time,
      },
    );
  }

  // --- Screen views ---

  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  // --- User properties ---

  Future<void> setUserProperties({
    int? totalEntries,
    int? currentStreak,
    String? mostCommonMood,
  }) async {
    if (totalEntries != null) {
      await _analytics.setUserProperty(
        name: 'total_entries',
        value: totalEntries.toString(),
      );
    }
    if (currentStreak != null) {
      await _analytics.setUserProperty(
        name: 'current_streak',
        value: currentStreak.toString(),
      );
    }
    if (mostCommonMood != null) {
      await _analytics.setUserProperty(
        name: 'most_common_mood',
        value: mostCommonMood,
      );
    }
  }
}
