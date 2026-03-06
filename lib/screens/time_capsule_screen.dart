import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:uuid/uuid.dart';
import '../models/mood_entry.dart';
import '../models/time_capsule.dart';
import '../services/ai_service.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class TimeCapsuleScreen extends StatefulWidget {
  final int? currentMood;

  const TimeCapsuleScreen({super.key, this.currentMood});

  @override
  State<TimeCapsuleScreen> createState() => _TimeCapsuleScreenState();
}

class _TimeCapsuleScreenState extends State<TimeCapsuleScreen> {
  final _letterController = TextEditingController();
  CapsuleDuration _selectedDuration = CapsuleDuration.oneMonth;
  bool _isSaving = false;
  bool _showList = true;
  List<TimeCapsule> _capsules = [];
  bool _isLoading = true;

  // For opening a capsule
  TimeCapsule? _openingCapsule;
  bool _showEnvelopeAnimation = false;
  bool _isGeneratingReflection = false;

  @override
  void initState() {
    super.initState();
    _loadCapsules();
    // If navigated from result screen, show compose view
    if (widget.currentMood != null) {
      _showList = false;
    }
  }

  Future<void> _loadCapsules() async {
    final storage = await StorageService.getInstance();
    final capsules = await storage.getCapsules();
    setState(() {
      _capsules = capsules;
      _isLoading = false;
    });
  }

  Future<void> _saveCapsule() async {
    if (_letterController.text.trim().isEmpty || _isSaving) return;

    setState(() => _isSaving = true);

    final now = DateTime.now();
    final capsule = TimeCapsule(
      id: const Uuid().v4(),
      letter: _letterController.text.trim(),
      moodAtCreation: widget.currentMood ?? 3,
      createdAt: now,
      unlocksAt: now.add(_selectedDuration.duration),
    );

    final storage = await StorageService.getInstance();
    await storage.saveCapsule(capsule);

    // Schedule notification
    final notifService = NotificationService();
    await notifService.scheduleCapsuleNotification(
      capsuleId: capsule.id,
      unlocksAt: capsule.unlocksAt,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surface,
        content: Text(
          'Letter sealed! It will unlock ${_selectedDuration.label.toLowerCase()} from now.',
          style: const TextStyle(color: AppColors.warmGold),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    Navigator.pop(context);
  }

  Future<void> _openCapsule(TimeCapsule capsule) async {
    if (!capsule.isUnlocked) return;

    setState(() {
      _openingCapsule = capsule;
      _showEnvelopeAnimation = true;
    });

    // Show animation for 2 seconds, then generate reflection
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    setState(() {
      _showEnvelopeAnimation = false;
      _isGeneratingReflection = true;
    });

    // Get current mood from latest entry
    final storage = await StorageService.getInstance();
    final entries = await storage.getEntries();
    final currentMood = entries.isNotEmpty ? entries.last.mood : 3;

    final reflection = await AiService.getTimeCapsuleReflection(
      originalLetter: capsule.letter,
      moodAtCreation: capsule.moodAtCreation,
      currentMood: currentMood,
      createdAt: capsule.createdAt,
      recentEntries: entries.reversed.take(5).toList(),
    );

    final updatedCapsule = capsule.copyWith(
      isOpened: true,
      aiReflection: reflection,
    );
    await storage.updateCapsule(updatedCapsule);

    if (!mounted) return;
    setState(() {
      _isGeneratingReflection = false;
      _openingCapsule = updatedCapsule;
      _loadCapsules();
    });
  }

  @override
  void dispose() {
    _letterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
                    onPressed: () {
                      if (_openingCapsule != null) {
                        setState(() => _openingCapsule = null);
                      } else if (!_showList && widget.currentMood == null) {
                        setState(() => _showList = true);
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Time Capsules',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                    ),
                  ),
                  if (_showList && _openingCapsule == null)
                    IconButton(
                      onPressed: () => setState(() => _showList = false),
                      icon: const Icon(
                        Icons.add,
                        color: AppColors.accent,
                        size: 22,
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: _openingCapsule != null
                  ? _buildOpenedCapsule(context)
                  : _showList
                      ? _buildCapsuleList(context)
                      : _buildComposeView(context),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildCapsuleList(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    if (_capsules.isEmpty) {
      return Center(
        child: FadeIn(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('💌', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(
                'No time capsules yet.\nWrite a letter to your future self!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                      height: 1.6,
                    ),
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => setState(() => _showList = false),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.accentBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                ),
                child: const Text(
                  'Write a Letter',
                  style: TextStyle(color: AppColors.accent),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final dateFormat = DateFormat('MMM d, yyyy');

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: kIsWeb ? 480 : double.infinity),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          itemCount: _capsules.length,
          itemBuilder: (ctx, idx) {
        final capsule = _capsules[idx];
        final mood =
            moodOptions.firstWhere((m) => m.value == capsule.moodAtCreation);

        return FadeInUp(
          delay: Duration(milliseconds: 50 * idx),
          duration: const Duration(milliseconds: 400),
          child: GestureDetector(
            onTap: capsule.isUnlocked ? () => _openCapsule(capsule) : null,
            child: GlassCard(
              color: capsule.isUnlocked
                  ? AppColors.accentTranslucent
                  : AppColors.surface.withOpacity(0.4),
              borderColor: capsule.isUnlocked
                  ? AppColors.accentBorder
                  : AppColors.borderLight,
              padding: const EdgeInsets.all(18),
              margin: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Text(
                    capsule.isOpened
                        ? '📖'
                        : capsule.isUnlocked
                            ? '💌'
                            : '🔒',
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          capsule.isOpened
                              ? 'Opened'
                              : capsule.isUnlocked
                                  ? 'Ready to open!'
                                  : capsule.timeRemainingLabel,
                          style: TextStyle(
                            fontSize: 14,
                            color: capsule.isUnlocked
                                ? AppColors.accent
                                : AppColors.textSecondary,
                            fontWeight: capsule.isUnlocked
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Written ${dateFormat.format(capsule.createdAt)} · ${mood.emoji}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textDim,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (capsule.isUnlocked && !capsule.isOpened)
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.accent,
                      size: 14,
                    ),
                ],
              ),
            ),
          ),
        );
      },
        ),
      ),
    );
  }

  Widget _buildComposeView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: kIsWeb ? 480 : double.infinity),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                duration: const Duration(milliseconds: 400),
                child: Text(
                  'Dear Future Me...',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppColors.warmGold,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          FadeInDown(
            delay: const Duration(milliseconds: 100),
            duration: const Duration(milliseconds: 400),
            child: Text(
              'Write something your future self needs to hear.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textDim,
                  ),
            ),
          ),
          const SizedBox(height: 24),

          // Letter text area
          FadeInDown(
            delay: const Duration(milliseconds: 200),
            duration: const Duration(milliseconds: 400),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: TextField(
                controller: _letterController,
                maxLines: 8,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.8,
                    ),
                decoration: InputDecoration(
                  hintText:
                      'Tell your future self what you\'re feeling, what you hope for, or what you want to remember...',
                  hintStyle: TextStyle(
                    color: AppColors.textDim,
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                  ),
                  contentPadding: const EdgeInsets.all(20),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Duration selector
          FadeInDown(
            delay: const Duration(milliseconds: 300),
            duration: const Duration(milliseconds: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OPEN IN',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 10),
                Row(
                  children: CapsuleDuration.values.map((d) {
                    final isSelected = d == _selectedDuration;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selectedDuration = d),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.accentTranslucent
                                : AppColors.surface.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.accentBorder
                                  : AppColors.borderLight,
                            ),
                          ),
                          child: Text(
                            d.label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: isSelected
                                  ? AppColors.accent
                                  : AppColors.textMuted,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Seal button
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            duration: const Duration(milliseconds: 400),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _letterController.text.trim().isNotEmpty
                    ? _saveCapsule
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.background,
                  disabledBackgroundColor: AppColors.surface,
                  disabledForegroundColor: AppColors.textDim,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  shadowColor: AppColors.accent.withOpacity(0.3),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.background,
                        ),
                      )
                    : const Text(
                        'Seal the Letter',
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
        ],
      ),
        ),
      ),
    );
  }

  Widget _buildOpenedCapsule(BuildContext context) {
    final capsule = _openingCapsule!;
    final dateFormat = DateFormat('MMM d, yyyy');
    final mood =
        moodOptions.firstWhere((m) => m.value == capsule.moodAtCreation);

    if (_showEnvelopeAnimation) {
      return Center(
        child: FadeIn(
          duration: const Duration(milliseconds: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: Lottie.asset(
                  'assets/envelope_open.json',
                  repeat: false,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Opening your time capsule...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.warmGold,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    if (_isGeneratingReflection) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.accent),
            const SizedBox(height: 16),
            Text(
              'Reflecting on your journey...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: kIsWeb ? 480 : double.infinity),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date info
              FadeInDown(
            duration: const Duration(milliseconds: 400),
            child: Row(
              children: [
                Text(mood.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Written ${dateFormat.format(capsule.createdAt)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'Feeling ${mood.label} at the time',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textDim,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // The letter
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            duration: const Duration(milliseconds: 500),
            child: GlassCard(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0x14D4A574),
                  Color(0x0FE8945A),
                ],
              ),
              borderColor: const Color(0x26D4A574),
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💌 YOUR LETTER',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.warmGold,
                        ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    capsule.letter,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textPrimary,
                          fontStyle: FontStyle.italic,
                          height: 1.8,
                        ),
                  ),
                ],
              ),
            ),
          ),

          // AI reflection
          if (capsule.aiReflection != null && capsule.aiReflection!.isNotEmpty)
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              duration: const Duration(milliseconds: 500),
              child: GlassCard(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0x14E8945A),
                    Color(0x0FD4A574),
                  ],
                ),
                borderColor: const Color(0x26E8945A),
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '✨ THEN VS NOW',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.accent,
                          ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      capsule.aiReflection!,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.7,
                          ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 40),
        ],
      ),
        ),
      ),
    );
  }
}
