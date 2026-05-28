import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/prompt_completion.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class PromptSheet extends StatefulWidget {
  final String title;
  final String prompt;
  final List<String> topics;
  final String promptKey;
  final PromptSource source;
  final void Function(PromptCompletion completion)? onCompleted;

  const PromptSheet({
    super.key,
    required this.title,
    required this.prompt,
    required this.topics,
    required this.promptKey,
    required this.source,
    this.onCompleted,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String prompt,
    required List<String> topics,
    required String promptKey,
    required PromptSource source,
    void Function(PromptCompletion completion)? onCompleted,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) => PromptSheet(
        title: title,
        prompt: prompt,
        topics: topics,
        promptKey: promptKey,
        source: source,
        onCompleted: onCompleted,
      ),
    );
  }

  @override
  State<PromptSheet> createState() => _PromptSheetState();
}

class _PromptSheetState extends State<PromptSheet> {
  bool _isWriting = false;
  bool _isSaving = false;
  PromptCompletion? _latest;
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLatest();
  }

  Future<void> _loadLatest() async {
    final storage = await StorageService.getInstance();
    final latest = await storage.latestCompletionFor(widget.promptKey);
    if (!mounted) return;
    setState(() => _latest = latest);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _complete({required bool writtenInApp}) async {
    if (_isSaving) return;
    final text = writtenInApp ? _textController.text.trim() : null;
    if (writtenInApp && (text == null || text.isEmpty)) return;

    setState(() => _isSaving = true);

    final completion = PromptCompletion(
      id: const Uuid().v4(),
      promptKey: widget.promptKey,
      promptTitle: widget.title,
      source: widget.source,
      completedAt: DateTime.now(),
      writtenInApp: writtenInApp,
      text: text,
    );

    final storage = await StorageService.getInstance();
    await storage.addPromptCompletion(completion);

    widget.onCompleted?.call(completion);

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMd().add_jm();
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
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

            // Existing completion banner
            if (_latest != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentTranslucent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.accentBorder),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: AppColors.accent,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _latest!.writtenInApp
                            ? 'Last written in-app on ${dateFormat.format(_latest!.completedAt)}'
                            : 'Last marked written on paper on ${dateFormat.format(_latest!.completedAt)}',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_latest!.writtenInApp && _latest!.text != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Text(
                    _latest!.text!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
            ],

            // Title
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 20,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),

            // Prompt body
            Text(
              widget.prompt,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                height: 1.6,
              ),
            ),

            // Topic suggestions
            if (widget.topics.isNotEmpty) ...[
              const SizedBox(height: 18),
              const Text(
                'TRY WRITING ABOUT',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textMuted,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              ...widget.topics.map(
                (t) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '•',
                        style: TextStyle(
                          color: AppColors.warmGold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          t,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // In-app writing area
            if (_isWriting) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.background.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: TextField(
                  controller: _textController,
                  autofocus: true,
                  maxLines: 6,
                  minLines: 4,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    height: 1.6,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Write here...',
                    hintStyle: TextStyle(
                      color: AppColors.textDim,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: _isSaving
                            ? null
                            : () => setState(() => _isWriting = false),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.borderLight),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Back',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isSaving
                            ? null
                            : () => _complete(writtenInApp: true),
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
                  ),
                ],
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : () => _complete(writtenInApp: false),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text(
                    'I wrote it on paper',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _isSaving
                      ? null
                      : () => setState(() => _isWriting = true),
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                  label: const Text(
                    'Write in-app',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.borderLight),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
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
