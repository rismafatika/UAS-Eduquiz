import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/participant.dart';
import '../models/quiz_room.dart';
import '../services/room_service.dart';
import '../widgets/app_background.dart';
import '../widgets/app_panel.dart';
import '../widgets/logout_action.dart';
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
    return RoomService.instance
        .addParticipant(room: widget.room, name: widget.user.name);
  }

  bool get _isHost => widget.user.role == UserRole.host;

  void _answer(int index) {
    setState(() {
      RoomService.instance.answerQuestion(
          room: widget.room, participant: _participant, answerIndex: index);
    });

    if (widget.room.phase == QuizPhase.leaderboard) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  LeaderboardPage(user: widget.user, room: widget.room)));
    }
  }

  void _finishFromHost() {
    setState(() => RoomService.instance.showLeaderboard(widget.room));
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) =>
                LeaderboardPage(user: widget.user, room: widget.room)));
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.room.questions[widget.room.currentQuestionIndex];
    final progress =
        (widget.room.currentQuestionIndex + 1) / widget.room.questions.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Real-Time'),
        actions: const [LogoutAction(), SizedBox(width: 8)],
      ),
      body: AppBackground(
        child: SafeArea(
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
                              Text(
                                  'Soal ${widget.room.currentQuestionIndex + 1}/${widget.room.questions.length}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w900)),
                              Text('${_participant.score} poin',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          LinearProgressIndicator(value: progress),
                          const SizedBox(height: 20),
                          Text(question.question,
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  height: 1.18)),
                          const SizedBox(height: 18),
                          for (var i = 0; i < question.options.length; i++)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: OutlinedButton.icon(
                                onPressed: _isHost ? null : () => _answer(i),
                                style: OutlinedButton.styleFrom(
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.all(16),
                                ),
                                icon: CircleAvatar(
                                  radius: 14,
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.1),
                                  child: Text(String.fromCharCode(65 + i),
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary)),
                                ),
                                label: Text(question.options[i]),
                              ),
                            ),
                          if (_isHost)
                            FilledButton.icon(
                              onPressed: _finishFromHost,
                              icon: const Icon(Icons.leaderboard_outlined),
                              label: const Text('Tampilkan Leaderboard'),
                            ),
                        ],
                      ),
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
