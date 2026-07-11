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

  // ─── SAVE USER ──────────────────────────────────────────────
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

  // ─── ROOM ────────────────────────────────────────────────────
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
        questions: sampleQuestions,
      );

      final phaseName = roomData['phase'] as String? ?? QuizPhase.waiting.name;

      room.phase = QuizPhase.values.firstWhere(
        (phase) => phase.name == phaseName,
        orElse: () => QuizPhase.waiting,
      );

      room.currentQuestionIndex =
          roomData['current_question_index'] as int? ?? 0;

      final participantRows =
          await client.from('participants').select().eq('room_code', room.code);

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

  Future<List<QuizRoom>> getAllRooms() async {
    final client = _client;
    if (client == null) return [];

    try {
      final roomRows = await client.from('rooms').select();
      final rooms = <QuizRoom>[];

      for (final row in roomRows) {
        final code = row['code'] as String;
        final room = await findRoom(code);
        if (room != null) rooms.add(room);
      }

      return rooms;
    } catch (_) {
      return [];
    }
  }

  // ─── PARTICIPANT ─────────────────────────────────────────────
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

  // ─── SUBMIT ANSWER ──────────────────────────────────────────
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
          })
          .eq('room_code', room.code)
          .eq('name', participant.name);
    } catch (_) {
      return;
    }
  }

  // ─── REALTIME SUBSCRIPTION (DIPERBAIKI) ────────────────────
  void subscribeRoom(String roomCode, VoidCallback onUpdate) {
    final client = _client;
    if (client == null) return;

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
        print('Error subscribing to room $roomCode: $error');
      }
    });
  }

  // ─── SIGNOUT (DIPERBAIKI) ──────────────────────────────────
  Future<void> signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  Future<void> deleteQuestion(QuizRoom room, String? oldId) async {}

  Future<void> addQuestion(
      QuizRoom room, int index, QuizQuestion updated) async {}
}
