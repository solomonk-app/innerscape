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

  // --- Achievements ---

  Future<void> logAchievementEarned({
    required String achievementId,
    required String category,
    required int tier,
  }) async {
    await _analytics.logEvent(
      name: 'achievement_earned',
      parameters: {
        'achievement_id': achievementId,
        'category': category,
        'tier': tier,
      },
    );
  }

  Future<void> logAchievementGalleryView({
    required int earnedCount,
    required int totalCount,
  }) async {
    await _analytics.logEvent(
      name: 'achievement_gallery_view',
      parameters: {
        'earned_count': earnedCount,
        'total_count': totalCount,
      },
    );
  }

  // --- Challenges ---

  Future<void> logChallengeGenerated({
    required String source,
    required String title,
  }) async {
    await _analytics.logEvent(
      name: 'challenge_generated',
      parameters: {'source': source, 'title': title},
    );
  }

  Future<void> logChallengeCompleted({
    required String challengeId,
    required bool hasReflection,
  }) async {
    await _analytics.logEvent(
      name: 'challenge_completed',
      parameters: {
        'challenge_id': challengeId,
        'has_reflection': hasReflection ? 1 : 0,
      },
    );
  }

  // --- Review ---

  Future<void> logReviewPromptShown() async {
    await _analytics.logEvent(name: 'review_prompt_shown');
  }

  Future<void> logReviewPromptAccepted() async {
    await _analytics.logEvent(name: 'review_prompt_accepted');
  }

  Future<void> logReviewPromptDeclined() async {
    await _analytics.logEvent(name: 'review_prompt_declined');
  }

  // --- Insight Feedback ---

  Future<void> logInsightFeedback({
    required String entryId,
    required bool isPositive,
  }) async {
    await _analytics.logEvent(
      name: 'insight_feedback',
      parameters: {
        'entry_id': entryId,
        'is_positive': isPositive ? 1 : 0,
      },
    );
  }

  // --- Journal ideas ---

  Future<void> logJournalIdeaCompleted({
    required String ideaId,
    required bool writtenInApp,
  }) async {
    await _analytics.logEvent(
      name: 'journal_idea_completed',
      parameters: {
        'idea_id': ideaId,
        'written_in_app': writtenInApp ? 1 : 0,
      },
    );
  }

  // --- Journal plans ---

  Future<void> logPlanStarted({
    required String planId,
    required int lengthDays,
  }) async {
    await _analytics.logEvent(
      name: 'plan_started',
      parameters: {
        'plan_id': planId,
        'length_days': lengthDays,
      },
    );
  }

  Future<void> logPlanDayCompleted({
    required String planId,
    required int day,
    required bool writtenInApp,
  }) async {
    await _analytics.logEvent(
      name: 'plan_day_completed',
      parameters: {
        'plan_id': planId,
        'day': day,
        'written_in_app': writtenInApp ? 1 : 0,
      },
    );
  }

  Future<void> logPlanCompleted({required String planId}) async {
    await _analytics.logEvent(
      name: 'plan_completed',
      parameters: {'plan_id': planId},
    );
  }

  // --- Affirmations ---

  Future<void> logAffirmationTimerStarted({required int durationMin}) async {
    await _analytics.logEvent(
      name: 'affirmation_timer_started',
      parameters: {'duration_min': durationMin},
    );
  }

  Future<void> logAffirmationNotificationsToggled({
    required bool enabled,
    int? intervalHours,
  }) async {
    await _analytics.logEvent(
      name: 'affirmation_notifications_toggled',
      parameters: {
        'enabled': enabled ? 1 : 0,
        if (intervalHours != null) 'interval_hours': intervalHours,
      },
    );
  }

  // --- Eisenhower ---

  Future<void> logEisenhowerSaved({
    required int itemCount,
    required bool hasReflection,
  }) async {
    await _analytics.logEvent(
      name: 'eisenhower_saved',
      parameters: {
        'item_count': itemCount,
        'has_reflection': hasReflection ? 1 : 0,
      },
    );
  }

  // --- Reflections ---

  Future<void> logReflectionCompleted({
    required String cadence,
    required bool writtenInApp,
  }) async {
    await _analytics.logEvent(
      name: 'reflection_completed',
      parameters: {
        'cadence': cadence,
        'written_in_app': writtenInApp ? 1 : 0,
      },
    );
  }

  // --- User properties ---

  Future<void> setUserProperties({
    int? totalEntries,
    int? currentStreak,
    String? mostCommonMood,
    int? achievementsEarned,
    int? challengesCompleted,
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
    if (achievementsEarned != null) {
      await _analytics.setUserProperty(
        name: 'achievements_earned',
        value: achievementsEarned.toString(),
      );
    }
    if (challengesCompleted != null) {
      await _analytics.setUserProperty(
        name: 'challenges_completed',
        value: challengesCompleted.toString(),
      );
    }
  }
}
