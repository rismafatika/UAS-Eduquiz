class Participant {
  Participant({
    required this.name,
    this.score = 0,
    this.streak = 0,
    this.xp = 0,
    this.level = 1,
    this.avatar,
    this.isOnline = true,
    Map<int, int>? answers,
  }) : answers = answers ?? {};

  // Informasi Peserta
  final String name;
  final String? avatar;
  bool isOnline;

  // Statistik Quiz
  int score;
  int streak;
  int xp;
  int level;

  // Key = nomor soal
  // Value = index jawaban yang dipilih
  final Map<int, int> answers;

  // Tambah skor dan XP
  void addScore(int points) {
    score += points;
    xp += points;

    // Naik level setiap 500 XP
    level = (xp ~/ 500) + 1;
  }

  // Saat jawaban benar
  void correctAnswer({int points = 100}) {
    streak++;
    addScore(points);
  }

  // Saat jawaban salah
  void wrongAnswer() {
    streak = 0;
  }

  // Gelar berdasarkan level
  String get rankTitle {
    if (level >= 10) return 'Quiz Master';
    if (level >= 7) return 'Quiz Expert';
    if (level >= 4) return 'Quiz Pro';
    return 'Beginner';
  }

  Participant copyWith({
    String? name,
    String? avatar,
    bool? isOnline,
    int? score,
    int? streak,
    int? xp,
    int? level,
    Map<int, int>? answers,
  }) {
    return Participant(
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      isOnline: isOnline ?? this.isOnline,
      score: score ?? this.score,
      streak: streak ?? this.streak,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      answers: answers ?? Map<int, int>.from(this.answers),
    );
  }

  @override
  String toString() {
    return '''
Participant(
  name: $name,
  score: $score,
  streak: $streak,
  xp: $xp,
  level: $level,
  online: $isOnline
)
''';
  }
}