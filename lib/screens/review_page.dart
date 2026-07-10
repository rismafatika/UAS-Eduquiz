import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/participant.dart';
import '../models/quiz_question.dart';
import '../models/quiz_room.dart';
import '../widgets/app_panel.dart';
import '../widgets/room_header.dart';
import '../widgets/section_title.dart';
import '../widgets/status_badge.dart';

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
                        const SectionTitle(
                          icon: Icons.fact_check_outlined,
                          title: 'Review Jawaban',
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFF8FAFC),
                                Color(0xFFF1F5F9),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                _activeParticipant.name,
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                              ),
                              StatusBadge(
                                label: '${_activeParticipant.score} poin',
                                icon: Icons.stars_outlined,
                                color: const Color(0xFFF59E0B),
                              ),
                              StatusBadge(
                                label: 'Lv ${_activeParticipant.level}',
                                icon: Icons.workspace_premium_outlined,
                                color: const Color(0xFF5B5FEF),
                              ),
                              StatusBadge(
                                label: '${_activeParticipant.answers.length}/${room.questions.length} dijawab',
                                icon: Icons.fact_check_outlined,
                                color: const Color(0xFF14B8A6),
                              ),
                            ],
                          ),
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
    final selectedText = selectedIndex == null ||
            selectedIndex! < 0 ||
            selectedIndex! >= question.options.length
        ? '-'
        : question.options[selectedIndex!];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color:
                isCorrect ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isCorrect ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isCorrect ? Icons.check_rounded : Icons.close_rounded,
                  size: 18,
                  color: isCorrect ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                ),
              ),
              const SizedBox(width: 10),
              Text('Soal $number', style: const TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 6),
          Text(question.question, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Jawaban kamu: $selectedText', style: const TextStyle(fontWeight: FontWeight.w700)),
          Text(
            'Jawaban benar: ${question.options[question.correctIndex]}',
            style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF166534)),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.65),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              question.explanation,
              style: const TextStyle(color: Color(0xFF334155), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
