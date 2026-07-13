import 'dart:math';
import 'package:flutter/material.dart';
import '../data/sample_questions.dart';
import '../models/participant.dart';
import '../models/quiz_question.dart';
import '../models/quiz_room.dart';
import 'supabase_service.dart';

class RoomService {
  RoomService._();
  static final RoomService instance = RoomService._();

  final Map<String, QuizRoom> _cache = {};
  final SupabaseService _supabase = SupabaseService.instance;

  // ─── BUAT ROOM ──────────────────────────────────────────────
  Future<QuizRoom> createRoom(
      {required String title, required String hostName}) async {
    final baseTitle = title.trim().isEmpty ? 'Kuis EduQuiz' : title.trim();

    for (var attempt = 0; attempt < 5; attempt++) {
      final room = QuizRoom(
        code: _generateCode(),
        title: baseTitle,
        hostName: hostName,
        questions: List.from(sampleQuestions),
      );
      room.phase = QuizPhase.waiting;
      room.participants.add(Participant(name: hostName));

      try {
        await _supabase.createRoom(room);
        _cache[room.code] = room;
        try {
          await _supabase.addParticipant(
            room: room,
            participant: Participant(name: hostName),
          );
        } catch (e) {
          _logError('Host participant add skipped', e);
        }
        return room;
      } catch (e) {
        final errorText = e.toString().toLowerCase();
        final duplicateRoom = errorText.contains('23505') ||
            errorText.contains('duplicate key') ||
            errorText.contains('unique constraint');
        if (duplicateRoom && attempt < 4) {
          debugPrint('Room code collision, retrying createRoom...');
          continue;
        }
        _logError('Supabase error (createRoom)', e);
        rethrow;
      }
    }

    throw StateError('Failed to create room after several attempts');
  }

  // ─── GET ALL ROOMS ──────────────────────────────────────────
  List<QuizRoom> getAllRooms() {
    return _cache.values.toList();
  }

  // ─── SYNC ────────────────────────────────────────────────────
  Future<void> syncRooms() async {
    try {
      final rooms = await _supabase.getAllRooms();
      for (var room in rooms) {
        _cache[room.code] = room;
      }
    } catch (e) {
      _logError('Sync error', e);
    }
  }

  // ─── FIND ROOM ──────────────────────────────────────────────
  Future<QuizRoom?> findRoomConnected(String code) async {
    final normalized = code.trim().toUpperCase();
    try {
      final room = await _supabase.findRoom(normalized);
      if (room != null) {
        _cache[room.code] = room;
        return room;
      }
    } catch (e) {
      _logError('Find room error', e);
      rethrow;
    }

    return null;
  }

  // ─── GET ROOM (SYNC) ────────────────────────────────────────
  QuizRoom? getRoom(String code) {
    return _cache[code.trim().toUpperCase()];
  }

  // ─── ADD PARTICIPANT ────────────────────────────────────────
  Future<Participant> addParticipant(
      {required QuizRoom room, required String name}) async {
    final existing = room.participants.where((p) => p.name == name);
    if (existing.isNotEmpty) return existing.first;

    final participant = Participant(name: name);
    room.participants.add(participant);
    _cache[room.code] = room;
    try {
      await _supabase.addParticipant(room: room, participant: participant);
    } catch (e) {
      _logError('Add participant error', e);
      rethrow;
    }
    return participant;
  }

  // ─── START QUIZ ─────────────────────────────────────────────
  Future<void> startQuiz(QuizRoom room) async {
    room.phase = QuizPhase.live;
    room.currentQuestionIndex = 0;
    for (final p in room.participants) p.score = 0;
    _cache[room.code] = room;
    try {
      await _supabase.updateRoom(room);
    } catch (e) {
      _logError('Start quiz error', e);
      rethrow;
    }
  }

  // ─── ANSWER ─────────────────────────────────────────────────
  Future<void> nextQuestion(QuizRoom room) async {
    if (room.currentQuestionIndex >= room.questions.length - 1) {
      room.phase = QuizPhase.leaderboard;
    } else {
      room.currentQuestionIndex++;
      room.phase = QuizPhase.live;
    }

    _cache[room.code] = room;
    try {
      await _supabase.updateRoom(room);
    } catch (e) {
      _logError('Next question error', e);
      rethrow;
    }
  }

  Future<void> answerQuestion({
    required QuizRoom room,
    required Participant participant,
    required int answerIndex,
  }) async {
    final questionIdx = room.currentQuestionIndex;
    final question = room.questions[questionIdx];
    final isCorrect = answerIndex == question.correctIndex;

    participant.answers[questionIdx] = answerIndex;
    if (isCorrect) participant.score += 100;

    _cache[room.code] = room;
    try {
      await _supabase.submitAnswer(
        room: room,
        participant: participant,
        questionIndex: questionIdx,
        answerIndex: answerIndex,
        isCorrect: isCorrect,
      );
    } catch (e) {
      _logError('Answer error', e);
      rethrow;
    }
  }

  // ─── CHANGE PHASE ───────────────────────────────────────────
  Future<void> showLeaderboard(QuizRoom room) async {
    room.phase = QuizPhase.leaderboard;
    _cache[room.code] = room;
    try {
      await _supabase.updateRoom(room);
    } catch (e) {
      _logError('Show leaderboard error', e);
      rethrow;
    }
  }

  Future<void> showReview(QuizRoom room) async {
    room.phase = QuizPhase.review;
    _cache[room.code] = room;
    try {
      await _supabase.updateRoom(room);
    } catch (e) {
      _logError('Show review error', e);
      rethrow;
    }
  }

  Future<void> showDashboard(QuizRoom room) async {
    room.phase = QuizPhase.dashboard;
    _cache[room.code] = room;
    try {
      await _supabase.updateRoom(room);
    } catch (e) {
      _logError('Show dashboard error', e);
      rethrow;
    }
  }

  // ─── CRUD SOAL (TANPA copyWith) ────────────────────────────
  Future<void> addQuestion(QuizRoom room, QuizQuestion question) async {
    final newQuestion = QuizQuestion(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      question: question.question,
      options: List.from(question.options),
      correctIndex: question.correctIndex,
      explanation: question.explanation,
      category: question.category ?? 'Umum',
      points: question.points ?? 100,
      color: question.color ?? const Color(0xFF1D4ED8),
    );
    room.questions.add(newQuestion);
    _cache[room.code] = room;
    try {
      await _supabase.addQuestion(room, room.questions.length - 1, newQuestion);
    } catch (e) {
      _logError('Add question error', e);
      rethrow;
    }
  }

  Future<void> updateQuestion(
      QuizRoom room, int index, QuizQuestion newQuestion) async {
    if (index < 0 || index >= room.questions.length) return;
    final oldId = room.questions[index].id;
    final updated = QuizQuestion(
      id: oldId,
      question: newQuestion.question,
      options: List.from(newQuestion.options),
      correctIndex: newQuestion.correctIndex,
      explanation: newQuestion.explanation,
      category: newQuestion.category ?? 'Umum',
      points: newQuestion.points ?? 100,
      color: newQuestion.color ?? const Color(0xFF1D4ED8),
    );
    room.questions[index] = updated;
    _cache[room.code] = room;
    try {
      await _supabase.addQuestion(room, index, updated);
    } catch (e) {
      _logError('Update question error', e);
      rethrow;
    }
  }

  Future<void> removeQuestion(QuizRoom room, int index) async {
    if (index < 0 || index >= room.questions.length) return;
    final oldId = room.questions[index].id;
    room.questions.removeAt(index);
    _cache[room.code] = room;
    try {
      await _supabase.deleteQuestion(room, oldId);
    } catch (e) {
      _logError('Delete question error', e);
      rethrow;
    }
  }

  // ─── HELPER ──────────────────────────────────────────────────
  void _logError(String context, Object error) {
    debugPrint('$context: $error');
  }

  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    String code;
    do {
      code =
          List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
    } while (_cache.containsKey(code));
    return code;
  }
}
