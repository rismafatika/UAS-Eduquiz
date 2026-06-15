import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/participant.dart';
import '../models/quiz_room.dart';
import '../widgets/app_background.dart';
import '../widgets/app_panel.dart';
import '../widgets/logout_action.dart';
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
    final participants = [...room.participants]
      ..sort((a, b) => b.score.compareTo(a.score));
    final isHost = user.role == UserRole.host;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
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
                              icon: Icons.leaderboard_outlined,
                              title: 'Leaderboard Otomatis'),
                          const SizedBox(height: 12),
                          for (var i = 0; i < participants.length; i++)
                            _RankRow(rank: i + 1, participant: participants[i]),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              FilledButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => ReviewPage(
                                              user: user, room: room)));
                                },
                                icon: const Icon(Icons.rate_review_outlined),
                                label: const Text('Review Jawaban'),
                              ),
                              if (isHost)
                                OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => HostDashboardPage(
                                                user: user, room: room)));
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
    final isWinner = rank == 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isWinner ? const Color(0xFFFFFBEB) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color:
                isWinner ? const Color(0xFFFDE68A) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: isWinner
                ? const Color(0xFFF59E0B)
                : Theme.of(context).colorScheme.primary,
            child: Text('$rank',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Text(participant.name,
                  style: const TextStyle(fontWeight: FontWeight.w800))),
          Text('${participant.score} poin',
              style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
