import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/participant.dart';
import '../models/quiz_room.dart';
import '../services/room_service.dart';
import '../widgets/room_header.dart';
import 'leaderboard_page.dart';
import 'quiz_result_page.dart';

class QuizLivePage extends StatefulWidget {
  const QuizLivePage({
    super.key,
    required this.user,
    required this.room,
  });

  final AppUser user;
  final QuizRoom room;

  @override
  State<QuizLivePage> createState() => _QuizLivePageState();
}

class _QuizLivePageState extends State<QuizLivePage> {
  Participant get _participant {
<<<<<<< HEAD
    return RoomService.instance.addParticipant(
      room: widget.room,
      name: widget.user.name,
    );
=======
    return RoomService.instance
        .addParticipant(room: widget.room, name: widget.user.name);
>>>>>>> origin/rista-ui
  }

  bool get _isHost => widget.user.role == UserRole.host;

  final List<Color> answerColors = const [
    Color(0xffef4444),
    Color(0xff3b82f6),
    Color(0xfff59e0b),
    Color(0xff22c55e),
  ];

  final List<IconData> answerIcons = const [
    Icons.crop_square,
    Icons.change_history,
    Icons.circle,
    Icons.star,
  ];

  void _answer(int index) {
    setState(() {
      RoomService.instance.answerQuestion(
<<<<<<< HEAD
        room: widget.room,
        participant: _participant,
        answerIndex: index,
      );
=======
          room: widget.room, participant: _participant, answerIndex: index);
>>>>>>> origin/rista-ui
    });
  }

  void _nextQuestion() {
    setState(() => RoomService.instance.advanceQuestion(widget.room));
    if (widget.room.phase == QuizPhase.leaderboard) {
<<<<<<< HEAD
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LeaderboardPage(
            user: widget.user,
            room: widget.room,
          ),
        ),
      );
=======
      if (_isHost) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    LeaderboardPage(user: widget.user, room: widget.room)));
        return;
      }

      final result = RoomService.instance.completeParticipantQuiz(
        room: widget.room,
        participant: _participant,
      );
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => QuizResultPage(
                    user: widget.user,
                    room: widget.room,
                    result: result,
                  )));
>>>>>>> origin/rista-ui
    }
  }

  void _finishFromHost() {
<<<<<<< HEAD
    setState(() {
      RoomService.instance.showLeaderboard(widget.room);
    });
=======
    setState(() => RoomService.instance.showLeaderboard(widget.room));
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) =>
                LeaderboardPage(user: widget.user, room: widget.room)));
  }
>>>>>>> origin/rista-ui

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder = (_) => LeaderboardPage(
          user: widget.user,
          room: widget.room,
        ),
      ),
    );
  }
    @override
  Widget build(BuildContext context) {
    final question = widget.room.questions[widget.room.currentQuestionIndex];
<<<<<<< HEAD

    final progress =
        (widget.room.currentQuestionIndex + 1) /
        widget.room.questions.length;
=======
    final progress =
        (widget.room.currentQuestionIndex + 1) / widget.room.questions.length;
    final selectedIndex =
        _participant.answers[widget.room.currentQuestionIndex];
    final hasAnswered = selectedIndex != null;
    final isCorrect = selectedIndex == question.correctIndex;
>>>>>>> origin/rista-ui

    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "EduQuiz Live",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  RoomHeader(room: widget.room),
<<<<<<< HEAD

                  const SizedBox(height: 20),

                  Row(
                    children: [

                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: question.color,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            children: [

                              Text(
                                question.category,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                "${question.points} Poin",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),

                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            children: [

                              const Text(
                                "SKOR",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                "${_participant.score}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),

                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: Colors.grey.shade300,
                      color: Colors.deepPurple,
=======
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
                            Text(
                                '${_participant.score} poin | Lv ${_participant.level}'),
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
                            if (_participant.streak > 0)
                              Chip(
                                  label: Text('Streak ${_participant.streak}')),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(question.question,
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 18),
                        for (var i = 0; i < question.options.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: OutlinedButton(
                              onPressed: _isHost || hasAnswered
                                  ? null
                                  : () => _answer(i),
                              style: OutlinedButton.styleFrom(
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.all(16),
                                backgroundColor:
                                    hasAnswered && i == question.correctIndex
                                        ? const Color(0xFFF0FDF4)
                                        : hasAnswered && i == selectedIndex
                                            ? const Color(0xFFFEF2F2)
                                            : null,
                                side: BorderSide(
                                  color:
                                      hasAnswered && i == question.correctIndex
                                          ? const Color(0xFF22C55E)
                                          : hasAnswered && i == selectedIndex
                                              ? const Color(0xFFEF4444)
                                              : const Color(0xFFD8DEE9),
                                ),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text(question.options[i]),
                            ),
                          ),
                        if (hasAnswered) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isCorrect
                                  ? const Color(0xFFF0FDF4)
                                  : const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: isCorrect
                                      ? const Color(0xFF86EFAC)
                                      : const Color(0xFFFCA5A5)),
                            ),
                            child: Text(
                              isCorrect
                                  ? 'Benar. ${question.explanation}'
                                  : 'Belum tepat. ${question.explanation}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: _nextQuestion,
                            icon: Icon(widget.room.currentQuestionIndex ==
                                    widget.room.questions.length - 1
                                ? Icons.leaderboard_outlined
                                : Icons.arrow_forward),
                            label: Text(widget.room.currentQuestionIndex ==
                                    widget.room.questions.length - 1
                                ? 'Lihat Leaderboard'
                                : 'Soal Berikutnya'),
                          ),
                        ],
                        if (_isHost)
                          FilledButton.icon(
                              onPressed: _finishFromHost,
                              icon: const Icon(Icons.leaderboard_outlined),
                              label: const Text('Tampilkan Leaderboard')),
                      ],
>>>>>>> origin/rista-ui
                    ),
                  ),

                  const SizedBox(height: 15),

                  Center(
                    child: Text(
                      "Soal ${widget.room.currentQuestionIndex + 1} / ${widget.room.questions.length}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Text(
                        question.question,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Expanded(
                    child: ListView.builder(
                      itemCount: question.options.length,
                      itemBuilder: (context, index) {

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: SizedBox(
                            height: 65,
                            child: ElevatedButton.icon(

                              onPressed: _isHost
                                  ? null
                                  : () => _answer(index),

                              icon: Icon(
                                answerIcons[index],
                                color: Colors.white,
                              ),

                              style: ElevatedButton.styleFrom(
                                backgroundColor: answerColors[index],
                                foregroundColor: Colors.white,
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(18),
                                ),
                              ),

                              label: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  question.options[index],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  if (_isHost)
 SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _finishFromHost,
                        icon: const Icon(Icons.emoji_events),
                        label: const Text(
                          "Tampilkan Leaderboard",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
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
