import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/participant.dart';
import '../models/quiz_question.dart';
import '../models/quiz_room.dart';
import '../widgets/app_background.dart';
import '../widgets/app_panel.dart';
import '../widgets/logout_action.dart';
import '../widgets/room_header.dart';
import '../widgets/section_title.dart';

class ReviewPage extends StatelessWidget {
  const ReviewPage({super.key, required this.user, required this.room});

  final AppUser user;
  final QuizRoom room;

  Participant? get _activeParticipant {
    if (room.participants.isEmpty) return null;

    return room.participants.firstWhere(
      (participant) => participant.name == user.name,
      orElse: () => room.participants.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeParticipant = _activeParticipant;
    final answeredCount = activeParticipant?.answers.length ?? 0;
    final totalQuestions = room.questions.length;
    final correctCount = activeParticipant == null
        ? 0
        : room.questions
            .asMap()
            .entries
            .where((entry) =>
                activeParticipant.answers[entry.key] ==
                entry.value.correctIndex)
            .length;
    final accuracy =
        totalQuestions == 0 ? 0 : (correctCount / totalQuestions * 100).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Jawaban'),
        actions: const [LogoutAction(), SizedBox(width: 8)],
      ),
      body: AppBackground(
        child: SafeArea(
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
                              title: 'Review Jawaban'),
                          const SizedBox(height: 12),
                          if (activeParticipant == null)
                            const _ReviewEmpty()
                          else ...[
                            _ReviewSummary(
                              score: activeParticipant.score,
                              answered: answeredCount,
                              total: totalQuestions,
                              accuracy: accuracy,
                            ),
                            const SizedBox(height: 12),
                            for (var i = 0; i < room.questions.length; i++)
                              _ReviewCard(
                                number: i + 1,
                                question: room.questions[i],
                                selectedIndex: activeParticipant.answers[i],
                              ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewSummary extends StatelessWidget {
  const _ReviewSummary({
    required this.score,
    required this.answered,
    required this.total,
    required this.accuracy,
  });

  final int score;
  final int answered;
  final int total;
  final int accuracy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _SummaryPill(
              icon: Icons.stars_rounded,
              label: '$score poin',
              color: Theme.of(context).colorScheme.tertiary),
          _SummaryPill(
              icon: Icons.checklist_rtl,
              label: '$answered/$total dijawab',
              color: Theme.of(context).colorScheme.primary),
          _SummaryPill(
              icon: Icons.percent_rounded,
              label: '$accuracy% benar',
              color: const Color(0xFF16A34A)),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill(
      {required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(color: color, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _ReviewEmpty extends StatelessWidget {
  const _ReviewEmpty();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Column(
        children: [
          Icon(Icons.fact_check_outlined, color: Color(0xFF64748B), size: 34),
          SizedBox(height: 8),
          Text('Belum ada jawaban peserta',
              style: TextStyle(fontWeight: FontWeight.w900)),
        ],
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
    final color = isCorrect ? const Color(0xFF16A34A) : const Color(0xFFDC2626);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCorrect ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color:
                isCorrect ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                  isCorrect
                      ? Icons.check_circle_outline
                      : Icons.cancel_outlined,
                  color: color),
              const SizedBox(width: 8),
              Text('Soal $number',
                  style: TextStyle(fontWeight: FontWeight.w900, color: color)),
            ],
          ),
          const SizedBox(height: 8),
          Text(question.question,
              style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(
              'Jawaban kamu: ${selectedIndex == null ? '-' : question.options[selectedIndex!]}'),
          Text('Jawaban benar: ${question.options[question.correctIndex]}'),
          const SizedBox(height: 8),
          Text(question.explanation,
              style: const TextStyle(color: Color(0xFF475569), height: 1.35)),
        ],
      ),
    );
  }
}
