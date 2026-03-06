import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../models/mood_entry.dart';
import '../models/weekly_digest.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/adaptive_banner_ad.dart';

class WeeklyDigestScreen extends StatefulWidget {
  final WeeklyDigest? initialDigest;

  const WeeklyDigestScreen({super.key, this.initialDigest});

  @override
  State<WeeklyDigestScreen> createState() => _WeeklyDigestScreenState();
}

class _WeeklyDigestScreenState extends State<WeeklyDigestScreen> {
  List<WeeklyDigest> _digests = [];
  WeeklyDigest? _selectedDigest;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDigests();
  }

  Future<void> _loadDigests() async {
    final storage = await StorageService.getInstance();
    final digests = await storage.getDigests();
    setState(() {
      _digests = digests;
      _selectedDigest = widget.initialDigest ?? (digests.isNotEmpty ? digests.first : null);
      _isLoading = false;
    });
  }

  static const _dayNames = {
    1: 'Monday', 2: 'Tuesday', 3: 'Wednesday',
    4: 'Thursday', 5: 'Friday', 6: 'Saturday', 7: 'Sunday',
  };

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d');

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
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Weekly Digest',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            if (_isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                ),
              )
            else if (_selectedDigest == null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('📊', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 16),
                      Text(
                        'No digests yet.\nCheck back on Sunday!',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textMuted,
                            ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: _buildDigestContent(context, _selectedDigest!, dateFormat),
                ),
              ),

            // Digest selector (if multiple)
            if (_digests.length > 1)
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.borderLight),
                  ),
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _digests.length,
                  itemBuilder: (ctx, idx) {
                    final d = _digests[idx];
                    final isSelected = d.id == _selectedDigest?.id;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDigest = d),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.accentTranslucent
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.accentBorder
                                : AppColors.borderLight,
                          ),
                        ),
                        child: Text(
                          '${dateFormat.format(d.weekStart)} - ${dateFormat.format(d.weekEnd)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected
                                ? AppColors.accent
                                : AppColors.textMuted,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Banner ad pinned to bottom
            const AdaptiveBannerAd(),
          ],
        ),
      ),
    );
  }

  Widget _buildDigestContent(
      BuildContext context, WeeklyDigest digest, DateFormat dateFormat) {
    final moodEmoji = moodOptions
        .firstWhere((m) => m.value == digest.averageMood.round(),
            orElse: () => moodOptions[2])
        .emoji;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Week header
        FadeInDown(
          duration: const Duration(milliseconds: 400),
          child: Text(
            'Week of ${dateFormat.format(digest.weekStart)}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w300,
                ),
          ),
        ),
        const SizedBox(height: 4),
        FadeInDown(
          delay: const Duration(milliseconds: 100),
          duration: const Duration(milliseconds: 400),
          child: Text(
            '${dateFormat.format(digest.weekStart)} – ${dateFormat.format(digest.weekEnd)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textDim,
                ),
          ),
        ),
        const SizedBox(height: 24),

        // Stats row
        FadeInDown(
          delay: const Duration(milliseconds: 200),
          duration: const Duration(milliseconds: 400),
          child: Row(
            children: [
              _StatBadge(
                label: 'AVG MOOD',
                value: '${digest.averageMood.toStringAsFixed(1)} $moodEmoji',
              ),
              const SizedBox(width: 8),
              _StatBadge(
                label: 'ENTRIES',
                value: '${digest.entryCount}',
              ),
              const SizedBox(width: 8),
              _StatBadge(
                label: 'BEST DAY',
                value: _dayNames[digest.bestDay]?.substring(0, 3) ?? '?',
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Mini mood chart for the week
        FadeInUp(
          delay: const Duration(milliseconds: 300),
          duration: const Duration(milliseconds: 500),
          child: _buildMiniChart(digest),
        ),
        const SizedBox(height: 24),

        // AI digest letter
        FadeInUp(
          delay: const Duration(milliseconds: 400),
          duration: const Duration(milliseconds: 600),
          child: GlassCard(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0x14E8945A),
                Color(0x0FD4A574),
              ],
            ),
            borderColor: const Color(0x26E8945A),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '✨ YOUR WEEKLY LETTER',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.accent,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  digest.content,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.8,
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildMiniChart(WeeklyDigest digest) {
    // Build a simple 7-day bar chart showing best/worst
    return GlassCard(
      color: AppColors.surface.withOpacity(0.4),
      borderColor: AppColors.borderLight,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MOOD ARC',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final dayNum = i + 1; // 1=Mon..7=Sun
                final isBest = dayNum == digest.bestDay;
                final isWorst = dayNum == digest.worstDay;
                final barHeight = dayNum == digest.bestDay
                    ? digest.bestMood / 6.0
                    : dayNum == digest.worstDay
                        ? digest.worstMood / 6.0
                        : digest.averageMood / 6.0;

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: FractionallySizedBox(
                            heightFactor: barHeight.clamp(0.1, 1.0),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: BoxDecoration(
                                color: isBest
                                    ? AppColors.accent
                                    : isWorst
                                        ? const Color(0xFF8B7E74)
                                        : AppColors.warmGold.withOpacity(0.4),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                        style: TextStyle(
                          fontSize: 9,
                          color: isBest
                              ? AppColors.accent
                              : isWorst
                                  ? const Color(0xFFCF8B8B)
                                  : AppColors.textDim,
                          fontWeight: isBest || isWorst
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;

  const _StatBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        color: AppColors.surface.withOpacity(0.4),
        borderColor: AppColors.borderLight,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                color: AppColors.textDim,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
