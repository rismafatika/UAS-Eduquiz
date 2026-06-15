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
}