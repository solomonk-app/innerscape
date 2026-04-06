class DailyChallenge {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final DateTime date;
  final bool isCompleted;
  final String? reflection;
  final DateTime? completedAt;

  DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.date,
    this.isCompleted = false,
    this.reflection,
    this.completedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'emoji': emoji,
        'date': date.toIso8601String(),
        'isCompleted': isCompleted,
        'reflection': reflection,
        'completedAt': completedAt?.toIso8601String(),
      };

  factory DailyChallenge.fromJson(Map<String, dynamic> json) =>
      DailyChallenge(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        emoji: json['emoji'] as String? ?? '\u{1F3AF}',
        date: DateTime.parse(json['date'] as String),
        isCompleted: json['isCompleted'] as bool? ?? false,
        reflection: json['reflection'] as String?,
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'] as String)
            : null,
      );

  DailyChallenge copyWith({
    bool? isCompleted,
    String? reflection,
    DateTime? completedAt,
  }) =>
      DailyChallenge(
        id: id,
        title: title,
        description: description,
        emoji: emoji,
        date: date,
        isCompleted: isCompleted ?? this.isCompleted,
        reflection: reflection ?? this.reflection,
        completedAt: completedAt ?? this.completedAt,
      );
}
