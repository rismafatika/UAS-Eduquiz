import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/participant.dart';
import '../models/quiz_room.dart';
import '../services/room_service.dart';
import '../widgets/app_panel.dart';
import '../widgets/room_header.dart';
import '../widgets/section_title.dart';
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
  void _restartQuiz() {
    setState(() => RoomService.instance.startQuiz(widget.room));
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => QuizLivePage(user: widget.user, room: widget.room)));
  }

  void _openReview() {
    RoomService.instance.showReview(widget.room);
    Navigator.push(context, MaterialPageRoute(builder: (_) => ReviewPage(user: widget.user, room: widget.room)));
  }

  @override
  Widget build(BuildContext context) {
    final totalAnswers = widget.room.participants.fold<int>(0, (sum, participant) => sum + participant.answers.length);
    final maxAnswers = widget.room.participants.length * widget.room.questions.length;
    final averageScore = widget.room.participants.isEmpty
        ? 0
        : widget.room.participants.map((participant) => participant.score).reduce((a, b) => a + b) / widget.room.participants.length;

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
                        _MetricCard(label: 'Peserta', value: '${widget.room.participants.length}', icon: Icons.groups_2_outlined),
                        _MetricCard(label: 'Jawaban', value: '$totalAnswers/$maxAnswers', icon: Icons.checklist_rtl),
                        _MetricCard(label: 'Rata-rata', value: averageScore.toStringAsFixed(0), icon: Icons.bar_chart),
                      ];

                      if (compact) {
                        return Column(
                          children: cards.map((card) => Padding(padding: const EdgeInsets.only(bottom: 10), child: card)).toList(),
                        );
                      }

                      return Row(
                        children: cards.map((card) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 10), child: card))).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  AppPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionTitle(icon: Icons.dashboard_outlined, title: 'Kontrol dan Progres'),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            FilledButton.icon(onPressed: _restartQuiz, icon: const Icon(Icons.refresh), label: const Text('Mulai Ulang Quiz')),
                            OutlinedButton.icon(onPressed: _openReview, icon: const Icon(Icons.rate_review_outlined), label: const Text('Review Jawaban')),
                          ],
                        ),
                        const SizedBox(height: 18),
                        for (final participant in widget.room.participants) _ParticipantProgress(room: widget.room, participant: participant),
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

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value, required this.icon});

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
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
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
              Text(participant.name, style: const TextStyle(fontWeight: FontWeight.w800)),
              Text('${participant.score} poin'),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(value: participant.answers.length / room.questions.length),
        ],
      ),
    );
  }
}
