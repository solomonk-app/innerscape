import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../constants/reflection_prompts.dart';
import '../models/prompt_completion.dart';
import '../services/analytics_service.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class ReflectionPromptsScreen extends StatefulWidget {
  const ReflectionPromptsScreen({super.key});

  @override
  State<ReflectionPromptsScreen> createState() =>
      _ReflectionPromptsScreenState();
}

class _ReflectionPromptsScreenState extends State<ReflectionPromptsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  List<PromptCompletion> _completions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    AnalyticsService().logScreenView('reflections');
    _loadCompletions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCompletions() async {
    final storage = await StorageService.getInstance();
    final all = await storage.getPromptCompletions();
    if (!mounted) return;
    setState(() {
      _completions = all
          .where((c) =>
              c.source == PromptSource.weekly ||
              c.source == PromptSource.monthly)
          .toList();
      _loading = false;
    });
  }

  Future<void> _openSchedule() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) => const _ReflectionScheduleSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
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
                      'Reflections',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _openSchedule,
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                    tooltip: 'Schedule reminders',
                  ),
                ],
              ),
            ),

            // Tab bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.accentTranslucent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.accentBorder),
                  ),
                  indicatorPadding: const EdgeInsets.all(3),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: AppColors.accent,
                  unselectedLabelColor: AppColors.textMuted,
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 13,
                  ),
                  tabs: const [
                    Tab(text: 'Weekly'),
                    Tab(text: 'Monthly'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accent,
                        strokeWidth: 2,
                      ),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _ReflectionTab(
                          cadence: ReflectionCadence.weekly,
                          completions: _completions
                              .where((c) => c.source == PromptSource.weekly)
                              .toList(),
                          onCompletionChanged: _loadCompletions,
                        ),
                        _ReflectionTab(
                          cadence: ReflectionCadence.monthly,
                          completions: _completions
                              .where((c) => c.source == PromptSource.monthly)
                              .toList(),
                          onCompletionChanged: _loadCompletions,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReflectionTab extends StatefulWidget {
  final ReflectionCadence cadence;
  final List<PromptCompletion> completions;
  final VoidCallback onCompletionChanged;

  const _ReflectionTab({
    required this.cadence,
    required this.completions,
    required this.onCompletionChanged,
  });

  @override
  State<_ReflectionTab> createState() => _ReflectionTabState();
}

class _ReflectionTabState extends State<_ReflectionTab>
    with AutomaticKeepAliveClientMixin {
  final _textController = TextEditingController();
  bool _isWriting = false;
  bool _isSaving = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  ReflectionPrompt get _currentPrompt {
    final now = DateTime.now();
    return widget.cadence == ReflectionCadence.weekly
        ? weeklyPromptForWeek(now)
        : monthlyPromptForMonth(now);
  }

  String _periodKey() {
    final now = DateTime.now();
    if (widget.cadence == ReflectionCadence.weekly) {
      // Week-of-year key, ISO-ish: year-weekIndex
      final dayOfYear = int.parse(
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}',
      );
      final weekIndex = dayOfYear ~/ 7;
      return 'weekly:${now.year}-w$weekIndex:${_currentPrompt.id}';
    }
    return 'monthly:${now.year}-${now.month.toString().padLeft(2, '0')}:${_currentPrompt.id}';
  }

  PromptCompletion? _completionForCurrentPeriod() {
    final key = _periodKey();
    for (final c in widget.completions) {
      if (c.promptKey == key) return c;
    }
    return null;
  }

  Future<void> _complete({required bool writtenInApp}) async {
    if (_isSaving) return;
    final text = writtenInApp ? _textController.text.trim() : null;
    if (writtenInApp && (text == null || text.isEmpty)) return;

    setState(() => _isSaving = true);

    final completion = PromptCompletion(
      id: const Uuid().v4(),
      promptKey: _periodKey(),
      promptTitle: _currentPrompt.title,
      source: widget.cadence == ReflectionCadence.weekly
          ? PromptSource.weekly
          : PromptSource.monthly,
      completedAt: DateTime.now(),
      writtenInApp: writtenInApp,
      text: text,
    );

    final storage = await StorageService.getInstance();
    await storage.addPromptCompletion(completion);

    AnalyticsService().logReflectionCompleted(
      cadence:
          widget.cadence == ReflectionCadence.weekly ? 'weekly' : 'monthly',
      writtenInApp: writtenInApp,
    );

    widget.onCompletionChanged();

    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _isWriting = false;
      _textController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reflection saved.'),
        backgroundColor: AppColors.surfaceLight,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final prompt = _currentPrompt;
    final current = _completionForCurrentPeriod();
    final past = widget.completions
        .where((c) => c.promptKey != _periodKey())
        .toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    final dateFormat = DateFormat.yMMMd().add_jm();

    final periodLabel =
        widget.cadence == ReflectionCadence.weekly ? 'THIS WEEK' : 'THIS MONTH';

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: kIsWeb ? 480 : double.infinity),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            // Current prompt
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
                  Text(
                    periodLabel,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.accent,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    prompt.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    prompt.prompt,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  if (prompt.topics.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    const Text(
                      'TRY WRITING ABOUT',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...prompt.topics.map(
                      (t) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '•',
                              style: TextStyle(
                                color: AppColors.warmGold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                t,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 18),

                  // Existing completion banner
                  if (current != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.accentBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            color: AppColors.accent,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              current.writtenInApp
                                  ? 'Written in-app ${dateFormat.format(current.completedAt)}'
                                  : 'Marked written on paper ${dateFormat.format(current.completedAt)}',
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (current.writtenInApp && current.text != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.background.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Text(
                          current.text!,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                  ],

                  // Action area
                  if (_isWriting) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: TextField(
                        controller: _textController,
                        autofocus: true,
                        maxLines: 8,
                        minLines: 5,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          height: 1.6,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Write here...',
                          hintStyle: TextStyle(color: AppColors.textDim),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 46,
                            child: OutlinedButton(
                              onPressed: _isSaving
                                  ? null
                                  : () => setState(() => _isWriting = false),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: AppColors.borderLight),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Back',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 46,
                            child: ElevatedButton(
                              onPressed: _isSaving
                                  ? null
                                  : () => _complete(writtenInApp: true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                foregroundColor: AppColors.background,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                _isSaving ? 'Saving...' : 'Save reflection',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving
                            ? null
                            : () => _complete(writtenInApp: false),
                        icon: const Icon(Icons.check, size: 18),
                        label: Text(
                          current == null
                              ? 'I wrote it on paper'
                              : 'Write again on paper',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.background,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: OutlinedButton.icon(
                        onPressed: _isSaving
                            ? null
                            : () => setState(() => _isWriting = true),
                        icon: const Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: AppColors.textPrimary,
                        ),
                        label: Text(
                          current == null
                              ? 'Write in-app'
                              : 'Write again in-app',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.borderLight),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Past reflections
            if (past.isNotEmpty) ...[
              const SizedBox(height: 28),
              const Text(
                'PAST REFLECTIONS',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textMuted,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              for (final c in past)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _PastReflectionCard(
                    completion: c,
                    dateLabel: dateFormat.format(c.completedAt),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PastReflectionCard extends StatelessWidget {
  final PromptCompletion completion;
  final String dateLabel;

  const _PastReflectionCard({
    required this.completion,
    required this.dateLabel,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      color: AppColors.surface.withOpacity(0.4),
      borderColor: AppColors.borderLight,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  completion.promptTitle,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accentTranslucent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  completion.writtenInApp ? 'in-app' : 'paper',
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 9,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            dateLabel,
            style: const TextStyle(
              color: AppColors.textDim,
              fontSize: 11,
            ),
          ),
          if (completion.writtenInApp && completion.text != null) ...[
            const SizedBox(height: 8),
            Text(
              completion.text!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Schedule sheet ─────────────────────────────────────────

class _ReflectionScheduleSheet extends StatefulWidget {
  const _ReflectionScheduleSheet();

  @override
  State<_ReflectionScheduleSheet> createState() =>
      _ReflectionScheduleSheetState();
}

class _ReflectionScheduleSheetState extends State<_ReflectionScheduleSheet> {
  bool _weeklyEnabled = false;
  int _weeklyWeekday = DateTime.sunday;
  TimeOfDay _weeklyTime = const TimeOfDay(hour: 10, minute: 0);

  bool _monthlyEnabled = false;
  int _monthlyDay = 1;
  TimeOfDay _monthlyTime = const TimeOfDay(hour: 10, minute: 0);

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final service = NotificationService();
    final wEnabled = await service.isWeeklyReflectionEnabled();
    final wSettings = await service.getWeeklyReflectionSettings();
    final mEnabled = await service.isMonthlyReflectionEnabled();
    final mSettings = await service.getMonthlyReflectionSettings();
    if (!mounted) return;
    setState(() {
      _weeklyEnabled = wEnabled;
      _weeklyWeekday = wSettings.weekday;
      _weeklyTime = TimeOfDay(hour: wSettings.hour, minute: wSettings.minute);
      _monthlyEnabled = mEnabled;
      _monthlyDay = mSettings.day;
      _monthlyTime = TimeOfDay(hour: mSettings.hour, minute: mSettings.minute);
      _loading = false;
    });
  }

  Future<void> _applyWeekly() async {
    final service = NotificationService();
    if (_weeklyEnabled) {
      final granted = await service.requestPermissions();
      if (!granted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notifications permission denied.'),
            backgroundColor: AppColors.surfaceLight,
          ),
        );
      }
      await service.scheduleWeeklyReflection(
        weekday: _weeklyWeekday,
        hour: _weeklyTime.hour,
        minute: _weeklyTime.minute,
      );
    } else {
      await service.cancelWeeklyReflection();
    }
  }

  Future<void> _applyMonthly() async {
    final service = NotificationService();
    if (_monthlyEnabled) {
      final granted = await service.requestPermissions();
      if (!granted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notifications permission denied.'),
            backgroundColor: AppColors.surfaceLight,
          ),
        );
      }
      await service.scheduleMonthlyReflection(
        dayOfMonth: _monthlyDay,
        hour: _monthlyTime.hour,
        minute: _monthlyTime.minute,
      );
    } else {
      await service.cancelMonthlyReflection();
    }
  }

  String _weekdayName(int w) {
    switch (w) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      default:
        return 'Sunday';
    }
  }

  Future<void> _pickWeekday() async {
    final picked = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final w in [
              DateTime.monday,
              DateTime.tuesday,
              DateTime.wednesday,
              DateTime.thursday,
              DateTime.friday,
              DateTime.saturday,
              DateTime.sunday,
            ])
              ListTile(
                title: Text(
                  _weekdayName(w),
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                trailing: w == _weeklyWeekday
                    ? const Icon(Icons.check, color: AppColors.accent)
                    : null,
                onTap: () => Navigator.of(ctx).pop(w),
              ),
          ],
        ),
      ),
    );
    if (picked != null) {
      setState(() => _weeklyWeekday = picked);
      await _applyWeekly();
    }
  }

  Future<void> _pickWeeklyTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _weeklyTime,
    );
    if (picked != null) {
      setState(() => _weeklyTime = picked);
      await _applyWeekly();
    }
  }

  Future<void> _pickMonthlyDay() async {
    final picked = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SizedBox(
        height: 320,
        child: ListView.builder(
          itemCount: 28,
          itemBuilder: (ctx, i) {
            final d = i + 1;
            return ListTile(
              title: Text(
                'Day $d',
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              trailing: d == _monthlyDay
                  ? const Icon(Icons.check, color: AppColors.accent)
                  : null,
              onTap: () => Navigator.of(ctx).pop(d),
            );
          },
        ),
      ),
    );
    if (picked != null) {
      setState(() => _monthlyDay = picked);
      await _applyMonthly();
    }
  }

  Future<void> _pickMonthlyTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _monthlyTime,
    );
    if (picked != null) {
      setState(() => _monthlyTime = picked);
      await _applyMonthly();
    }
  }

  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 240,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.accent,
            strokeWidth: 2,
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.textDim,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text(
            'Reflection reminders',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),

          // Weekly
          _ScheduleRow(
            title: 'Weekly',
            enabled: _weeklyEnabled,
            onToggle: (v) async {
              setState(() => _weeklyEnabled = v);
              await _applyWeekly();
            },
            children: [
              _ScheduleSubRow(
                label: 'Day',
                value: _weekdayName(_weeklyWeekday),
                onTap: _pickWeekday,
              ),
              _ScheduleSubRow(
                label: 'Time',
                value: _formatTime(_weeklyTime),
                onTap: _pickWeeklyTime,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Monthly
          _ScheduleRow(
            title: 'Monthly',
            enabled: _monthlyEnabled,
            onToggle: (v) async {
              setState(() => _monthlyEnabled = v);
              await _applyMonthly();
            },
            children: [
              _ScheduleSubRow(
                label: 'Day of month',
                value: 'Day $_monthlyDay',
                onTap: _pickMonthlyDay,
              ),
              _ScheduleSubRow(
                label: 'Time',
                value: _formatTime(_monthlyTime),
                onTap: _pickMonthlyTime,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  final String title;
  final bool enabled;
  final ValueChanged<bool> onToggle;
  final List<Widget> children;

  const _ScheduleRow({
    required this.title,
    required this.enabled,
    required this.onToggle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      color: AppColors.surface.withOpacity(0.5),
      borderColor: AppColors.borderLight,
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Switch(
                value: enabled,
                onChanged: onToggle,
                activeColor: AppColors.accent,
              ),
            ],
          ),
          if (enabled) ...children,
        ],
      ),
    );
  }
}

class _ScheduleSubRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _ScheduleSubRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textDim,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
