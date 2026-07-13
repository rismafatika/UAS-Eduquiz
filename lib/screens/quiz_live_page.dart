import 'dart:async';

import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../models/participant.dart';
import '../models/quiz_room.dart';
import '../services/room_service.dart';
import '../services/supabase_service.dart';
import 'leaderboard_page.dart';

class QuizLivePage extends StatefulWidget {
  const QuizLivePage({super.key, required this.user, required this.room});
  final AppUser user;
  final QuizRoom room;

  @override
  State<QuizLivePage> createState() => _QuizLivePageState();
}

class _QuizLivePageState extends State<QuizLivePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  Timer? _refreshTimer;
  int? _selectedAnswer;
  bool _answered = false;
  Participant? _participant;
  bool _isLoading = true;

  bool get _isHost => widget.user.role == UserRole.host;
  Color get _primary =>
      _isHost ? const Color(0xFFEA580C) : const Color(0xFF0D9488);

  @override
  void initState() {
    super.initState();
    _pulseCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat(reverse: true);
    _initParticipant();
    SupabaseService.instance.subscribeRoom(widget.room.code, () {
      unawaited(_syncRoom());
    });
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      unawaited(_syncRoom());
    });
  }

  Future<void> _syncRoom() async {
    try {
      final previousQuestionIndex = widget.room.currentQuestionIndex;
      final updated =
          await RoomService.instance.findRoomConnected(widget.room.code);
      if (!mounted || updated == null) {
        return;
      }
      final questionChanged =
          updated.currentQuestionIndex != previousQuestionIndex;

      setState(() {
        widget.room.phase = updated.phase;
        widget.room.currentQuestionIndex = updated.currentQuestionIndex;
        widget.room.participants
          ..clear()
          ..addAll(updated.participants);
      });

      if (questionChanged && !_isHost) {
        setState(() {
          _selectedAnswer = null;
          _answered = false;
        });
      }

      if (widget.room.phase == QuizPhase.leaderboard ||
          widget.room.phase == QuizPhase.review ||
          widget.room.phase == QuizPhase.dashboard) {
        _goLeaderboard();
      }
    } catch (e) {
      debugPrint('Quiz sync failed: $e');
    }
  }

  Future<void> _initParticipant() async {
    try {
      // Coba tambahkan peserta (jika sudah ada, akan return existing)
      final p = await RoomService.instance.addParticipant(
        room: widget.room,
        name: widget.user.name,
      );
      if (mounted) {
        setState(() {
          _participant = p;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Jika gagal, tetap lanjut dengan participant dummy (tanpa score)
      debugPrint('Participant init error: $e');
      if (mounted) {
        setState(() {
          // Buat participant lokal agar tetap bisa jalan
          _participant = Participant(name: widget.user.name, score: 0);
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _answer(int index) async {
    if (_answered || _isHost || _participant == null) return;
    setState(() {
      _selectedAnswer = index;
      _answered = true;
    });

    try {
      await RoomService.instance.answerQuestion(
        room: widget.room,
        participant: _participant!,
        answerIndex: index,
      );
    } catch (e) {
      debugPrint('Answer submit failed: $e');
    }

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _selectedAnswer = null;
          _answered = false;
        });
      }
    });
  }

  Future<void> _finishFromHost() async {
    await RoomService.instance.nextQuestion(widget.room);
    if (!mounted) {
      return;
    }

    setState(() {});
    if (widget.room.phase == QuizPhase.leaderboard) {
      _goLeaderboard();
    }
  }

  void _goLeaderboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LeaderboardPage(user: widget.user, room: widget.room),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Memulai kuis...'),
            ],
          ),
        ),
      );
    }

    final question = widget.room.questions[widget.room.currentQuestionIndex];
    final progress =
        (widget.room.currentQuestionIndex + 1) / widget.room.questions.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildHeader(progress),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _QuestionCard(
                          question: question.question, primary: _primary),
                      const SizedBox(height: 16),
                      ...List.generate(
                        question.options.length,
                        (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _AnswerTile(
                            label: question.options[i],
                            index: i,
                            selected: _selectedAnswer,
                            answered: _answered,
                            correctIndex: question.correctIndex,
                            isHost: _isHost,
                            primary: _primary,
                            onTap: () => unawaited(_answer(i)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_isHost) _buildHostControls(),
                      if (!_isHost && _answered) _buildAnsweredNote(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double progress) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isHost
              ? [const Color(0xFFEA580C), const Color(0xFFD97706)]
              : [const Color(0xFF0D9488), const Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: SafeArea(
        bottom: false,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.room.title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Soal ${widget.room.currentQuestionIndex + 1}/${widget.room.questions.length}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                  minHeight: 7,
                ),
              ),
            ),
            const SizedBox(width: 10),
            if (!_isHost && _participant != null)
              Text(
                '${_participant!.score} poin',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700),
              ),
          ]),
        ]),
      ),
    );
  }

  Widget _buildHostControls() {
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
          ],
        ),
        child: Row(children: [
          Icon(Icons.people_outline_rounded, color: _primary, size: 20),
          const SizedBox(width: 10),
          Text(
            '${widget.room.participants.length} peserta aktif',
            style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A)),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF059669).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Live',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF059669))),
          ),
        ]),
      ),
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        height: 50,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient:
                LinearGradient(colors: [_primary, _primary.withOpacity(0.8)]),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: _primary.withOpacity(0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 6)),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: _finishFromHost,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.leaderboard_outlined, color: Colors.white),
            label: Text(
              widget.room.currentQuestionIndex >=
                      widget.room.questions.length - 1
                  ? 'Tampilkan Leaderboard'
                  : 'Soal Berikutnya',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15),
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _buildAnsweredNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF059669).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF059669).withOpacity(0.2)),
      ),
      child: Row(children: [
        const Icon(Icons.check_circle_rounded,
            color: Color(0xFF059669), size: 18),
        const SizedBox(width: 8),
        const Text(
          'Jawaban tersimpan! Menunggu soal berikutnya...',
          style: TextStyle(
              fontSize: 13,
              color: Color(0xFF059669),
              fontWeight: FontWeight.w600),
        ),
      ]),
    );
  }
}

// ─── Kartu Pertanyaan ────────────────────────────────────────
class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.question, required this.primary});
  final String question;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withOpacity(0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.help_outline_rounded, color: primary, size: 16),
          ),
          const SizedBox(width: 8),
          Text('Pertanyaan',
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: primary)),
        ]),
        const SizedBox(height: 14),
        Text(question,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
                height: 1.4)),
      ]),
    );
  }
}

// ─── Tile Pilihan Jawaban ──────────────────────────────────
class _AnswerTile extends StatelessWidget {
  const _AnswerTile({
    required this.label,
    required this.index,
    required this.selected,
    required this.answered,
    required this.correctIndex,
    required this.isHost,
    required this.primary,
    required this.onTap,
  });
  final String label;
  final int index;
  final int? selected;
  final bool answered, isHost;
  final int correctIndex;
  final Color primary;
  final VoidCallback onTap;

  static const _letters = ['A', 'B', 'C', 'D'];

  @override
  Widget build(BuildContext context) {
    Color bg = Colors.white;
    Color border = const Color(0xFFE2E8F0);
    Color textColor = const Color(0xFF0F172A);
    Color letterBg = const Color(0xFFF1F5F9);
    Color letterColor = const Color(0xFF94A3B8);
    IconData? trailingIcon;

    if (answered) {
      if (index == correctIndex) {
        bg = const Color(0xFFDCFCE7);
        border = const Color(0xFF059669);
        textColor = const Color(0xFF065F46);
        letterBg = const Color(0xFF059669).withOpacity(0.15);
        letterColor = const Color(0xFF059669);
        trailingIcon = Icons.check_circle_rounded;
      } else if (index == selected) {
        bg = const Color(0xFFFEE2E2);
        border = const Color(0xFFDC2626);
        textColor = const Color(0xFF991B1B);
        letterBg = const Color(0xFFDC2626).withOpacity(0.15);
        letterColor = const Color(0xFFDC2626);
        trailingIcon = Icons.cancel_rounded;
      }
    } else if (index == selected) {
      bg = primary.withOpacity(0.07);
      border = primary;
      textColor = primary;
      letterBg = primary.withOpacity(0.12);
      letterColor = primary;
    }

    return GestureDetector(
      onTap: (answered || isHost) ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: 1.5),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: letterBg,
              shape: BoxShape.circle,
              border: Border.all(color: border.withOpacity(0.3), width: 1),
            ),
            child: Center(
              child: Text(
                _letters[index.clamp(0, 3)],
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: letterColor),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  height: 1.3),
            ),
          ),
          if (trailingIcon != null) Icon(trailingIcon, size: 20, color: border),
        ]),
      ),
    );
  }
}
