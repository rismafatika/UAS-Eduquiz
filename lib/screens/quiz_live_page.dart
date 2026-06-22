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
  }

  void _nextQuestion() {
    setState(() => RoomService.instance.advanceQuestion(widget.room));
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
    final selectedIndex = _participant.answers[widget.room.currentQuestionIndex];
    final hasAnswered = selectedIndex != null;
    final isCorrect = selectedIndex == question.correctIndex;

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
                            Text('${_participant.score} poin | Lv ${_participant.level}'),
                          ],
                        ),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(value: progress),
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Chip(label: Text(question.category)),
                            Chip(label: Text('${question.points} poin')),
                            if (_participant.streak > 0) Chip(label: Text('Streak ${_participant.streak}')),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(question.question, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 18),
                        for (var i = 0; i < question.options.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: OutlinedButton(
                              onPressed: _isHost || hasAnswered ? null : () => _answer(i),
                              style: OutlinedButton.styleFrom(
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.all(16),
                                backgroundColor: hasAnswered && i == question.correctIndex
                                    ? const Color(0xFFF0FDF4)
                                    : hasAnswered && i == selectedIndex
                                        ? const Color(0xFFFEF2F2)
                                        : null,
                                side: BorderSide(
                                  color: hasAnswered && i == question.correctIndex
                                      ? const Color(0xFF22C55E)
                                      : hasAnswered && i == selectedIndex
                                          ? const Color(0xFFEF4444)
                                          : const Color(0xFFD8DEE9),
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text(question.options[i]),
                            ),
                          ),
                        if (hasAnswered) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isCorrect ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: isCorrect ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5)),
                            ),
                            child: Text(
                              isCorrect ? 'Benar. ${question.explanation}' : 'Belum tepat. ${question.explanation}',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: _nextQuestion,
                            icon: Icon(widget.room.currentQuestionIndex == widget.room.questions.length - 1 ? Icons.leaderboard_outlined : Icons.arrow_forward),
                            label: Text(widget.room.currentQuestionIndex == widget.room.questions.length - 1 ? 'Lihat Leaderboard' : 'Soal Berikutnya'),
                          ),
                        ],
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
