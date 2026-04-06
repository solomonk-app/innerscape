import 'dart:math';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../models/achievement.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

class AchievementCelebration extends StatefulWidget {
  final List<AchievementDefinition> achievements;
  final VoidCallback onDismiss;

  const AchievementCelebration({
    super.key,
    required this.achievements,
    required this.onDismiss,
  });

  @override
  State<AchievementCelebration> createState() => _AchievementCelebrationState();
}

class _AchievementCelebrationState extends State<AchievementCelebration>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _confettiController;
  late List<_ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );
    _generateParticles();
    _confettiController.forward();
    _confettiController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _advance();
      }
    });
  }

  void _generateParticles() {
    final rng = Random();
    final tier = widget.achievements[_currentIndex].tier;
    final colors = _tierColors(tier);
    _particles = List.generate(40, (_) {
      return _ConfettiParticle(
        x: rng.nextDouble(),
        speed: 0.3 + rng.nextDouble() * 0.7,
        size: 3.0 + rng.nextDouble() * 5.0,
        color: colors[rng.nextInt(colors.length)],
        drift: (rng.nextDouble() - 0.5) * 0.3,
      );
    });
  }

  List<Color> _tierColors(AchievementTier tier) {
    switch (tier) {
      case AchievementTier.bronze:
        return [
          const Color(0xFFC4A882),
          const Color(0xFFD4B896),
          const Color(0xFFE8945A),
        ];
      case AchievementTier.silver:
        return [
          const Color(0xFFC0C0C0),
          const Color(0xFFD8D8D8),
          const Color(0xFFA0A0A0),
        ];
      case AchievementTier.gold:
        return [
          const Color(0xFFFFD700),
          const Color(0xFFFFC107),
          const Color(0xFFFF9800),
        ];
    }
  }

  Color _tierAccent(AchievementTier tier) {
    switch (tier) {
      case AchievementTier.bronze:
        return const Color(0xFFC4A882);
      case AchievementTier.silver:
        return const Color(0xFFC0C0C0);
      case AchievementTier.gold:
        return const Color(0xFFFFD700);
    }
  }

  void _advance() {
    if (_currentIndex < widget.achievements.length - 1) {
      setState(() {
        _currentIndex++;
        _generateParticles();
      });
      _confettiController.forward(from: 0);
    } else {
      widget.onDismiss();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final achievement = widget.achievements[_currentIndex];
    final accent = _tierAccent(achievement.tier);

    return GestureDetector(
      onTap: _advance,
      child: Container(
        color: AppColors.background.withOpacity(0.85),
        child: Stack(
          children: [
            // Confetti
            AnimatedBuilder(
              animation: _confettiController,
              builder: (context, _) {
                return CustomPaint(
                  size: MediaQuery.of(context).size,
                  painter: _ConfettiPainter(
                    particles: _particles,
                    progress: _confettiController.value,
                  ),
                );
              },
            ),

            // Achievement card
            Center(
              child: FadeInUp(
                duration: const Duration(milliseconds: 500),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: GlassCard(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accent.withOpacity(0.15),
                        accent.withOpacity(0.05),
                      ],
                    ),
                    borderColor: accent.withOpacity(0.4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 36),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          achievement.emoji,
                          style: const TextStyle(fontSize: 56),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'ACHIEVEMENT UNLOCKED',
                          style: TextStyle(
                            fontSize: 10,
                            color: accent,
                            letterSpacing: 2.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          achievement.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          achievement.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Tap to continue',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textDim,
                          ),
                        ),
                      ],
                    ),
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

class _ConfettiParticle {
  final double x;
  final double speed;
  final double size;
  final Color color;
  final double drift;

  _ConfettiParticle({
    required this.x,
    required this.speed,
    required this.size,
    required this.color,
    required this.drift,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final y = -20 + (size.height + 40) * progress * p.speed;
      final x = p.x * size.width + sin(progress * pi * 4 + p.x * 10) * 20 * p.drift;
      final opacity = (1.0 - progress).clamp(0.0, 1.0);
      final paint = Paint()..color = p.color.withOpacity(opacity * 0.8);
      canvas.drawCircle(Offset(x, y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => progress != old.progress;
}
