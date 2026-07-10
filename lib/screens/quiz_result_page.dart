import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/quiz_result.dart';
import '../models/quiz_room.dart';
import '../widgets/app_panel.dart';
import '../widgets/room_header.dart';
import '../widgets/section_title.dart';
import 'leaderboard_page.dart';
import 'review_page.dart';

class QuizResultPage extends StatelessWidget {
  const QuizResultPage({
    super.key,
    required this.user,
    required this.room,
    required this.result,
  });

  final AppUser user;
  final QuizRoom room;
  final QuizResult result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Quiz')),
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
                          icon: Icons.assignment_turned_in_outlined,
                          title: 'Hasil Akhir',
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF0F172A),
                                Color(0xFF1E293B),
                                Color(0xFF312E81),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(26),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 70,
                                height: 70,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF59E0B),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: Text(
                                  result.grade,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      result.participantName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    Text(
                                      '${result.totalScore} poin - ${result.percentage.toStringAsFixed(1)}%',
                                      style: const TextStyle(
                                        color: Color(0xFFE2E8F0),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final compact = constraints.maxWidth < 620;
                            final cards = [
                              _ResultMetric(label: 'Total Skor', value: '${result.totalScore}', icon: Icons.stars_outlined),
                              _ResultMetric(label: 'Benar', value: '${result.correctAnswers}', icon: Icons.check_circle_outline),
                              _ResultMetric(label: 'Salah', value: '${result.wrongAnswers}', icon: Icons.cancel_outlined),
                              _ResultMetric(label: 'Persentase', value: '${result.percentage.toStringAsFixed(1)}%', icon: Icons.percent),
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
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Rekap Cepat',
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(child: _MiniStat(icon: Icons.check_circle_outline, label: 'Benar', value: '${result.correctAnswers}')),
                                  const SizedBox(width: 10),
                                  Expanded(child: _MiniStat(icon: Icons.cancel_outlined, label: 'Salah', value: '${result.wrongAnswers}')),
                                  const SizedBox(width: 10),
                                  Expanded(child: _MiniStat(icon: Icons.percent, label: 'Akurasi', value: '${result.percentage.toStringAsFixed(1)}%')),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            FilledButton.icon(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => LeaderboardPage(user: user, room: room)),
                              ),
                              icon: const Icon(Icons.leaderboard_outlined),
                              label: const Text('Leaderboard'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => ReviewPage(user: user, room: room)),
                              ),
                              icon: const Icon(Icons.rate_review_outlined),
                              label: const Text('Review Jawaban'),
                            ),
                          ],
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

class _ResultMetric extends StatelessWidget {
  const _ResultMetric({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                Text(label, style: const TextStyle(color: Color(0xFF64748B))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          Text(label, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
