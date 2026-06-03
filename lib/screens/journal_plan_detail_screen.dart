import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/journal_plans.dart';
import '../models/journal_plan.dart';
import '../services/analytics_service.dart';
import '../services/journal_plan_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/prompt_sheet.dart';
import '../models/prompt_completion.dart';

class JournalPlanDetailScreen extends StatefulWidget {
  final JournalPlanTemplate template;
  final JournalPlanProgress progress;

  const JournalPlanDetailScreen({
    super.key,
    required this.template,
    required this.progress,
  });

  @override
  State<JournalPlanDetailScreen> createState() =>
      _JournalPlanDetailScreenState();
}

class _JournalPlanDetailScreenState extends State<JournalPlanDetailScreen> {
  late JournalPlanProgress _progress;

  @override
  void initState() {
    super.initState();
    _progress = widget.progress;
    AnalyticsService().logScreenView('journal_plan_detail');
  }

  Future<void> _refresh() async {
    final fresh = await JournalPlanService().getById(_progress.planId);
    if (!mounted || fresh == null) return;
    setState(() => _progress = fresh);
  }

  void _openDay(DayPrompt day) {
    final service = JournalPlanService();
    final promptKey = service.promptKey(widget.template.id, day.day);
    final alreadyDone = _progress.completedDays.containsKey(day.day);
    final wasComplete = service.isComplete(_progress, widget.template);

    PromptSheet.show(
      context: context,
      title: 'Day ${day.day} — ${day.title}',
      prompt: day.prompt,
      topics: day.topics,
      promptKey: promptKey,
      source: PromptSource.plan,
      onCompleted: (completion) async {
        if (!alreadyDone) {
          await service.markDayComplete(
            planId: widget.template.id,
            day: day.day,
          );
          AnalyticsService().logPlanDayCompleted(
            planId: widget.template.id,
            day: day.day,
            writtenInApp: completion.writtenInApp,
          );
        }
        await _refresh();

        final nowComplete = service.isComplete(_progress, widget.template);
        if (!wasComplete && nowComplete) {
          AnalyticsService().logPlanCompleted(planId: widget.template.id);
          if (mounted) _showCelebration();
        }
      },
    );
  }

  void _showCelebration() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          '${widget.template.emoji}  Plan complete',
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 18),
        ),
        content: Text(
          'You finished "${widget.template.title}". That\'s ${widget.template.lengthDays} days of showing up for yourself.',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Beautiful',
              style: TextStyle(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmArchive() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Archive this plan?',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
        ),
        content: const Text(
          'Your progress will be saved, but the plan won\'t appear in your active list. You can start it again later.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Archive',
              style: TextStyle(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await JournalPlanService().archive(widget.template.id);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final service = JournalPlanService();
    final fraction = service.progressFraction(_progress, widget.template);
    final currentDay = service.currentDay(_progress, widget.template);
    final isDone = service.isComplete(_progress, widget.template);

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
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Plan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _confirmArchive,
                    icon: const Icon(
                      Icons.archive_outlined,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                    tooltip: 'Archive plan',
                  ),
                ],
              ),
            ),

            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: kIsWeb ? 480 : double.infinity,
                  ),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    children: [
                      // Plan summary card
                      GlassCard(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0x1AE8945A),
                            Color(0x14D4A574),
                          ],
                        ),
                        borderColor: AppColors.accentBorder,
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.template.emoji,
                                  style: const TextStyle(fontSize: 28),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.template.title,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        widget.template.description,
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: SizedBox(
                                height: 6,
                                child: LinearProgressIndicator(
                                  value: fraction,
                                  backgroundColor: AppColors.borderLight,
                                  valueColor: const AlwaysStoppedAnimation(
                                    AppColors.accent,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isDone
                                  ? 'Plan complete — ${widget.template.lengthDays} of ${widget.template.lengthDays} days'
                                  : 'Day ${currentDay ?? widget.template.lengthDays} of ${widget.template.lengthDays}',
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'DAYS',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                          letterSpacing: 2,
                        ),
                      ),

                      const SizedBox(height: 10),

                      for (final day in widget.template.dayPrompts)
                        _DayRow(
                          day: day,
                          completedAt: _progress.completedDays[day.day],
                          isCurrent: currentDay == day.day,
                          onTap: () => _openDay(day),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  final DayPrompt day;
  final DateTime? completedAt;
  final bool isCurrent;
  final VoidCallback onTap;

  const _DayRow({
    required this.day,
    required this.completedAt,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final completed = completedAt != null;
    final dateFormat = DateFormat.MMMd();

    final Color borderColor = completed
        ? AppColors.accentBorder
        : isCurrent
            ? AppColors.accentBorder
            : AppColors.borderLight;
    final Color titleColor = completed
        ? AppColors.textPrimary
        : isCurrent
            ? AppColors.textPrimary
            : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Semantics(
        button: true,
        label:
            'Day ${day.day}: ${day.title}.${completed ? " Completed." : isCurrent ? " Current day." : ""}',
        child: GestureDetector(
          onTap: onTap,
          child: GlassCard(
            color: isCurrent
                ? AppColors.accentTranslucent
                : AppColors.surface.withOpacity(0.4),
            borderColor: borderColor,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: completed
                        ? AppColors.accent
                        : isCurrent
                            ? AppColors.accentTranslucent
                            : Colors.transparent,
                    border: Border.all(
                      color: completed
                          ? AppColors.accent
                          : isCurrent
                              ? AppColors.accent
                              : AppColors.borderLight,
                    ),
                  ),
                  child: completed
                      ? const Icon(
                          Icons.check,
                          color: AppColors.background,
                          size: 16,
                        )
                      : Text(
                          '${day.day}',
                          style: TextStyle(
                            color: isCurrent
                                ? AppColors.accent
                                : AppColors.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        day.title,
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 13,
                          fontWeight:
                              isCurrent ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                      if (completedAt != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Done ${dateFormat.format(completedAt!)}',
                          style: const TextStyle(
                            color: AppColors.textDim,
                            fontSize: 11,
                          ),
                        ),
                      ] else if (isCurrent) ...[
                        const SizedBox(height: 2),
                        const Text(
                          'Today\'s prompt',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: isCurrent ? AppColors.accent : AppColors.textDim,
                  size: 12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
