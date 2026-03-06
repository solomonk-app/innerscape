class MoodEntry {
  final String id;
  final int mood;
  final String text;
  final DateTime timestamp;
  final String aiInsight;
  final List<String> tags;

  MoodEntry({
    required this.id,
    required this.mood,
    this.text = '',
    required this.timestamp,
    this.aiInsight = '',
    this.tags = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'mood': mood,
        'text': text,
        'timestamp': timestamp.toIso8601String(),
        'aiInsight': aiInsight,
        'tags': tags,
      };

  factory MoodEntry.fromJson(Map<String, dynamic> json) => MoodEntry(
        id: json['id'] as String,
        mood: json['mood'] as int,
        text: json['text'] as String? ?? '',
        timestamp: DateTime.parse(json['timestamp'] as String),
        aiInsight: json['aiInsight'] as String? ?? '',
        tags: (json['tags'] as List<dynamic>?)
                ?.map((t) => t as String)
                .toList() ??
            [],
      );

  MoodEntry copyWith({
    String? aiInsight,
    List<String>? tags,
  }) =>
      MoodEntry(
        id: id,
        mood: mood,
        text: text,
        timestamp: timestamp,
        aiInsight: aiInsight ?? this.aiInsight,
        tags: tags ?? this.tags,
      );
}

class MoodOption {
  final String emoji;
  final String label;
  final int value;
  final int colorValue;

  const MoodOption({
    required this.emoji,
    required this.label,
    required this.value,
    required this.colorValue,
  });
}

const List<MoodOption> moodOptions = [
  MoodOption(emoji: '😢', label: 'Awful', value: 1, colorValue: 0xFF8B7E74),
  MoodOption(emoji: '😟', label: 'Bad', value: 2, colorValue: 0xFFA89F91),
  MoodOption(emoji: '😐', label: 'Meh', value: 3, colorValue: 0xFFC4B8A5),
  MoodOption(emoji: '🙂', label: 'Good', value: 4, colorValue: 0xFFD4A574),
  MoodOption(emoji: '😊', label: 'Great', value: 5, colorValue: 0xFFE8945A),
  MoodOption(emoji: '🤩', label: 'Amazing', value: 6, colorValue: 0xFFE07B3C),
];
