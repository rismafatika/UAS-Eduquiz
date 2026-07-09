import 'dart:async';
import 'dart:math';

import '../data/sample_questions.dart';
import '../models/participant.dart';
import '../models/quiz_question.dart';
import '../models/quiz_result.dart';
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
      questions: List.of(sampleQuestions),
    );

    room.participants.addAll([
      Participant(name: 'Dina'),
      Participant(name: 'Rafi'),
      Participant(name: 'Salsa'),
    ]);

    _rooms[code] = room;
    unawaited(SupabaseService.instance.createRoom(room));
    unawaited(SupabaseService.instance.saveRoomQuestions(room));
    return room;
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
    final normalizedName = _normalizeName(name);
    final existing = room.participants.where((participant) => participant.name == normalizedName);
    if (existing.isNotEmpty) return existing.first;

    final participant = Participant(name: normalizedName);
    room.participants.add(participant);
    unawaited(SupabaseService.instance.addParticipant(room: room, participant: participant));
    return participant;
  }

  void startQuiz(QuizRoom room) {
    room.phase = QuizPhase.live;
    room.currentQuestionIndex = 0;
    room.results.clear();

    for (final participant in room.participants) {
      participant.score = 0;
      participant.streak = 0;
      participant.xp = 0;
      participant.level = 1;
      participant.answers.clear();
    }

    unawaited(SupabaseService.instance.updateRoom(room));
  }

  void answerQuestion({
    required QuizRoom room,
    required Participant participant,
    required int answerIndex,
  }) {
    if (room.questions.isEmpty) return;
    final questionIndex = room.currentQuestionIndex.clamp(0, room.questions.length - 1);
    final question = room.questions[questionIndex];
    final isCorrect = answerIndex == question.correctIndex;

    participant.answers[questionIndex] = answerIndex;
    if (isCorrect) {
      participant.correctAnswer(points: question.points);
    } else {
      participant.wrongAnswer();
    }

    unawaited(
      SupabaseService.instance.submitAnswer(
        room: room,
        participant: participant,
        questionIndex: questionIndex,
        answerIndex: answerIndex,
        isCorrect: isCorrect,
      ),
    );

    _simulateOtherParticipants(room, questionIndex, participant.name);
    advanceQuestion(room);
  }

  void advanceQuestion(QuizRoom room) {
    if (room.questions.isEmpty) return;

    if (room.currentQuestionIndex >= room.questions.length - 1) {
      room.phase = QuizPhase.leaderboard;
      _saveResults(room);
    } else {
      room.currentQuestionIndex++;
      room.phase = QuizPhase.live;
    }

    unawaited(SupabaseService.instance.updateRoom(room));
  }

  void showLeaderboard(QuizRoom room) {
    room.phase = QuizPhase.leaderboard;
    _saveResults(room);
    unawaited(SupabaseService.instance.updateRoom(room));
  }

  void showReview(QuizRoom room) {
    room.phase = QuizPhase.review;
    unawaited(SupabaseService.instance.updateRoom(room));
  }

  void showDashboard(QuizRoom room) {
    room.phase = QuizPhase.dashboard;
    unawaited(SupabaseService.instance.updateRoom(room));
  }

  void addQuestion({
    required QuizRoom room,
    required QuizQuestion question,
  }) {
    room.questions.add(question);
    _recalculateRoomScores(room);
    unawaited(SupabaseService.instance.saveRoomQuestions(room));
  }

  void updateQuestion({
    required QuizRoom room,
    required int index,
    required QuizQuestion question,
  }) {
    if (index < 0 || index >= room.questions.length) return;

    room.questions[index] = question;
    _recalculateRoomScores(room);
    unawaited(SupabaseService.instance.saveRoomQuestions(room));
  }

  void deleteQuestion({
    required QuizRoom room,
    required int index,
  }) {
    if (room.questions.length <= 1 || index < 0 || index >= room.questions.length) return;

    room.questions.removeAt(index);
    if (room.currentQuestionIndex >= room.questions.length) {
      room.currentQuestionIndex = room.questions.length - 1;
    }

    for (final participant in room.participants) {
      final adjustedAnswers = <int, int>{};
      participant.answers.forEach((questionIndex, answerIndex) {
        if (questionIndex < index) {
          adjustedAnswers[questionIndex] = answerIndex;
        } else if (questionIndex > index) {
          adjustedAnswers[questionIndex - 1] = answerIndex;
        }
      });
      participant.answers
        ..clear()
        ..addAll(adjustedAnswers);
    }

    _recalculateRoomScores(room);
    unawaited(SupabaseService.instance.saveRoomQuestions(room));
  }

  int pointsFor(int basePoints, int streak) {
    final bonus = max(0, streak - 1) * 10;
    return basePoints + bonus;
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

  String _normalizeName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'Peserta';
    return trimmed;
  }

  void _simulateOtherParticipants(QuizRoom room, int questionIndex, String activeName) {
    final random = Random();
    final question = room.questions[questionIndex];

    for (final participant in room.participants) {
      if (participant.name == activeName || participant.answers.containsKey(questionIndex)) {
        continue;
      }

      final answer = random.nextInt(question.options.length);
      final isCorrect = answer == question.correctIndex;
      participant.answers[questionIndex] = answer;
      if (isCorrect) {
        participant.correctAnswer(points: question.points);
      } else {
        participant.wrongAnswer();
      }

      unawaited(
        SupabaseService.instance.submitAnswer(
          room: room,
          participant: participant,
          questionIndex: questionIndex,
          answerIndex: answer,
          isCorrect: isCorrect,
        ),
      );
    }
  }

  void _recalculateRoomScores(QuizRoom room) {
    for (final participant in room.participants) {
      participant.score = 0;
      participant.streak = 0;
      participant.xp = 0;
      participant.level = 1;

      final orderedIndexes = participant.answers.keys.toList()..sort();
      for (final questionIndex in orderedIndexes) {
        if (questionIndex < 0 || questionIndex >= room.questions.length) continue;
        final question = room.questions[questionIndex];
        final answerIndex = participant.answers[questionIndex];
        if (answerIndex == question.correctIndex) {
          participant.correctAnswer(points: question.points);
        } else {
          participant.wrongAnswer();
        }
      }
    }
  }

  void _saveResults(QuizRoom room) {
    room.results
      ..clear()
      ..addAll(room.participants.map((participant) => _resultFor(room, participant)));

    for (final result in room.results) {
      unawaited(SupabaseService.instance.saveQuizResult(room: room, result: result));
    }
  }

  QuizResult _resultFor(QuizRoom room, Participant participant) {
    var correctAnswers = 0;
    for (final entry in participant.answers.entries) {
      if (entry.key >= 0 &&
          entry.key < room.questions.length &&
          entry.value == room.questions[entry.key].correctIndex) {
        correctAnswers++;
      }
    }

    final totalQuestions = room.questions.length;
    final wrongAnswers = max(0, participant.answers.length - correctAnswers);
    final percentage = totalQuestions == 0 ? 0.0 : (correctAnswers / totalQuestions) * 100;

    return QuizResult(
      participantName: participant.name,
      totalScore: participant.score,
      correctAnswers: correctAnswers,
      wrongAnswers: wrongAnswers,
      percentage: percentage,
      grade: _gradeFor(percentage),
      completedAt: DateTime.now(),
    );
  }

  String _gradeFor(double percentage) {
    if (percentage >= 90) return 'A';
    if (percentage >= 80) return 'B';
    if (percentage >= 70) return 'C';
    if (percentage >= 60) return 'D';
    return 'E';
  }
}
