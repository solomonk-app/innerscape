import 'package:flutter/material.dart';
import '../constants/journal_ideas.dart';
import '../models/prompt_completion.dart';
import '../services/analytics_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/prompt_sheet.dart';

class JournalIdeasScreen extends StatefulWidget {
  const JournalIdeasScreen({super.key});

  @override
  State<JournalIdeasScreen> createState() => _JournalIdeasScreenState();
}

class _JournalIdeasScreenState extends State<JournalIdeasScreen> {
  JournalCategory? _selectedCategory;
  Set<String> _completedKeys = {};

  @override
  void initState() {
    super.initState();
    AnalyticsService().logScreenView('journal_ideas');
    _loadCompletions();
  }

  Future<void> _loadCompletions() async {
    final storage = await StorageService.getInstance();
    final completions = await storage.getPromptCompletions();
    if (!mounted) return;
    setState(() {
      _completedKeys = completions
          .where((c) => c.source == PromptSource.idea)
          .map((c) => c.promptKey)
          .toSet();
    });
  }

  List<JournalIdea> get _visibleIdeas {
    if (_selectedCategory == null) return journalIdeas;
    return ideasByCategory(_selectedCategory!);
  }

  String _promptKey(JournalIdea idea) => 'idea:${idea.id}';

  void _openIdea(JournalIdea idea) {
    PromptSheet.show(
      context: context,
      title: idea.title,
      prompt: idea.prompt,
      topics: idea.topics,
      promptKey: _promptKey(idea),
      source: PromptSource.idea,
      onCompleted: (completion) {
        AnalyticsService().logJournalIdeaCompleted(
          ideaId: idea.id,
          writtenInApp: completion.writtenInApp,
        );
        _loadCompletions();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Journal Ideas',
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

            // Subtitle
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 4, 24, 16),
              child: Text(
                'Pick a prompt. Write it in your notebook — or in-app.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textDim,
                  fontSize: 12,
                ),
              ),
            ),

            // Category filter chips
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _CategoryChip(
                    label: 'All',
                    emoji: '\u{2728}',
                    isActive: _selectedCategory == null,
                    onTap: () => setState(() => _selectedCategory = null),
                  ),
                  for (final cat in JournalCategory.values)
                    _CategoryChip(
                      label: journalCategoryLabel(cat),
                      emoji: journalCategoryEmoji(cat),
                      isActive: _selectedCategory == cat,
                      onTap: () => setState(() => _selectedCategory = cat),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Idea list
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                itemCount: _visibleIdeas.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) {
                  final idea = _visibleIdeas[i];
                  final completed = _completedKeys.contains(_promptKey(idea));
                  return _IdeaCard(
                    idea: idea,
                    completed: completed,
                    onTap: () => _openIdea(idea),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final String emoji;
  final bool isActive;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.emoji,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Semantics(
        button: true,
        selected: isActive,
        label: label,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.accentTranslucent
                  : AppColors.surface.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isActive
                    ? AppColors.accentBorder
                    : AppColors.borderLight,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isActive
                        ? AppColors.accent
                        : AppColors.textMuted,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IdeaCard extends StatelessWidget {
  final JournalIdea idea;
  final bool completed;
  final VoidCallback onTap;

  const _IdeaCard({
    required this.idea,
    required this.completed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label:
          '${idea.title}. ${idea.prompt}. ${completed ? "Completed." : "Tap to start."}',
      child: GestureDetector(
        onTap: onTap,
        child: GlassCard(
          color: AppColors.surface.withOpacity(0.5),
          borderColor: completed
              ? AppColors.accentBorder
              : AppColors.borderLight,
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                journalCategoryEmoji(idea.category),
                style: const TextStyle(fontSize: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            idea.title,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (completed)
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.accent,
                            size: 16,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      idea.prompt,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '~${idea.estMinutes} min',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 10,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            journalCategoryLabel(idea.category),
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 10,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
