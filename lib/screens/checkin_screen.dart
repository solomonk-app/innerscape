import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:uuid/uuid.dart';
import '../models/mood_entry.dart';
import '../models/tag_definitions.dart';
import '../constants/bible_verses.dart';
import '../services/ai_service.dart';
import '../services/bible_verse_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../services/analytics_service.dart';
import 'result_screen.dart';
import 'breathwork_screen.dart';

class CheckInScreen extends StatefulWidget {
  final VoidCallback onEntryAdded;

  const CheckInScreen({super.key, required this.onEntryAdded});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  int? _selectedMood;
  final _textController = TextEditingController();
  final _customTagController = TextEditingController();
  bool _isSubmitting = false;
  late String _dailyPrompt;
  bool _hasCheckedInToday = false;
  final Set<String> _selectedTags = {};
  final Map<String, List<String>> _customTags = {};
  String? _addingTagForCategory;

  @override
  void initState() {
    super.initState();
    _dailyPrompt = (dailyPrompts..shuffle()).first;
    _checkTodayEntry();
  }

  Future<void> _checkTodayEntry() async {
    final storage = await StorageService.getInstance();
    final entries = await storage.getEntries();
    final today = DateTime.now();
    setState(() {
      _hasCheckedInToday = entries.any((e) =>
          e.timestamp.year == today.year &&
          e.timestamp.month == today.month &&
          e.timestamp.day == today.day);
    });
  }

  Future<void> _submit() async {
    if (_selectedMood == null || _isSubmitting) return;
    setState(() => _isSubmitting = true);

    final entry = MoodEntry(
      id: const Uuid().v4(),
      mood: _selectedMood!,
      text: _textController.text.trim(),
      timestamp: DateTime.now(),
      tags: _selectedTags.toList(),
    );

    AnalyticsService().logCheckInSubmitted(
      mood: _selectedMood!,
      tagCount: _selectedTags.length,
      hasJournalText: _textController.text.trim().isNotEmpty,
    );

    final storage = await StorageService.getInstance();
    final entries = await storage.getEntries();

    // Get AI insight and Bible verse in parallel
    final results = await Future.wait([
      AiService.getInsight(
        currentEntry: entry,
        recentEntries: entries.reversed.toList(),
      ),
      BibleVerseService().getVerse(_selectedMood!),
    ]);
    final insight = results[0] as String;
    final bibleVerse = results[1] as BibleVerse;

    final updatedEntry = entry.copyWith(aiInsight: insight);
    await storage.saveEntry(updatedEntry);

    final wellnessTip = WellnessTips.getTip(_selectedMood!);

    widget.onEntryAdded();

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ResultScreen(
          entry: updatedEntry,
          wellnessTip: wellnessTip,
          bibleVerse: bibleVerse,
          onNewCheckIn: () {
            Navigator.of(context).pop();
            setState(() {
              _selectedMood = null;
              _textController.clear();
              _selectedTags.clear();
              _customTags.clear();
              _hasCheckedInToday = true;
            });
          },
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _confirmCustomTag() {
    final tag = _customTagController.text.trim();
    final category = _addingTagForCategory;
    if (tag.isNotEmpty && !_selectedTags.contains(tag) && category != null) {
      setState(() {
        _selectedTags.add(tag);
        _customTags.putIfAbsent(category, () => []).add(tag);
      });
    }
    _customTagController.clear();
    setState(() => _addingTagForCategory = null);
  }

  @override
  void dispose() {
    _textController.dispose();
    _customTagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: kIsWeb ? 480 : double.infinity),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // Today already checked in notice
          if (_hasCheckedInToday)
            FadeInDown(
              duration: const Duration(milliseconds: 400),
              child: GlassCard(
                color: AppColors.accentTranslucent,
                borderColor: AppColors.accentBorder,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                child: Text(
                  '✓ You already checked in today — but you can add another entry anytime.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.warmGold,
                        fontSize: 13,
                      ),
                ),
              ),
            ),

          // "Need a moment?" breathwork card — shows when mood is low (1-3)
          if (_selectedMood != null && _selectedMood! <= 3)
            FadeInDown(
              duration: const Duration(milliseconds: 400),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => BreathworkScreen(
                        suggestedMood: _selectedMood!,
                      ),
                      transitionsBuilder: (_, anim, __, child) =>
                          FadeTransition(opacity: anim, child: child),
                      transitionDuration: const Duration(milliseconds: 400),
                    ),
                  );
                },
                child: GlassCard(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0x1A7B9ECF),
                      Color(0x14A78BCA),
                    ],
                  ),
                  borderColor: const Color(0x337B9ECF),
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    children: [
                      const Text('🫧', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Need a moment?',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: const Color(0xFFB8CCE5),
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Try a guided breathing exercise',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: const Color(0xFF8BA5C4),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFF8BA5C4),
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Daily prompt
          FadeInDown(
            duration: const Duration(milliseconds: 500),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _dailyPrompt,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: AppColors.textSecondary,
                      ),
                ),
              ),
            ),
          ),

          // Mood section label
          FadeInDown(
            delay: const Duration(milliseconds: 100),
            duration: const Duration(milliseconds: 500),
            child: Text(
              'HOW ARE YOU FEELING?',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          const SizedBox(height: 16),

          // Mood selector
          FadeInDown(
            delay: const Duration(milliseconds: 200),
            duration: const Duration(milliseconds: 500),
            child: Row(
              children: moodOptions.map((mood) {
                final isSelected = _selectedMood == mood.value;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedMood = mood.value),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accentTranslucent
                            : AppColors.surface.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.accentBorder
                              : AppColors.borderLight,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.accent.withOpacity(0.15),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                )
                              ]
                            : [],
                      ),
                      transform: isSelected
                          ? Matrix4.translationValues(0, -4, 0)
                          : Matrix4.identity(),
                      child: Column(
                        children: [
                          Text(mood.emoji,
                              style: const TextStyle(fontSize: 26)),
                          const SizedBox(height: 6),
                          Text(
                            mood.label,
                            style: TextStyle(
                              fontSize: 10,
                              color: isSelected
                                  ? AppColors.accent
                                  : AppColors.textMuted,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 28),

          // Tag selector
          FadeInDown(
            delay: const Duration(milliseconds: 250),
            duration: const Duration(milliseconds: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.labelSmall,
                    children: const [
                      TextSpan(text: 'WHAT\'S THE CONTEXT? '),
                      TextSpan(
                        text: '(OPTIONAL)',
                        style: TextStyle(color: AppColors.textDim),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ...tagCategories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${category.icon} ${category.name}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textDim,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            ...category.tags.map((tag) {
                              final isSelected = _selectedTags.contains(tag);
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedTags.remove(tag);
                                    } else {
                                      _selectedTags.add(tag);
                                    }
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.accentTranslucent
                                        : AppColors.surface.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.accentBorder
                                          : AppColors.borderLight,
                                    ),
                                  ),
                                  child: Text(
                                    tag,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isSelected
                                          ? AppColors.accent
                                          : AppColors.textMuted,
                                    ),
                                  ),
                                ),
                              );
                            }),
                            ...(_customTags[category.name] ?? []).map((tag) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedTags.remove(tag);
                                    _customTags[category.name]?.remove(tag);
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentTranslucent,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: AppColors.accentBorder),
                                  ),
                                  child: Text(
                                    tag,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ),
                              );
                            }),
                            if (_addingTagForCategory == category.name)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 130,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: AppColors.surface.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: AppColors.accentBorder),
                                    ),
                                    padding: const EdgeInsets.only(
                                        left: 12, right: 4),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: _customTagController,
                                            autofocus: true,
                                            textInputAction:
                                                TextInputAction.done,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textPrimary),
                                            decoration: const InputDecoration(
                                              hintText: 'Add tag...',
                                              hintStyle: TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.textDim),
                                              border: InputBorder.none,
                                              isDense: true,
                                              contentPadding: EdgeInsets.zero,
                                            ),
                                            onSubmitted: (_) =>
                                                _confirmCustomTag(),
                                            onEditingComplete:
                                                _confirmCustomTag,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: _confirmCustomTag,
                                          child: const Icon(Icons.check,
                                              size: 16,
                                              color: AppColors.accent),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () {
                                      _customTagController.clear();
                                      setState(() =>
                                          _addingTagForCategory = null);
                                    },
                                    child: const Icon(Icons.close,
                                        size: 18, color: AppColors.textDim),
                                  ),
                                ],
                              )
                            else
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _addingTagForCategory = category.name;
                                    _customTagController.clear();
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: AppColors.borderLight),
                                  ),
                                  child: const Icon(Icons.add,
                                      size: 14, color: AppColors.textDim),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Journal label
          FadeInDown(
            delay: const Duration(milliseconds: 300),
            duration: const Duration(milliseconds: 500),
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.labelSmall,
                children: const [
                  TextSpan(text: 'JOURNAL ENTRY '),
                  TextSpan(
                    text: '(OPTIONAL)',
                    style: TextStyle(color: AppColors.textDim),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Text area
          FadeInDown(
            delay: const Duration(milliseconds: 400),
            duration: const Duration(milliseconds: 500),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: TextField(
                controller: _textController,
                maxLines: 6,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Write whatever comes to mind...',
                  hintStyle: TextStyle(
                    color: AppColors.textDim,
                    fontStyle: FontStyle.italic,
                  ),
                  contentPadding: const EdgeInsets.all(20),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Submit button
          FadeInUp(
            delay: const Duration(milliseconds: 500),
            duration: const Duration(milliseconds: 500),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _selectedMood != null ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedMood != null
                      ? AppColors.accent
                      : AppColors.surface,
                  foregroundColor: _selectedMood != null
                      ? AppColors.background
                      : AppColors.textDim,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: _selectedMood != null ? 8 : 0,
                  shadowColor: AppColors.accent.withOpacity(0.3),
                ),
                child: _isSubmitting
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.background,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Reflecting...'),
                        ],
                      )
                    : const Text(
                        'Save & Get AI Insight',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 40),

          // Privacy & Terms links
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pushNamed('/privacy'),
                  child: const Text(
                    'Privacy Policy',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textDim,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.textDim,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    '·',
                    style: TextStyle(color: AppColors.textDim, fontSize: 11),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pushNamed('/terms'),
                  child: const Text(
                    'Terms of Service',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textDim,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.textDim,
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
    ),
    );
  }
}
