import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/eisenhower_entry.dart';
import '../services/analytics_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

const _q1Color = Color(0xFFE07B6A);
const _q2Color = Color(0xFF7BC47F);
const _q3Color = Color(0xFFE8B85A);
const _q4Color = Color(0xFF8B7E74);

Color _quadrantColor(EisenhowerQuadrant q) {
  switch (q) {
    case EisenhowerQuadrant.q1DoNow:
      return _q1Color;
    case EisenhowerQuadrant.q2Schedule:
      return _q2Color;
    case EisenhowerQuadrant.q3Delegate:
      return _q3Color;
    case EisenhowerQuadrant.q4Eliminate:
      return _q4Color;
  }
}

String _quadrantShort(EisenhowerQuadrant q) {
  switch (q) {
    case EisenhowerQuadrant.q1DoNow:
      return 'Q1';
    case EisenhowerQuadrant.q2Schedule:
      return 'Q2';
    case EisenhowerQuadrant.q3Delegate:
      return 'Q3';
    case EisenhowerQuadrant.q4Eliminate:
      return 'Q4';
  }
}

class EisenhowerScreen extends StatefulWidget {
  const EisenhowerScreen({super.key});

  @override
  State<EisenhowerScreen> createState() => _EisenhowerScreenState();
}

class _EisenhowerScreenState extends State<EisenhowerScreen> {
  final _itemController = TextEditingController();
  final _reflectionController = TextEditingController();
  final List<EisenhowerItem> _items = [];
  EisenhowerQuadrant _selectedQuadrant = EisenhowerQuadrant.q2Schedule;
  bool _showExplanation = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    AnalyticsService().logScreenView('eisenhower');
  }

  @override
  void dispose() {
    _itemController.dispose();
    _reflectionController.dispose();
    super.dispose();
  }

  void _addItem() {
    final text = _itemController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _items.add(EisenhowerItem(
        id: const Uuid().v4(),
        text: text,
        quadrant: _selectedQuadrant,
      ));
      _itemController.clear();
    });
  }

  void _editItem(EisenhowerItem item) {
    final controller = TextEditingController(text: item.text);
    EisenhowerQuadrant chosen = item.quadrant;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            16,
            24,
            24 + MediaQuery.of(ctx).viewInsets.bottom,
          ),
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
              const Text(
                'Edit item',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.background.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: TextField(
                  controller: controller,
                  maxLines: 3,
                  minLines: 1,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Update the item',
                    hintStyle: TextStyle(color: AppColors.textDim),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'QUADRANT',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textMuted,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final q in EisenhowerQuadrant.values)
                    _QuadrantChip(
                      quadrant: q,
                      isActive: chosen == q,
                      onTap: () => setSheetState(() => chosen = q),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _items.removeWhere((i) => i.id == item.id);
                          });
                          Navigator.of(ctx).pop();
                        },
                        icon: const Icon(
                          Icons.delete_outline,
                          color: _q1Color,
                          size: 18,
                        ),
                        label: const Text(
                          'Delete',
                          style: TextStyle(
                            color: _q1Color,
                            fontSize: 13,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: _q1Color),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () {
                          final text = controller.text.trim();
                          if (text.isEmpty) {
                            Navigator.of(ctx).pop();
                            return;
                          }
                          setState(() {
                            final idx =
                                _items.indexWhere((i) => i.id == item.id);
                            if (idx >= 0) {
                              _items[idx] = _items[idx]
                                  .copyWith(text: text, quadrant: chosen);
                            }
                          });
                          Navigator.of(ctx).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.background,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveEntry() async {
    if (_isSaving) return;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least one item before saving.'),
          backgroundColor: AppColors.surfaceLight,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final reflection = _reflectionController.text.trim();
    final entry = EisenhowerEntry(
      id: const Uuid().v4(),
      createdAt: DateTime.now(),
      items: List.of(_items),
      reflection: reflection.isEmpty ? null : reflection,
    );

    final storage = await StorageService.getInstance();
    await storage.saveEisenhowerEntry(entry);

    AnalyticsService().logEisenhowerSaved(
      itemCount: entry.items.length,
      hasReflection: entry.reflection != null,
    );

    if (!mounted) return;
    setState(() {
      _items.clear();
      _reflectionController.clear();
      _isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Entry saved.'),
        backgroundColor: AppColors.surfaceLight,
      ),
    );
  }

  Future<void> _openHistory() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) => const _EisenhowerHistorySheet(),
    );
  }

  List<EisenhowerItem> _itemsFor(EisenhowerQuadrant q) =>
      _items.where((i) => i.quadrant == q).toList();

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
                      'Eisenhower Matrix',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _openHistory,
                    icon: const Icon(
                      Icons.history,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                    tooltip: 'History',
                  ),
                ],
              ),
            ),

            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(maxWidth: kIsWeb ? 880 : double.infinity),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      // Explanation
                      if (_showExplanation)
                        GlassCard(
                          color: AppColors.surface.withOpacity(0.4),
                          borderColor: AppColors.borderLight,
                          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'What is this for?',
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => setState(
                                        () => _showExplanation = false),
                                    child: const Padding(
                                      padding: EdgeInsets.all(4),
                                      child: Icon(
                                        Icons.close,
                                        color: AppColors.textMuted,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "Sort what's on your plate by urgency and importance. Notice how much of your time goes to Q2 — that's where wellbeing lives.",
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                      if (_showExplanation) const SizedBox(height: 14),

                      // 2x2 Matrix
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _QuadrantPanel(
                              quadrant: EisenhowerQuadrant.q1DoNow,
                              items: _itemsFor(EisenhowerQuadrant.q1DoNow),
                              onItemTap: _editItem,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _QuadrantPanel(
                              quadrant: EisenhowerQuadrant.q2Schedule,
                              items: _itemsFor(EisenhowerQuadrant.q2Schedule),
                              onItemTap: _editItem,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _QuadrantPanel(
                              quadrant: EisenhowerQuadrant.q3Delegate,
                              items: _itemsFor(EisenhowerQuadrant.q3Delegate),
                              onItemTap: _editItem,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _QuadrantPanel(
                              quadrant: EisenhowerQuadrant.q4Eliminate,
                              items: _itemsFor(EisenhowerQuadrant.q4Eliminate),
                              onItemTap: _editItem,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Add-item bar
                      const Text(
                        'ADD AN ITEM',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _itemController,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                ),
                                decoration: const InputDecoration(
                                  hintText: "What's on your plate?",
                                  hintStyle: TextStyle(
                                    color: AppColors.textDim,
                                    fontSize: 14,
                                  ),
                                  border: InputBorder.none,
                                ),
                                onSubmitted: (_) => _addItem(),
                              ),
                            ),
                            IconButton(
                              onPressed: _addItem,
                              icon: const Icon(
                                Icons.add_circle,
                                color: AppColors.accent,
                                size: 26,
                              ),
                              tooltip: 'Add to selected quadrant',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final q in EisenhowerQuadrant.values)
                            _QuadrantChip(
                              quadrant: q,
                              isActive: _selectedQuadrant == q,
                              onTap: () =>
                                  setState(() => _selectedQuadrant = q),
                            ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Reflection
                      const Text(
                        'REFLECT (OPTIONAL)',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: TextField(
                          controller: _reflectionController,
                          maxLines: 5,
                          minLines: 3,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            height: 1.6,
                          ),
                          decoration: const InputDecoration(
                            hintText:
                                "What do you notice about how you're spending your time?",
                            hintStyle: TextStyle(
                              color: AppColors.textDim,
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Save
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveEntry,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: AppColors.background,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            _isSaving ? 'Saving...' : 'Save entry',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
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

class _QuadrantPanel extends StatelessWidget {
  final EisenhowerQuadrant quadrant;
  final List<EisenhowerItem> items;
  final void Function(EisenhowerItem) onItemTap;

  const _QuadrantPanel({
    required this.quadrant,
    required this.items,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _quadrantColor(quadrant);
    return GlassCard(
      color: color.withOpacity(0.08),
      borderColor: color.withOpacity(0.4),
      padding: const EdgeInsets.all(10),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    eisenhowerQuadrantLabel(quadrant),
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              eisenhowerQuadrantSubtitle(quadrant),
              style: const TextStyle(
                color: AppColors.textDim,
                fontSize: 9.5,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  '—',
                  style: TextStyle(
                    color: AppColors.textDim,
                    fontSize: 12,
                  ),
                ),
              )
            else
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: GestureDetector(
                    onTap: () => onItemTap(item),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: color.withOpacity(0.3)),
                      ),
                      child: Text(
                        item.text,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 11,
                          height: 1.4,
                        ),
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

class _QuadrantChip extends StatelessWidget {
  final EisenhowerQuadrant quadrant;
  final bool isActive;
  final VoidCallback onTap;

  const _QuadrantChip({
    required this.quadrant,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _quadrantColor(quadrant);
    return Semantics(
      button: true,
      selected: isActive,
      label:
          '${_quadrantShort(quadrant)} — ${eisenhowerQuadrantLabel(quadrant)}',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isActive
                ? color.withOpacity(0.2)
                : AppColors.surface.withOpacity(0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? color : AppColors.borderLight,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${_quadrantShort(quadrant)}  ${eisenhowerQuadrantLabel(quadrant)}',
                style: TextStyle(
                  color: isActive ? color : AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EisenhowerHistorySheet extends StatefulWidget {
  const _EisenhowerHistorySheet();

  @override
  State<_EisenhowerHistorySheet> createState() =>
      _EisenhowerHistorySheetState();
}

class _EisenhowerHistorySheetState extends State<_EisenhowerHistorySheet> {
  List<EisenhowerEntry> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final storage = await StorageService.getInstance();
    final entries = await storage.getEisenhowerEntries();
    if (!mounted) return;
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  Future<void> _confirmDelete(EisenhowerEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Delete this entry?',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: _q1Color),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final storage = await StorageService.getInstance();
    await storage.deleteEisenhowerEntry(entry.id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMd().add_jm();
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (ctx, scrollController) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.textDim,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'History',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accent,
                        strokeWidth: 2,
                      ),
                    )
                  : _entries.isEmpty
                      ? const Center(
                          child: Text(
                            'No past entries yet.',
                            style: TextStyle(
                              color: AppColors.textDim,
                              fontSize: 13,
                            ),
                          ),
                        )
                      : ListView.separated(
                          controller: scrollController,
                          itemCount: _entries.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (ctx, i) {
                            final e = _entries[i];
                            return _HistoryEntryCard(
                              entry: e,
                              dateLabel: dateFormat.format(e.createdAt),
                              onDelete: () => _confirmDelete(e),
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

class _HistoryEntryCard extends StatelessWidget {
  final EisenhowerEntry entry;
  final String dateLabel;
  final VoidCallback onDelete;

  const _HistoryEntryCard({
    required this.entry,
    required this.dateLabel,
    required this.onDelete,
  });

  List<EisenhowerItem> _itemsFor(EisenhowerQuadrant q) =>
      entry.items.where((i) => i.quadrant == q).toList();

  @override
  Widget build(BuildContext context) {
    final populatedQuadrants = EisenhowerQuadrant.values
        .where((q) => _itemsFor(q).isNotEmpty)
        .toList();

    return GlassCard(
      color: AppColors.surface.withOpacity(0.4),
      borderColor: AppColors.borderLight,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  dateLabel,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onDelete,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.delete_outline,
                    color: AppColors.textMuted,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (int i = 0; i < populatedQuadrants.length; i++) ...[
            _QuadrantItemGroup(
              quadrant: populatedQuadrants[i],
              items: _itemsFor(populatedQuadrants[i]),
            ),
            if (i < populatedQuadrants.length - 1) const SizedBox(height: 10),
          ],
          if (entry.reflection != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background.withOpacity(0.35),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Text(
                entry.reflection!,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuadrantItemGroup extends StatelessWidget {
  final EisenhowerQuadrant quadrant;
  final List<EisenhowerItem> items;
  const _QuadrantItemGroup({required this.quadrant, required this.items});

  @override
  Widget build(BuildContext context) {
    final color = _quadrantColor(quadrant);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${_quadrantShort(quadrant)}  ${eisenhowerQuadrantLabel(quadrant)}',
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '· ${items.length}',
              style: const TextStyle(
                color: AppColors.textDim,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final item in items)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Text(
                  item.text,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
