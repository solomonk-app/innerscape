class BreathingPattern {
  final String name;
  final String description;
  final String icon;
  final int inhaleSeconds;
  final int holdAfterInhaleSeconds;
  final int exhaleSeconds;
  final int holdAfterExhaleSeconds;
  final int totalCycles;

  const BreathingPattern({
    required this.name,
    required this.description,
    required this.icon,
    required this.inhaleSeconds,
    required this.holdAfterInhaleSeconds,
    required this.exhaleSeconds,
    required this.holdAfterExhaleSeconds,
    this.totalCycles = 4,
  });

  int get cycleDurationSeconds =>
      inhaleSeconds + holdAfterInhaleSeconds + exhaleSeconds + holdAfterExhaleSeconds;

  /// Returns the phase label and progress within that phase for a given elapsed time
  BreathPhase getPhase(double elapsedInCycle) {
    double t = elapsedInCycle % cycleDurationSeconds;
    if (t < inhaleSeconds) {
      return BreathPhase(
        label: 'Inhale',
        progress: t / inhaleSeconds,
        type: BreathPhaseType.inhale,
      );
    }
    t -= inhaleSeconds;
    if (holdAfterInhaleSeconds > 0 && t < holdAfterInhaleSeconds) {
      return BreathPhase(
        label: 'Hold',
        progress: t / holdAfterInhaleSeconds,
        type: BreathPhaseType.holdIn,
      );
    }
    t -= holdAfterInhaleSeconds;
    if (t < exhaleSeconds) {
      return BreathPhase(
        label: 'Exhale',
        progress: t / exhaleSeconds,
        type: BreathPhaseType.exhale,
      );
    }
    t -= exhaleSeconds;
    return BreathPhase(
      label: 'Hold',
      progress: holdAfterExhaleSeconds > 0 ? t / holdAfterExhaleSeconds : 0,
      type: BreathPhaseType.holdOut,
    );
  }
}

enum BreathPhaseType { inhale, holdIn, exhale, holdOut }

class BreathPhase {
  final String label;
  final double progress; // 0.0 to 1.0 within this phase
  final BreathPhaseType type;

  const BreathPhase({
    required this.label,
    required this.progress,
    required this.type,
  });
}

const List<BreathingPattern> breathingPatterns = [
  BreathingPattern(
    name: 'Box Breathing',
    description: 'Calming focus — equal parts in, hold, out, hold',
    icon: '🔲',
    inhaleSeconds: 4,
    holdAfterInhaleSeconds: 4,
    exhaleSeconds: 4,
    holdAfterExhaleSeconds: 4,
    totalCycles: 4,
  ),
  BreathingPattern(
    name: '4-7-8 Relaxation',
    description: 'Deep calm — long exhale activates your rest response',
    icon: '🌊',
    inhaleSeconds: 4,
    holdAfterInhaleSeconds: 7,
    exhaleSeconds: 8,
    holdAfterExhaleSeconds: 0,
    totalCycles: 4,
  ),
  BreathingPattern(
    name: 'Energizing Breath',
    description: 'Quick boost — rhythmic breathing for low energy',
    icon: '⚡',
    inhaleSeconds: 3,
    holdAfterInhaleSeconds: 0,
    exhaleSeconds: 3,
    holdAfterExhaleSeconds: 0,
    totalCycles: 6,
  ),
];

/// Auto-suggest a pattern based on mood value
BreathingPattern suggestPattern(int mood) {
  if (mood <= 1) return breathingPatterns[1]; // 4-7-8 for very low
  if (mood <= 2) return breathingPatterns[0]; // Box for low
  return breathingPatterns[2]; // Energizing for meh
}
