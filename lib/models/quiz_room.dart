import 'package:flutter/material.dart';
import 'participant.dart';
import 'quiz_question.dart';

enum QuizPhase {
  waiting,
  lobby,
  live,
  leaderboard,
  review,
  dashboard,
}

class QuizRoom {
  final String code;
  final String title;
  final String hostName;
  final List<QuizQuestion> questions;
  final List<Participant> participants;
  int currentQuestionIndex;
  QuizPhase phase;
  final DateTime createdAt;

  QuizRoom({
    required this.code,
    required this.title,
    required this.hostName,
    required this.questions,
    List<Participant>? participants,
    this.currentQuestionIndex = 0,
    this.phase = QuizPhase.waiting,
    DateTime? createdAt,
  })  : participants = participants ?? [], // MUTABLE
        createdAt = createdAt ?? DateTime.now();

  // ─── FROM JSON ──────────────────────────────────────────
  factory QuizRoom.fromJson(Map<String, dynamic> json) {
    return QuizRoom(
      code: json['code'] as String,
      title: json['title'] as String,
      hostName: json['host_name'] as String,
      questions: (json['questions'] as List?)
              ?.map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
      participants: (json['participants'] as List?)
              ?.map((p) => Participant.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      currentQuestionIndex: json['current_question_index'] as int? ?? 0,
      phase: QuizPhase.values.firstWhere(
        (e) => e.name == (json['phase'] as String? ?? 'waiting'),
        orElse: () => QuizPhase.waiting,
      ),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  // ─── TO JSON ──────────────────────────────────────────────
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'title': title,
      'host_name': hostName,
      'questions': questions.map((q) => q.toJson()).toList(),
      'participants': participants.map((p) => p.toJson()).toList(),
      'current_question_index': currentQuestionIndex,
      'phase': phase.name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // ─── COPY WITH ─────────────────────────────────────────────
  QuizRoom copyWith({
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
      code: code ?? this.code,
      title: title ?? this.title,
      hostName: hostName ?? this.hostName,
      questions: questions ?? List.from(this.questions),
      participants: participants ?? List.from(this.participants),
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      phase: phase ?? this.phase,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
