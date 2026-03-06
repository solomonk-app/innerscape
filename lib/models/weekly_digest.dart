class WeeklyDigest {
  final String id;
  final DateTime weekStart; // Monday of the week
  final DateTime weekEnd; // Sunday of the week
  final DateTime generatedAt;
  final String content; // AI-generated letter
  final double averageMood;
  final int entryCount;
  final int bestDay; // weekday (1=Mon..7=Sun)
  final int worstDay;
  final double bestMood;
  final double worstMood;

  WeeklyDigest({
    required this.id,
    required this.weekStart,
    required this.weekEnd,
    required this.generatedAt,
    required this.content,
    required this.averageMood,
    required this.entryCount,
    required this.bestDay,
    required this.worstDay,
    required this.bestMood,
    required this.worstMood,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'weekStart': weekStart.toIso8601String(),
        'weekEnd': weekEnd.toIso8601String(),
        'generatedAt': generatedAt.toIso8601String(),
        'content': content,
        'averageMood': averageMood,
        'entryCount': entryCount,
        'bestDay': bestDay,
        'worstDay': worstDay,
        'bestMood': bestMood,
        'worstMood': worstMood,
      };

  factory WeeklyDigest.fromJson(Map<String, dynamic> json) => WeeklyDigest(
        id: json['id'] as String,
        weekStart: DateTime.parse(json['weekStart'] as String),
        weekEnd: DateTime.parse(json['weekEnd'] as String),
        generatedAt: DateTime.parse(json['generatedAt'] as String),
        content: json['content'] as String,
        averageMood: (json['averageMood'] as num).toDouble(),
        entryCount: json['entryCount'] as int,
        bestDay: json['bestDay'] as int,
        worstDay: json['worstDay'] as int,
        bestMood: (json['bestMood'] as num).toDouble(),
        worstMood: (json['worstMood'] as num).toDouble(),
      );
}
