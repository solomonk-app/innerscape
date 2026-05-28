class JournalPlanProgress {
  final String planId;
  final DateTime startedAt;
  final Map<int, DateTime> completedDays;
  final bool archived;
  final DateTime? archivedAt;

  JournalPlanProgress({
    required this.planId,
    required this.startedAt,
    Map<int, DateTime>? completedDays,
    this.archived = false,
    this.archivedAt,
  }) : completedDays = completedDays ?? {};

  Map<String, dynamic> toJson() => {
        'planId': planId,
        'startedAt': startedAt.toIso8601String(),
        'completedDays': completedDays.map(
          (k, v) => MapEntry(k.toString(), v.toIso8601String()),
        ),
        'archived': archived,
        'archivedAt': archivedAt?.toIso8601String(),
      };

  factory JournalPlanProgress.fromJson(Map<String, dynamic> json) {
    final raw = (json['completedDays'] as Map?) ?? {};
    final completed = <int, DateTime>{};
    raw.forEach((k, v) {
      final day = int.tryParse(k.toString());
      final date = v == null ? null : DateTime.tryParse(v.toString());
      if (day != null && date != null) {
        completed[day] = date;
      }
    });
    return JournalPlanProgress(
      planId: json['planId'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedDays: completed,
      archived: json['archived'] as bool? ?? false,
      archivedAt: json['archivedAt'] != null
          ? DateTime.parse(json['archivedAt'] as String)
          : null,
    );
  }

  JournalPlanProgress copyWith({
    Map<int, DateTime>? completedDays,
    bool? archived,
    DateTime? archivedAt,
  }) =>
      JournalPlanProgress(
        planId: planId,
        startedAt: startedAt,
        completedDays: completedDays ?? this.completedDays,
        archived: archived ?? this.archived,
        archivedAt: archivedAt ?? this.archivedAt,
      );
}
