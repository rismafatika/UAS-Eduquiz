class Participant {
  Participant({
    required this.name,
    this.score = 0,
    Map<int, int>? answers,
  }) : answers = answers ?? {};

  final String name;
  int score;
  final Map<int, int> answers;
}
