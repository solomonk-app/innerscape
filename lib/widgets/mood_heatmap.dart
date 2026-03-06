import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/mood_entry.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

class MoodHeatmap extends StatelessWidget {
  final List<MoodEntry> entries;

  const MoodHeatmap({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Show ~3 months (13 weeks)
    const totalWeeks = 13;
    final startDate = now.subtract(Duration(days: totalWeeks * 7 - 1));
    // Align to start of week (Monday)
    final alignedStart =
        startDate.subtract(Duration(days: startDate.weekday - 1));

    // Build mood map: date string → average mood for that day
    final moodMap = <String, _DayMood>{};
    for (final entry in entries) {
      final key = _dateKey(entry.timestamp);
      if (moodMap.containsKey(key)) {
        moodMap[key]!.addMood(entry.mood);
        moodMap[key]!.entries.add(entry);
      } else {
        moodMap[key] = _DayMood(entry.mood, [entry]);
      }
    }

    // Pattern analysis
    final patternText = _analyzePatterns(entries);

    return GlassCard(
      color: AppColors.surface.withOpacity(0.4),
      borderColor: AppColors.borderLight,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MOOD HEATMAP',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.accent,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Last 3 months',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textDim,
                ),
          ),
          const SizedBox(height: 16),

          // Day labels
          Row(
            children: [
              const SizedBox(width: 0),
              Expanded(
                child: Column(
                  children: [
                    // Weekday labels
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Day abbreviations column
                        Column(
                          children: ['M', '', 'W', '', 'F', '', 'S']
                              .map((d) => SizedBox(
                                    height: 14,
                                    child: Text(
                                      d,
                                      style: const TextStyle(
                                        fontSize: 8,
                                        color: AppColors.textDim,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(width: 4),
                        // Grid
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final cellSize =
                                  (constraints.maxWidth - (totalWeeks - 1) * 2) /
                                      totalWeeks;
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: List.generate(totalWeeks, (weekIdx) {
                                  return Column(
                                    children: List.generate(7, (dayIdx) {
                                      final date = alignedStart.add(
                                          Duration(days: weekIdx * 7 + dayIdx));
                                      if (date.isAfter(now)) {
                                        return SizedBox(
                                          width: cellSize,
                                          height: 14,
                                        );
                                      }
                                      final key = _dateKey(date);
                                      final dayMood = moodMap[key];
                                      final color = dayMood != null
                                          ? _moodColor(dayMood.average)
                                          : AppColors.surface.withOpacity(0.3);

                                      return GestureDetector(
                                        onTap: dayMood != null
                                            ? () => _showDayDetail(
                                                context, date, dayMood)
                                            : null,
                                        child: Container(
                                          width: cellSize,
                                          height: 12,
                                          margin: const EdgeInsets.only(
                                              bottom: 2),
                                          decoration: BoxDecoration(
                                            color: color,
                                            borderRadius:
                                                BorderRadius.circular(2),
                                          ),
                                        ),
                                      );
                                    }),
                                  );
                                }),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Less',
                style: TextStyle(fontSize: 9, color: AppColors.textDim),
              ),
              const SizedBox(width: 4),
              ...List.generate(6, (i) {
                return Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: _moodColor((i + 1).toDouble()),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
              const SizedBox(width: 4),
              const Text(
                'More',
                style: TextStyle(fontSize: 9, color: AppColors.textDim),
              ),
            ],
          ),

          // Pattern text
          if (patternText.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentTranslucent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Text('💡', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      patternText,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.warmGold,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static Color _moodColor(double mood) {
    // Interpolate: 1 = cool dark → 6 = warm orange
    const colors = [
      Color(0xFF3A3530), // 1 - dark
      Color(0xFF5A524A), // 2 - dim brown
      Color(0xFF8B7E74), // 3 - muted
      Color(0xFFC4A882), // 4 - warm tan
      Color(0xFFD4915A), // 5 - warm orange
      Color(0xFFE07B3C), // 6 - bright orange
    ];
    final idx = (mood - 1).clamp(0.0, 5.0);
    final lower = idx.floor();
    final upper = idx.ceil();
    if (lower == upper) return colors[lower];
    return Color.lerp(colors[lower], colors[upper], (idx - lower).toDouble())!;
  }

  void _showDayDetail(BuildContext context, DateTime date, _DayMood dayMood) {
    final dateFormat = DateFormat('EEEE, MMM d');
    final timeFormat = DateFormat('h:mm a');

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                dateFormat.format(date),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ...dayMood.entries.map((entry) {
                final mood =
                    moodOptions.firstWhere((m) => m.value == entry.mood);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(mood.emoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${mood.label} · ${timeFormat.format(entry.timestamp)}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            if (entry.text.isNotEmpty)
                              Text(
                                entry.text,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                  height: 1.5,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  String _analyzePatterns(List<MoodEntry> entries) {
    if (entries.length < 7) return '';

    // Group by day of week
    final dayMoods = <int, List<int>>{};
    for (final e in entries) {
      dayMoods.putIfAbsent(e.timestamp.weekday, () => []).add(e.mood);
    }

    // Find best and worst days
    double bestAvg = 0;
    int bestDay = 1;
    double worstAvg = 7;
    int worstDay = 1;

    for (final entry in dayMoods.entries) {
      if (entry.value.length < 2) continue;
      final avg = entry.value.fold<int>(0, (s, v) => s + v) / entry.value.length;
      if (avg > bestAvg) {
        bestAvg = avg;
        bestDay = entry.key;
      }
      if (avg < worstAvg) {
        worstAvg = avg;
        worstDay = entry.key;
      }
    }

    final dayNames = {
      1: 'Mondays', 2: 'Tuesdays', 3: 'Wednesdays',
      4: 'Thursdays', 5: 'Fridays', 6: 'Saturdays', 7: 'Sundays',
    };

    // Weekend vs weekday comparison
    final weekdayMoods = entries
        .where((e) => e.timestamp.weekday <= 5)
        .map((e) => e.mood)
        .toList();
    final weekendMoods = entries
        .where((e) => e.timestamp.weekday > 5)
        .map((e) => e.mood)
        .toList();

    if (weekendMoods.length >= 2 && weekdayMoods.length >= 2) {
      final wdAvg =
          weekdayMoods.fold<int>(0, (s, v) => s + v) / weekdayMoods.length;
      final weAvg =
          weekendMoods.fold<int>(0, (s, v) => s + v) / weekendMoods.length;
      if ((weAvg - wdAvg).abs() > 0.5) {
        if (weAvg > wdAvg) {
          return 'You tend to feel better on weekends. ${dayNames[worstDay]} are consistently tougher.';
        } else {
          return 'Interestingly, your weekday moods are higher than weekends. ${dayNames[bestDay]} tend to be your best.';
        }
      }
    }

    if (bestAvg - worstAvg > 0.5) {
      return '${dayNames[bestDay]} tend to be your best days. ${dayNames[worstDay]} are consistently tougher.';
    }

    return '';
  }
}

class _DayMood {
  final List<MoodEntry> entries;
  int _totalMood;
  int _count;

  _DayMood(int firstMood, List<MoodEntry> initialEntries)
      : _totalMood = firstMood,
        _count = 1,
        entries = List.from(initialEntries);

  void addMood(int mood) {
    _totalMood += mood;
    _count++;
  }

  double get average => _totalMood / _count;
}
