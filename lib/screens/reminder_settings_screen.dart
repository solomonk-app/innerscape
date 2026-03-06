import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class ReminderSettingsScreen extends StatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  State<ReminderSettingsScreen> createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {
  final _notificationService = NotificationService();
  bool _isEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);
  bool _isLoading = true;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await _notificationService.isReminderEnabled();
    final time = await _notificationService.getReminderTime();
    setState(() {
      _isEnabled = enabled;
      _reminderTime = time;
      _isLoading = false;
    });
  }

  Future<void> _toggleReminder(bool value) async {
    if (value) {
      // Request permissions first
      final granted = await _notificationService.requestPermissions();
      if (!granted) {
        setState(() => _permissionDenied = true);
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) setState(() => _permissionDenied = false);
        });
        return;
      }
      await _notificationService.scheduleDailyReminder(
        hour: _reminderTime.hour,
        minute: _reminderTime.minute,
      );
    } else {
      await _notificationService.cancelReminder();
    }
    setState(() => _isEnabled = value);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accent,
              onPrimary: AppColors.background,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppColors.surface,
              hourMinuteColor: AppColors.background,
              hourMinuteTextColor: AppColors.textPrimary,
              dialHandColor: AppColors.accent,
              dialBackgroundColor: AppColors.background,
              dialTextColor: AppColors.textPrimary,
              dayPeriodColor: AppColors.accentTranslucent,
              dayPeriodTextColor: AppColors.accent,
              entryModeIconColor: AppColors.textMuted,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              helpTextStyle: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                letterSpacing: 1.5,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _reminderTime) {
      setState(() => _reminderTime = picked);
      if (_isEnabled) {
        await _notificationService.scheduleDailyReminder(
          hour: picked.hour,
          minute: picked.minute,
        );
      }
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Ambient glow
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent.withOpacity(0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Reminders',
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge
                            ?.copyWith(fontSize: 24),
                      ),
                    ],
                  ),
                ),

                if (_isLoading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accent,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Illustration
                          FadeInDown(
                            duration: const Duration(milliseconds: 500),
                            child: Center(
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.accentTranslucent,
                                  border: Border.all(
                                    color: AppColors.accentBorder,
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    '🔔',
                                    style: TextStyle(fontSize: 42),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          FadeInDown(
                            delay: const Duration(milliseconds: 100),
                            duration: const Duration(milliseconds: 500),
                            child: Center(
                              child: Text(
                                'Never forget to check in',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontStyle: FontStyle.italic,
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          FadeInDown(
                            delay: const Duration(milliseconds: 150),
                            duration: const Duration(milliseconds: 500),
                            child: Center(
                              child: Text(
                                'Set a gentle daily nudge to pause, breathe,\nand reflect on how you\'re feeling.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.textDim,
                                      height: 1.6,
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 36),

                          // Toggle card
                          FadeInUp(
                            delay: const Duration(milliseconds: 200),
                            duration: const Duration(milliseconds: 500),
                            child: GlassCard(
                              color: AppColors.surface.withOpacity(0.5),
                              borderColor: _isEnabled
                                  ? AppColors.accentBorder
                                  : AppColors.borderLight,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 6),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Daily Reminder',
                                        style: TextStyle(
                                          color: _isEnabled
                                              ? AppColors.textPrimary
                                              : AppColors.textMuted,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _isEnabled
                                            ? 'You\'ll get a nudge every day'
                                            : 'Currently off',
                                        style: TextStyle(
                                          color: AppColors.textDim,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Switch.adaptive(
                                    value: _isEnabled,
                                    onChanged: _toggleReminder,
                                    activeColor: AppColors.accent,
                                    activeTrackColor:
                                        AppColors.accent.withOpacity(0.3),
                                    inactiveThumbColor: AppColors.textMuted,
                                    inactiveTrackColor:
                                        AppColors.borderLight,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Time picker card
                          FadeInUp(
                            delay: const Duration(milliseconds: 300),
                            duration: const Duration(milliseconds: 500),
                            child: GestureDetector(
                              onTap: _pickTime,
                              child: GlassCard(
                                color: AppColors.surface.withOpacity(0.5),
                                borderColor: AppColors.borderLight,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 18),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Reminder Time',
                                          style: TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Tap to change',
                                          style: TextStyle(
                                            color: AppColors.textDim,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentTranslucent,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.accentBorder,
                                        ),
                                      ),
                                      child: Text(
                                        _formatTime(_reminderTime),
                                        style: const TextStyle(
                                          color: AppColors.accent,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Permission denied warning
                          if (_permissionDenied)
                            FadeInUp(
                              duration: const Duration(milliseconds: 300),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: GlassCard(
                                  color: const Color(0x20FF6B6B),
                                  borderColor: const Color(0x40FF6B6B),
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.warning_rounded,
                                        color: Color(0xFFFF6B6B),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Notification permission denied. Please enable notifications in your device settings.',
                                          style: TextStyle(
                                            color: const Color(0xFFFF6B6B)
                                                .withOpacity(0.9),
                                            fontSize: 13,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                          const SizedBox(height: 36),

                          // Quick presets
                          FadeInUp(
                            delay: const Duration(milliseconds: 400),
                            duration: const Duration(milliseconds: 500),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'QUICK PRESETS',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall,
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    _PresetChip(
                                      label: '☀️ Morning',
                                      subtitle: '8:00 AM',
                                      isSelected: _reminderTime.hour == 8 &&
                                          _reminderTime.minute == 0,
                                      onTap: () =>
                                          _applyPreset(8, 0),
                                    ),
                                    const SizedBox(width: 8),
                                    _PresetChip(
                                      label: '🌤️ Midday',
                                      subtitle: '12:00 PM',
                                      isSelected:
                                          _reminderTime.hour == 12 &&
                                              _reminderTime.minute == 0,
                                      onTap: () =>
                                          _applyPreset(12, 0),
                                    ),
                                    const SizedBox(width: 8),
                                    _PresetChip(
                                      label: '🌙 Evening',
                                      subtitle: '8:00 PM',
                                      isSelected:
                                          _reminderTime.hour == 20 &&
                                              _reminderTime.minute == 0,
                                      onTap: () =>
                                          _applyPreset(20, 0),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _PresetChip(
                                      label: '🛏️ Bedtime',
                                      subtitle: '10:00 PM',
                                      isSelected:
                                          _reminderTime.hour == 22 &&
                                              _reminderTime.minute == 0,
                                      onTap: () =>
                                          _applyPreset(22, 0),
                                    ),
                                    const SizedBox(width: 8),
                                    _PresetChip(
                                      label: '🍽️ Lunch',
                                      subtitle: '1:00 PM',
                                      isSelected:
                                          _reminderTime.hour == 13 &&
                                              _reminderTime.minute == 0,
                                      onTap: () =>
                                          _applyPreset(13, 0),
                                    ),
                                    const SizedBox(width: 8),
                                    _PresetChip(
                                      label: '🌆 After Work',
                                      subtitle: '6:00 PM',
                                      isSelected:
                                          _reminderTime.hour == 18 &&
                                              _reminderTime.minute == 0,
                                      onTap: () =>
                                          _applyPreset(18, 0),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 36),

                          // Info note
                          FadeInUp(
                            delay: const Duration(milliseconds: 500),
                            duration: const Duration(milliseconds: 500),
                            child: GlassCard(
                              color: AppColors.surface.withOpacity(0.3),
                              borderColor: AppColors.borderLight,
                              padding: const EdgeInsets.all(18),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('💡',
                                      style: TextStyle(fontSize: 16)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Reminders are sent locally from your device. No data is shared. Each notification includes a unique motivational message.',
                                      style: TextStyle(
                                        color: AppColors.textDim,
                                        fontSize: 12,
                                        height: 1.6,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _applyPreset(int hour, int minute) async {
    setState(() => _reminderTime = TimeOfDay(hour: hour, minute: minute));
    if (_isEnabled) {
      await _notificationService.scheduleDailyReminder(
        hour: hour,
        minute: minute,
      );
    }
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _PresetChip({
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.accentTranslucent
                : AppColors.surface.withOpacity(0.4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? AppColors.accentBorder
                  : AppColors.borderLight,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected
                      ? AppColors.accent
                      : AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected
                      ? AppColors.accent.withOpacity(0.7)
                      : AppColors.textDim,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
