import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/quiz_room.dart';
import '../services/room_service.dart';
import '../widgets/app_panel.dart';
import '../widgets/room_header.dart';
import '../widgets/section_title.dart';
import 'host_dashboard_page.dart';
import 'quiz_live_page.dart';

class LobbyPage extends StatefulWidget {
  const LobbyPage({super.key, required this.user, required this.room});

  final AppUser user;
  final QuizRoom room;

  @override
  State<LobbyPage> createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  bool get _isHost => widget.user.role == UserRole.host;

  void _startQuiz() {
    setState(() => RoomService.instance.startQuiz(widget.room));
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => QuizLivePage(user: widget.user, room: widget.room)));
  }

  void _openDashboard() {
    RoomService.instance.showDashboard(widget.room);
    Navigator.push(context, MaterialPageRoute(builder: (_) => HostDashboardPage(user: widget.user, room: widget.room)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lobby Room')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RoomHeader(room: widget.room),
                  const SizedBox(height: 16),
                  AppPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionTitle(icon: Icons.groups_2_outlined, title: 'Lobby Peserta'),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: widget.room.participants
                              .map((participant) => Chip(avatar: const Icon(Icons.person_outline, size: 18), label: Text(participant.name)))
                              .toList(),
                        ),
                        const SizedBox(height: 18),
                        if (_isHost)
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              FilledButton.icon(onPressed: _startQuiz, icon: const Icon(Icons.play_arrow), label: const Text('Mulai Quiz')),
                              OutlinedButton.icon(onPressed: _openDashboard, icon: const Icon(Icons.dashboard_outlined), label: const Text('Dashboard Host')),
                            ],
                          )
                        else
                          const Text('Menunggu host memulai quiz...'),
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
