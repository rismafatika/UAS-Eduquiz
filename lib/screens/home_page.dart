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
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
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
      body: ProPage(
        title: isHost ? 'Dashboard Awal Host' : 'Portal Peserta',
        subtitle: isHost
            ? 'Buat room code, kelola lobby, mulai kuis, dan pantau hasil peserta dari satu tempat.'
            : 'Gabung ke room dari host, jawab kuis, lalu lihat skor dan pembahasan jawaban.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppPanel(
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 14,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionTitle(
                        icon: isHost ? Icons.add_circle_outline : Icons.key,
                        title: isHost ? 'Mulai sesi baru' : 'Gabung sesi kuis',
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isHost ? 'Generate kode room dan undang peserta.' : 'Gunakan kode dari host untuk masuk lobby.',
                        style: const TextStyle(color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => isHost ? CreateRoomPage(user: user) : JoinRoomPage(user: user)),
                      );
                    },
                    icon: Icon(isHost ? Icons.meeting_room_outlined : Icons.login),
                    label: Text(isHost ? 'Buat Room Code' : 'Gabung Room'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 760;
                final cards = [
                  const _FeatureCard(icon: Icons.verified_user_outlined, title: 'Auth', description: 'Login pengguna host dan peserta.'),
                  const _FeatureCard(icon: Icons.pin_outlined, title: 'Room Code', description: 'Kode unik untuk setiap sesi kuis.'),
                  const _FeatureCard(icon: Icons.leaderboard_outlined, title: 'Leaderboard', description: 'Skor peserta otomatis terurut.'),
                ];

                if (compact) {
                  return Column(
                    children: cards.map((card) => Padding(padding: const EdgeInsets.only(bottom: 10), child: card)).toList(),
                  );
                }

                return Row(
                  children: cards.map((card) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 10), child: card))).toList(),
                );
              },
            ),
            const SizedBox(height: 16),
            AppPanel(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  const StatusBadge(label: 'Quiz real-time', icon: Icons.bolt, color: Color(0xFF14B8A6)),
                  const StatusBadge(label: 'Review jawaban', icon: Icons.fact_check_outlined, color: Color(0xFF1D4ED8)),
                  StatusBadge(
                    label: SupabaseService.instance.isReady ? 'Database aktif' : 'Database belum dikonfigurasi',
                    icon: SupabaseService.instance.isReady ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
                    color: SupabaseService.instance.isReady ? const Color(0xFF16A34A) : const Color(0xFFF59E0B),
                  ),
                ],
              ),
            ),
          ],
        ),
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
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(description, style: const TextStyle(color: Color(0xFF64748B))),
        ],
      ),
    );
  }
}
