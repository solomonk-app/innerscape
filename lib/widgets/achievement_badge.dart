import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

class AchievementBadge extends StatelessWidget {
  final AchievementDefinition definition;
  final EarnedAchievement? earned;
  final double progress;

  const AchievementBadge({
    super.key,
    required this.definition,
    this.earned,
    this.progress = 0.0,
  });

  bool get isEarned => earned != null;

  Color get _tierColor {
    switch (definition.tier) {
      case AchievementTier.bronze:
        return const Color(0xFFC4A882);
      case AchievementTier.silver:
        return const Color(0xFFC0C0C0);
      case AchievementTier.gold:
        return const Color(0xFFFFD700);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isEarned ? 1.0 : 0.4,
      child: GlassCard(
        borderColor: isEarned ? _tierColor.withOpacity(0.4) : AppColors.borderLight,
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  definition.emoji,
                  style: const TextStyle(fontSize: 32),
                ),
                if (!isEarned)
                  const Icon(
                    Icons.lock_outline,
                    color: AppColors.textDim,
                    size: 16,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              definition.title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: isEarned ? _tierColor : AppColors.textDim,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              definition.description,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textDim,
              ),
            ),
            if (!isEarned && progress > 0) ...[
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: SizedBox(
                  height: 3,
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.borderLight,
                    valueColor: AlwaysStoppedAnimation(_tierColor.withOpacity(0.5)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
