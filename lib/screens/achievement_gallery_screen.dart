import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../models/achievement.dart';
import '../models/mood_entry.dart';
import '../models/time_capsule.dart';
import '../services/achievement_service.dart';
import '../services/storage_service.dart';
import '../services/analytics_service.dart';
import '../theme/app_theme.dart';
import '../widgets/achievement_badge.dart';
import '../widgets/adaptive_banner_ad.dart';

class AchievementGalleryScreen extends StatefulWidget {
  const AchievementGalleryScreen({super.key});

  @override
  State<AchievementGalleryScreen> createState() =>
      _AchievementGalleryScreenState();
}

class _AchievementGalleryScreenState extends State<AchievementGalleryScreen> {
  List<EarnedAchievement> _earned = [];
  List<MoodEntry> _entries = [];
  List<TimeCapsule> _capsules = [];
  int _streak = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final storage = await StorageService.getInstance();
    final entries = await storage.getEntries();
    final capsules = await storage.getCapsules();
    final earned = await AchievementService().getEarned();

    AnalyticsService().logAchievementGalleryView(
      earnedCount: earned.length,
      totalCount: allAchievements.length,
    );

    if (mounted) {
      setState(() {
        _entries = entries;
        _capsules = capsules;
        _streak = storage.calculateStreak(entries);
        _earned = earned;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final earnedIds = _earned.map((e) => e.achievementId).toSet();

    final categories = AchievementCategory.values;
    final categoryLabels = {
      AchievementCategory.entries: 'Journaling',
      AchievementCategory.streak: 'Streaks',
      AchievementCategory.features: 'Explorer',
      AchievementCategory.mood: 'Mood',
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Go back',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                  ),
                  Expanded(
                    child: FadeInDown(
                      duration: const Duration(milliseconds: 400),
                      child: Column(
                        children: [
                          Text(
                            'Achievements',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: AppColors.textPrimary),
                          ),
                          if (!_isLoading)
                            Text(
                              '${earnedIds.length} of ${allAchievements.length} earned',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textDim,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accent,
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: kIsWeb ? 480 : double.infinity,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final category in categories) ...[
                                _buildCategorySection(
                                  category,
                                  categoryLabels[category]!,
                                  earnedIds,
                                ),
                              ],
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),

            const AdaptiveBannerAd(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(
    AchievementCategory category,
    String label,
    Set<String> earnedIds,
  ) {
    final achievements =
        allAchievements.where((a) => a.category == category).toList();
    if (achievements.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textDim,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.75,
            children: achievements.map((def) {
              final earned = _earned.cast<EarnedAchievement?>().firstWhere(
                    (e) => e!.achievementId == def.id,
                    orElse: () => null,
                  );
              final progress = earned != null
                  ? 1.0
                  : AchievementService()
                      .getProgress(def.id, _entries, _streak, _capsules);
              return AchievementBadge(
                definition: def,
                earned: earned,
                progress: progress,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
