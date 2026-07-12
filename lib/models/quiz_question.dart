import 'package:flutter/material.dart';

class QuizQuestion {
  final String? id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? explanation;
  final String? category;
  final int? points;
  final Color? color;

  const QuizQuestion({
    this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.explanation,
    this.category,
    this.points,
    this.color,
  });

  // ─── FROM JSON ──────────────────────────────────────────
  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as String?,
      question: json['question'] as String,
      options: List<String>.from(json['options'] ?? []),
      correctIndex: json['correctIndex'] as int? ?? 0,
      explanation: json['explanation'] as String?,
      category: json['category'] as String?,
      points: json['points'] as int?,
      color: json['color'] != null ? Color(json['color'] as int) : null,
    );
  }

  // ─── TO JSON ──────────────────────────────────────────────
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctIndex': correctIndex,
      'explanation': explanation,
      'category': category,
      'points': points,
      'color': color?.value,
    };
  }

  // ─── COPY WITH ─────────────────────────────────────────────
  QuizQuestion copyWith({
    String? id,
    String? question,
    List<String>? options,
    int? correctIndex,
    String? explanation,
    String? category,
    int? points,
    Color? color,
  }) {
    return QuizQuestion(
      id: id ?? this.id,
      question: question ?? this.question,
      options: options ?? List.from(this.options),
      correctIndex: correctIndex ?? this.correctIndex,
      explanation: explanation ?? this.explanation,
      category: category ?? this.category,
      points: points ?? this.points,
      color: color ?? this.color,
    );
  }
}
