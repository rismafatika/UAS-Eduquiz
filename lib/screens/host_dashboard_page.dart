import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/participant.dart';
import '../models/quiz_room.dart';
import '../models/quiz_result.dart';
import '../services/room_service.dart';
import '../widgets/app_panel.dart';
import '../widgets/room_header.dart';
import '../widgets/section_title.dart';
import 'leaderboard_page.dart';
import 'manage_questions_page.dart';
import 'quiz_live_page.dart';
import 'review_page.dart';

class HostDashboardPage extends StatefulWidget {
  const HostDashboardPage({super.key, required this.user, required this.room});

  final AppUser user;
  final QuizRoom room;

  @override
  State<HostDashboardPage> createState() => _HostDashboardPageState();
}

class _HostDashboardPageState extends State<HostDashboardPage> {
  int _demoParticipantCounter = 1;

  void _restartQuiz() {
    setState(() => RoomService.instance.startQuiz(widget.room));
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) =>
                QuizLivePage(user: widget.user, room: widget.room)));
  }

  void _openReview() {
    RoomService.instance.showReview(widget.room);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ReviewPage(user: widget.user, room: widget.room)));
  }

  void _openLeaderboard() {
    RoomService.instance.showLeaderboard(widget.room);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) =>
                LeaderboardPage(user: widget.user, room: widget.room)));
  }

  void _openManageQuestions() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ManageQuestionsPage(user: widget.user, room: widget.room),
      ),
    ).then((_) => setState(() {}));
  }

  void _addDemoParticipant() {
    setState(() {
      RoomService.instance.addParticipant(
        room: widget.room,
        name: 'Peserta Demo $_demoParticipantCounter',
      );
      _demoParticipantCounter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalAnswers = widget.room.participants
        .fold<int>(0, (sum, participant) => sum + participant.answers.length);
    final maxAnswers =
        widget.room.participants.length * widget.room.questions.length;
    final averageScore = widget.room.participants.isEmpty
        ? 0
        : widget.room.participants
                .map((participant) => participant.score)
                .reduce((a, b) => a + b) /
            widget.room.participants.length;
    final topStreak = widget.room.participants.isEmpty
        ? 0
        : widget.room.participants
            .map((participant) => participant.streak)
            .reduce((a, b) => a > b ? a : b);
    final participantResults = widget.room.participants
        .where((participant) => participant.answers.isNotEmpty)
        .map((participant) => RoomService.instance.resultForParticipant(
              room: widget.room,
              participant: participant,
            ))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Host')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RoomHeader(room: widget.room),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 720;
                      final cards = [
                        _MetricCard(
                            label: 'Peserta',
                            value: '${widget.room.participants.length}',
                            icon: Icons.groups_2_outlined),
                        _MetricCard(
                            label: 'Jawaban',
                            value: '$totalAnswers/$maxAnswers',
                            icon: Icons.checklist_rtl),
                        _MetricCard(
                            label: 'Rata-rata',
                            value: averageScore.toStringAsFixed(0),
                            icon: Icons.bar_chart),
                        _MetricCard(
                            label: 'Top streak',
                            value: '$topStreak',
                            icon: Icons.local_fire_department_outlined),
                      ];

                      if (compact) {
                        return Column(
                          children: cards
                              .map((card) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: card))
                              .toList(),
                        );
                      }

                      return Row(
                        children: cards
                            .map((card) => Expanded(
                                child: Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: card)))
                            .toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  AppPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionTitle(
                            icon: Icons.dashboard_outlined,
                            title: 'Kontrol dan Progres'),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            FilledButton.icon(
                                onPressed: _restartQuiz,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Mulai Ulang Quiz')),
                            OutlinedButton.icon(
                                onPressed: _openLeaderboard,
                                icon: const Icon(Icons.leaderboard_outlined),
                                label: const Text('Leaderboard')),
                            OutlinedButton.icon(
                                onPressed: _openReview,
                                icon: const Icon(Icons.rate_review_outlined),
                                label: const Text('Review Jawaban')),
                            OutlinedButton.icon(
                                onPressed: _openManageQuestions,
                                icon: const Icon(Icons.edit_note_outlined),
                                label: const Text('Kelola Soal')),
                            OutlinedButton.icon(
                                onPressed: _addDemoParticipant,
                                icon:
                                    const Icon(Icons.person_add_alt_1_outlined),
                                label: const Text('Tambah Peserta Demo')),
                          ],
                        ),
                        const SizedBox(height: 18),
                        for (final participant in widget.room.participants)
                          _ParticipantProgress(
                              room: widget.room, participant: participant),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionTitle(
                            icon: Icons.assignment_turned_in_outlined,
                            title: 'Hasil Peserta'),
                        const SizedBox(height: 12),
                        if (participantResults.isEmpty)
                          const Text(
                            'Belum ada peserta yang menjawab quiz.',
                            style: TextStyle(color: Color(0xFF64748B)),
                          )
                        else
                          for (final result in participantResults)
                            _ParticipantResultRow(result: result),
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

class _ParticipantResultRow extends StatelessWidget {
  const _ParticipantResultRow({required this.result});

  final QuizResult result;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(result.grade, style: const TextStyle(fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result.participantName, style: const TextStyle(fontWeight: FontWeight.w800)),
                Text(
                  '${result.correctAnswers} benar - ${result.wrongAnswers} salah - ${result.percentage.toStringAsFixed(1)}%',
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                ),
              ],
            ),
          ),
          Text('${result.totalScore} poin', style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard(
      {required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w900)),
              Text(label),
            ],
          ),
        ],
      ),
    );
  }
}

class _ParticipantProgress extends StatelessWidget {
  const _ParticipantProgress({required this.room, required this.participant});

  final QuizRoom room;
  final Participant participant;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(participant.name,
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              Text('${participant.score} poin | Lv ${participant.level}'),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
              value: participant.answers.length / room.questions.length),
          const SizedBox(height: 4),
          Text(
            '${participant.answers.length}/${room.questions.length} jawaban - ${participant.streak} streak - ${participant.rankTitle}',
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
        ],
      ),
    );
  }
}
