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
    _ready = SupabaseConfig.isConfigured;
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

  Future<AppUser?> findUserByEmail(String email) async {
    final client = _client;
    if (client == null || email.isEmpty) return null;

    try {
      final row = await client
          .from('app_users')
          .select()
          .eq('email', email)
          .maybeSingle();
      if (row == null) return null;

      final roleName = row['role'] as String? ?? UserRole.participant.name;
      return AppUser(
        email: row['email'] as String? ?? email,
        name: row['name'] as String? ?? email.split('@').first,
        role: UserRole.values.firstWhere(
          (role) => role.name == roleName,
          orElse: () => UserRole.participant,
        ),
      );
    } catch (_) {
      return null;
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
      final roomData = await client
          .from('rooms')
          .select()
          .eq('code', code)
          .maybeSingle();
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

      final participantRows = await client
          .from('participants')
          .select()
          .eq('room_code', room.code);
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
      await client.from('room_questions').delete().eq('room_code', room.code);
      await client.from('room_questions').insert(
            room.questions.asMap().entries.map((entry) {
              final question = entry.value;
              return {
                'room_code': room.code,
                'sort_order': entry.key,
                'question': question.question,
                'options': question.options,
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

  Future<List<QuizQuestion>> _loadQuestions(
    SupabaseClient client,
    String roomCode,
  ) async {
    try {
      final rows = await client
          .from('room_questions')
          .select()
          .eq('room_code', roomCode)
          .order('sort_order');
      if (rows.isEmpty) return List.of(sampleQuestions);

      return rows.map<QuizQuestion>((row) {
        final options = (row['options'] as List<dynamic>? ?? const [])
            .map((option) => option.toString())
            .toList();

        return QuizQuestion(
          question: row['question'] as String,
          options: options.length == 4
              ? options
              : ['A', 'B', 'C', 'D'],
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
