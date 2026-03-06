import 'package:flutter/material.dart';
import '../models/mood_entry.dart';

enum AtmosphereMode { warm, cool, neutral }

class AtmosphereService {
  /// Calculate the 7-day weighted average mood and return atmosphere mode
  static AtmosphereMode getMode(List<MoodEntry> entries) {
    if (entries.isEmpty) return AtmosphereMode.neutral;

    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final recentEntries =
        entries.where((e) => e.timestamp.isAfter(sevenDaysAgo)).toList();

    if (recentEntries.isEmpty) return AtmosphereMode.neutral;

    // Weighted: more recent entries count more
    double totalWeight = 0;
    double weightedSum = 0;
    for (final entry in recentEntries) {
      final daysAgo = now.difference(entry.timestamp).inHours / 24.0;
      final weight = 1.0 - (daysAgo / 7.0) * 0.5; // 1.0 for today, 0.5 for 7d ago
      weightedSum += entry.mood * weight;
      totalWeight += weight;
    }

    final weightedAvg = weightedSum / totalWeight;

    if (weightedAvg >= 4.0) return AtmosphereMode.warm;
    if (weightedAvg <= 2.5) return AtmosphereMode.cool;
    return AtmosphereMode.neutral;
  }

  static Color getParticleColor(AtmosphereMode mode) {
    switch (mode) {
      case AtmosphereMode.warm:
        return const Color(0xFFE8945A); // Golden orange
      case AtmosphereMode.cool:
        return const Color(0xFF7B9ECF); // Blue lavender
      case AtmosphereMode.neutral:
        return const Color(0xFFC4B8A5); // Warm muted
    }
  }

  static Color getGlowColor(AtmosphereMode mode) {
    switch (mode) {
      case AtmosphereMode.warm:
        return const Color(0xFFD4A574); // Warm gold
      case AtmosphereMode.cool:
        return const Color(0xFFA78BCA); // Lavender
      case AtmosphereMode.neutral:
        return const Color(0xFF8B7E74); // Muted brown
    }
  }
}
