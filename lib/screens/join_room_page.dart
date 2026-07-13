import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../models/quiz_room.dart';
import '../services/room_service.dart';
import 'lobby_page.dart';

class JoinRoomPage extends StatefulWidget {
  final AppUser user;

  const JoinRoomPage({super.key, required this.user});

  @override
  State<JoinRoomPage> createState() => _JoinRoomPageState();
}

class _JoinRoomPageState extends State<JoinRoomPage> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;

  Future<void> _joinRoom() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan kode room')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final room = await RoomService.instance.findRoomConnected(code);
      if (room == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Room tidak ditemukan'),
              backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
        return;
      }

      // Cek apakah room sudah dimulai
      if (room.phase == QuizPhase.live || room.phase == QuizPhase.leaderboard) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Room sudah dimulai, tidak bisa bergabung'),
              backgroundColor: Colors.orange),
        );
        setState(() => _isLoading = false);
        return;
      }

      // Tambahkan peserta
      await RoomService.instance
          .addParticipant(room: room, name: widget.user.name);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LobbyPage(user: widget.user, room: room),
        ),
      );
    } catch (e) {
      debugPrint('Join room failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Gagal bergabung: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gabung Room')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Masukkan Kode Room',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Kode 6 digit',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.key),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _joinRoom,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Gabung'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
