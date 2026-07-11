import 'participant.dart';
import 'quiz_question.dart';

enum QuizPhase { waiting, live, leaderboard, review, dashboard, lobby }

class QuizRoom {
  final String id;
  final String code;
  final String title;
  final String hostName;
  final List<QuizQuestion> questions;
  final List<Participant> participants;
  int currentQuestionIndex;
  QuizPhase phase;
  final DateTime createdAt;

  QuizRoom({
    this.id = '',
    required this.code,
    required this.title,
    required this.hostName,
    this.questions = const [],
    this.participants = const [],
    this.currentQuestionIndex = 0,
    this.phase = QuizPhase.waiting,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  QuizRoom copyWith({
    String? id,
    String? code,
    String? title,
    String? hostName,
    List<QuizQuestion>? questions,
    List<Participant>? participants,
    int? currentQuestionIndex,
    QuizPhase? phase,
    DateTime? createdAt,
  }) {
    return QuizRoom(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      hostName: hostName ?? this.hostName,
      questions: questions ?? this.questions,
      participants: participants ?? this.participants,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      phase: phase ?? this.phase,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'title': title,
      'host_name': hostName,
      'phase': phase.name,
      'current_question_index': currentQuestionIndex,
    };
  }

  factory QuizRoom.fromJson(
    Map<String, dynamic> json, {
    List<QuizQuestion>? questions,
    List<Participant>? participants,
  }) {
    return QuizRoom(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      title: json['title'] ?? '',
      hostName: json['host_name'] ?? '',
      questions: questions ?? [],
      participants: participants ?? [],
      currentQuestionIndex: json['current_question_index'] ?? 0,
      phase: QuizPhase.values.firstWhere(
        (e) => e.name == (json['phase'] ?? 'waiting'),
        orElse: () => QuizPhase.waiting,
      ),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}
