import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/participant.dart';
import '../models/quiz_room.dart';
import '../services/room_service.dart';
import '../widgets/room_header.dart';
import 'quiz_live_page.dart';
import 'review_page.dart';

class _C {
  static const orange = Color(0xFFEA580C);
  static const orangeBg = Color(0xFFFEF3C7);
  static const bg = Color(0xFFF8FAFC);
  static const card = Color(0xFFFFFFFF);
  static const dark = Color(0xFF0F172A);
  static const body = Color(0xFF334155);
  static const muted = Color(0xFF94A3B8);
  static const border = Color(0xFFE2E8F0);
}

class HostDashboardPage extends StatefulWidget {
  const HostDashboardPage({super.key, required this.user, required this.room});
  final AppUser user;
  final QuizRoom room;

  @override
  State<HostDashboardPage> createState() => _HostDashboardPageState();
}

class _HostDashboardPageState extends State<HostDashboardPage> {
  int _tab = 0; // 0=Overview 1=Peserta 2=Rekap

  int get _totalAnswers =>
      widget.room.participants.fold(0, (sum, p) => sum + p.answers.length);
  int get _maxAnswers =>
      widget.room.participants.length * widget.room.questions.length;
  double get _avgScore => widget.room.participants.isEmpty
      ? 0
      : widget.room.participants.map((p) => p.score).reduce((a, b) => a + b) /
          widget.room.participants.length;

  void _restartQuiz() {
    setState(() => RoomService.instance.startQuiz(widget.room));
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) =>
                QuizLivePage(user: widget.user, room: widget.room)));
  }

  void _openReview() {
    RoomService.instance.showReview(widget.room);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ReviewPage(user: widget.user, room: widget.room)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
              child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _buildContent(),
          )),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEA580C), Color(0xFFD97706)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
              color: _C.orange.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8))
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
      child: SafeArea(
        bottom: false,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Top bar
          Row(children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.arrow_back_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
            const SizedBox(width: 12),
            const Text('Dashboard Host',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800)),
            const Spacer(),
            // Room code badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.pin_outlined, color: Colors.white, size: 14),
                const SizedBox(width: 5),
                Text(widget.room.code,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2)),
              ]),
            ),
          ]),
          const SizedBox(height: 18),
          Text(widget.room.title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5)),
          const SizedBox(height: 4),
          Text('Host: ${widget.user.name}',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.75), fontSize: 13)),
          const SizedBox(height: 16),
          // Metrik row
          Row(children: [
            _HeaderMetric(
                label: 'Peserta',
                value: '${widget.room.participants.length}',
                icon: Icons.groups_2_outlined),
            _VDivider(),
            _HeaderMetric(
                label: 'Jawaban',
                value: '$_totalAnswers/$_maxAnswers',
                icon: Icons.checklist_rtl_outlined),
            _VDivider(),
            _HeaderMetric(
                label: 'Rata-rata',
                value: _avgScore.toStringAsFixed(0),
                icon: Icons.bar_chart_rounded),
          ]),
        ]),
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = [
      ('Overview', Icons.dashboard_outlined),
      ('Peserta', Icons.people_outline),
      ('Rekap Nilai', Icons.analytics_outlined)
    ];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
          children: List.generate(tabs.length, (i) {
        final active = _tab == i;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => setState(() => _tab = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: active ? _C.orange : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(tabs[i].$2,
                    size: 15, color: active ? Colors.white : _C.muted),
                const SizedBox(width: 5),
                Text(tabs[i].$1,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: active ? Colors.white : _C.muted,
                    )),
              ]),
            ),
          ),
        );
      })),
    );
  }

  Widget _buildContent() {
    switch (_tab) {
      case 1:
        return _PesertaTab(room: widget.room);
      case 2:
        return _RekapTab(room: widget.room, avgScore: _avgScore);
      default:
        return _OverviewTab(
            room: widget.room, onRestart: _restartQuiz, onReview: _openReview);
    }
  }
}

// ── Tab Overview ──
class _OverviewTab extends StatelessWidget {
  const _OverviewTab(
      {required this.room, required this.onRestart, required this.onReview});
  final QuizRoom room;
  final VoidCallback onRestart, onReview;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Kontrol
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ]),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Kontrol Sesi',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w800, color: _C.dark)),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                  child: SizedBox(
                      height: 46,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Color(0xFFEA580C), Color(0xFFD97706)]),
                          borderRadius: BorderRadius.circular(13),
                          boxShadow: [
                            BoxShadow(
                                color: _C.orange.withOpacity(0.35),
                                blurRadius: 14,
                                offset: const Offset(0, 6))
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: onRestart,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13))),
                          icon: const Icon(Icons.refresh_rounded,
                              color: Colors.white, size: 18),
                          label: const Text('Mulai Ulang',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ))),
              const SizedBox(width: 10),
              Expanded(
                  child: SizedBox(
                      height: 46,
                      child: OutlinedButton.icon(
                        onPressed: onReview,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _C.orange,
                          side: const BorderSide(
                              color: Color(0xFFEA580C), width: 1.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13)),
                        ),
                        icon: const Icon(Icons.rate_review_outlined, size: 18),
                        label: const Text('Review',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                      ))),
            ]),
          ]),
        ),
        const SizedBox(height: 16),
        // Progress per peserta
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ]),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Text('Progres Peserta',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _C.dark)),
              const Spacer(),
              Text('${room.participants.length} orang',
                  style: const TextStyle(fontSize: 12, color: _C.muted)),
            ]),
            const SizedBox(height: 14),
            if (room.participants.isEmpty)
              const Center(
                  child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('Belum ada peserta bergabung',
                    style: TextStyle(color: _C.muted)),
              ))
            else
              ...room.participants
                  .map((p) => _ProgressRow(participant: p, room: room)),
          ]),
        ),
      ],
    );
  }
}

// ── Tab Peserta ──
class _PesertaTab extends StatelessWidget {
  const _PesertaTab({required this.room});
  final QuizRoom room;

  @override
  Widget build(BuildContext context) {
    if (room.participants.isEmpty) {
      return const Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.people_outline, size: 48, color: _C.muted),
        SizedBox(height: 12),
        Text('Belum ada peserta',
            style: TextStyle(fontSize: 15, color: _C.muted)),
      ]));
    }

    final sorted = [...room.participants]
      ..sort((a, b) => b.score.compareTo(a.score));

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: sorted.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final p = sorted[i];
        final rank = i + 1;
        final rankColor = rank == 1
            ? const Color(0xFFF59E0B)
            : rank == 2
                ? const Color(0xFF94A3B8)
                : rank == 3
                    ? const Color(0xFFCD7F32)
                    : _C.muted;
        final initials = p.name
            .trim()
            .split(' ')
            .take(2)
            .map((w) => w[0].toUpperCase())
            .join();
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: rank <= 3
                ? Border.all(color: rankColor.withOpacity(0.35), width: 1.5)
                : null,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3))
            ],
          ),
          child: Row(children: [
            Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: rankColor.withOpacity(0.12), shape: BoxShape.circle),
                child: Center(
                    child: rank <= 3
                        ? Icon(Icons.emoji_events_rounded,
                            color: rankColor, size: 18)
                        : Text('#$rank',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: rankColor)))),
            const SizedBox(width: 10),
            Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [_C.orange, _C.orange.withOpacity(0.7)]),
                    shape: BoxShape.circle),
                child: Center(
                    child: Text(initials,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)))),
            const SizedBox(width: 10),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(p.name,
                      style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: _C.dark)),
                  Text('${p.answers.length}/${room.questions.length} dijawab',
                      style: const TextStyle(fontSize: 11.5, color: _C.muted)),
                ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${p.score}',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: _C.orange)),
              const Text('poin',
                  style: TextStyle(fontSize: 10.5, color: _C.muted)),
            ]),
          ]),
        );
      },
    );
  }
}

// ── Tab Rekap Nilai ──
class _RekapTab extends StatelessWidget {
  const _RekapTab({required this.room, required this.avgScore});
  final QuizRoom room;
  final double avgScore;

  @override
  Widget build(BuildContext context) {
    if (room.participants.isEmpty) {
      return const Center(
          child:
              Text('Belum ada data rekap', style: TextStyle(color: _C.muted)));
    }

    final sorted = [...room.participants]
      ..sort((a, b) => b.score.compareTo(a.score));
    final lulus = sorted.where((p) => p.score >= 70).length;
    final maxScore = sorted.first.score;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Ringkasan
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFFEA580C), Color(0xFFD97706)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: _C.orange.withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6))
            ],
          ),
          child: Row(children: [
            Expanded(
                child: _SummaryItem(
                    label: 'Peserta',
                    value: '${sorted.length}',
                    icon: Icons.group_outlined)),
            _VLine(),
            Expanded(
                child: _SummaryItem(
                    label: 'Rata-rata',
                    value: avgScore.toStringAsFixed(1),
                    icon: Icons.bar_chart_rounded)),
            _VLine(),
            Expanded(
                child: _SummaryItem(
                    label: 'Lulus (≥70)',
                    value: '$lulus',
                    icon: Icons.check_circle_outline)),
          ]),
        ),
        const SizedBox(height: 14),
        // Progress kelulusan
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
              ]),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Tingkat Kelulusan',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _C.dark)),
              Text('${(lulus / sorted.length * 100).round()}%',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _C.orange)),
            ]),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: lulus / sorted.length,
                backgroundColor: _C.orange.withOpacity(0.12),
                valueColor: const AlwaysStoppedAnimation(_C.orange),
                minHeight: 10,
              ),
            ),
          ]),
        ),
        const SizedBox(height: 14),
        // Soal paling banyak salah
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
              ]),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Distribusi Skor',
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700, color: _C.dark)),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: sorted.asMap().entries.map((e) {
                final pct = maxScore > 0 ? e.value.score / maxScore : 0.0;
                return _ScoreBar(
                    name: e.value.name.split(' ').first,
                    score: e.value.score,
                    height: 80 * pct);
              }).toList(),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        const Text('Peringkat Lengkap',
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w800, color: _C.dark)),
        const SizedBox(height: 10),
        ...sorted.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _RekapRow(
                  participant: e.value,
                  rank: e.key + 1,
                  total: room.questions.length),
            )),
      ],
    );
  }
}

// ── Widget kecil ──
class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.participant, required this.room});
  final Participant participant;
  final QuizRoom room;

  @override
  Widget build(BuildContext context) {
    final progress = room.questions.isEmpty
        ? 0.0
        : participant.answers.length / room.questions.length;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(participant.name,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, color: _C.dark, fontSize: 13.5)),
          Text('${participant.score} poin',
              style: const TextStyle(
                  fontSize: 12.5,
                  color: _C.orange,
                  fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          Expanded(
              child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: _C.orange.withOpacity(0.12),
              valueColor: const AlwaysStoppedAnimation(_C.orange),
              minHeight: 7,
            ),
          )),
          const SizedBox(width: 10),
          Text('${participant.answers.length}/${room.questions.length}',
              style: const TextStyle(
                  fontSize: 11, color: _C.muted, fontWeight: FontWeight.w600)),
        ]),
      ]),
    );
  }
}

class _HeaderMetric extends StatelessWidget {
  const _HeaderMetric(
      {required this.label, required this.value, required this.icon});
  final String label, value;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Column(children: [
      Icon(icon, color: Colors.white.withOpacity(0.8), size: 18),
      const SizedBox(height: 4),
      Text(value,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5)),
      Text(label,
          style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.7))),
    ]));
  }
}

class _VDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
      width: 1,
      height: 40,
      color: Colors.white.withOpacity(0.25),
      margin: const EdgeInsets.symmetric(horizontal: 6));
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem(
      {required this.label, required this.value, required this.icon});
  final String label, value;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Icon(icon, color: Colors.white.withOpacity(0.85), size: 18),
      const SizedBox(height: 5),
      Text(value,
          style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5)),
      const SizedBox(height: 2),
      Text(label,
          style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.75)),
          textAlign: TextAlign.center),
    ]);
  }
}

class _VLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
      width: 1,
      height: 44,
      color: Colors.white.withOpacity(0.25),
      margin: const EdgeInsets.symmetric(horizontal: 4));
}

class _ScoreBar extends StatelessWidget {
  const _ScoreBar(
      {required this.name, required this.score, required this.height});
  final String name;
  final int score;
  final double height;
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
      Text('$score',
          style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700, color: _C.orange)),
      const SizedBox(height: 4),
      Container(
          width: 32,
          height: height.clamp(8.0, 80.0),
          decoration: BoxDecoration(
              color: _C.orange, borderRadius: BorderRadius.circular(6))),
      const SizedBox(height: 6),
      Text(name,
          style: const TextStyle(fontSize: 10, color: _C.muted),
          overflow: TextOverflow.ellipsis),
    ]);
  }
}

class _RekapRow extends StatelessWidget {
  const _RekapRow(
      {required this.participant, required this.rank, required this.total});
  final Participant participant;
  final int rank, total;

  Color get _rankColor {
    if (rank == 1) return const Color(0xFFF59E0B);
    if (rank == 2) return const Color(0xFF94A3B8);
    if (rank == 3) return const Color(0xFFCD7F32);
    return _C.muted;
  }

  @override
  Widget build(BuildContext context) {
    final scoreColor = participant.score >= 70
        ? const Color(0xFF059669)
        : const Color(0xFFDC2626);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: rank <= 3
            ? Border.all(color: _rankColor.withOpacity(0.3), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
        ],
      ),
      child: Row(children: [
        Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
                color: _rankColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Center(
                child: rank <= 3
                    ? Icon(Icons.emoji_events_rounded,
                        size: 15, color: _rankColor)
                    : Text('#$rank',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: _rankColor)))),
        const SizedBox(width: 10),
        Expanded(
            child: Text(participant.name,
                style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: _C.dark))),
        Text('${participant.score}',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w900, color: scoreColor)),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
              color: scoreColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20)),
          child: Text(participant.score >= 70 ? 'Lulus' : 'Belum',
              style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: scoreColor)),
        ),
      ]),
    );
  }
}
