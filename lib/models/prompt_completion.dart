enum PromptSource { idea, plan, weekly, monthly }

String promptSourceLabel(PromptSource s) {
  switch (s) {
    case PromptSource.idea:
      return 'Idea';
    case PromptSource.plan:
      return 'Plan';
    case PromptSource.weekly:
      return 'Weekly';
    case PromptSource.monthly:
      return 'Monthly';
  }
}

class PromptCompletion {
  final String id;
  final String promptKey;
  final String promptTitle;
  final PromptSource source;
  final DateTime completedAt;
  final bool writtenInApp;
  final String? text;

  const PromptCompletion({
    required this.id,
    required this.promptKey,
    required this.promptTitle,
    required this.source,
    required this.completedAt,
    required this.writtenInApp,
    this.text,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'promptKey': promptKey,
        'promptTitle': promptTitle,
        'source': source.name,
        'completedAt': completedAt.toIso8601String(),
        'writtenInApp': writtenInApp,
        'text': text,
      };

  factory PromptCompletion.fromJson(Map<String, dynamic> json) =>
      PromptCompletion(
        id: json['id'] as String,
        promptKey: json['promptKey'] as String,
        promptTitle: json['promptTitle'] as String,
        source: PromptSource.values.firstWhere(
          (s) => s.name == json['source'],
          orElse: () => PromptSource.idea,
        ),
        completedAt: DateTime.parse(json['completedAt'] as String),
        writtenInApp: json['writtenInApp'] as bool? ?? false,
        text: json['text'] as String?,
      );
}
