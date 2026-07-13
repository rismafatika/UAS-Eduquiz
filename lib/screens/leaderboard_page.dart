import 'dart:async';

import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/participant.dart';
import '../models/quiz_room.dart';
import '../services/room_service.dart';
import '../services/supabase_service.dart';
import '../widgets/app_panel.dart';
import '../widgets/room_header.dart';
import '../widgets/section_title.dart';
import 'host_dashboard_page.dart';
import 'review_page.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key, required this.user, required this.room});

  final AppUser user;
  final QuizRoom room;

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  Timer? _refreshTimer;
  late QuizRoom _room;

  bool get _isHost => widget.user.role == UserRole.host;

  @override
  void initState() {
    super.initState();
    _room = widget.room;
    _syncRoom();
    SupabaseService.instance.subscribeRoom(_room.code, () {
      unawaited(_syncRoom());
    });
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      unawaited(_syncRoom());
    });
  }

  Future<void> _syncRoom() async {
    try {
      final updated = await RoomService.instance.findRoomConnected(_room.code);
      if (!mounted || updated == null) {
        return;
      }

      setState(() {
        _room.phase = updated.phase;
        _room.currentQuestionIndex = updated.currentQuestionIndex;
        _room.participants
          ..clear()
          ..addAll(updated.participants);
      });
    } catch (e) {
      debugPrint('Leaderboard sync failed: $e');
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final participants = [..._room.participants]
      ..sort((a, b) => b.score.compareTo(a.score));

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Center(
            child: Text(
              '←',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
          ),
        ),
        title: const Text('Leaderboard'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RoomHeader(room: _room),
                  const SizedBox(height: 16),
                  AppPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionTitle(
                          icon: Icons.leaderboard_outlined,
                          leadingText: '🏆',
                          title: 'Leaderboard Otomatis',
                        ),
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
                                RoomService.instance.showReview(_room);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ReviewPage(
                                      user: widget.user,
                                      room: _room,
                                    ),
                                  ),
                                );
                              },
                              icon: const Text('📝'),
                              label: const Text('Review Jawaban'),
                            ),
                            if (_isHost)
                              OutlinedButton.icon(
                                onPressed: () {
                                  RoomService.instance.showDashboard(_room);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => HostDashboardPage(
                                        user: widget.user,
                                        room: _room,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Text('📊'),
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
        border: Border.all(
          color: rank == 1 ? const Color(0xFFFDE68A) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Text('#$rank',
                style: const TextStyle(fontWeight: FontWeight.w900)),
          ),
          Expanded(
            child: Text(participant.name,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          Text('${participant.score} poin'),
        ],
      ),
    );
  }
}
