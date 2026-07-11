import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../models/participant.dart';
import '../models/quiz_question.dart';
import '../models/quiz_room.dart';
import '../services/room_service.dart';
import 'review_page.dart';
import 'quiz_live_page.dart';
import 'rekap_nilai_page.dart'; // ← tambahkan import ini

class HostDashboardPage extends StatefulWidget {
  const HostDashboardPage({super.key, required this.user, required this.room});

  final AppUser user;
  final QuizRoom room;

  @override
  State<HostDashboardPage> createState() => _HostDashboardPageState();
}

class _HostDashboardPageState extends State<HostDashboardPage> {
  static const _primary = Color(0xFF0D9488);
  static const _primaryDark = Color(0xFF0F766E);
  static const _bg = Color(0xFFF0FDF4);
  static const _white = Color(0xFFFFFFFF);
  static const _muted = Color(0xFF6B7280);
  static const _shadow = Color(0x1A000000);
  static const _green = Color(0xFF059669);
  static const _orange = Color(0xFFEA580C);
  static const _red = Color(0xFFDC2626);

  // ─── Controller untuk pencarian ──────────────────────────
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  String get _statusLabel {
    switch (widget.room.phase) {
      case QuizPhase.live:
        return 'Berlangsung';
      case QuizPhase.leaderboard:
      case QuizPhase.review:
      case QuizPhase.dashboard:
        return 'Selesai';
      default:
        return 'Menunggu';
    }
  }

  Color get _statusColor {
    switch (widget.room.phase) {
      case QuizPhase.live:
        return _green;
      case QuizPhase.leaderboard:
      case QuizPhase.review:
      case QuizPhase.dashboard:
        return _green;
      default:
        return _orange;
    }
  }

  String get _statusIcon {
    switch (widget.room.phase) {
      case QuizPhase.live:
        return '🟢';
      case QuizPhase.leaderboard:
      case QuizPhase.review:
      case QuizPhase.dashboard:
        return '✔️';
      default:
        return '⏳';
    }
  }

  void _restartQuiz() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mulai Ulang Quiz?'),
        content: const Text(
          'Semua progres peserta akan direset. Yakin ingin melanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                RoomService.instance.startQuiz(widget.room);
              });
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => QuizLivePage(
                    user: widget.user,
                    room: widget.room,
                  ),
                ),
              );
            },
            child: const Text('Mulai Ulang'),
          ),
        ],
      ),
    );
  }

  void _openReview() {
    RoomService.instance.showReview(widget.room);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewPage(
          user: widget.user,
          room: widget.room,
        ),
      ),
    );
  }

  Future<void> _addQuestion() async {
    final question = await showDialog<QuizQuestion>(
      context: context,
      builder: (_) => _QuestionEditorDialog(
        initialQuestion: null,
      ),
    );

    if (question != null) {
      setState(() {
        RoomService.instance.addQuestion(widget.room, question);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Soal berhasil ditambahkan'),
          backgroundColor: _primary,
        ),
      );
    }
  }

  Future<void> _editQuestion(int index) async {
    final question = await showDialog<QuizQuestion>(
      context: context,
      builder: (_) => _QuestionEditorDialog(
        initialQuestion: widget.room.questions[index],
      ),
    );

    if (question != null) {
      setState(() {
        RoomService.instance.updateQuestion(widget.room, index, question);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Soal berhasil diperbarui'),
          backgroundColor: _primary,
        ),
      );
    }
  }

  Future<void> _deleteQuestion(int index) async {
    if (widget.room.questions.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimal harus ada 1 soal.'),
          backgroundColor: _orange,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Soal?'),
        content: Text('Soal nomor ${index + 1} akan dihapus. Yakin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: _red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        RoomService.instance.removeQuestion(widget.room, index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Soal berhasil dihapus'),
          backgroundColor: _red,
        ),
      );
    }
  }

  // ─── STATISTIK ──────────────────────────────────────────────
  Widget _buildStatistics() {
    final rooms = RoomService.instance.getAllRooms();
    final totalQuiz = rooms.length;
    final totalSoal = rooms.fold(0, (sum, r) => sum + r.questions.length);
    final totalPeserta = rooms.fold(0, (sum, r) => sum + r.participants.length);
    final totalRoom = rooms.length;

    // Top Quiz: room dengan peserta terbanyak
    QuizRoom? topQuiz;
    if (rooms.isNotEmpty) {
      topQuiz = rooms.reduce(
          (a, b) => a.participants.length > b.participants.length ? a : b);
    }

    // Top Peserta: gabungkan semua peserta dari semua room, total skor per nama
    final Map<String, int> participantScores = {};
    for (var room in rooms) {
      for (var p in room.participants) {
        participantScores[p.name] = (participantScores[p.name] ?? 0) + p.score;
      }
    }
    final sortedParticipants = participantScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topParticipants = sortedParticipants.take(3).toList();

    // Nilai rata-rata semua peserta
    final totalScore = participantScores.values.fold(0, (sum, s) => sum + s);
    final avgScore =
        participantScores.isEmpty ? 0 : totalScore / participantScores.length;

    // Grafik Quiz: distribusi room berdasarkan hari (Senin-Minggu) dari indeks room
    final Map<int, int> dayCount = {};
    for (int i = 0; i < rooms.length; i++) {
      final day = i % 7;
      dayCount[day] = (dayCount[day] ?? 0) + 1;
    }
    final List<int> chartData = List.generate(7, (i) => dayCount[i] ?? 0);
    final maxChart = chartData.reduce((a, b) => a > b ? a : b);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _shadow,
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 Statistik',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF064E3B),
            ),
          ),
          const SizedBox(height: 16),
          // Grid statistik 4 kolom
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _StatItem(
                label: 'Total Quiz',
                value: '$totalQuiz',
                icon: Icons.quiz_outlined,
                color: const Color(0xFF8B5CF6),
              ),
              _StatItem(
                label: 'Total Soal',
                value: '$totalSoal',
                icon: Icons.question_answer_outlined,
                color: const Color(0xFF0EA5E9),
              ),
              _StatItem(
                label: 'Peserta Aktif',
                value: '$totalPeserta',
                icon: Icons.people_alt_outlined,
                color: const Color(0xFFF59E0B),
              ),
              _StatItem(
                label: 'Total Room',
                value: '$totalRoom',
                icon: Icons.meeting_room_outlined,
                color: const Color(0xFF059669),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Grafik Quiz
          const Text(
            '📈 Grafik Quiz (Senin - Minggu)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF064E3B),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(7, (i) {
                final height =
                    maxChart == 0 ? 0 : (chartData[i] / maxChart) * 80;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      chartData[i].toString(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 20,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D9488)
                            .withOpacity(0.7 + (i / 7) * 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'][i],
                      style: const TextStyle(
                        fontSize: 9,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
          const Divider(height: 24),
          // Top Quiz
          Row(
            children: [
              const Text(
                '🏆 Top Quiz',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF064E3B),
                ),
              ),
              const Spacer(),
              if (topQuiz != null)
                Text(
                  '${topQuiz.participants.length} peserta',
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
            ],
          ),
          if (topQuiz != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                topQuiz.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0D9488),
                ),
              ),
            )
          else
            const Text(
              'Belum ada quiz',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          const Divider(height: 24),
          // Top Peserta
          const Text(
            '🏅 Top Peserta',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF064E3B),
            ),
          ),
          const SizedBox(height: 8),
          ...topParticipants.asMap().entries.map((entry) {
            final index = entry.key;
            final p = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0D9488),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(p.key),
                  const Spacer(),
                  Text(
                    '${p.value} poin',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }),
          const Divider(height: 24),
          // Nilai rata-rata
          Row(
            children: [
              const Text(
                '📊 Nilai rata-rata',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF064E3B),
                ),
              ),
              const Spacer(),
              Text(
                avgScore.toStringAsFixed(0),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0D9488),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Tombol Rekap Nilai
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RekapNilaiPage(
                      user: widget.user,
                      room: widget.room,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.bar_chart_outlined, size: 18),
              label: const Text('Lihat Rekap Nilai Detail'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0D9488),
                side: const BorderSide(color: Color(0xFF0D9488)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Build ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final participants = widget.room.participants;
    final totalQuestions = widget.room.questions.length;
    final totalAnswers = participants.fold<int>(
      0,
      (sum, p) => sum + p.answers.length,
    );
    final maxAnswers = participants.length * totalQuestions;
    final averageScore = participants.isEmpty
        ? 0
        : participants.map((p) => p.score).reduce((a, b) => a + b) /
            participants.length;

    final ranked = List<Participant>.from(participants)
      ..sort((a, b) => b.score.compareTo(a.score));

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
          '📊 Dashboard Host',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatusCard(
                title: widget.room.title,
                code: widget.room.code,
                hostName: widget.room.hostName,
                participantCount: participants.length,
                status: _statusLabel,
                statusColor: _statusColor,
                statusIcon: _statusIcon,
              ),
              const SizedBox(height: 16),
              _StatGrid(
                participantCount: participants.length,
                questionCount: totalQuestions,
                answerSummary: '$totalAnswers/$maxAnswers',
                averageScore: averageScore.toStringAsFixed(0),
              ),
              const SizedBox(height: 16),
              _ParticipantList(participants: participants),
              const SizedBox(height: 16),
              _ControlButtons(
                onRestart: _restartQuiz,
                onReview: _openReview,
                onAddQuestion: _addQuestion,
              ),
              const SizedBox(height: 16),
              _ScoreBoard(
                participants: ranked,
                totalQuestions: totalQuestions,
              ),
              const SizedBox(height: 16),
              // ─── STATISTIK ─────────────────────────────────
              _buildStatistics(), // <-- TAMBAHKAN INI
              const SizedBox(height: 16),
              // ─── BANK SOAL ─────────────────────────────────
              _BankSoalSection(
                questions: widget.room.questions,
                searchQuery: _searchQuery,
                searchController: _searchController,
                onSearchChanged: (query) {
                  setState(() {
                    _searchQuery = query;
                  });
                },
                onAdd: _addQuestion,
                onEdit: _editQuestion,
                onDelete: _deleteQuestion,
                onImport: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fitur Import Excel akan segera hadir'),
                    ),
                  );
                },
                onExport: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fitur Export Excel akan segera hadir'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── STATUS ROOM ─────────────────────────────────────────────
class _StatusCard extends StatelessWidget {
  final String title;
  final String code;
  final String hostName;
  final int participantCount;
  final String status;
  final Color statusColor;
  final String statusIcon;

  const _StatusCard({
    required this.title,
    required this.code,
    required this.hostName,
    required this.participantCount,
    required this.status,
    required this.statusColor,
    required this.statusIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _HostDashboardPageState._white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _HostDashboardPageState._shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: statusColor.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF064E3B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(statusIcon, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: _HostDashboardPageState._primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '🔑 $code',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _HostDashboardPageState._primary,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: _HostDashboardPageState._muted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$participantCount peserta',
                    style: TextStyle(
                      fontSize: 13,
                      color: _HostDashboardPageState._muted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Host: $hostName',
            style: TextStyle(
              fontSize: 13,
              color: _HostDashboardPageState._muted,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── STAT GRID ──────────────────────────────────────────────
class _StatGrid extends StatelessWidget {
  final int participantCount;
  final int questionCount;
  final String answerSummary;
  final String averageScore;

  const _StatGrid({
    required this.participantCount,
    required this.questionCount,
    required this.answerSummary,
    required this.averageScore,
  });

  @override
  Widget build(BuildContext context) {
    final stats = [
      {
        'label': 'Peserta',
        'value': '$participantCount',
        'icon': Icons.groups_2_outlined,
        'color': const Color(0xFF8B5CF6),
      },
      {
        'label': 'Soal',
        'value': '$questionCount',
        'icon': Icons.quiz_outlined,
        'color': const Color(0xFF0EA5E9),
      },
      {
        'label': 'Jawaban',
        'value': answerSummary,
        'icon': Icons.checklist_rtl,
        'color': const Color(0xFFF59E0B),
      },
      {
        'label': 'Rata-rata',
        'value': averageScore,
        'icon': Icons.bar_chart_rounded,
        'color': const Color(0xFF059669),
      },
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: stats
          .map((s) => _StatItem(
                label: s['label'] as String,
                value: s['value'] as String,
                icon: s['icon'] as IconData,
                color: s['color'] as Color,
              ))
          .toList(),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _HostDashboardPageState._white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: _HostDashboardPageState._shadow,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
        ],
      ),
    );
  }
}

// ─── DAFTAR PESERTA ────────────────────────────────────────
class _ParticipantList extends StatelessWidget {
  final List<Participant> participants;

  const _ParticipantList({required this.participants});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _HostDashboardPageState._white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _HostDashboardPageState._shadow,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.people_outline,
                color: _HostDashboardPageState._primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Peserta (${participants.length})',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF064E3B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (participants.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Belum ada peserta yang bergabung',
                  style: TextStyle(color: Color(0xFF6B7280)),
                ),
              ),
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: participants.map((p) {
                final hasAnswered = p.answers.isNotEmpty;
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: hasAnswered
                        ? Colors.green.shade50
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: hasAnswered
                          ? Colors.green.shade200
                          : Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor:
                            hasAnswered ? const Color(0xFF059669) : Colors.grey,
                        child: Text(
                          p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        p.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: hasAnswered
                              ? const Color(0xFF064E3B)
                              : const Color(0xFF6B7280),
                        ),
                      ),
                      if (hasAnswered)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.check_circle_rounded,
                            size: 14,
                            color: Color(0xFF059669),
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

// ─── KONTROL SESI ──────────────────────────────────────────
class _ControlButtons extends StatelessWidget {
  final VoidCallback onRestart;
  final VoidCallback onReview;
  final VoidCallback onAddQuestion;

  const _ControlButtons({
    required this.onRestart,
    required this.onReview,
    required this.onAddQuestion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _HostDashboardPageState._white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _HostDashboardPageState._shadow,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🎮 Kontrol Sesi',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF064E3B),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ElevatedButton.icon(
                onPressed: onRestart,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Mulai Ulang'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
              OutlinedButton.icon(
                onPressed: onReview,
                icon: const Icon(Icons.rate_review_outlined, size: 18),
                label: const Text('Review'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0EA5E9),
                  side: const BorderSide(color: Color(0xFF0EA5E9)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
              OutlinedButton.icon(
                onPressed: onAddQuestion,
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text('Tambah Soal'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _HostDashboardPageState._primary,
                  side: BorderSide(color: _HostDashboardPageState._primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── SCORE BOARD ──────────────────────────────────────────
class _ScoreBoard extends StatelessWidget {
  final List<Participant> participants;
  final int totalQuestions;

  const _ScoreBoard({
    required this.participants,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _HostDashboardPageState._white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _HostDashboardPageState._shadow,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🏆 Score Board',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF064E3B),
            ),
          ),
          const SizedBox(height: 12),
          if (participants.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Belum ada peserta',
                  style: TextStyle(color: Color(0xFF6B7280)),
                ),
              ),
            )
          else
            ...participants.asMap().entries.map((entry) {
              final index = entry.key;
              final p = entry.value;
              final rank = index + 1;
              final progress =
                  totalQuestions == 0 ? 0.0 : p.answers.length / totalQuestions;

              return _ScoreRow(
                rank: rank,
                participant: p,
                progress: progress,
              );
            }),
        ],
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final int rank;
  final Participant participant;
  final double progress;

  const _ScoreRow({
    required this.rank,
    required this.participant,
    required this.progress,
  });

  String get _rankEmoji {
    if (rank == 1) return '🥇';
    if (rank == 2) return '🥈';
    if (rank == 3) return '🥉';
    return '#$rank';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: rank <= 3 ? const Color(0xFFFFFBEB) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: rank == 1 ? const Color(0xFFFDE68A) : Colors.grey.shade200,
          width: rank == 1 ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Text(
              _rankEmoji,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: rank <= 3
                    ? const Color(0xFFF59E0B)
                    : const Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participant.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF064E3B),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation(
                            progress >= 0.8
                                ? const Color(0xFF059669)
                                : progress >= 0.5
                                    ? const Color(0xFFF59E0B)
                                    : const Color(0xFFDC2626),
                          ),
                          minHeight: 4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${participant.score}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0D9488),
                ),
              ),
              Text(
                '${participant.answers.length}/10',
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── BANK SOAL ──────────────────────────────────────────────
class _BankSoalSection extends StatelessWidget {
  final List<QuizQuestion> questions;
  final String searchQuery;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onAdd;
  final ValueChanged<int> onEdit;
  final ValueChanged<int> onDelete;
  final VoidCallback onImport;
  final VoidCallback onExport;

  const _BankSoalSection({
    required this.questions,
    required this.searchQuery,
    required this.searchController,
    required this.onSearchChanged,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.onImport,
    required this.onExport,
  });

  Map<String, List<QuizQuestion>> get _groupedQuestions {
    final Map<String, List<QuizQuestion>> map = {};
    final filtered = questions.where((q) =>
        q.question.toLowerCase().contains(searchQuery.toLowerCase()) ||
        (q.category?.toLowerCase().contains(searchQuery.toLowerCase()) ??
            false));
    for (var q in filtered) {
      final category = q.category ?? 'Umum';
      map.putIfAbsent(category, () => []).add(q);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupedQuestions;
    final totalQuestions = questions.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _HostDashboardPageState._white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _HostDashboardPageState._shadow,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '📚 Bank Soal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF064E3B),
                ),
              ),
              const Spacer(),
              Text(
                '$totalQuestions Soal',
                style: TextStyle(
                  fontSize: 13,
                  color: _HostDashboardPageState._muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Cari soal atau kategori...',
              prefixIcon: const Icon(Icons.search, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('+ Tambah Soal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _HostDashboardPageState._primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (grouped.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Text(
                  'Tidak ada soal ditemukan',
                  style: TextStyle(color: Color(0xFF6B7280)),
                ),
              ),
            )
          else
            ...grouped.entries.map((entry) {
              final category = entry.key;
              final soalList = entry.value;
              return _CategorySection(
                category: category,
                questions: soalList,
                onEdit: (index) {
                  final originalIndex = questions.indexOf(soalList[index]);
                  onEdit(originalIndex);
                },
                onDelete: (index) {
                  final originalIndex = questions.indexOf(soalList[index]);
                  onDelete(originalIndex);
                },
              );
            }),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onImport,
                  icon: const Icon(Icons.file_upload_outlined, size: 18),
                  label: const Text('Import Excel'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onExport,
                  icon: const Icon(Icons.file_download_outlined, size: 18),
                  label: const Text('Export Excel'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── WIDGET KATEGORI ──────────────────────────────────────
class _CategorySection extends StatelessWidget {
  final String category;
  final List<QuizQuestion> questions;
  final ValueChanged<int> onEdit;
  final ValueChanged<int> onDelete;

  const _CategorySection({
    required this.category,
    required this.questions,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                category,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF064E3B),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _HostDashboardPageState._primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${questions.length} Soal',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _HostDashboardPageState._primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...questions.asMap().entries.map((entry) {
            final idx = entry.key;
            final q = entry.value;
            return _QuestionItemSimple(
              number: idx + 1,
              question: q,
              onEdit: () => onEdit(idx),
              onDelete: () => onDelete(idx),
            );
          }),
        ],
      ),
    );
  }
}

// ─── ITEM SOAL SEDERHANA ──────────────────────────────────
class _QuestionItemSimple extends StatelessWidget {
  final int number;
  final QuizQuestion question;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _QuestionItemSimple({
    required this.number,
    required this.question,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${number}. ${question.question}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF064E3B),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 18),
            color: const Color(0xFF0EA5E9),
            tooltip: 'Ubah',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, size: 18),
            color: const Color(0xFFDC2626),
            tooltip: 'Hapus',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

// ─── DIALOG EDITOR SOAL ──────────────────────────────────
class _QuestionEditorDialog extends StatefulWidget {
  final QuizQuestion? initialQuestion;

  const _QuestionEditorDialog({this.initialQuestion});

  @override
  State<_QuestionEditorDialog> createState() => _QuestionEditorDialogState();
}

class _QuestionEditorDialogState extends State<_QuestionEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _questionController;
  late final List<TextEditingController> _optionControllers;
  late final TextEditingController _explanationController;
  late final TextEditingController _categoryController;
  late int _correctIndex;

  @override
  void initState() {
    super.initState();
    final q = widget.initialQuestion;
    _questionController = TextEditingController(text: q?.question ?? '');
    _optionControllers = List.generate(
      4,
      (i) => TextEditingController(text: q?.options[i] ?? ''),
    );
    _explanationController = TextEditingController(text: q?.explanation ?? '');
    _categoryController = TextEditingController(text: q?.category ?? 'Umum');
    _correctIndex = q?.correctIndex ?? 0;
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (final c in _optionControllers) c.dispose();
    _explanationController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      QuizQuestion(
        question: _questionController.text.trim(),
        options: _optionControllers.map((c) => c.text.trim()).toList(),
        correctIndex: _correctIndex,
        explanation: _explanationController.text.trim(),
        category: _categoryController.text.trim().isEmpty
            ? 'Umum'
            : _categoryController.text.trim(),
        points: 100,
        color: const Color(0xFF1D4ED8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initialQuestion == null ? 'Tambah Soal' : 'Ubah Soal',
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _questionController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Pertanyaan',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v?.trim().isEmpty == true ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                ...List.generate(
                  4,
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TextFormField(
                      controller: _optionControllers[i],
                      decoration: InputDecoration(
                        labelText: 'Pilihan ${String.fromCharCode(65 + i)}',
                        border: const OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v?.trim().isEmpty == true ? 'Wajib diisi' : null,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Jawaban Benar',
                    border: OutlineInputBorder(),
                  ),
                  value: _correctIndex,
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('Pilihan A')),
                    DropdownMenuItem(value: 1, child: Text('Pilihan B')),
                    DropdownMenuItem(value: 2, child: Text('Pilihan C')),
                    DropdownMenuItem(value: 3, child: Text('Pilihan D')),
                  ],
                  onChanged: (value) =>
                      setState(() => _correctIndex = value ?? 0),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Kategori (contoh: Matematika, IPA, dll)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _explanationController,
                  minLines: 2,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Pembahasan (opsional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Simpan'),
          style: FilledButton.styleFrom(
            backgroundColor: _HostDashboardPageState._primary,
          ),
        ),
      ],
    );
  }
}
