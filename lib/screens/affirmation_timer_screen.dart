import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import '../constants/affirmations.dart';
import '../services/analytics_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

const List<int> _presetMinutes = [5, 10, 15];

enum _Phase { idle, running, done }

class AffirmationTimerScreen extends StatefulWidget {
  const AffirmationTimerScreen({super.key});

  @override
  State<AffirmationTimerScreen> createState() => _AffirmationTimerScreenState();
}

class _AffirmationTimerScreenState extends State<AffirmationTimerScreen>
    with TickerProviderStateMixin {
  _Phase _phase = _Phase.idle;
  int _selectedMinutes = 5;
  int _remainingSeconds = 5 * 60;
  int _totalSeconds = 5 * 60;
  Timer? _ticker;
  Affirmation? _revealed;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    AnalyticsService().logScreenView('affirmation_timer');
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _start() {
    AnalyticsService().logAffirmationTimerStarted(
      durationMin: _selectedMinutes,
    );
    setState(() {
      _phase = _Phase.running;
      _totalSeconds = _selectedMinutes * 60;
      _remainingSeconds = _totalSeconds;
    });
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remainingSeconds <= 1) {
        _ticker?.cancel();
        setState(() {
          _remainingSeconds = 0;
          _phase = _Phase.done;
          _revealed = _pickAffirmation();
        });
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  void _stop() {
    _ticker?.cancel();
    setState(() {
      _phase = _Phase.idle;
      _remainingSeconds = _selectedMinutes * 60;
    });
  }

  void _repeat() {
    setState(() {
      _phase = _Phase.idle;
      _remainingSeconds = _selectedMinutes * 60;
      _revealed = null;
    });
  }

  Affirmation _pickAffirmation() {
    if (affirmations.isEmpty) {
      return const Affirmation(
        text: 'A small kindness for yourself today.',
        tone: AffirmationTone.selfCompassion,
      );
    }
    return affirmations[Random().nextInt(affirmations.length)];
  }

  String _formatRemaining() {
    final m = _remainingSeconds ~/ 60;
    final s = _remainingSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
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
                      'Affirmation Timer',
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
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: switch (_phase) {
                  _Phase.idle => _buildIdle(),
                  _Phase.running => _buildRunning(),
                  _Phase.done => _buildDone(),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdle() {
    return Padding(
      key: const ValueKey('idle'),
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Sit with yourself for',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final m in _presetMinutes) ...[
                _PresetChip(
                  minutes: m,
                  isActive: _selectedMinutes == m,
                  onTap: () => setState(() {
                    _selectedMinutes = m;
                    _remainingSeconds = m * 60;
                  }),
                ),
                if (m != _presetMinutes.last) const SizedBox(width: 10),
              ],
            ],
          ),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: _start,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (ctx, child) {
                final t = _pulseController.value;
                return Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.accent.withOpacity(0.18 + 0.10 * t),
                        AppColors.accent.withOpacity(0.04),
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.accentBorder,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.play_arrow,
                          color: AppColors.accent,
                          size: 38,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Begin',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 13,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'A pause. A breath. A single affirmation\nwaiting at the end.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textDim,
              fontSize: 12,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRunning() {
    final progress = _totalSeconds == 0
        ? 0.0
        : 1 - (_remainingSeconds / _totalSeconds);
    return Padding(
      key: const ValueKey('running'),
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 220,
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background ring
                SizedBox(
                  width: 220,
                  height: 220,
                  child: CircularProgressIndicator(
                    value: 1,
                    strokeWidth: 6,
                    valueColor:
                        AlwaysStoppedAnimation(AppColors.borderLight),
                    backgroundColor: Colors.transparent,
                  ),
                ),
                // Progress ring
                SizedBox(
                  width: 220,
                  height: 220,
                  child: CircularProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    strokeWidth: 6,
                    valueColor:
                        const AlwaysStoppedAnimation(AppColors.accent),
                    backgroundColor: Colors.transparent,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatRemaining(),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 44,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'remaining',
                      style: TextStyle(
                        color: AppColors.textDim,
                        fontSize: 11,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),
          const Text(
            'Take a slow breath in.\nLet it out, even slower.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 28),
          OutlinedButton(
            onPressed: _stop,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.borderLight),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'End early',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDone() {
    return Padding(
      key: const ValueKey('done'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                Text(
                  '\u{2728}',
                  style: TextStyle(
                    fontSize: 28,
                    color: AppColors.accent.withOpacity(0.85),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _revealed?.text ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    height: 1.6,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                if (_revealed != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    affirmationToneLabel(_revealed!.tone).toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 10,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: _repeat,
                    icon: const Icon(
                      Icons.refresh,
                      color: AppColors.textPrimary,
                      size: 18,
                    ),
                    label: const Text(
                      'Again',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.borderLight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final int minutes;
  final bool isActive;
  final VoidCallback onTap;

  const _PresetChip({
    required this.minutes,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isActive,
      label: '$minutes minutes',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.accentTranslucent
                : AppColors.surface.withOpacity(0.4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive ? AppColors.accentBorder : AppColors.borderLight,
            ),
          ),
          child: Text(
            '$minutes min',
            style: TextStyle(
              color: isActive ? AppColors.accent : AppColors.textMuted,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
