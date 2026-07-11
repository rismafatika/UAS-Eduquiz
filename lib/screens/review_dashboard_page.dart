import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../models/quiz_room.dart';
import '../models/participant.dart';
import '../services/room_service.dart';
import 'review_page.dart';
import 'lobby_page.dart';

class ReviewDashboardPage extends StatelessWidget {
  final AppUser user;

  const ReviewDashboardPage({super.key, required this.user});

  static const _primary = Color(0xFF0D9488);
  static const _bg = Color(0xFFF0FDF4);
  static const _white = Color(0xFFFFFFFF);
  static const _muted = Color(0xFF6B7280);
  static const _shadow = Color(0x1A000000);

  @override
  Widget build(BuildContext context) {
    final rooms = RoomService.instance.getAllRooms();
    final QuizRoom? lastRoom = rooms.isNotEmpty ? rooms.last : null;

    Participant? currentParticipant;
    if (lastRoom != null) {
      currentParticipant = lastRoom.participants.firstWhere(
        (p) => p.name == user.name,
        orElse: () => Participant(name: user.name, score: 0),
      );
    }

    final hasData = lastRoom != null;
    final score = currentParticipant?.score ?? 0;
    final totalQuestions = hasData ? lastRoom!.questions.length : 0;
    final isCompleted = hasData &&
        (lastRoom!.phase == QuizPhase.leaderboard ||
            lastRoom!.phase == QuizPhase.review);

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
          '📖 Review Jawaban',
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quiz terakhir
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: _white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: _shadow,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📖 Quiz Terakhir',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF064E3B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (hasData) ...[
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.quiz_rounded,
                              color: _primary,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lastRoom!.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF064E3B),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isCompleted
                                            ? Colors.green.shade100
                                            : Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        isCompleted
                                            ? '✔ Selesai'
                                            : '⏳ Belum selesai',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: isCompleted
                                              ? Colors.green.shade800
                                              : Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _InfoItem(
                            label: 'Nilai',
                            value: '$score',
                            color: score >= 80
                                ? const Color(0xFF059669)
                                : score >= 60
                                    ? const Color(0xFFF59E0B)
                                    : const Color(0xFFDC2626),
                          ),
                          const SizedBox(width: 12),
                          _InfoItem(
                            label: 'Tanggal',
                            value: '10 Juli 2026',
                            color: _muted,
                          ),
                          const SizedBox(width: 12),
                          _InfoItem(
                            label: 'Soal',
                            value: '$totalQuestions',
                            color: _muted,
                          ),
                        ],
                      ),
                    ] else ...[
                      const Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.quiz_outlined,
                              size: 48,
                              color: Color(0xFF6B7280),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Belum ada quiz yang diikuti',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: hasData
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ReviewPage(
                                      user: user,
                                      room: lastRoom!,
                                    ),
                                  ),
                                );
                              }
                            : null,
                        icon: const Icon(Icons.rate_review_outlined, size: 18),
                        label: const Text('Lihat Pembahasan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor: _white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor: _muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Room terakhir
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: _white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: _shadow,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🔑 Room Terakhir',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF064E3B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (hasData) ...[
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              lastRoom!.code,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: _primary,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? Colors.green.shade100
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isCompleted ? '✔ Selesai' : '⏳ Menunggu',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isCompleted
                                    ? Colors.green.shade800
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Guru: ${lastRoom.hostName}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ] else ...[
                      const Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.key_off_rounded,
                              size: 48,
                              color: Color(0xFF6B7280),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Belum ada room yang diikuti',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: hasData
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => LobbyPage(
                                      user: user,
                                      room: lastRoom!,
                                    ),
                                  ),
                                );
                              }
                            : null,
                        icon: const Icon(Icons.login_rounded, size: 18),
                        label: const Text('Masuk Lagi'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _primary,
                          side: BorderSide(
                            color: _primary.withOpacity(0.4),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.04),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.08)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
