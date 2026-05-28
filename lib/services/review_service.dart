import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import 'analytics_service.dart';

class ReviewService {
  static final ReviewService _instance = ReviewService._();
  factory ReviewService() => _instance;
  ReviewService._();

  static const String _promptShownKey = 'review_prompt_shown';
  static const String _promptTimestampKey = 'review_prompt_timestamp';
  static const String _declinedKey = 'review_declined';
  static const int _checkInThreshold = 5;

  final InAppReview _inAppReview = InAppReview.instance;

  Future<bool> shouldPromptForReview(int currentCheckInCount) async {
    if (currentCheckInCount < _checkInThreshold) return false;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_declinedKey) ?? false) return false;
    if (prefs.getBool(_promptShownKey) ?? false) return false;
    return true;
  }

  Future<void> showReviewPrompt(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_promptShownKey, true);
    await prefs.setInt(_promptTimestampKey, DateTime.now().millisecondsSinceEpoch);
    await AnalyticsService().logReviewPromptShown();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Enjoying Feelong?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Your reflections matter to us. If Feelong has been helpful, would you mind leaving a quick rating?',
          style: TextStyle(color: AppColors.textMuted, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await prefs.setBool(_declinedKey, true);
              await AnalyticsService().logReviewPromptDeclined();
            },
            child: const Text(
              'Not Now',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await AnalyticsService().logReviewPromptAccepted();
              if (await _inAppReview.isAvailable()) {
                await _inAppReview.requestReview();
              } else {
                await openStoreListing();
              }
            },
            child: const Text(
              'Rate Feelong',
              style: TextStyle(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> openStoreListing() async {
    await _inAppReview.openStoreListing(
      appStoreId: '6760197546',
    );
  }
}
