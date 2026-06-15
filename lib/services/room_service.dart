import 'dart:async';
import 'dart:math';

import '../data/sample_questions.dart';
import '../models/participant.dart';
import '../models/quiz_room.dart';
import 'supabase_service.dart';

class RoomService {
  RoomService._();

  static final RoomService instance = RoomService._();

  final Map<String, QuizRoom> _rooms = {};

  QuizRoom createRoom({
    required String title,
    required String hostName,
  }) {
    final code = _generateCode();
    final room = QuizRoom(
      code: code,
      title: title.trim().isEmpty ? 'Kuis EduQuiz' : title.trim(),
      hostName: hostName,
      questions: sampleQuestions,
    );

    room.participants.addAll([
      Participant(name: 'Dina'),
      Participant(name: 'Rafi'),
      Participant(name: 'Salsa'),
    ]);

    _rooms[code] = room;
    unawaited(SupabaseService.instance.createRoom(room));
    return room;
  }

  QuizRoom? findRoom(String code) {
    return _rooms[code.trim().toUpperCase()];
  }

  Future<QuizRoom?> findRoomConnected(String code) async {
    final normalizedCode = code.trim().toUpperCase();
    final localRoom = _rooms[normalizedCode];
    if (localRoom != null) return localRoom;

    final remoteRoom = await SupabaseService.instance.findRoom(normalizedCode);
    if (remoteRoom != null) {
      _rooms[remoteRoom.code] = remoteRoom;
    }
    return remoteRoom;
  }

  Participant addParticipant({
    required QuizRoom room,
    required String name,
  }) {
    final existing = room.participants.where((item) => item.name == name);
    if (existing.isNotEmpty) return existing.first;

    final participant = Participant(name: name);
    room.participants.add(participant);
    unawaited(SupabaseService.instance.addParticipant(room: room, participant: participant));
    return participant;
  }

  void startQuiz(QuizRoom room) {
    room.phase = QuizPhase.live;
    room.currentQuestionIndex = 0;
    for (final participant in room.participants) {
      participant.score = 0;
      participant.answers.clear();
    }
    unawaited(SupabaseService.instance.updateRoom(room));
  }

  void answerQuestion({
    required QuizRoom room,
    required Participant participant,
    required int answerIndex,
  }) {
    final questionIndex = room.currentQuestionIndex;
    final question = room.questions[questionIndex];

    participant.answers[questionIndex] = answerIndex;
    if (answerIndex == question.correctIndex) {
      participant.score += 100;
    }
    unawaited(
      SupabaseService.instance.submitAnswer(
        room: room,
        participant: participant,
        questionIndex: questionIndex,
        answerIndex: answerIndex,
        isCorrect: answerIndex == question.correctIndex,
      ),
    );

    _simulateOtherParticipants(room, questionIndex, participant.name);

    if (questionIndex == room.questions.length - 1) {
      room.phase = QuizPhase.leaderboard;
    } else {
      room.currentQuestionIndex++;
    }
    unawaited(SupabaseService.instance.updateRoom(room));
  }

  void showLeaderboard(QuizRoom room) {
    room.phase = QuizPhase.leaderboard;
    unawaited(SupabaseService.instance.updateRoom(room));
  }

  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    String code;

    do {
      code = List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
    } while (_rooms.containsKey(code));

    return code;
  }

  void _simulateOtherParticipants(QuizRoom room, int questionIndex, String activeName) {
    final random = Random();
    final question = room.questions[questionIndex];

    for (final participant in room.participants) {
      if (participant.name == activeName || participant.answers.containsKey(questionIndex)) {
        continue;
      }

      final answer = random.nextInt(question.options.length);
      participant.answers[questionIndex] = answer;
      if (answer == question.correctIndex) {
        participant.score += 100;
      }
      unawaited(
        SupabaseService.instance.submitAnswer(
          room: room,
          participant: participant,
          questionIndex: questionIndex,
          answerIndex: answer,
          isCorrect: answer == question.correctIndex,
        ),
      );
    }
  }
}
