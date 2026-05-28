enum EisenhowerQuadrant { q1DoNow, q2Schedule, q3Delegate, q4Eliminate }

String eisenhowerQuadrantLabel(EisenhowerQuadrant q) {
  switch (q) {
    case EisenhowerQuadrant.q1DoNow:
      return 'Do now';
    case EisenhowerQuadrant.q2Schedule:
      return 'Schedule';
    case EisenhowerQuadrant.q3Delegate:
      return 'Delegate';
    case EisenhowerQuadrant.q4Eliminate:
      return 'Eliminate';
  }
}

String eisenhowerQuadrantSubtitle(EisenhowerQuadrant q) {
  switch (q) {
    case EisenhowerQuadrant.q1DoNow:
      return 'Urgent + Important';
    case EisenhowerQuadrant.q2Schedule:
      return 'Important, not urgent — where wellbeing lives';
    case EisenhowerQuadrant.q3Delegate:
      return 'Urgent, not important';
    case EisenhowerQuadrant.q4Eliminate:
      return 'Neither';
  }
}

class EisenhowerItem {
  final String id;
  final String text;
  final EisenhowerQuadrant quadrant;

  const EisenhowerItem({
    required this.id,
    required this.text,
    required this.quadrant,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'quadrant': quadrant.name,
      };

  factory EisenhowerItem.fromJson(Map<String, dynamic> json) => EisenhowerItem(
        id: json['id'] as String,
        text: json['text'] as String,
        quadrant: EisenhowerQuadrant.values.firstWhere(
          (q) => q.name == json['quadrant'],
          orElse: () => EisenhowerQuadrant.q4Eliminate,
        ),
      );

  EisenhowerItem copyWith({String? text, EisenhowerQuadrant? quadrant}) =>
      EisenhowerItem(
        id: id,
        text: text ?? this.text,
        quadrant: quadrant ?? this.quadrant,
      );
}

class EisenhowerEntry {
  final String id;
  final DateTime createdAt;
  final List<EisenhowerItem> items;
  final String? reflection;

  const EisenhowerEntry({
    required this.id,
    required this.createdAt,
    required this.items,
    this.reflection,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'items': items.map((i) => i.toJson()).toList(),
        'reflection': reflection,
      };

  factory EisenhowerEntry.fromJson(Map<String, dynamic> json) => EisenhowerEntry(
        id: json['id'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        items: ((json['items'] as List?) ?? [])
            .map((e) => EisenhowerItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        reflection: json['reflection'] as String?,
      );
}
