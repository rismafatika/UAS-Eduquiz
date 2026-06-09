import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../widgets/app_panel.dart';
import '../widgets/section_title.dart';
import 'create_room_page.dart';
import 'join_room_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final isHost = user.role == UserRole.host;

    return Scaffold(
      appBar: AppBar(
        title: const Text('EduQuiz'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Text(user.name)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isHost ? 'Dashboard Awal Host' : 'Masuk Room Kuis', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  Text(isHost ? 'Buat room code, kelola lobby, mulai kuis, dan pantau hasil.' : 'Masukkan room code dari host untuk bergabung ke lobby.'),
                  const SizedBox(height: 20),
                  AppPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SectionTitle(icon: isHost ? Icons.add_circle_outline : Icons.key, title: isHost ? 'Menu Host' : 'Menu Peserta'),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => isHost ? CreateRoomPage(user: user) : JoinRoomPage(user: user)),
                            );
                          },
                          icon: Icon(isHost ? Icons.meeting_room_outlined : Icons.login),
                          label: Text(isHost ? 'Buat Room Code' : 'Gabung Room'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const AppPanel(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(label: Text('Authentication')),
                        Chip(label: Text('Room code')),
                        Chip(label: Text('Lobby peserta')),
                        Chip(label: Text('Quiz real-time')),
                        Chip(label: Text('Leaderboard')),
                        Chip(label: Text('Review jawaban')),
                        Chip(label: Text('Dashboard host')),
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
