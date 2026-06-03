import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../services/analytics_service.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import 'affirmation_timer_screen.dart';

const List<int> _intervalOptions = [1, 3, 6];

class AffirmationSettingsScreen extends StatefulWidget {
  const AffirmationSettingsScreen({super.key});

  @override
  State<AffirmationSettingsScreen> createState() =>
      _AffirmationSettingsScreenState();
}

class _AffirmationSettingsScreenState extends State<AffirmationSettingsScreen> {
  bool _enabled = false;
  int _intervalHours = 3;
  TimeOfDay _start = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _end = const TimeOfDay(hour: 21, minute: 0);
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    AnalyticsService().logScreenView('affirmation_settings');
    _load();
  }

  Future<void> _load() async {
    final service = NotificationService();
    final enabled = await service.isAffirmationEnabled();
    final settings = await service.getAffirmationSettings();
    if (!mounted) return;
    setState(() {
      _enabled = enabled;
      _intervalHours = settings.intervalHours;
      _start = TimeOfDay(hour: settings.startHour, minute: 0);
      _end = TimeOfDay(hour: settings.endHour, minute: 0);
      _loading = false;
    });
  }

  Future<void> _apply() async {
    if (_saving) return;
    setState(() => _saving = true);
    final service = NotificationService();
    if (_enabled) {
      final granted = await service.requestPermissions();
      if (!granted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notifications permission denied.'),
            backgroundColor: AppColors.surfaceLight,
          ),
        );
      }
      await service.scheduleAffirmationSlots(
        intervalHours: _intervalHours,
        startHour: _start.hour,
        endHour: _end.hour,
      );
      AnalyticsService().logAffirmationNotificationsToggled(
        enabled: true,
        intervalHours: _intervalHours,
      );
    } else {
      await service.cancelAffirmations();
      AnalyticsService().logAffirmationNotificationsToggled(enabled: false);
    }
    if (!mounted) return;
    setState(() => _saving = false);
  }

  Future<void> _pickStartHour() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _start,
    );
    if (picked == null) return;
    setState(() => _start = TimeOfDay(hour: picked.hour, minute: 0));
    await _apply();
  }

  Future<void> _pickEndHour() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _end,
    );
    if (picked == null) return;
    setState(() => _end = TimeOfDay(hour: picked.hour, minute: 0));
    await _apply();
  }

  String _formatHour(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour $period';
  }

  int get _slotsPerDay {
    if (_intervalHours < 1) return 0;
    final start = _start.hour;
    final end = _end.hour;
    if (end < start) return 0;
    return ((end - start) ~/ _intervalHours) + 1;
  }

  void _openTimer() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const AffirmationTimerScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
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
                      'Affirmations',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accent,
                        strokeWidth: 2,
                      ),
                    )
                  : Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: kIsWeb ? 480 : double.infinity,
                        ),
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                'Gentle nudges throughout your day, drawn from a curated list of affirmations.',
                                style: TextStyle(
                                  color: AppColors.textDim,
                                  fontSize: 12,
                                  height: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Toggle
                            GlassCard(
                              color: AppColors.surface.withOpacity(0.5),
                              borderColor: AppColors.borderLight,
                              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                              child: Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Send affirmation reminders',
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Switch(
                                    value: _enabled,
                                    onChanged: (v) async {
                                      setState(() => _enabled = v);
                                      await _apply();
                                    },
                                    activeColor: AppColors.accent,
                                  ),
                                ],
                              ),
                            ),

                            if (_enabled) ...[
                              const SizedBox(height: 18),
                              const _SectionLabel(label: 'INTERVAL'),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 10,
                                children: [
                                  for (final h in _intervalOptions)
                                    _IntervalChip(
                                      hours: h,
                                      isActive: _intervalHours == h,
                                      onTap: () async {
                                        setState(() => _intervalHours = h);
                                        await _apply();
                                      },
                                    ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              const _SectionLabel(label: 'ACTIVE WINDOW'),
                              const SizedBox(height: 8),
                              GlassCard(
                                color: AppColors.surface.withOpacity(0.4),
                                borderColor: AppColors.borderLight,
                                padding: EdgeInsets.zero,
                                child: Column(
                                  children: [
                                    _TimeRow(
                                      label: 'Starts at',
                                      value: _formatHour(_start),
                                      onTap: _pickStartHour,
                                    ),
                                    Container(
                                      height: 1,
                                      color: AppColors.borderLight,
                                    ),
                                    _TimeRow(
                                      label: 'Ends at',
                                      value: _formatHour(_end),
                                      onTap: _pickEndHour,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _slotsPerDay > 0
                                    ? "You'll get $_slotsPerDay ${_slotsPerDay == 1 ? "affirmation" : "affirmations"} per day."
                                    : 'Adjust the window to schedule at least one slot.',
                                style: const TextStyle(
                                  color: AppColors.textDim,
                                  fontSize: 12,
                                ),
                              ),
                            ],

                            const SizedBox(height: 28),
                            const _SectionLabel(label: 'TRY IT NOW'),
                            const SizedBox(height: 8),
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
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.accentTranslucent,
                                    ),
                                    child: const Icon(
                                      Icons.self_improvement,
                                      color: AppColors.accent,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Run a timed affirmation',
                                          style: TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          'A short pause that ends with a single affirmation.',
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12,
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: _openTimer,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.accent,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'Begin',
                                        style: TextStyle(
                                          color: AppColors.background,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 10,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

class _IntervalChip extends StatelessWidget {
  final int hours;
  final bool isActive;
  final VoidCallback onTap;

  const _IntervalChip({
    required this.hours,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isActive,
      label: 'Every $hours hours',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.accentTranslucent
                : AppColors.surface.withOpacity(0.4),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isActive ? AppColors.accentBorder : AppColors.borderLight,
            ),
          ),
          child: Text(
            'Every ${hours}h',
            style: TextStyle(
              color: isActive ? AppColors.accent : AppColors.textMuted,
              fontSize: 13,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _TimeRow({
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                fontWeight: FontWeight.w500,
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
