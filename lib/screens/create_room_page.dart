import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/room_service.dart';
import '../widgets/app_background.dart';
import '../widgets/app_panel.dart';
import '../widgets/logout_action.dart';
import '../widgets/section_title.dart';
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
    final room = RoomService.instance
        .createRoom(title: _titleController.text, hostName: widget.user.name);
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => LobbyPage(user: widget.user, room: room)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Room'),
        actions: const [LogoutAction(), SizedBox(width: 8)],
      ),
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: AppPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SectionTitle(
                          icon: Icons.meeting_room_outlined,
                          title: 'Sistem Room Code'),
                      const SizedBox(height: 8),
                      const Text(
                          'Beri judul kuis, lalu bagikan kode room ke peserta.',
                          style: TextStyle(color: Color(0xFF64748B))),
                      const SizedBox(height: 18),
                      TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                            labelText: 'Judul kuis',
                            prefixIcon: Icon(Icons.title_rounded)),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                          onPressed: _createRoom,
                          icon: const Icon(Icons.add),
                          label: const Text('Generate Room Code')),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
