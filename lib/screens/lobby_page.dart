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
  const LobbyPage({
    super.key,
    required this.user,
    required this.room,
  });

  final AppUser user;
  final QuizRoom room;

  @override
  State<LobbyPage> createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  bool get _isHost => widget.user.role == UserRole.host;

  void _startQuiz() {
    RoomService.instance.startQuiz(widget.room);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => QuizLivePage(
          user: widget.user,
          room: widget.room,
        ),
      ),
    );
  }

  void _openDashboard() {
    RoomService.instance.showDashboard(widget.room);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HostDashboardPage(
          user: widget.user,
          room: widget.room,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Jika peserta dan quiz sudah dimulai, otomatis masuk ke halaman quiz
    if (!_isHost && widget.room.phase == QuizPhase.live) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => QuizLivePage(
              user: widget.user,
              room: widget.room,
            ),
          ),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lobby Room"),
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
                  RoomHeader(room: widget.room),

                  const SizedBox(height: 20),

                  AppPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionTitle(
                          icon: Icons.groups,
                          title: "Lobby Peserta",
                        ),

                        const SizedBox(height: 15),
                        Text(
                          _isHost
                              ? 'Peserta yang bergabung akan muncul di bawah. Siap mulai kapan saja.'
                              : 'Tunggu host memulai quiz. Kamu akan otomatis masuk ketika sesi live dimulai.',
                          style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 14),

                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: widget.room.participants
                              .map(
                                (e) => Chip(
                                  avatar: const Icon(
                                    Icons.person,
                                    size: 18,
                                  ),
                                  label: Text(e.name),
                                ),
                              )
                              .toList(),
                        ),

                        const SizedBox(height: 20),

                        if (_isHost)
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: _startQuiz,
                                  icon: const Icon(Icons.play_arrow),
                                  label: const Text("Mulai Quiz"),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _openDashboard,
                                  icon: const Icon(Icons.dashboard),
                                  label: const Text("Dashboard Host"),
                                ),
                              ),
                            ],
                          )
                        else
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: const Text(
                              "Menunggu host memulai quiz...",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
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
