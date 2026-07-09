import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/room_service.dart';
import '../widgets/app_panel.dart';
import '../widgets/pro_page.dart';
import '../widgets/section_title.dart';
import '../widgets/status_badge.dart';
import 'lobby_page.dart';

class CreateRoomPage extends StatefulWidget {
  const CreateRoomPage({super.key, required this.user});

  final AppUser user;

  @override
  State<CreateRoomPage> createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends State<CreateRoomPage> {
  final _titleController = TextEditingController(text: 'Kuis EduQuiz');

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _createRoom() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul kuis tidak boleh kosong.')),
      );
      return;
    }

    final room = RoomService.instance.createRoom(
      title: _titleController.text,
      hostName: widget.user.name,
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (_) => LobbyPage(user: widget.user, room: room)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Room')),
      body: ProPage(
        title: 'Buat Sesi Kuis',
        subtitle:
            'Generate room code unik, bagikan ke peserta, lalu pantau semua aktivitas dari dashboard host.',
        maxWidth: 760,
        child: AppPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionTitle(
                  icon: Icons.meeting_room_outlined, title: 'Sistem Room Code'),
              const SizedBox(height: 14),
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  StatusBadge(
                      label: 'Kode unik',
                      icon: Icons.pin_outlined,
                      color: Color(0xFF1D4ED8)),
                  StatusBadge(
                      label: 'Lobby aktif',
                      icon: Icons.groups_2_outlined,
                      color: Color(0xFF14B8A6)),
                ],
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul kuis',
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _createRoom,
                icon: const Icon(Icons.add),
                label: const Text('Generate Room Code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
