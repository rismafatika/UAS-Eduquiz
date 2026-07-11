class Participant {
  final String id;
  final String name;
  int score;
  Map<int, int> answers;
  final DateTime joinedAt;

  Participant({
    this.id = '',
    required this.name,
    this.score = 0,
    this.answers = const {},
    DateTime? joinedAt,
  }) : joinedAt = joinedAt ?? DateTime.now();

  Participant copyWith({
    String? id,
    String? name,
    int? score,
    Map<int, int>? answers,
    DateTime? joinedAt,
  }) {
    return Participant(
      id: id ?? this.id,
      name: name ?? this.name,
      score: score ?? this.score,
      answers: answers ?? this.answers,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  Map<String, dynamic> toJson(String roomCode) {
    return {
      'room_code': roomCode,
      'name': name,
      'score': score,
      'answers': answers,
    };
  }

  factory Participant.fromJson(Map<String, dynamic> json) {
    Map<int, int> parsedAnswers = {};
    if (json['answers'] is Map) {
      final answersMap = json['answers'] as Map;
      parsedAnswers = answersMap.map((key, value) {
        final questionIndex = int.tryParse(key.toString()) ?? 0;
        final selectedOption = (value as num).toInt();
        return MapEntry(questionIndex, selectedOption);
      });
    }

    return Participant(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      score: json['score'] ?? 0,
      answers: parsedAnswers,
      joinedAt: json['joined_at'] != null
          ? DateTime.parse(json['joined_at'])
          : DateTime.now(),
    );
  }
}
