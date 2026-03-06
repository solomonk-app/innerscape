import 'dart:math';
import 'package:flutter/material.dart';
import '../services/atmosphere_service.dart';

class AmbientParticles extends StatefulWidget {
  final AtmosphereMode mode;

  const AmbientParticles({super.key, required this.mode});

  @override
  State<AmbientParticles> createState() => _AmbientParticlesState();
}

class _AmbientParticlesState extends State<AmbientParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _particles = List.generate(25, (_) => _createParticle());
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void didUpdateWidget(AmbientParticles oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mode != widget.mode) {
      // Regenerate particles for new mode
      _particles = List.generate(25, (_) => _createParticle());
    }
  }

  _Particle _createParticle() {
    return _Particle(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      size: 2 + _random.nextDouble() * 3, // 2-5px
      opacity: 0.08 + _random.nextDouble() * 0.17, // 8-25%
      speedX: (_random.nextDouble() - 0.5) * 0.0003,
      speedY: _getVerticalSpeed(),
      phase: _random.nextDouble() * pi * 2,
    );
  }

  double _getVerticalSpeed() {
    switch (widget.mode) {
      case AtmosphereMode.warm:
        return -0.0002 - _random.nextDouble() * 0.0003; // Drift up (fireflies)
      case AtmosphereMode.cool:
        return 0.0002 + _random.nextDouble() * 0.0003; // Drift down (rain)
      case AtmosphereMode.neutral:
        return (_random.nextDouble() - 0.5) * 0.0001; // Gentle orbit
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          // Update particle positions
          for (final p in _particles) {
            p.x += p.speedX;
            p.y += p.speedY;

            // Subtle sine wave for organic movement
            p.x += sin(p.phase + _controller.value * pi * 2) * 0.0002;

            // Wrap around
            if (p.x < -0.05) p.x = 1.05;
            if (p.x > 1.05) p.x = -0.05;
            if (p.y < -0.05) {
              p.y = 1.05;
              p.x = _random.nextDouble();
            }
            if (p.y > 1.05) {
              p.y = -0.05;
              p.x = _random.nextDouble();
            }
          }

          return CustomPaint(
            painter: _ParticlePainter(
              particles: _particles,
              color: AtmosphereService.getParticleColor(widget.mode),
              glowColor: AtmosphereService.getGlowColor(widget.mode),
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _Particle {
  double x; // 0-1 normalized
  double y; // 0-1 normalized
  double size;
  double opacity;
  double speedX;
  double speedY;
  double phase;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.speedX,
    required this.speedY,
    required this.phase,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final Color color;
  final Color glowColor;

  _ParticlePainter({
    required this.particles,
    required this.color,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final pos = Offset(p.x * size.width, p.y * size.height);

      // Soft bokeh glow
      final glowPaint = Paint()
        ..color = glowColor.withOpacity(p.opacity * 0.3)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.size * 3);
      canvas.drawCircle(pos, p.size * 2, glowPaint);

      // Core particle
      final paint = Paint()..color = color.withOpacity(p.opacity);
      canvas.drawCircle(pos, p.size, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) => true; // Always repaint (animated)
}
