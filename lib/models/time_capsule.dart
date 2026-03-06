class TimeCapsule {
  final String id;
  final String letter;
  final int moodAtCreation;
  final DateTime createdAt;
  final DateTime unlocksAt;
  final String? aiReflection;
  final bool isOpened;

  TimeCapsule({
    required this.id,
    required this.letter,
    required this.moodAtCreation,
    required this.createdAt,
    required this.unlocksAt,
    this.aiReflection,
    this.isOpened = false,
  });

  bool get isUnlocked => DateTime.now().isAfter(unlocksAt);

  Duration get timeRemaining => unlocksAt.difference(DateTime.now());

  String get timeRemainingLabel {
    final remaining = timeRemaining;
    if (remaining.isNegative) return 'Ready to open!';
    if (remaining.inDays > 0) return '${remaining.inDays}d remaining';
    if (remaining.inHours > 0) return '${remaining.inHours}h remaining';
    return '${remaining.inMinutes}m remaining';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'letter': letter,
        'moodAtCreation': moodAtCreation,
        'createdAt': createdAt.toIso8601String(),
        'unlocksAt': unlocksAt.toIso8601String(),
        'aiReflection': aiReflection,
        'isOpened': isOpened,
      };

  factory TimeCapsule.fromJson(Map<String, dynamic> json) => TimeCapsule(
        id: json['id'] as String,
        letter: json['letter'] as String,
        moodAtCreation: json['moodAtCreation'] as int,
        createdAt: DateTime.parse(json['createdAt'] as String),
        unlocksAt: DateTime.parse(json['unlocksAt'] as String),
        aiReflection: json['aiReflection'] as String?,
        isOpened: json['isOpened'] as bool? ?? false,
      );

  TimeCapsule copyWith({
    String? aiReflection,
    bool? isOpened,
  }) =>
      TimeCapsule(
        id: id,
        letter: letter,
        moodAtCreation: moodAtCreation,
        createdAt: createdAt,
        unlocksAt: unlocksAt,
        aiReflection: aiReflection ?? this.aiReflection,
        isOpened: isOpened ?? this.isOpened,
      );
}

enum CapsuleDuration {
  oneWeek(Duration(days: 7), '1 Week'),
  oneMonth(Duration(days: 30), '1 Month'),
  threeMonths(Duration(days: 90), '3 Months');

  final Duration duration;
  final String label;

  const CapsuleDuration(this.duration, this.label);
}
