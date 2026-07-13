import 'package:eduquiz/models/quiz_question.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../data/sample_questions.dart';
import '../models/app_user.dart';
import '../models/participant.dart';
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

    _ready = true;
  }

  void _logError(String context, Object error) {
    debugPrint('$context: $error');
  }

  SupabaseClient _requireClient(String context) {
    final client = _client;
    if (client == null) {
      final error = StateError('Supabase client is not initialized for $context');
      _logError(context, error);
      throw error;
    }
    return client;
  }

  // ─── SAVE USER ──────────────────────────────────────────────
  Future<void> saveUser(AppUser user) async {
    final client = _requireClient('saveUser');

    try {
      await client.from('app_users').upsert({
        'email': user.email,
        'name': user.name,
        'role': user.role.name,
        'last_login_at': DateTime.now().toIso8601String(),
      }, onConflict: 'email');
    } catch (error) {
      _logError('Supabase saveUser error', error);
      rethrow;
    }
  }

  // ─── ROOM ────────────────────────────────────────────────────
  Future<void> createRoom(QuizRoom room) async {
    final client = _requireClient('createRoom');

    try {
      await client.from('rooms').insert({
        'code': room.code,
        'title': room.title,
        'host_name': room.hostName,
        'phase': room.phase.name,
        'current_question_index': room.currentQuestionIndex,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (error) {
      _logError('Supabase createRoom error', error);
      rethrow;
    }
  }

  Future<void> updateRoom(QuizRoom room) async {
    final client = _requireClient('updateRoom');

    try {
      await client.from('rooms').update({
        'phase': room.phase.name,
        'current_question_index': room.currentQuestionIndex,
      }).eq('code', room.code);
    } catch (error) {
      _logError('Supabase updateRoom error', error);
      rethrow;
    }
  }

  Future<QuizRoom?> findRoom(String code) async {
    final client = _requireClient('findRoom');

    try {
      final roomData =
          await client.from('rooms').select().eq('code', code).maybeSingle();

      if (roomData == null) return null;

      final room = QuizRoom(
        code: roomData['code'] as String,
        title: roomData['title'] as String,
        hostName: roomData['host_name'] as String,
        questions: sampleQuestions,
      );

      final phaseName = roomData['phase'] as String? ?? QuizPhase.waiting.name;

      room.phase = QuizPhase.values.firstWhere(
        (phase) => phase.name == phaseName,
        orElse: () => QuizPhase.waiting,
      );

      room.currentQuestionIndex =
          (roomData['current_question_index'] as num?)?.toInt() ?? 0;

      final participantRows =
          await client.from('participants').select().eq('room_code', room.code);
      final participantNames = <String>{
        for (final row in participantRows) row['name'] as String,
      };
      final answerRows = await client.from('answers').select();

      final answersByParticipant = <String, Map<int, int>>{};
      for (final row in answerRows) {
        final name = row['participant_name'] as String?;
        if (name == null || !participantNames.contains(name)) continue;
        final questionIndex = (row['question_index'] as num?)?.toInt() ?? 0;
        if (questionIndex < 0 || questionIndex >= room.questions.length) {
          continue;
        }
        final answerIndex = (row['answer_index'] as num?)?.toInt();
        if (answerIndex == null) continue;

        final question = room.questions[questionIndex];
        final participantAnswers =
            answersByParticipant[name] ?? <int, int>{};
        participantAnswers[questionIndex] = answerIndex;
        answersByParticipant[name] = participantAnswers;
      }

      for (final row in participantRows) {
        final name = row['name'] as String;
        room.participants.add(
          Participant(
            name: name,
            score: (row['score'] as num?)?.toInt() ?? 0,
            answers: answersByParticipant[name],
          ),
        );
      }

      return room;
    } catch (error) {
      _logError('Supabase findRoom error', error);
      rethrow;
    }
  }

  Future<List<QuizRoom>> getAllRooms() async {
    final client = _requireClient('getAllRooms');

    try {
      final roomRows = await client.from('rooms').select();
      final rooms = <QuizRoom>[];

      for (final row in roomRows) {
        final code = row['code'] as String;
        final room = await findRoom(code);
        if (room != null) rooms.add(room);
      }

      return rooms;
    } catch (error) {
      _logError('Supabase getAllRooms error', error);
      rethrow;
    }
  }

  // ─── PARTICIPANT ─────────────────────────────────────────────
  Future<void> addParticipant({
    required QuizRoom room,
    required Participant participant,
  }) async {
    final client = _requireClient('addParticipant');

    try {
      final existing = await client
          .from('participants')
          .select('id')
          .eq('room_code', room.code)
          .eq('name', participant.name)
          .maybeSingle();

      if (existing == null) {
        await client.from('participants').insert({
          'room_code': room.code,
          'name': participant.name,
          'score': participant.score,
          'joined_at': DateTime.now().toIso8601String(),
        });
      } else {
        await client.from('participants').update({
          'score': participant.score,
        }).eq('id', existing['id']);
      }
    } catch (error) {
      _logError('Supabase addParticipant error', error);
      rethrow;
    }
  }

  // ─── SUBMIT ANSWER ──────────────────────────────────────────
  Future<void> submitAnswer({
    required QuizRoom room,
    required Participant participant,
    required int questionIndex,
    required int answerIndex,
    required bool isCorrect,
  }) async {
    final client = _requireClient('submitAnswer');

    try {
      final participantRow = await client
          .from('participants')
          .select('id,score')
          .eq('room_code', room.code)
          .eq('name', participant.name)
          .maybeSingle();

      final currentScore =
          (participantRow?['score'] as num?)?.toInt() ?? participant.score;
      final points = questionIndex >= 0 &&
              questionIndex < room.questions.length &&
              room.questions[questionIndex].points != null
          ? room.questions[questionIndex].points!
          : 100;
      final updatedScore = isCorrect ? currentScore + points : currentScore;

      final answerRow = {
        'participant_name': participant.name,
        'question_index': questionIndex,
        'answer_index': answerIndex,
        'is_correct': isCorrect,
        'answered_at': DateTime.now().toIso8601String(),
      };

      final existingAnswer = await client
          .from('answers')
          .select('id')
          .eq('participant_name', participant.name)
          .eq('question_index', questionIndex)
          .maybeSingle();

      if (existingAnswer == null) {
        await client.from('answers').insert(answerRow);
      } else {
        await client.from('answers').update(answerRow).eq('id', existingAnswer['id']);
      }

      if (participantRow == null) {
        await client.from('participants').insert({
          'room_code': room.code,
          'name': participant.name,
          'score': updatedScore,
          'joined_at': DateTime.now().toIso8601String(),
        });
      } else {
        await client.from('participants').update({
          'score': updatedScore,
        }).eq('id', participantRow['id']);
      }
    } catch (error) {
      _logError('Supabase submitAnswer error', error);
      rethrow;
    }
  }

  // ─── REALTIME SUBSCRIPTION (DIPERBAIKI) ────────────────────
  void subscribeRoom(String roomCode, VoidCallback onUpdate) {
    final client = _requireClient('subscribeRoom');

    final channel = client.channel('room:$roomCode');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'rooms',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'code',
            value: roomCode,
          ),
          callback: (event) => onUpdate(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'participants',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'room_code',
            value: roomCode,
          ),
          callback: (event) => onUpdate(),
        )
        .subscribe((status, error) {
      if (error != null) {
        debugPrint('Error subscribing to room $roomCode: $error');
      }
    });
  }

  // ─── SIGNOUT (DIPERBAIKI) ──────────────────────────────────
  Future<void> signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  Future<void> deleteQuestion(QuizRoom room, String? oldId) async {}

  Future<void> addQuestion(
      QuizRoom room, int index, QuizQuestion updated) async {}
}
