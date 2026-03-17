import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import '../models/breathing_pattern.dart';
import '../services/breathwork_audio_service.dart';
import '../services/analytics_service.dart';
import '../theme/app_theme.dart';

class BreathworkScreen extends StatefulWidget {
  final int suggestedMood;

  const BreathworkScreen({super.key, required this.suggestedMood});

  @override
  State<BreathworkScreen> createState() => _BreathworkScreenState();
}

class _BreathworkScreenState extends State<BreathworkScreen>
    with TickerProviderStateMixin {
  late BreathingPattern _pattern;
  late AnimationController _breathController;
  final BreathworkAudioService _audioService = BreathworkAudioService();
  bool _isActive = false;
  int _currentCycle = 0;
  BreathPhase _currentPhase = const BreathPhase(
    label: 'Ready',
    progress: 0,
    type: BreathPhaseType.inhale,
  );
  BreathPhaseType? _lastPhaseType;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _pattern = suggestPattern(widget.suggestedMood);
    _breathController = AnimationController(
      vsync: this,
      duration:
          Duration(seconds: _pattern.cycleDurationSeconds * _pattern.totalCycles),
    );
    _breathController.addListener(_onTick);
    _breathController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isActive = false;
          _isComplete = true;
        });
        HapticFeedback.heavyImpact();
        _audioService.stop();
        AnalyticsService().logBreathworkComplete(
          pattern: _pattern.name,
          cycles: _pattern.totalCycles,
        );
      }
    });
    _audioService.init();
  }

  void _onTick() {
    final totalDuration = _pattern.cycleDurationSeconds * _pattern.totalCycles;
    final elapsed = _breathController.value * totalDuration;
    final cycle = (elapsed / _pattern.cycleDurationSeconds).floor();
    final elapsedInCycle = elapsed % _pattern.cycleDurationSeconds;
    final phase = _pattern.getPhase(elapsedInCycle);

    // Haptic + chime on phase transition
    if (_lastPhaseType != null && _lastPhaseType != phase.type) {
      HapticFeedback.mediumImpact();
      _audioService.playChime();
    }

    setState(() {
      _currentCycle = cycle;
      _currentPhase = phase;
      _lastPhaseType = phase.type;
    });
  }

  void _selectPattern(BreathingPattern pattern) {
    if (_isActive) return;
    _breathController.reset();
    setState(() {
      _pattern = pattern;
      _isComplete = false;
      _currentCycle = 0;
      _currentPhase = const BreathPhase(
        label: 'Ready',
        progress: 0,
        type: BreathPhaseType.inhale,
      );
      _lastPhaseType = null;
    });
    _breathController.duration =
        Duration(seconds: _pattern.cycleDurationSeconds * _pattern.totalCycles);
  }

  void _startBreathing() {
    HapticFeedback.lightImpact();
    AnalyticsService().logBreathworkStart(pattern: _pattern.name);
    setState(() {
      _isActive = true;
      _isComplete = false;
    });
    _breathController.forward(from: 0);
    _audioService.start();
  }

  void _stopBreathing() {
    _breathController.stop();
    _breathController.reset();
    _audioService.stop();
    setState(() {
      _isActive = false;
      _isComplete = false;
      _currentCycle = 0;
      _currentPhase = const BreathPhase(
        label: 'Ready',
        progress: 0,
        type: BreathPhaseType.inhale,
      );
      _lastPhaseType = null;
    });
  }

  @override
  void dispose() {
    _audioService.dispose();
    _breathController.dispose();
    super.dispose();
  }

  /// Calculate the breathing circle scale: expands on inhale, contracts on exhale
  double _getCircleScale() {
    if (!_isActive && !_isComplete) return 0.5;
    switch (_currentPhase.type) {
      case BreathPhaseType.inhale:
        return 0.5 + 0.5 * _currentPhase.progress;
      case BreathPhaseType.holdIn:
        return 1.0;
      case BreathPhaseType.exhale:
        return 1.0 - 0.5 * _currentPhase.progress;
      case BreathPhaseType.holdOut:
        return 0.5;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = _getCircleScale();

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
                    child: FadeInDown(
                      duration: const Duration(milliseconds: 400),
                      child: Text(
                        'Breathwork',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.textPrimary,
                            ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() => _audioService.toggleMute());
                    },
                    icon: Icon(
                      _audioService.isMuted
                          ? Icons.volume_off_rounded
                          : Icons.volume_up_rounded,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // Sound selector
            if (!_isActive && !_isComplete)
              FadeInDown(
                delay: const Duration(milliseconds: 50),
                duration: const Duration(milliseconds: 400),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (final entry in {
                        AmbientSound.rain: 'Rain',
                        AmbientSound.ocean: 'Ocean',
                        AmbientSound.forest: 'Forest',
                        AmbientSound.none: 'Silent',
                      }.entries)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Text(
                              entry.value,
                              style: TextStyle(
                                fontSize: 12,
                                color: _audioService.currentSound == entry.key
                                    ? AppColors.accent
                                    : AppColors.textMuted,
                              ),
                            ),
                            selected: _audioService.currentSound == entry.key,
                            selectedColor: AppColors.accentTranslucent,
                            backgroundColor: AppColors.surface.withOpacity(0.4),
                            side: BorderSide(
                              color: _audioService.currentSound == entry.key
                                  ? AppColors.accentBorder
                                  : AppColors.borderLight,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            showCheckmark: false,
                            onSelected: (_) {
                              setState(() {
                                _audioService.setAmbientSound(entry.key);
                              });
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),

            // Pattern selector
            if (!_isActive && !_isComplete)
              FadeInDown(
                delay: const Duration(milliseconds: 100),
                duration: const Duration(milliseconds: 400),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: breathingPatterns.map((p) {
                      final isSelected = p.name == _pattern.name;
                      return GestureDetector(
                        onTap: () => _selectPattern(p),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.accentTranslucent
                                : AppColors.surface.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.accentBorder
                                  : AppColors.borderLight,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(p.icon, style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.name,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isSelected
                                            ? AppColors.accent
                                            : AppColors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      p.description,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isSelected
                                            ? AppColors.warmGold
                                            : AppColors.textDim,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: AppColors.accent,
                                  size: 18,
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

            // Breathing circle
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Phase label
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _isComplete
                            ? 'Well done'
                            : _isActive
                                ? _currentPhase.label
                                : 'Tap to begin',
                        key: ValueKey(_isComplete
                            ? 'done'
                            : _isActive
                                ? _currentPhase.label
                                : 'ready'),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: _isActive
                                  ? AppColors.textPrimary
                                  : AppColors.textMuted,
                              fontWeight: FontWeight.w300,
                            ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Animated breathing rings
                    GestureDetector(
                      onTap: _isComplete
                          ? () => Navigator.pop(context)
                          : _isActive
                              ? _stopBreathing
                              : _startBreathing,
                      child: SizedBox(
                        width: 220,
                        height: 220,
                        child: CustomPaint(
                          painter: _BreathingRingPainter(
                            scale: scale,
                            phase: _currentPhase.type,
                            isActive: _isActive,
                            isComplete: _isComplete,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Cycle counter
                    if (_isActive)
                      Text(
                        'Cycle ${_currentCycle + 1} of ${_pattern.totalCycles}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textDim,
                          letterSpacing: 1,
                        ),
                      ),
                    if (_isComplete)
                      FadeInUp(
                        duration: const Duration(milliseconds: 500),
                        child: Column(
                          children: [
                            const Text(
                              '🧘',
                              style: TextStyle(fontSize: 32),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Take a moment to notice how you feel',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.textMuted,
                                    fontStyle: FontStyle.italic,
                                  ),
                            ),
                            const SizedBox(height: 24),
                            OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: AppColors.accentBorder),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 12),
                              ),
                              child: const Text(
                                'Back to Check-In',
                                style: TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 14,
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
          ],
        ),
      ),
    );
  }
}

class _BreathingRingPainter extends CustomPainter {
  final double scale;
  final BreathPhaseType phase;
  final bool isActive;
  final bool isComplete;

  _BreathingRingPainter({
    required this.scale,
    required this.phase,
    required this.isActive,
    required this.isComplete,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // Outer glow ring
    final glowRadius = maxRadius * scale;
    final glowPaint = Paint()
      ..color = (isComplete ? const Color(0xFF7BC47F) : AppColors.accent)
          .withOpacity(isActive || isComplete ? 0.08 : 0.04)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawCircle(center, glowRadius + 20, glowPaint);

    // Outer ring
    final outerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = (isComplete ? const Color(0xFF7BC47F) : AppColors.accent)
          .withOpacity(isActive || isComplete ? 0.3 : 0.15);
    canvas.drawCircle(center, glowRadius, outerPaint);

    // Middle ring
    final midRadius = maxRadius * scale * 0.75;
    final midPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = (isComplete ? const Color(0xFF7BC47F) : AppColors.warmGold)
          .withOpacity(isActive || isComplete ? 0.2 : 0.1);
    canvas.drawCircle(center, midRadius, midPaint);

    // Inner filled circle with gradient
    final innerRadius = maxRadius * scale * 0.5;
    final gradient = RadialGradient(
      colors: isComplete
          ? [
              const Color(0xFF7BC47F).withOpacity(0.3),
              const Color(0xFF7BC47F).withOpacity(0.05),
            ]
          : [
              AppColors.accent.withOpacity(isActive ? 0.25 : 0.1),
              AppColors.accent.withOpacity(0.02),
            ],
    );
    final rect = Rect.fromCircle(center: center, radius: innerRadius);
    final innerPaint = Paint()..shader = gradient.createShader(rect);
    canvas.drawCircle(center, innerRadius, innerPaint);

    // Center dot
    final dotPaint = Paint()
      ..color = (isComplete ? const Color(0xFF7BC47F) : AppColors.accent)
          .withOpacity(isActive || isComplete ? 0.6 : 0.3);
    canvas.drawCircle(center, 4, dotPaint);
  }

  @override
  bool shouldRepaint(_BreathingRingPainter oldDelegate) =>
      scale != oldDelegate.scale ||
      phase != oldDelegate.phase ||
      isActive != oldDelegate.isActive ||
      isComplete != oldDelegate.isComplete;
}
