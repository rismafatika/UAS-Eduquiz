import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/room_service.dart';
import '../widgets/app_background.dart';
import '../widgets/app_panel.dart';
import '../widgets/logout_action.dart';
import '../widgets/section_title.dart';
import 'lobby_page.dart';

class JoinRoomPage extends StatefulWidget {
  const JoinRoomPage({super.key, required this.user});

  final AppUser user;

  @override
  State<JoinRoomPage> createState() => _JoinRoomPageState();
}

class _JoinRoomPageState extends State<JoinRoomPage> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _joinRoom() {
    final room = RoomService.instance.findRoom(_codeController.text);

    if (room == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Room code tidak ditemukan.')));
      return;
    }

    RoomService.instance.addParticipant(room: room, name: widget.user.name);
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => LobbyPage(user: widget.user, room: room)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gabung Room'),
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
                          icon: Icons.key, title: 'Masukkan Room Code'),
                      const SizedBox(height: 8),
                      const Text(
                          'Gunakan kode dari host untuk masuk ke lobby kelas.',
                          style: TextStyle(color: Color(0xFF64748B))),
                      const SizedBox(height: 18),
                      TextField(
                        controller: _codeController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                            labelText: 'Room code',
                            prefixIcon: Icon(Icons.pin_outlined)),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                          onPressed: _joinRoom,
                          icon: const Icon(Icons.login_rounded),
                          label: const Text('Gabung Lobby')),
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
