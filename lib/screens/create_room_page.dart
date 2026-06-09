import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/room_service.dart';
import '../widgets/app_panel.dart';
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
    final room = RoomService.instance.createRoom(title: _titleController.text, hostName: widget.user.name);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LobbyPage(user: widget.user, room: room)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Room')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: AppPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SectionTitle(icon: Icons.meeting_room_outlined, title: 'Sistem Room Code'),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Judul kuis', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(onPressed: _createRoom, icon: const Icon(Icons.add), label: const Text('Generate Room Code')),
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
