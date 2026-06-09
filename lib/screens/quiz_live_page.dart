import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/participant.dart';
import '../models/quiz_room.dart';
import '../services/room_service.dart';
import '../widgets/app_panel.dart';
import '../widgets/room_header.dart';
import 'leaderboard_page.dart';

class QuizLivePage extends StatefulWidget {
  const QuizLivePage({super.key, required this.user, required this.room});

  final AppUser user;
  final QuizRoom room;

  @override
  State<QuizLivePage> createState() => _QuizLivePageState();
}

class _QuizLivePageState extends State<QuizLivePage> {
  Participant get _participant {
    return RoomService.instance.addParticipant(room: widget.room, name: widget.user.name);
  }

  bool get _isHost => widget.user.role == UserRole.host;

  void _answer(int index) {
    setState(() {
      RoomService.instance.answerQuestion(room: widget.room, participant: _participant, answerIndex: index);
    });

    if (widget.room.phase == QuizPhase.leaderboard) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LeaderboardPage(user: widget.user, room: widget.room)));
    }
  }

  void _finishFromHost() {
    setState(() => RoomService.instance.showLeaderboard(widget.room));
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LeaderboardPage(user: widget.user, room: widget.room)));
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.room.questions[widget.room.currentQuestionIndex];
    final progress = (widget.room.currentQuestionIndex + 1) / widget.room.questions.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Real-Time')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RoomHeader(room: widget.room),
                  const SizedBox(height: 16),
                  AppPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Soal ${widget.room.currentQuestionIndex + 1}/${widget.room.questions.length}', style: const TextStyle(fontWeight: FontWeight.w900)),
                            Text('${_participant.score} poin'),
                          ],
                        ),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(value: progress),
                        const SizedBox(height: 18),
                        Text(question.question, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 18),
                        for (var i = 0; i < question.options.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: OutlinedButton(
                              onPressed: _isHost ? null : () => _answer(i),
                              style: OutlinedButton.styleFrom(
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.all(16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text(question.options[i]),
                            ),
                          ),
                        if (_isHost)
                          FilledButton.icon(onPressed: _finishFromHost, icon: const Icon(Icons.leaderboard_outlined), label: const Text('Tampilkan Leaderboard')),
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
