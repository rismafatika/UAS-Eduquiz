import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../data/sample_questions.dart';
import '../models/app_user.dart';
import '../models/participant.dart';
import '../models/quiz_question.dart';
import '../models/quiz_result.dart';
import '../models/quiz_room.dart';

class SupabaseService {
  SupabaseService._();

  static final SupabaseService instance = SupabaseService._();

  bool _ready = false;

  bool get isReady => _ready;

  SupabaseClient? get _client {
    if (!_ready) return null;
    return Supabase.instance.client;
  }

  Future<void> initialize() async {
    if (!SupabaseConfig.isConfigured) return;

    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        publishableKey: SupabaseConfig.anonKey,
      );
      _ready = true;
    } catch (_) {
      _ready = false;
    }
  }

  Future<void> saveUser(AppUser user) async {
    final client = _client;
    if (client == null) return;

    try {
      await client.from('app_users').upsert({
        'email': user.email,
        'name': user.name,
        'role': user.role.name,
        'last_login_at': DateTime.now().toIso8601String(),
      }, onConflict: 'email');
    } catch (_) {
      return;
    }
  }

  Future<void> createRoom(QuizRoom room) async {
    final client = _client;
    if (client == null) return;

    try {
      await client.from('rooms').upsert({
        'code': room.code,
        'title': room.title,
        'host_name': room.hostName,
        'phase': room.phase.name,
        'current_question_index': room.currentQuestionIndex,
        'created_at': DateTime.now().toIso8601String(),
      });

      await saveRoomQuestions(room);

      for (final participant in room.participants) {
        await addParticipant(room: room, participant: participant);
      }
    } catch (_) {
      return;
    }
  }

  Future<void> updateRoom(QuizRoom room) async {
    final client = _client;
    if (client == null) return;

    try {
      await client.from('rooms').update({
        'phase': room.phase.name,
        'current_question_index': room.currentQuestionIndex,
      }).eq('code', room.code);
    } catch (_) {
      return;
    }
  }

  Future<QuizRoom?> findRoom(String code) async {
    final client = _client;
    if (client == null) return null;

    try {
      final roomData =
          await client.from('rooms').select().eq('code', code).maybeSingle();
      if (roomData == null) return null;

      final room = QuizRoom(
        code: roomData['code'] as String,
        title: roomData['title'] as String,
        hostName: roomData['host_name'] as String,
        questions: List<QuizQuestion>.from(sampleQuestions),
      );

      final phaseName = roomData['phase'] as String? ?? QuizPhase.lobby.name;
      room.phase = QuizPhase.values.firstWhere(
        (phase) => phase.name == phaseName,
        orElse: () => QuizPhase.lobby,
      );
      room.currentQuestionIndex =
          roomData['current_question_index'] as int? ?? 0;
      final questionRows = await client
          .from('room_questions')
          .select()
          .eq('room_code', room.code)
          .order('sort_order');
      if (questionRows.isNotEmpty) {
        room.questions
          ..clear()
          ..addAll(questionRows.map((row) => _questionFromRow(Map<String, dynamic>.from(row))));
      }

      final resultRows = await client
          .from('quiz_results')
          .select()
          .eq('room_code', room.code)
          .order('completed_at', ascending: false);
      room.results.addAll(resultRows.map((row) => _resultFromRow(Map<String, dynamic>.from(row))));

      final participantRows =
          await client.from('participants').select().eq('room_code', room.code);
      for (final row in participantRows) {
        final participant = Participant(
          name: row['name'] as String,
          score: row['score'] as int? ?? 0,
          streak: row['streak'] as int? ?? 0,
          xp: row['xp'] as int? ?? 0,
          level: row['level'] as int? ?? 1,
        );

        final answerRows = await client
            .from('answers')
            .select()
            .eq('room_code', room.code)
            .eq('participant_name', participant.name);
        for (final answerRow in answerRows) {
          final questionIndex = answerRow['question_index'] as int?;
          final answerIndex = answerRow['answer_index'] as int?;
          if (questionIndex != null && answerIndex != null) {
            participant.answers[questionIndex] = answerIndex;
          }
        }

        room.participants.add(participant);
      }

      return room;
    } catch (_) {
      return null;
    }
  }

  Future<void> addParticipant({
    required QuizRoom room,
    required Participant participant,
  }) async {
    final client = _client;
    if (client == null) return;

    try {
      await client.from('participants').upsert({
        'room_code': room.code,
        'name': participant.name,
        'score': participant.score,
        'streak': participant.streak,
        'xp': participant.xp,
        'level': participant.level,
        'joined_at': DateTime.now().toIso8601String(),
      }, onConflict: 'room_code,name');
    } catch (_) {
      return;
    }
  }

  Future<void> submitAnswer({
    required QuizRoom room,
    required Participant participant,
    required int questionIndex,
    required int answerIndex,
    required bool isCorrect,
  }) async {
    final client = _client;
    if (client == null) return;

    try {
      await client.from('answers').upsert({
        'room_code': room.code,
        'participant_name': participant.name,
        'question_index': questionIndex,
        'answer_index': answerIndex,
        'is_correct': isCorrect,
        'answered_at': DateTime.now().toIso8601String(),
      }, onConflict: 'room_code,participant_name,question_index');

      await client
          .from('participants')
          .update({
            'score': participant.score,
            'streak': participant.streak,
            'xp': participant.xp,
            'level': participant.level,
          })
          .eq('room_code', room.code)
          .eq('name', participant.name);
    } catch (_) {
      return;
    }
  }

  Future<void> saveRoomQuestions(QuizRoom room) async {
    final client = _client;
    if (client == null) return;

    try {
      await client.from('room_questions').delete().eq('room_code', room.code);
      for (var i = 0; i < room.questions.length; i++) {
        final question = room.questions[i];
        await client.from('room_questions').insert({
          'room_code': room.code,
          'sort_order': i,
          'question': question.question,
          'options': question.options,
          'correct_index': question.correctIndex,
          'explanation': question.explanation,
          'category': question.category,
          'points': question.points,
          'color_value': question.color.value,
        });
      }
    } catch (_) {
      return;
    }
  }

  Future<void> saveQuizResult({
    required QuizRoom room,
    required QuizResult result,
  }) async {
    final client = _client;
    if (client == null) return;

    try {
      await client.from('quiz_results').upsert({
        'room_code': room.code,
        'participant_name': result.participantName,
        'total_score': result.totalScore,
        'correct_answers': result.correctAnswers,
        'wrong_answers': result.wrongAnswers,
        'percentage': result.percentage,
        'grade': result.grade,
        'completed_at': result.completedAt.toIso8601String(),
      }, onConflict: 'room_code,participant_name');
    } catch (_) {
      return;
    }
  }

  QuizQuestion _questionFromRow(Map<String, dynamic> row) {
    final rawOptions = row['options'];
    final options = rawOptions is List
        ? rawOptions.map((item) => item.toString()).toList()
        : <String>['Pilihan A', 'Pilihan B', 'Pilihan C', 'Pilihan D'];

    return QuizQuestion(
      question: row['question'] as String? ?? '',
      options: options,
      correctIndex: row['correct_index'] as int? ?? 0,
      explanation: row['explanation'] as String? ?? '',
      category: row['category'] as String? ?? 'Umum',
      points: row['points'] as int? ?? 100,
      color: Color(row['color_value'] as int? ?? 0xFF2563EB),
    );
  }

  QuizResult _resultFromRow(Map<String, dynamic> row) {
    return QuizResult(
      participantName: row['participant_name'] as String? ?? 'Peserta',
      totalScore: row['total_score'] as int? ?? 0,
      correctAnswers: row['correct_answers'] as int? ?? 0,
      wrongAnswers: row['wrong_answers'] as int? ?? 0,
      percentage: (row['percentage'] as num?)?.toDouble() ?? 0,
      grade: row['grade'] as String? ?? 'D',
      completedAt: DateTime.tryParse(row['completed_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
