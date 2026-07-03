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
      questions: List<QuizQuestion>.from(sampleQuestions),
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
    final existing = room.participants.where(
      (item) => item.name.toLowerCase() == normalizedName.toLowerCase(),
    );
    if (existing.isNotEmpty) return existing.first;

    final participant = Participant(name: normalizedName);
    room.participants.add(participant);
    unawaited(SupabaseService.instance
        .addParticipant(room: room, participant: participant));
    return participant;
  }

  void startQuiz(QuizRoom room) {
    room.phase = QuizPhase.live;
    room.currentQuestionIndex = 0;
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
    final questionIndex = room.currentQuestionIndex;
    final question = room.questions[questionIndex];
    final isCorrect = answerIndex == question.correctIndex;

    if (participant.answers.containsKey(questionIndex)) {
      return;
    }

    participant.answers[questionIndex] = answerIndex;
    if (isCorrect) {
      participant.correctAnswer(
        points: _pointsFor(question.points, participant.streak),
      );
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

    unawaited(SupabaseService.instance.updateRoom(room));
  }

  void advanceQuestion(QuizRoom room) {
    if (room.currentQuestionIndex >= room.questions.length - 1) {
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
    unawaited(SupabaseService.instance.updateRoom(room));
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
    unawaited(SupabaseService.instance.updateRoom(room));
  }

  void deleteQuestion({
    required QuizRoom room,
    required int index,
  }) {
    if (room.questions.length <= 1 || index < 0 || index >= room.questions.length) {
      return;
    }

    room.questions.removeAt(index);
    if (room.currentQuestionIndex >= room.questions.length) {
      room.currentQuestionIndex = room.questions.length - 1;
    }

    for (final participant in room.participants) {
      final shiftedAnswers = <int, int>{};
      for (final entry in participant.answers.entries) {
        if (entry.key == index) continue;
        shiftedAnswers[entry.key > index ? entry.key - 1 : entry.key] = entry.value;
      }
      participant.answers
        ..clear()
        ..addAll(shiftedAnswers);
    }

    _recalculateRoomScores(room);
    unawaited(SupabaseService.instance.saveRoomQuestions(room));
    unawaited(SupabaseService.instance.updateRoom(room));
  }

  QuizResult completeParticipantQuiz({
    required QuizRoom room,
    required Participant participant,
  }) {
    final result = resultForParticipant(room: room, participant: participant);
    final existingIndex = room.results.indexWhere(
      (item) => item.participantName.toLowerCase() == participant.name.toLowerCase(),
    );
    if (existingIndex == -1) {
      room.results.add(result);
    } else {
      room.results[existingIndex] = result;
    }
    unawaited(SupabaseService.instance.saveQuizResult(room: room, result: result));
    return result;
  }

  QuizResult resultForParticipant({
    required QuizRoom room,
    required Participant participant,
  }) {
    var correctAnswers = 0;
    var earnedBasePoints = 0;
    final totalBasePoints = room.questions.fold<int>(
      0,
      (sum, question) => sum + question.points,
    );

    for (var i = 0; i < room.questions.length; i++) {
      final question = room.questions[i];
      final selectedIndex = participant.answers[i];
      if (selectedIndex == question.correctIndex) {
        correctAnswers++;
        earnedBasePoints += question.points;
      }
    }

    final percentage = totalBasePoints == 0
        ? 0.0
        : (earnedBasePoints / totalBasePoints * 100).clamp(0.0, 100.0).toDouble();

    return QuizResult(
      participantName: participant.name,
      totalScore: participant.score,
      correctAnswers: correctAnswers,
      wrongAnswers: room.questions.length - correctAnswers,
      percentage: percentage,
      grade: _gradeFor(percentage),
      completedAt: DateTime.now(),
    );
  }

  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    String code;

    do {
      code =
          List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
    } while (_rooms.containsKey(code));

    return code;
  }

  String _normalizeName(String name) {
    final trimmed = name.trim().replaceAll(RegExp(r'\s+'), ' ');
    return trimmed.isEmpty ? 'Peserta' : trimmed;
  }

  int _pointsFor(int basePoints, int currentStreak) {
    final streakBonus = currentStreak >= 2
        ? 50
        : currentStreak == 1
            ? 25
            : 0;
    return basePoints + streakBonus;
  }

  void _simulateOtherParticipants(
      QuizRoom room, int questionIndex, String activeName) {
    final random = Random();
    final question = room.questions[questionIndex];

    for (final participant in room.participants) {
      if (participant.name == activeName ||
          participant.answers.containsKey(questionIndex)) {
        continue;
      }

      final answer = random.nextInt(question.options.length);
      final isCorrect = answer == question.correctIndex;
      participant.answers[questionIndex] = answer;
      if (isCorrect) {
        participant.correctAnswer(
          points: _pointsFor(question.points, participant.streak),
        );
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

      final answeredIndexes = participant.answers.keys.toList()..sort();
      for (final questionIndex in answeredIndexes) {
        if (questionIndex < 0 || questionIndex >= room.questions.length) continue;
        final answerIndex = participant.answers[questionIndex];
        final question = room.questions[questionIndex];
        if (answerIndex == question.correctIndex) {
          participant.correctAnswer(
            points: _pointsFor(question.points, participant.streak),
          );
        } else {
          participant.wrongAnswer();
        }
      }

      unawaited(SupabaseService.instance.addParticipant(
        room: room,
        participant: participant,
      ));
    }
  }

  String _gradeFor(double percentage) {
    if (percentage >= 85) return 'A';
    if (percentage >= 70) return 'B';
    if (percentage >= 55) return 'C';
    return 'D';
  }
}
