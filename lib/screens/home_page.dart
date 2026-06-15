import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/quiz_room.dart';
import '../services/room_service.dart';
import '../widgets/app_background.dart';
import '../widgets/feature_card.dart';
import '../widgets/logout_action.dart';
import 'create_room_page.dart';
import 'host_dashboard_page.dart';
import 'join_room_page.dart';
import 'leaderboard_page.dart';
import 'quiz_live_page.dart';
import 'review_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.user});

  final AppUser user;

  bool get _isHost => user.role == UserRole.host;

  QuizRoom _demoRoom({bool live = false, bool leaderboard = false}) {
    final room = RoomService.instance.createRoom(
        title: 'Demo EduQuiz', hostName: _isHost ? user.name : 'Host Demo');
    RoomService.instance.addParticipant(room: room, name: user.name);

    if (live || leaderboard) {
      RoomService.instance.startQuiz(room);
    }

    if (leaderboard) {
      final participant =
          RoomService.instance.addParticipant(room: room, name: user.name);
      while (room.phase != QuizPhase.leaderboard) {
        RoomService.instance.answerQuestion(
            room: room,
            participant: participant,
            answerIndex:
                room.questions[room.currentQuestionIndex].correctIndex);
      }
    }

    return room;
  }

  void _open(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final title = _isHost ? 'Dashboard Host' : 'Ruang Peserta';
    final subtitle = _isHost
        ? 'Buat room, mulai quiz, pantau progress, dan review jawaban peserta.'
        : 'Gabung ke room dari host, kerjakan quiz, lalu lihat skor dan pembahasan.';

    return Scaffold(
      appBar: AppBar(
        title: const Text('EduQuiz'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Center(
              child: Text(
                user.name,
                style: const TextStyle(
                    fontWeight: FontWeight.w800, color: Color(0xFF334155)),
              ),
            ),
          ),
          const LogoutAction(),
          const SizedBox(width: 8),
        ],
      ),
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 980),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _HomeHero(
                        title: title, subtitle: subtitle, isHost: _isHost),
                    const SizedBox(height: 18),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final compact = constraints.maxWidth < 760;
                        final cards = _featureCards(context);

                        if (compact) {
                          return Column(
                            children: cards
                                .map((card) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: card,
                                    ))
                                .toList(),
                          );
                        }

                        return GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 1.75,
                          children: cards,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _featureCards(BuildContext context) {
    final teal = Theme.of(context).colorScheme.secondary;
    final amber = Theme.of(context).colorScheme.tertiary;

    return [
      FeatureCard(
        icon: _isHost ? Icons.add_circle_outline : Icons.key_rounded,
        title: _isHost ? 'Buat Room Code' : 'Gabung Room',
        subtitle: _isHost
            ? 'Generate kode kelas dan kumpulkan peserta di lobby.'
            : 'Masukkan kode dari host untuk masuk ke lobby.',
        accentColor: Theme.of(context).colorScheme.primary,
        onTap: () => _open(context,
            _isHost ? CreateRoomPage(user: user) : JoinRoomPage(user: user)),
      ),
      FeatureCard(
        icon: Icons.play_circle_outline,
        title: 'Quiz Real-Time',
        subtitle: 'Masuk ke sesi quiz live dan jawab soal secara bertahap.',
        accentColor: teal,
        onTap: () => _open(
            context, QuizLivePage(user: user, room: _demoRoom(live: true))),
      ),
      FeatureCard(
        icon: Icons.leaderboard_outlined,
        title: 'Leaderboard',
        subtitle: 'Lihat ranking otomatis berdasarkan skor peserta.',
        accentColor: amber,
        onTap: () => _open(context,
            LeaderboardPage(user: user, room: _demoRoom(leaderboard: true))),
      ),
      FeatureCard(
        icon: _isHost ? Icons.dashboard_outlined : Icons.fact_check_outlined,
        title: _isHost ? 'Dashboard Host' : 'Review Jawaban',
        subtitle: _isHost
            ? 'Pantau peserta, jawaban, rata-rata skor, dan kontrol quiz.'
            : 'Buka pembahasan soal dan cek jawaban benar.',
        accentColor: const Color(0xFF7C3AED),
        onTap: () {
          final room = _demoRoom(leaderboard: true);
          _open(
              context,
              _isHost
                  ? HostDashboardPage(user: user, room: room)
                  : ReviewPage(user: user, room: room));
        },
      ),
      if (_isHost)
        FeatureCard(
          icon: Icons.rate_review_outlined,
          title: 'Review Jawaban',
          subtitle: 'Buka pembahasan untuk mengevaluasi hasil peserta.',
          accentColor: const Color(0xFFEF4444),
          onTap: () => _open(context,
              ReviewPage(user: user, room: _demoRoom(leaderboard: true))),
        ),
      if (_isHost)
        FeatureCard(
          icon: Icons.login_rounded,
          title: 'Coba Sebagai Peserta',
          subtitle: 'Masuk ke halaman gabung room untuk menguji alur peserta.',
          accentColor: const Color(0xFF0F766E),
          onTap: () => _open(context, JoinRoomPage(user: user)),
        ),
    ];
  }
}

class _HomeHero extends StatelessWidget {
  const _HomeHero(
      {required this.title, required this.subtitle, required this.isHost});

  final String title;
  final String subtitle;
  final bool isHost;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.16),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 18,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHost ? 'Mode Host' : 'Mode Peserta',
                  style: const TextStyle(
                      color: Color(0xFF93C5FD), fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text(subtitle,
                    style:
                        const TextStyle(color: Color(0xFFCBD5E1), height: 1.4)),
              ],
            ),
          ),
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            ),
            child: Icon(
                isHost
                    ? Icons.dashboard_customize_outlined
                    : Icons.groups_2_outlined,
                color: Colors.white,
                size: 34),
          ),
        ],
      ),
    );
  }
}
