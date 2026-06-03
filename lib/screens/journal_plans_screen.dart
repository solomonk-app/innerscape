import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../constants/journal_plans.dart';
import '../models/journal_plan.dart';
import '../services/analytics_service.dart';
import '../services/journal_plan_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import 'journal_plan_detail_screen.dart';

class JournalPlansScreen extends StatefulWidget {
  const JournalPlansScreen({super.key});

  @override
  State<JournalPlansScreen> createState() => _JournalPlansScreenState();
}

class _JournalPlansScreenState extends State<JournalPlansScreen> {
  List<JournalPlanProgress> _active = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    AnalyticsService().logScreenView('journal_plans');
    _load();
  }

  Future<void> _load() async {
    final active = await JournalPlanService().getActive();
    if (!mounted) return;
    setState(() {
      _active = active;
      _loading = false;
    });
  }

  Set<String> get _activeIds => _active.map((p) => p.planId).toSet();

  List<JournalPlanTemplate> get _availableTemplates =>
      journalPlanTemplates.where((t) => !_activeIds.contains(t.id)).toList();

  Future<void> _openTemplate(JournalPlanTemplate template) async {
    final started = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) => _TemplatePreviewSheet(template: template),
    );

    if (started == true) {
      final progress = await JournalPlanService().startPlan(template.id);
      if (progress != null) {
        AnalyticsService().logPlanStarted(
          planId: template.id,
          lengthDays: template.lengthDays,
        );
      }
      await _load();
      if (progress != null && mounted) {
        _openActive(progress);
      }
    }
  }

  void _openActive(JournalPlanProgress progress) {
    final template = planTemplateById(progress.planId);
    if (template == null) return;
    Navigator.of(context)
        .push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => JournalPlanDetailScreen(
              template: template,
              progress: progress,
            ),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 300),
          ),
        )
        .then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
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
                      'Journal Plans',
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
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 4, 24, 16),
              child: Text(
                'Structured journaling — one prompt a day. Run several at once.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textDim, fontSize: 12),
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accent,
                        strokeWidth: 2,
                      ),
                    )
                  : Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: kIsWeb ? 480 : double.infinity,
                        ),
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                          children: [
                            if (_active.isNotEmpty) ...[
                              const _SectionHeader(label: 'YOUR ACTIVE PLANS'),
                              const SizedBox(height: 10),
                              for (final p in _active) ...[
                                _ActivePlanCard(
                                  progress: p,
                                  onTap: () => _openActive(p),
                                ),
                                const SizedBox(height: 10),
                              ],
                              const SizedBox(height: 18),
                            ],
                            _SectionHeader(
                              label: _active.isEmpty
                                  ? 'CHOOSE A PLAN TO START'
                                  : 'AVAILABLE PLANS',
                            ),
                            const SizedBox(height: 10),
                            if (_availableTemplates.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: Center(
                                  child: Text(
                                    "You're running every plan we've got. \u{1F44F}",
                                    style: TextStyle(
                                      color: AppColors.textDim,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            for (final t in _availableTemplates) ...[
                              _TemplateCard(
                                template: t,
                                onTap: () => _openTemplate(t),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ],
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

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 10,
        color: AppColors.textMuted,
        letterSpacing: 2,
      ),
    );
  }
}

class _ActivePlanCard extends StatelessWidget {
  final JournalPlanProgress progress;
  final VoidCallback onTap;

  const _ActivePlanCard({required this.progress, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final template = planTemplateById(progress.planId);
    if (template == null) return const SizedBox.shrink();

    final service = JournalPlanService();
    final fraction = service.progressFraction(progress, template);
    final currentDay = service.currentDay(progress, template);
    final completedCount = progress.completedDays.length;
    final isDone = service.isComplete(progress, template);

    return Semantics(
      button: true,
      label:
          '${template.title}. Day ${currentDay ?? template.lengthDays} of ${template.lengthDays}.',
      child: GestureDetector(
        onTap: onTap,
        child: GlassCard(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0x1AE8945A),
              Color(0x14D4A574),
            ],
          ),
          borderColor: AppColors.accentBorder,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(template.emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          template.title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isDone
                              ? 'Plan complete'
                              : 'Day ${currentDay ?? template.lengthDays} of ${template.lengthDays}',
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.accent,
                    size: 14,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  height: 6,
                  child: LinearProgressIndicator(
                    value: fraction,
                    backgroundColor: AppColors.borderLight,
                    valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$completedCount / ${template.lengthDays} days written',
                style: const TextStyle(
                  color: AppColors.textDim,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final JournalPlanTemplate template;
  final VoidCallback onTap;

  const _TemplateCard({required this.template, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${template.title}. ${template.description}',
      child: GestureDetector(
        onTap: onTap,
        child: GlassCard(
          color: AppColors.surface.withOpacity(0.5),
          borderColor: AppColors.borderLight,
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(template.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      template.description,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
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
                        '${template.lengthDays} days',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.add_circle_outline,
                color: AppColors.accent,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TemplatePreviewSheet extends StatelessWidget {
  final JournalPlanTemplate template;
  const _TemplatePreviewSheet({required this.template});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.textDim,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(template.emoji, style: const TextStyle(fontSize: 30)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${template.lengthDays} days',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              template.description,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'A FEW PROMPTS YOU\'LL SEE',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            for (final d in template.dayPrompts.take(3))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accentTranslucent,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Text(
                        '${d.day}',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        d.title,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.background,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Start this plan',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
