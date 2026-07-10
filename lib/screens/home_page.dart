import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/supabase_service.dart';
import '../widgets/app_panel.dart';
import '../widgets/pro_page.dart';
import '../widgets/section_title.dart';
import '../widgets/status_badge.dart';
import 'create_room_page.dart';
import 'logout_page.dart';
import 'join_room_page.dart';

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
          IconButton(
            tooltip: 'Logout',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const LogoutPage(),
              );
            },
            icon: const Icon(Icons.logout_rounded),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                user.name,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
      body: ProPage(
        title: isHost ? 'Dashboard Awal Host' : 'Portal Peserta',
        subtitle: isHost
            ? 'Buat room code, kelola lobby, mulai quiz, dan pantau nilai peserta.'
            : 'Gabung room dari host, jawab quiz, lalu lihat leaderboard dan review jawaban.',
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
                        title: isHost ? 'Mulai sesi baru' : 'Gabung sesi quiz',
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isHost
                            ? 'Generate kode room, kelola soal, dan pantau peserta dari dashboard.'
                            : 'Masukkan kode room, ikuti quiz, lalu lihat rekap nilai dan pembahasan.',
                        style: const TextStyle(color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => isHost ? CreateRoomPage(user: user) : JoinRoomPage(user: user),
                        ),
                      );
                    },
                    icon: Icon(isHost ? Icons.meeting_room_outlined : Icons.login),
                    label: Text(isHost ? 'Buat Room Code' : 'Gabung Room'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppPanel(
              child: Row(
                children: [
                  Expanded(
                    child: _QuickStat(
                      icon: isHost ? Icons.dashboard_customize_outlined : Icons.emoji_events_outlined,
                      label: isHost ? 'Dashboard Host' : 'Portal Peserta',
                      value: isHost ? 'Kelola konten' : 'Lihat hasil',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickStat(
                      icon: Icons.workspace_premium_outlined,
                      label: 'Status akun',
                      value: user.role == UserRole.host ? 'Host' : 'Peserta',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 760;
                final cards = [
                  const _FeatureCard(
                    icon: Icons.verified_user_outlined,
                    title: 'Authentication',
                    description: 'Login pengguna sebagai host atau peserta.',
                  ),
                  const _FeatureCard(
                    icon: Icons.pin_outlined,
                    title: 'Room Code',
                    description: 'Kode unik untuk setiap sesi quiz.',
                  ),
                  const _FeatureCard(
                    icon: Icons.leaderboard_outlined,
                    title: 'Leaderboard',
                    description: 'Skor peserta otomatis terurut.',
                  ),
                ];

                if (compact) {
                  return Column(
                    children: cards
                        .map((card) => Padding(padding: const EdgeInsets.only(bottom: 10), child: card))
                        .toList(),
                  );
                }

                return Row(
                  children: cards
                      .map((card) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 10), child: card)))
                      .toList(),
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
                    label: SupabaseService.instance.isReady ? 'Database aktif' : 'Mode lokal',
                    icon: SupabaseService.instance.isReady ? Icons.cloud_done_outlined : Icons.storage_outlined,
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

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(description, style: const TextStyle(color: Color(0xFF64748B))),
        ],
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  const _QuickStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  scheme.primary.withOpacity(.14),
                  scheme.secondary.withOpacity(.10),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: scheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700, fontSize: 12.5)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
