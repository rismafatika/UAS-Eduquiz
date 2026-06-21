import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/participant.dart';
import '../models/quiz_room.dart';
import '../services/room_service.dart';
import '../widgets/app_panel.dart';
import '../widgets/room_header.dart';
import '../widgets/section_title.dart';
import 'host_dashboard_page.dart';
import 'review_page.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key, required this.user, required this.room});

  final AppUser user;
  final QuizRoom room;

  @override
  Widget build(BuildContext context) {
    final participants = [...room.participants]..sort((a, b) => b.score.compareTo(a.score));
    final isHost = user.role == UserRole.host;

    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
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
                        const SectionTitle(icon: Icons.leaderboard_outlined, title: 'Leaderboard Otomatis'),
                        const SizedBox(height: 12),
                        for (var i = 0; i < participants.length; i++) _RankRow(rank: i + 1, participant: participants[i]),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            FilledButton.icon(
                              onPressed: () {
                                RoomService.instance.showReview(room);
                                Navigator.push(context, MaterialPageRoute(builder: (_) => ReviewPage(user: user, room: room)));
                              },
                              icon: const Icon(Icons.rate_review_outlined),
                              label: const Text('Review Jawaban'),
                            ),
                            if (isHost)
                              OutlinedButton.icon(
                                onPressed: () {
                                  RoomService.instance.showDashboard(room);
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => HostDashboardPage(user: user, room: room)));
                                },
                                icon: const Icon(Icons.dashboard_outlined),
                                label: const Text('Dashboard Host'),
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

class _RankRow extends StatelessWidget {
  const _RankRow({required this.rank, required this.participant});

  final int rank;
  final Participant participant;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: rank == 1 ? const Color(0xFFFFFBEB) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: rank == 1 ? const Color(0xFFFDE68A) : const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          SizedBox(width: 44, child: Text('#$rank', style: const TextStyle(fontWeight: FontWeight.w900))),
          Expanded(child: Text(participant.name, style: const TextStyle(fontWeight: FontWeight.w700))),
          Text('${participant.score} poin'),
        ],
      ),
    );
  }
}
