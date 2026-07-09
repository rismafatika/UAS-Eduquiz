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
    if (!SupabaseConfig.isConfigured) {
      _ready = false;
      return;
    }

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

  Future<void> signOut() async {
    if (!_ready) return;
    await Supabase.instance.client.auth.signOut();
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

      for (final participant in room.participants) {
        await addParticipant(room: room, participant: participant);
      }
      await saveRoomQuestions(room);
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
      final roomData = await client.from('rooms').select().eq('code', code).maybeSingle();
      if (roomData == null) return null;

      final room = QuizRoom(
        code: roomData['code'] as String,
        title: roomData['title'] as String,
        hostName: roomData['host_name'] as String,
        questions: await _loadQuestions(client, roomData['code'] as String),
      );

      final phaseName = roomData['phase'] as String? ?? QuizPhase.lobby.name;
      room.phase = QuizPhase.values.firstWhere(
        (phase) => phase.name == phaseName,
        orElse: () => QuizPhase.lobby,
      );
      room.currentQuestionIndex = roomData['current_question_index'] as int? ?? 0;

      final participantRows = await client.from('participants').select().eq('room_code', room.code);
      for (final row in participantRows) {
        room.participants.add(
          Participant(
            name: row['name'] as String,
            score: row['score'] as int? ?? 0,
          ),
        );
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

      await client.from('participants').update({
        'score': participant.score,
      }).eq('room_code', room.code).eq('name', participant.name);
    } catch (_) {
      return;
    }
  }

  Future<void> saveRoomQuestions(QuizRoom room) async {
    final client = _client;
    if (client == null) return;

    try {
      await client.from('questions').delete().eq('room_code', room.code);
      await client.from('questions').insert(
            room.questions.asMap().entries.map((entry) {
              final question = entry.value;
              return {
                'room_code': room.code,
                'question_index': entry.key,
                'question_text': question.question,
                'option_a': question.options[0],
                'option_b': question.options[1],
                'option_c': question.options[2],
                'option_d': question.options[3],
                'correct_index': question.correctIndex,
                'explanation': question.explanation,
                'category': question.category,
                'points': question.points,
                'color_value': question.color.value,
              };
            }).toList(),
          );
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

  Future<List<QuizQuestion>> _loadQuestions(SupabaseClient client, String roomCode) async {
    try {
      final rows = await client.from('questions').select().eq('room_code', roomCode).order('question_index');
      if (rows.isEmpty) return List.of(sampleQuestions);

      return rows.map<QuizQuestion>((row) {
        return QuizQuestion(
          question: row['question_text'] as String,
          options: [
            row['option_a'] as String,
            row['option_b'] as String,
            row['option_c'] as String,
            row['option_d'] as String,
          ],
          correctIndex: row['correct_index'] as int? ?? 0,
          explanation: row['explanation'] as String? ?? '',
          category: row['category'] as String? ?? 'Umum',
          points: row['points'] as int? ?? 100,
          color: Color(row['color_value'] as int? ?? 0xFF1D4ED8),
        );
      }).toList();
    } catch (_) {
      return List.of(sampleQuestions);
    }
  }
}
