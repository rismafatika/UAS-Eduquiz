import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/participant.dart';
import '../models/quiz_question.dart';
import '../models/quiz_room.dart';
import '../widgets/app_panel.dart';
import '../widgets/room_header.dart';
import '../widgets/section_title.dart';

class ReviewPage extends StatelessWidget {
  const ReviewPage({super.key, required this.user, required this.room});

  final AppUser user;
  final QuizRoom room;

  Participant get _activeParticipant {
    return room.participants.firstWhere(
      (participant) => participant.name == user.name,
      orElse: () => room.participants.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review Jawaban')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RoomHeader(room: room),
                  const SizedBox(height: 16),
                  AppPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionTitle(icon: Icons.fact_check_outlined, title: 'Review Jawaban'),
                        const SizedBox(height: 12),
                        Text(
                          '${_activeParticipant.name} - ${_activeParticipant.score} poin - Lv ${_activeParticipant.level}',
                          style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF334155)),
                        ),
                        const SizedBox(height: 12),
                        for (var i = 0; i < room.questions.length; i++)
                          _ReviewCard(
                            number: i + 1,
                            question: room.questions[i],
                            selectedIndex: _activeParticipant.answers[i],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.number,
    required this.question,
    required this.selectedIndex,
  });

  final int number;
  final QuizQuestion question;
  final int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    final isCorrect = selectedIndex == question.correctIndex;
    final selectedText = selectedIndex == null || selectedIndex! < 0 || selectedIndex! >= question.options.length
        ? '-'
        : question.options[selectedIndex!];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCorrect ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isCorrect ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Soal $number', style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(question.question),
          const SizedBox(height: 8),
          Text('Jawaban kamu: $selectedText'),
          Text('Jawaban benar: ${question.options[question.correctIndex]}'),
          const SizedBox(height: 6),
          Text(question.explanation),
        ],
      ),
    );
  }
}
