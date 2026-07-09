import 'participant.dart';
import 'quiz_question.dart';
import 'quiz_result.dart';

enum QuizPhase { lobby, live, leaderboard, review, dashboard }

class QuizRoom {
  QuizRoom({
    required this.code,
    required this.title,
    required this.hostName,
    required this.questions,
  });

  final String code;
  final String title;
  final String hostName;
  final List<QuizQuestion> questions;
  final List<Participant> participants = [];
  final List<QuizResult> results = [];
  QuizPhase phase = QuizPhase.lobby;
  int currentQuestionIndex = 0;
}
