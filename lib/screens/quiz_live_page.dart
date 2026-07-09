import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/participant.dart';
import '../models/quiz_room.dart';
import '../services/room_service.dart';
import '../widgets/room_header.dart';
import 'leaderboard_page.dart';

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
    return RoomService.instance.addParticipant(
      room: widget.room,
      name: widget.user.name,
    );
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
        room: widget.room,
        participant: _participant,
        answerIndex: index,
      );
    });

    if (widget.room.phase == QuizPhase.leaderboard) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LeaderboardPage(
            user: widget.user,
            room: widget.room,
          ),
        ),
      );
    }
  }

  void _finishFromHost() {
    setState(() {
      RoomService.instance.showLeaderboard(widget.room);
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LeaderboardPage(
          user: widget.user,
          room: widget.room,
        ),
      ),
    );
  }
    @override
  Widget build(BuildContext context) {
    final question = widget.room.questions[widget.room.currentQuestionIndex];

    final progress =
        (widget.room.currentQuestionIndex + 1) /
        widget.room.questions.length;

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
