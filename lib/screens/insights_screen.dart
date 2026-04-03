import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../models/mood_entry.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class InsightsScreen extends StatelessWidget {
  final List<MoodEntry> entries;
  final int streak;
  final VoidCallback onClearData;
  final Widget? digestCard;
  final Widget? capsuleCard;

  const InsightsScreen({
    super.key,
    required this.entries,
    required this.streak,
    required this.onClearData,
    this.digestCard,
    this.capsuleCard,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.length < 3) {
      return Center(
        child: FadeIn(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🔮', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(
                'Log at least 3 entries to unlock\nyour mood insights and patterns.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                      height: 1.6,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '${3 - entries.length} more to go!',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textDim,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    final avgMood =
        (entries.fold<int>(0, (sum, e) => sum + e.mood) / entries.length);
    final avgMoodStr = avgMood.toStringAsFixed(1);
    final avgMoodEmoji = moodOptions
        .firstWhere((m) => m.value == avgMood.round(),
            orElse: () => moodOptions[2])
        .emoji;

    // Most common mood
    final moodCounts = <int, int>{};
    for (final e in entries) {
      moodCounts[e.mood] = (moodCounts[e.mood] ?? 0) + 1;
    }
    final mostCommonValue =
        moodCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    final mostCommon = moodOptions.firstWhere((m) => m.value == mostCommonValue);

    final stats = [
      {'label': 'Average Mood', 'value': avgMoodStr, 'icon': avgMoodEmoji},
      {
        'label': 'Total Entries',
        'value': entries.length.toString(),
        'icon': '📝'
      },
      {'label': 'Current Streak', 'value': '${streak}d', 'icon': '🔥'},
      {
        'label': 'Most Common',
        'value': mostCommon.label,
        'icon': mostCommon.emoji
      },
    ];

    // Tag trigger analysis
    final tagAnalysis = _analyzeTagTriggers();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: kIsWeb ? 480 : double.infinity),
          child: Column(
            children: [
          // Weekly Digest card (injected from main.dart)
          if (digestCard != null) ...[
            FadeInDown(
              duration: const Duration(milliseconds: 500),
              child: digestCard!,
            ),
            const SizedBox(height: 12),
          ],

          // Time Capsule card (injected from main.dart)
          if (capsuleCard != null) ...[
            FadeInDown(
              delay: const Duration(milliseconds: 100),
              duration: const Duration(milliseconds: 500),
              child: capsuleCard!,
            ),
            const SizedBox(height: 12),
          ],

          // Stats grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.05,
            children: stats.asMap().entries.map((item) {
              final stat = item.value;
              return FadeInUp(
                delay: Duration(milliseconds: 100 * item.key),
                duration: const Duration(milliseconds: 500),
                child: GlassCard(
                  semanticLabel: '${stat['label']}: ${stat['value']}',
                  color: AppColors.surface.withOpacity(0.5),
                  borderColor: const Color(0x148B7E74),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        (stat['label'] as String).toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textDim,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        stat['value'] as String,
                        style: const TextStyle(
                          fontSize: 28,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        stat['icon'] as String,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Tag Trigger Analysis
          if (tagAnalysis.isNotEmpty)
            FadeInUp(
              delay: const Duration(milliseconds: 450),
              duration: const Duration(milliseconds: 500),
              child: GlassCard(
                color: AppColors.surface.withOpacity(0.4),
                borderColor: AppColors.borderLight,
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TRIGGER DISCOVERY',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.accent,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'How context affects your mood',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textDim,
                          ),
                    ),
                    const SizedBox(height: 16),
                    // Boosters
                    if (tagAnalysis['boosters']!.isNotEmpty) ...[
                      const Text(
                        '↑ MOOD BOOSTERS',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF7BC47F),
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...tagAnalysis['boosters']!.map((item) => Semantics(
                          label: 'Mood booster: ${item['tag']}, average ${(item['avg'] as double).toStringAsFixed(1)}',
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF7BC47F),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    item['tag'] as String,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                Text(
                                  'avg ${(item['avg'] as double).toStringAsFixed(1)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF7BC47F),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          )),
                      const SizedBox(height: 14),
                    ],
                    // Drainers
                    if (tagAnalysis['drainers']!.isNotEmpty) ...[
                      const Text(
                        '↓ MOOD DRAINERS',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFFCF8B8B),
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...tagAnalysis['drainers']!.map((item) => Semantics(
                          label: 'Mood drainer: ${item['tag']}, average ${(item['avg'] as double).toStringAsFixed(1)}',
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFCF8B8B),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    item['tag'] as String,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                Text(
                                  'avg ${(item['avg'] as double).toStringAsFixed(1)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFCF8B8B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          )),
                    ],
                  ],
                ),
              ),
            ),

          // Mood distribution
          FadeInUp(
            delay: const Duration(milliseconds: 500),
            duration: const Duration(milliseconds: 500),
            child: GlassCard(
              color: AppColors.surface.withOpacity(0.4),
              borderColor: AppColors.borderLight,
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MOOD DISTRIBUTION',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 20),
                  ...moodOptions.map((mood) {
                    final count =
                        entries.where((e) => e.mood == mood.value).length;
                    final pct = (count / entries.length * 100);
                    return Semantics(
                      label: '${mood.label}: ${pct.toStringAsFixed(0)} percent',
                      child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 28,
                            child: Text(mood.emoji,
                                style: const TextStyle(fontSize: 18)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: SizedBox(
                                height: 8,
                                child: Stack(
                                  alignment: Alignment.topLeft,
                                  children: [
                                    Container(
                                      color: AppColors.borderLight,
                                    ),
                                    FractionallySizedBox(
                                      widthFactor: pct / 100,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Color(mood.colorValue),
                                              Color(mood.colorValue)
                                                  .withOpacity(0.5),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 36,
                            child: Text(
                              '${pct.toStringAsFixed(0)}%',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textDim,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Reset button
          FadeInUp(
            delay: const Duration(milliseconds: 700),
            duration: const Duration(milliseconds: 400),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: const Text(
                        'Clear all data?',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                      content: const Text(
                        'This will permanently delete all your journal entries. This can\'t be undone.',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel',
                              style: TextStyle(color: AppColors.textMuted)),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            onClearData();
                          },
                          child: const Text('Delete All',
                              style: TextStyle(color: Colors.redAccent)),
                        ),
                      ],
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.borderLight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Reset All Data',
                  style: TextStyle(
                    color: AppColors.textDim,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
        ),
      ),
    );
  }

  /// Analyze tag correlations — returns boosters (above avg) and drainers (below avg)
  Map<String, List<Map<String, dynamic>>> _analyzeTagTriggers() {
    final entriesWithTags = entries.where((e) => e.tags.isNotEmpty).toList();
    if (entriesWithTags.length < 3) return {};

    final overallAvg =
        entries.fold<int>(0, (s, e) => s + e.mood) / entries.length;

    final tagMoods = <String, List<int>>{};
    for (final entry in entries) {
      for (final tag in entry.tags) {
        tagMoods.putIfAbsent(tag, () => []).add(entry.mood);
      }
    }

    final boosters = <Map<String, dynamic>>[];
    final drainers = <Map<String, dynamic>>[];

    for (final entry in tagMoods.entries) {
      if (entry.value.length < 2) continue; // Need at least 2 data points
      final avg =
          entry.value.fold<int>(0, (s, v) => s + v) / entry.value.length;
      final diff = avg - overallAvg;
      if (diff > 0.3) {
        boosters.add({'tag': entry.key, 'avg': avg, 'diff': diff});
      } else if (diff < -0.3) {
        drainers.add({'tag': entry.key, 'avg': avg, 'diff': diff});
      }
    }

    boosters.sort((a, b) =>
        (b['diff'] as double).compareTo(a['diff'] as double));
    drainers.sort((a, b) =>
        (a['diff'] as double).compareTo(b['diff'] as double));

    return {
      'boosters': boosters.take(4).toList(),
      'drainers': drainers.take(4).toList(),
    };
  }
}
