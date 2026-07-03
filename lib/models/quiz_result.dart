class QuizResult {
  const QuizResult({
    required this.participantName,
    required this.totalScore,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.percentage,
    required this.grade,
    required this.completedAt,
  });

  final String participantName;
  final int totalScore;
  final int correctAnswers;
  final int wrongAnswers;
  final double percentage;
  final String grade;
  final DateTime completedAt;
}
