import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/room_service.dart';
import '../widgets/app_panel.dart';
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
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _joinRoom() async {
    setState(() => _isLoading = true);
    final room = await RoomService.instance.findRoomConnected(_codeController.text);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (room == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Room code tidak ditemukan.')));
      return;
    }

    RoomService.instance.addParticipant(room: room, name: widget.user.name);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LobbyPage(user: widget.user, room: room)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gabung Room')),
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
                    const SectionTitle(icon: Icons.key, title: 'Masukkan Room Code'),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _codeController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(labelText: 'Room code', prefixIcon: Icon(Icons.pin_outlined), border: OutlineInputBorder()),
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
          ),
        ),
      ),
    );
  }
}
