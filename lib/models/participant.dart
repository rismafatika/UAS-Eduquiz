class Participant {
  final String name;
  int score;
  Map<int, int> answers;

  Participant({
    required this.name,
    this.score = 0,
    Map<int, int>? answers,
  }) : answers = answers ?? {};

  // ─── FROM JSON ──────────────────────────────────────────
  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      name: json['name'] as String,
      score: json['score'] as int? ?? 0,
      answers: Map<int, int>.from(json['answers'] ?? {}),
    );
  }

  // ─── TO JSON ──────────────────────────────────────────────
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'score': score,
      'answers': answers,
    };
  }

  // ─── COPY WITH ─────────────────────────────────────────────
  Participant copyWith({
    String? name,
    int? score,
    Map<int, int>? answers,
  }) {
    return Participant(
      name: name ?? this.name,
      score: score ?? this.score,
      answers: answers ?? Map.from(this.answers),
    );
  }
}
