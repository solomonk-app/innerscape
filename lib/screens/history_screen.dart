import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/mood_entry.dart';
import '../constants/bible_verses.dart';
import '../services/ai_service.dart';
import '../theme/app_theme.dart';
import 'result_screen.dart';
import '../widgets/glass_card.dart';
import '../widgets/mood_heatmap.dart';

class HistoryScreen extends StatefulWidget {
  final List<MoodEntry> entries;

  const HistoryScreen({super.key, required this.entries});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    if (widget.entries.isEmpty) {
      return Center(
        child: FadeIn(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('📝', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(
                'No entries yet. Start your first check-in!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    final chartData = widget.entries.reversed.take(14).toList().reversed.toList();
    final reversedEntries = widget.entries.reversed.toList();
    final dateFormat = DateFormat('EEE, MMM d');
    final timeFormat = DateFormat('h:mm a');

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: kIsWeb ? 480 : double.infinity),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // Mood Heatmap
          if (widget.entries.length > 1)
            FadeInDown(
              duration: const Duration(milliseconds: 500),
              child: MoodHeatmap(entries: widget.entries),
            ),

          // Chart
          if (chartData.length > 1)
            FadeInDown(
              delay: const Duration(milliseconds: 100),
              duration: const Duration(milliseconds: 500),
              child: GlassCard(
                color: AppColors.surface.withOpacity(0.4),
                borderColor: AppColors.borderLight,
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                margin: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        'MOOD TREND (LAST 14 ENTRIES)',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Semantics(
                      label: 'Mood trend chart showing last ${chartData.length} entries',
                      excludeSemantics: true,
                      child: SizedBox(
                      height: 180,
                      child: LineChart(
                        LineChartData(
                          minY: 0.5,
                          maxY: 6.5,
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 1,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: AppColors.borderLight,
                              strokeWidth: 0.5,
                            ),
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                interval: 1,
                                getTitlesWidget: (value, _) {
                                  if (value < 1 || value > 6) return const Text('');
                                  final mood = moodOptions.firstWhere(
                                    (m) => m.value == value.toInt(),
                                    orElse: () => moodOptions[0],
                                  );
                                  return Text(
                                    mood.emoji,
                                    style: const TextStyle(fontSize: 12),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: chartData.asMap().entries.map((e) {
                                return FlSpot(
                                    e.key.toDouble(), e.value.mood.toDouble());
                              }).toList(),
                              isCurved: true,
                              curveSmoothness: 0.3,
                              color: AppColors.accent,
                              barWidth: 2.5,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (_, __, ___, ____) =>
                                    FlDotCirclePainter(
                                  radius: 4,
                                  color: AppColors.accent,
                                  strokeWidth: 0,
                                ),
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    AppColors.accent.withOpacity(0.25),
                                    AppColors.accent.withOpacity(0.0),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              tooltipBgColor:
                                  AppColors.surface.withOpacity(0.95),
                              tooltipRoundedRadius: 12,
                              tooltipPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              getTooltipItems: (spots) {
                                return spots.map((spot) {
                                  final entry = chartData[spot.x.toInt()];
                                  final mood = moodOptions
                                      .firstWhere((m) => m.value == entry.mood);
                                  return LineTooltipItem(
                                    '${mood.emoji} ${mood.label}\n',
                                    const TextStyle(
                                      color: AppColors.accent,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: dateFormat.format(entry.timestamp),
                                        style: const TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 11,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList();
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    ),
                  ],
                ),
              ),
            ),

          // Entry list
          ...reversedEntries.asMap().entries.map((item) {
            final entry = item.value;
            final mood = moodOptions.firstWhere((m) => m.value == entry.mood);
            return FadeInUp(
              delay: Duration(milliseconds: 50 * (item.key < 10 ? item.key : 10)),
              duration: const Duration(milliseconds: 400),
              child: Semantics(
                button: true,
                label: '${mood.label} entry from ${dateFormat.format(entry.timestamp)} at ${timeFormat.format(entry.timestamp)}',
                child: GestureDetector(
                onTap: () => Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) {
                      final category = moodToCategory(entry.mood);
                      final verses = curatedVerses[category]!;
                      final verse = verses[entry.timestamp.millisecond % verses.length];
                      return ResultScreen(
                        entry: entry,
                        wellnessTip: WellnessTips.getTip(entry.mood),
                        bibleVerse: verse,
                        onNewCheckIn: () => Navigator.of(context).pop(),
                      );
                    },
                    transitionsBuilder: (_, a, __, child) =>
                        FadeTransition(opacity: a, child: child),
                  ),
                ),
                child: GlassCard(
                  color: AppColors.surface.withOpacity(0.4),
                  borderColor: const Color(0x148B7E74),
                  padding: const EdgeInsets.all(18),
                  margin: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(mood.emoji, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mood.label,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${dateFormat.format(entry.timestamp)} · ${timeFormat.format(entry.timestamp)}',
                                style: const TextStyle(
                                  color: AppColors.textDim,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(mood.colorValue).withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    // Tags
                    if (entry.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 36),
                        child: Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: entry.tags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.accentTranslucent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                tag,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.warmGold,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                    if (entry.text.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(left: 36),
                        child: Text(
                          entry.text.length > 120
                              ? '${entry.text.substring(0, 120)}...'
                              : entry.text,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                    if (entry.aiInsight.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(left: 36),
                        child: Container(
                          padding: const EdgeInsets.only(top: 10),
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Color(0x148B7E74),
                              ),
                            ),
                          ),
                          child: Text(
                            '✨ ${entry.aiInsight.length > 100 ? '${entry.aiInsight.substring(0, 100)}...' : entry.aiInsight}',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ),
              ),
            );
          }),
          const SizedBox(height: 40),
        ],
      ),
        ),
      ),
    );
  }
}
