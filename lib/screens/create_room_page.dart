import 'dart:async';
import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../models/quiz_room.dart';
import '../models/participant.dart';
import '../services/room_service.dart';
import 'quiz_live_page.dart';

class CreateRoomPage extends StatefulWidget {
  const CreateRoomPage({super.key, required this.user});
  final AppUser user;

  @override
  State<CreateRoomPage> createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends State<CreateRoomPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _classController = TextEditingController();
  final TextEditingController _questionCountController =
      TextEditingController(text: '20');
  final TextEditingController _durationController =
      TextEditingController(text: '30');

  String _mode = 'Live Quiz';
  bool _shuffleQuestions = true;
  bool _shuffleAnswers = true;
  bool _allowLateJoin = true;

  QuizRoom? _room;
  List<Participant> _participants = [];
  bool _isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _createRoomAndSetup();
  }

  Future<void> _createRoomAndSetup() async {
    try {
      final room = await RoomService.instance.createRoom(
        title: 'Kuis EduQuiz',
        hostName: widget.user.name,
      );
      await RoomService.instance
          .addParticipant(room: room, name: widget.user.name);
      if (mounted) {
        setState(() {
          _room = room;
          _titleController.text = room.title;
          _participants = List.from(room.participants);
          _isLoading = false;
        });
        _refreshTimer =
            Timer.periodic(const Duration(seconds: 3), (timer) async {
          if (mounted && _room != null) {
            final updated =
                await RoomService.instance.findRoomConnected(_room!.code);
            if (updated != null) {
              setState(() {
                _participants = List.from(updated.participants);
              });
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Gagal membuat room: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    _classController.dispose();
    _questionCountController.dispose();
    _durationController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _startQuiz() async {
    if (_room == null) return;
    await RoomService.instance.startQuiz(_room!);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QuizLivePage(user: widget.user, room: _room!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_room == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Buat Room')),
        body:
            const Center(child: Text('Gagal membuat room. Silakan coba lagi.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Buat Room Quiz'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF0D9488),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildForm(),
              const SizedBox(height: 24),
              _buildRoomCode(),
              const SizedBox(height: 16),
              _buildStatusAndParticipants(),
              const SizedBox(height: 24),
              _buildStartButton(),
              const SizedBox(height: 12),
              _buildParticipantList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
                labelText: 'Judul Quiz',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _subjectController,
            decoration: const InputDecoration(
                labelText: 'Mata Pelajaran',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.book)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _classController,
            decoration: const InputDecoration(
                labelText: 'Kelas',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.class_)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _questionCountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Jumlah Soal',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.numbers)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _durationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Durasi (menit)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.timer)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Mode :',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(width: 16),
              Row(
                children: [
                  Radio<String>(
                    value: 'Live Quiz',
                    groupValue: _mode,
                    onChanged: (val) => setState(() => _mode = val!),
                    activeColor: const Color(0xFF0D9488),
                  ),
                  const Text('Live Quiz'),
                ],
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  Radio<String>(
                    value: 'Homework',
                    groupValue: _mode,
                    onChanged: (val) => setState(() => _mode = val!),
                    activeColor: const Color(0xFF0D9488),
                  ),
                  const Text('Homework'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Checkbox(
                value: _shuffleQuestions,
                onChanged: (val) => setState(() => _shuffleQuestions = val!),
                activeColor: const Color(0xFF0D9488),
              ),
              const Text('Acak Soal'),
              const SizedBox(width: 24),
              Checkbox(
                value: _shuffleAnswers,
                onChanged: (val) => setState(() => _shuffleAnswers = val!),
                activeColor: const Color(0xFF0D9488),
              ),
              const Text('Acak Jawaban'),
              const SizedBox(width: 24),
              Checkbox(
                value: _allowLateJoin,
                onChanged: (val) => setState(() => _allowLateJoin = val!),
                activeColor: const Color(0xFF0D9488),
              ),
              const Text('Izinkan Join Terlambat'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCode() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D9488).withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF0D9488).withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Kode Room',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0D9488))),
          Text(_room!.code,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0D9488),
                  letterSpacing: 2)),
        ],
      ),
    );
  }

  Widget _buildStatusAndParticipants() {
    final status = _room!.phase == QuizPhase.lobby
        ? 'Belum Dimulai'
        : _room!.phase == QuizPhase.live
            ? 'Sedang Berlangsung'
            : 'Selesai';
    final statusColor = _room!.phase == QuizPhase.lobby
        ? Colors.orange
        : _room!.phase == QuizPhase.live
            ? Colors.green
            : Colors.grey;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Icon(Icons.person_outline, color: Colors.grey.shade600),
            const SizedBox(width: 6),
            Text('Peserta : ${_participants.length}',
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ]),
          Row(children: [
            Container(
                width: 10,
                height: 10,
                decoration:
                    BoxDecoration(color: statusColor, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(status,
                style:
                    TextStyle(fontWeight: FontWeight.w600, color: statusColor)),
          ]),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _startQuiz,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0D9488),
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 4,
        ),
        child: const Text('MULAI QUIZ',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 1)),
      ),
    );
  }

  Widget _buildParticipantList() {
    if (_participants.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: const Center(
            child: Text('Belum ada peserta yang bergabung',
                style: TextStyle(color: Colors.grey))),
      );
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Peserta yang sudah bergabung',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0D9488))),
          const SizedBox(height: 8),
          ..._participants.asMap().entries.map((entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(children: [
                  Text('${entry.key + 1}. ',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(entry.value.name),
                ]),
              )),
          const Divider(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Total', style: TextStyle(fontWeight: FontWeight.w600)),
            Text('${_participants.length} Peserta',
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ]),
        ],
      ),
    );
  }
}
