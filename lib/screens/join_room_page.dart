import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../services/room_service.dart';
import '../services/supabase_service.dart';
import 'lobby_page.dart';

class JoinRoomPage extends StatefulWidget {
  const JoinRoomPage({super.key, required this.user});
  final AppUser user;

  @override
  State<JoinRoomPage> createState() => _JoinRoomPageState();
}

class _JoinRoomPageState extends State<JoinRoomPage> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;

  // ─── DATA DUMMY ──────────────────────────────────────────────
  // Data room aktif (bisa diganti dengan data dari RoomService nanti)
  final List<Map<String, dynamic>> _activeRooms = [
    {
      'id': '1',
      'title': 'Matematika XI',
      'host': 'Pak Budi',
      'participants': 25,
      'code': 'MATH123',
      'status': 'active',
    },
    {
      'id': '2',
      'title': 'Bahasa Indonesia',
      'host': 'Bu Sinta',
      'participants': 18,
      'code': 'BIND456',
      'status': 'active',
    },
    {
      'id': '3',
      'title': 'IPA',
      'host': 'Pak Andi',
      'participants': 30,
      'code': 'IPA789',
      'status': 'active',
    },
  ];

  // Data riwayat room
  final List<Map<String, dynamic>> _historyRooms = [
    {'title': 'MTK Bab 3', 'score': 90},
    {'title': 'Bahasa Indonesia', 'score': 85},
    {'title': 'IPA', 'score': 100},
  ];

  // ─── FUNGSI ──────────────────────────────────────────────────
  Future<void> _joinRoom() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Masukkan kode room'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    final room = await RoomService.instance.findRoomConnected(code);
    setState(() => _isLoading = false);
    if (!mounted) return;

    if (room == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Room tidak ditemukan'), backgroundColor: Colors.red),
      );
      return;
    }

    RoomService.instance.addParticipant(room: room, name: widget.user.name);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (_) => LobbyPage(user: widget.user, room: room)),
    );
  }

  void _joinActiveRoom(String code) {
    _codeController.text = code;
    _joinRoom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0D9488)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Gabung Room',
          style: TextStyle(
            color: Color(0xFF0D9488),
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── 1. INPUT KODE ROOM ──────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.key_rounded,
                            color: Color(0xFF0D9488), size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Masukkan Kode Room',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF064E3B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _codeController,
                      decoration: InputDecoration(
                        hintText: 'Contoh: MATH123',
                        prefixIcon: const Icon(Icons.pin_outlined,
                            color: Color(0xFF0D9488)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFF0D9488), width: 2),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      onSubmitted: (_) => _joinRoom(),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _joinRoom,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.login_rounded),
                        label: Text(
                            _isLoading ? 'Memproses...' : 'Gabung Sekarang'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D9488),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ─── 2. ROOM AKTIF ─────────────────────────────
              const Row(
                children: [
                  Icon(Icons.wifi_rounded, color: Color(0xFF0D9488), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Room Aktif',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF064E3B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ..._activeRooms.map((room) => _ActiveRoomCard(
                    room: room,
                    onJoin: () => _joinActiveRoom(room['code']),
                  )),
              const SizedBox(height: 24),

              // ─── 3. RIWAYAT ROOM ────────────────────────────
              const Row(
                children: [
                  Icon(Icons.history_edu_outlined,
                      color: Color(0xFF0D9488), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Riwayat Room',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF064E3B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ..._historyRooms
                  .map((history) => _HistoryRoomCard(history: history)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── WIDGET ROOM AKTIF ──────────────────────────────────────
class _ActiveRoomCard extends StatelessWidget {
  final Map<String, dynamic> room;
  final VoidCallback onJoin;

  const _ActiveRoomCard({required this.room, required this.onJoin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Status dot hijau
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Color(0xFF059669),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          // Informasi room
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF064E3B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Host: ${room['host']} • ${room['participants']} Peserta',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          // Tombol gabung
          ElevatedButton(
            onPressed: onJoin,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Gabung',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ─── WIDGET RIWAYAT ROOM ────────────────────────────────────
class _HistoryRoomCard extends StatelessWidget {
  final Map<String, dynamic> history;

  const _HistoryRoomCard({required this.history});

  Color get _scoreColor {
    final score = history['score'] as int;
    if (score >= 90) return const Color(0xFF059669);
    if (score >= 75) return const Color(0xFFF59E0B);
    return const Color(0xFFDC2626);
  }

  String get _scoreLabel {
    final score = history['score'] as int;
    if (score >= 90) return 'Sempurna!';
    if (score >= 75) return 'Bagus';
    return 'Perlu Latihan';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _scoreColor.withOpacity(0.1),
              shape: BoxShape.circle,
              border:
                  Border.all(color: _scoreColor.withOpacity(0.3), width: 1.5),
            ),
            child: Center(
              child: Icon(
                Icons.check_circle_rounded,
                color: _scoreColor,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  history['title'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF064E3B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _scoreLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _scoreColor,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${history['score']}',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: _scoreColor,
            ),
          ),
        ],
      ),
    );
  }
}
