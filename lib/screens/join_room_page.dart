import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/quiz_room.dart';
import '../services/room_service.dart';
import '../services/supabase_service.dart';
import '../widgets/app_panel.dart';
import '../widgets/pro_page.dart';
import '../widgets/section_title.dart';
import '../widgets/status_badge.dart';
import 'leaderboard_page.dart';
import 'lobby_page.dart';
import 'quiz_live_page.dart';
import 'review_page.dart';

class JoinRoomPage extends StatefulWidget {
  const JoinRoomPage({super.key, required this.user});

  final AppUser user;

  @override
  State<JoinRoomPage> createState() => _JoinRoomPageState();
}

class _JoinRoomPageState extends State<JoinRoomPage> {
  final _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _joinRoom() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan room code terlebih dahulu.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final room = await RoomService.instance.findRoomConnected(code);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (room == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Room code tidak ditemukan.')),
      );
      return;
    }

    RoomService.instance.addParticipant(room: room, name: widget.user.name);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) {
        return switch (room.phase) {
          QuizPhase.live => QuizLivePage(user: widget.user, room: room),
          QuizPhase.leaderboard => LeaderboardPage(user: widget.user, room: room),
          QuizPhase.review => ReviewPage(user: widget.user, room: room),
          _ => LobbyPage(user: widget.user, room: room),
        };
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gabung Room')),
      body: ProPage(
        title: 'Gabung Sesi Kuis',
        subtitle: 'Masukkan room code dari host. Jika Supabase aktif, aplikasi juga mencari room dari database online.',
        maxWidth: 760,
        child: AppPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionTitle(icon: Icons.key, title: 'Masukkan Room Code'),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  const StatusBadge(label: 'Lobby peserta', icon: Icons.groups_2_outlined, color: Color(0xFF1D4ED8)),
                  StatusBadge(
                    label: SupabaseService.instance.isReady ? 'Online sync' : 'Local only',
                    icon: SupabaseService.instance.isReady ? Icons.cloud_done_outlined : Icons.storage_outlined,
                    color: SupabaseService.instance.isReady ? const Color(0xFF16A34A) : const Color(0xFFF59E0B),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Room code',
                  prefixIcon: Icon(Icons.pin_outlined),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _isLoading ? null : _joinRoom,
                icon: Icon(_isLoading ? Icons.hourglass_top : Icons.login),
                label: Text(_isLoading ? 'Mencari room...' : 'Gabung Lobby'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
