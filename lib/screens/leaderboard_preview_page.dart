import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../models/quiz_room.dart';
import '../models/participant.dart';
import '../services/room_service.dart';
import 'leaderboard_page.dart';

class LeaderboardPreviewPage extends StatelessWidget {
  final AppUser user;
  final QuizRoom room;

  const LeaderboardPreviewPage({
    super.key,
    required this.user,
    required this.room,
  });

  static const _primary = Color(0xFF0D9488);
  static const _bg = Color(0xFFF0FDF4);
  static const _white = Color(0xFFFFFFFF);
  static const _muted = Color(0xFF6B7280);
  static const _shadow = Color(0x1A000000);

  @override
  Widget build(BuildContext context) {
    final participants = room.participants;

    // Cari user saat ini
    Participant? currentParticipant = participants.isNotEmpty
        ? participants.firstWhere(
            (p) => p.name == user.name,
            orElse: () => Participant(name: user.name, score: 0),
          )
        : Participant(name: user.name, score: 0);

    // Urutkan untuk peringkat
    final sorted = List<Participant>.from(participants)
      ..sort((a, b) => b.score.compareTo(a.score));

    final rank = sorted.indexOf(currentParticipant) + 1;
    final score = currentParticipant.score;
    final totalQuestions = room.questions.length;
    final answeredQuestions = currentParticipant.answers.length;
    final progress =
        totalQuestions > 0 ? answeredQuestions / totalQuestions : 0.0;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '🏆 Leaderboard',
          style: TextStyle(
            color: _primary,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── PERINGKAT SAYA ──────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_primary, _primary.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _primary.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: _white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.emoji_events_rounded,
                              color: _white,
                              size: 18,
                            ),
                            Text(
                              '#$rank',
                              style: const TextStyle(
                                color: _white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Peringkat Saya',
                            style: TextStyle(
                              color: _white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$score poin',
                            style: const TextStyle(
                              color: _white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'Benar $answeredQuestions/$totalQuestions',
                            style: TextStyle(
                              color: _white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ─── PROGRESS BAR ─────────────────────────────────
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: _white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _shadow,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Progress',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF064E3B),
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: _primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        backgroundColor: _primary.withOpacity(0.12),
                        valueColor: AlwaysStoppedAnimation(_primary),
                        minHeight: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('0%',
                            style: TextStyle(fontSize: 11, color: _muted)),
                        Text('100%',
                            style: TextStyle(fontSize: 11, color: _muted)),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // ─── TOMBOL LIHAT LEADERBOARD ─────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LeaderboardPage(user: user, room: room),
                      ),
                    );
                  },
                  icon: const Icon(Icons.leaderboard_outlined),
                  label: const Text(
                    'Lihat Leaderboard',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: _white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                    shadowColor: _primary.withOpacity(0.3),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Lihat peringkat lengkap dan detail semua peserta',
                style: TextStyle(
                  fontSize: 12,
                  color: _muted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
