import 'package:flutter/material.dart';
import '../models/daily_challenge.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

class ChallengeCard extends StatelessWidget {
  final DailyChallenge challenge;
  final void Function(String? reflection) onComplete;

  const ChallengeCard({
    super.key,
    required this.challenge,
    required this.onComplete,
  });

  void _showCompletionSheet(BuildContext context) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          24 + MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How did it go?',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Optional \u2014 share a quick reflection',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textDim,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.background.withOpacity(0.5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: TextField(
                controller: controller,
                maxLines: 3,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
                decoration: const InputDecoration(
                  hintText: 'What did you notice?',
                  hintStyle: TextStyle(color: AppColors.textDim, fontSize: 14),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  onComplete(
                    controller.text.trim().isEmpty ? null : controller.text.trim(),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7BC47F),
                  foregroundColor: AppColors.background,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Complete Challenge',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: challenge.isCompleted
          ? 'Challenge completed: ${challenge.title}'
          : 'Daily challenge: ${challenge.title}. ${challenge.description}',
      child: GlassCard(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: challenge.isCompleted
              ? [
                  const Color(0x1A7BC47F),
                  const Color(0x147BC47F),
                ]
              : [
                  const Color(0x1A7BC47F),
                  const Color(0x14A5C9A0),
                ],
        ),
        borderColor: challenge.isCompleted
            ? const Color(0x407BC47F)
            : const Color(0x267BC47F),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(
              challenge.emoji,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DAILY CHALLENGE',
                    style: TextStyle(
                      fontSize: 9,
                      color: const Color(0xFFA5C9A0),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    challenge.title,
                    style: TextStyle(
                      fontSize: 14,
                      color: challenge.isCompleted
                          ? const Color(0xFF7BC47F)
                          : const Color(0xFFA5C9A0),
                      fontWeight: FontWeight.w600,
                      decoration: challenge.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    challenge.isCompleted ? 'Completed!' : challenge.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: challenge.isCompleted
                          ? const Color(0xFF7BC47F).withOpacity(0.7)
                          : AppColors.textDim,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (!challenge.isCompleted)
              GestureDetector(
                onTap: () => _showCompletionSheet(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF7BC47F).withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Color(0xFF7BC47F),
                    size: 18,
                  ),
                ),
              )
            else
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF7BC47F),
                ),
                child: const Icon(
                  Icons.check,
                  color: AppColors.background,
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
