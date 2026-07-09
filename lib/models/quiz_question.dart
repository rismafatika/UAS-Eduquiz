import 'package:flutter/material.dart';

class QuizQuestion {
  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.category,
    required this.points,
    required this.color,
  });

  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  final String category;
  final int points;
  final Color color;

  QuizQuestion copyWith({
    String? question,
    List<String>? options,
    int? correctIndex,
    String? explanation,
    String? category,
    int? points,
    Color? color,
  }) {
    return QuizQuestion(
      question: question ?? this.question,
      options: options ?? List<String>.from(this.options),
      correctIndex: correctIndex ?? this.correctIndex,
      explanation: explanation ?? this.explanation,
      category: category ?? this.category,
      points: points ?? this.points,
      color: color ?? this.color,
    );
  }
}
