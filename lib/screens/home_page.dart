import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/room_service.dart';
import '../services/supabase_service.dart';
import '../widgets/app_panel.dart';
import '../widgets/status_badge.dart';
import 'create_room_page.dart';
import 'host_dashboard_page.dart';
import 'join_room_page.dart';
import 'logout_page.dart';
import 'lobby_page.dart';
import 'quiz_live_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.user});

  final AppUser user;

  void _openCreateRoom(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreateRoomPage(user: user)),
    );
  }

  void _openJoinRoom(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => JoinRoomPage(user: user)),
    );
  }

  void _openLobbyDemo(BuildContext context) {
    final room = RoomService.instance.createRoom(
      title: 'Latihan Cepat EduQuiz',
      hostName: user.name,
    );
    RoomService.instance.addParticipant(room: room, name: user.name);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LobbyPage(user: user, room: room)),
    );
  }

  void _openQuickPlay(BuildContext context) {
    final room = RoomService.instance.createRoom(
      title: 'Quick Play EduQuiz',
      hostName: 'EduQuiz Coach',
    );
    RoomService.instance.addParticipant(room: room, name: user.name);
    RoomService.instance.startQuiz(room);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => QuizLivePage(user: user, room: room)),
    );
  }

  void _openHostDemoDashboard(BuildContext context) {
    final room = RoomService.instance.createRoom(
      title: 'Demo Dashboard Kelas',
      hostName: user.name,
    );
    RoomService.instance.startQuiz(room);
    final firstParticipant = room.participants.first;
    RoomService.instance.answerQuestion(
      room: room,
      participant: firstParticipant,
      answerIndex: room.questions.first.correctIndex,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HostDashboardPage(user: user, room: room),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isHost = user.role == UserRole.host;

    return Scaffold(
      appBar: AppBar(
        title: const Text('EduQuiz'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Text(
                user.name,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const LogoutPage(),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HeroPanel(
                    user: user,
                    isHost: isHost,
                    onPrimary: () => isHost
                        ? _openCreateRoom(context)
                        : _openJoinRoom(context),
                    onSecondary: () => isHost
                        ? _openHostDemoDashboard(context)
                        : _openQuickPlay(context),
                  ),
                  const SizedBox(height: 16),
                  isHost
                      ? _HostDashboardActions(
                          onCreate: () => _openCreateRoom(context),
                          onLobbyDemo: () => _openLobbyDemo(context),
                          onDashboardDemo: () =>
                              _openHostDemoDashboard(context))
                      : _ParticipantDashboardActions(
                          onJoin: () => _openJoinRoom(context),
                          onQuickPlay: () => _openQuickPlay(context),
                          onLobbyDemo: () => _openLobbyDemo(context)),
                  const SizedBox(height: 16),
                  _StatusStrip(isHost: isHost),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.user,
    required this.isHost,
    required this.onPrimary,
    required this.onSecondary,
  });

  final AppUser user;
  final bool isHost;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2B1464),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2B1464).withValues(alpha: 0.20),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 760;
          final intro = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatusBadge(
                label: isHost ? 'Host mode' : 'Student mode',
                icon: isHost
                    ? Icons.school_outlined
                    : Icons.emoji_events_outlined,
                color: const Color(0xFFFFD166),
              ),
              const SizedBox(height: 14),
              Text(
                isHost
                    ? 'Kelola kuis kelas yang hidup'
                    : 'Masuk, jawab, naik level',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isHost
                    ? 'Buat room, mulai sesi, pantau jawaban, lalu buka leaderboard dan review dari satu dashboard.'
                    : 'Gabung dengan kode host atau coba quick play untuk latihan soal, dapat skor, XP, streak, dan level.',
                style: const TextStyle(
                  color: Color(0xFFEDE9FE),
                  fontSize: 15,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    onPressed: onPrimary,
                    icon: Icon(isHost ? Icons.add_circle_outline : Icons.login),
                    label: Text(isHost ? 'Buat Room' : 'Masukkan Kode'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD166),
                      foregroundColor: const Color(0xFF24124D),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: onSecondary,
                    icon: Icon(
                        isHost ? Icons.dashboard_outlined : Icons.play_arrow),
                    label: Text(isHost ? 'Lihat Demo' : 'Quick Play'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                    ),
                  ),
                ],
              ),
            ],
          );
          final scoreCard = _ScorePreviewCard(user: user, isHost: isHost);

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                intro,
                const SizedBox(height: 16),
                scoreCard,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 6, child: intro),
              const SizedBox(width: 16),
              Expanded(flex: 4, child: scoreCard),
            ],
          );
        },
      ),
    );
  }
}

class _ScorePreviewCard extends StatelessWidget {
  const _ScorePreviewCard({required this.user, required this.isHost});

  final AppUser user;
  final bool isHost;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isHost ? 'Ringkasan kelas' : 'Profil skor kamu',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          _MiniMetric(
              label: isHost ? 'Mode' : 'Level',
              value: isHost ? 'Live' : '${user.level}',
              color: const Color(0xFF06B6D4)),
          _MiniMetric(
              label: isHost ? 'Kontrol' : 'Skor',
              value: isHost ? 'Aktif' : '${user.score}',
              color: const Color(0xFF22C55E)),
          _MiniMetric(
              label: isHost ? 'Review' : 'Streak',
              value: isHost ? 'Siap' : '${user.streak}',
              color: const Color(0xFFF97316)),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
          Text(value,
              style: TextStyle(color: color, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _ParticipantDashboardActions extends StatelessWidget {
  const _ParticipantDashboardActions({
    required this.onJoin,
    required this.onQuickPlay,
    required this.onLobbyDemo,
  });

  final VoidCallback onJoin;
  final VoidCallback onQuickPlay;
  final VoidCallback onLobbyDemo;

  @override
  Widget build(BuildContext context) {
    return _ResponsiveActionGrid(
      actions: [
        _ActionTileData(
          icon: Icons.pin_outlined,
          title: 'Gabung Kelas',
          description: 'Masukkan room code dari host dan masuk lobby.',
          color: const Color(0xFF7C3AED),
          onTap: onJoin,
        ),
        _ActionTileData(
          icon: Icons.flash_on_outlined,
          title: 'Quick Play',
          description: 'Latihan mandiri dengan soal kelas dan skor langsung.',
          color: const Color(0xFF0EA5E9),
          onTap: onQuickPlay,
        ),
        _ActionTileData(
          icon: Icons.groups_2_outlined,
          title: 'Coba Lobby',
          description: 'Lihat alur menunggu host sebelum kuis dimulai.',
          color: const Color(0xFF10B981),
          onTap: onLobbyDemo,
        ),
      ],
    );
  }
}

class _HostDashboardActions extends StatelessWidget {
  const _HostDashboardActions({
    required this.onCreate,
    required this.onLobbyDemo,
    required this.onDashboardDemo,
  });

  final VoidCallback onCreate;
  final VoidCallback onLobbyDemo;
  final VoidCallback onDashboardDemo;

  @override
  Widget build(BuildContext context) {
    return _ResponsiveActionGrid(
      actions: [
        _ActionTileData(
          icon: Icons.add_circle_outline,
          title: 'Buat Room',
          description: 'Generate kode kelas dan undang peserta.',
          color: const Color(0xFF7C3AED),
          onTap: onCreate,
        ),
        _ActionTileData(
          icon: Icons.play_circle_outline,
          title: 'Simulasi Lobby',
          description: 'Buka lobby demo untuk cek alur peserta.',
          color: const Color(0xFF0EA5E9),
          onTap: onLobbyDemo,
        ),
        _ActionTileData(
          icon: Icons.analytics_outlined,
          title: 'Dashboard Demo',
          description: 'Pantau skor, jawaban, streak, dan progres kelas.',
          color: const Color(0xFFF97316),
          onTap: onDashboardDemo,
        ),
      ],
    );
  }
}

class _ResponsiveActionGrid extends StatelessWidget {
  const _ResponsiveActionGrid({required this.actions});

  final List<_ActionTileData> actions;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 780;
        if (compact) {
          return Column(
            children: actions
                .map(
                  (action) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ActionTile(data: action),
                  ),
                )
                .toList(),
          );
        }

        return Row(
          children: actions
              .map(
                (action) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _ActionTile(data: action),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _ActionTileData {
  const _ActionTileData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.data});

  final _ActionTileData data;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(data.icon, color: data.color),
              ),
              const SizedBox(height: 14),
              Text(
                data.title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                data.description,
                style: const TextStyle(color: Color(0xFF64748B), height: 1.35),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Icon(Icons.arrow_forward, color: data.color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusStrip extends StatelessWidget {
  const _StatusStrip({required this.isHost});

  final bool isHost;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          StatusBadge(
            label: isHost ? 'Kontrol host aktif' : 'Skor setelah quiz',
            icon: isHost ? Icons.tune : Icons.emoji_events_outlined,
            color: const Color(0xFF14B8A6),
          ),
          const StatusBadge(
            label: 'Review jawaban',
            icon: Icons.fact_check_outlined,
            color: Color(0xFF1D4ED8),
          ),
          const StatusBadge(
            label: 'XP dan level',
            icon: Icons.trending_up,
            color: Color(0xFFF97316),
          ),
          StatusBadge(
            label: SupabaseService.instance.isReady
                ? 'Database aktif'
                : 'Local demo aktif',
            icon: SupabaseService.instance.isReady
                ? Icons.cloud_done_outlined
                : Icons.storage_outlined,
            color: SupabaseService.instance.isReady
                ? const Color(0xFF16A34A)
                : const Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }
}
