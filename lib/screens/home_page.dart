import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/supabase_service.dart';
import '../widgets/app_panel.dart';
import '../widgets/pro_page.dart';
import '../widgets/section_title.dart';
import '../widgets/status_badge.dart';
import 'create_room_page.dart';
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
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Text(user.name, style: const TextStyle(fontWeight: FontWeight.w800))),
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
                  _FeatureCard(icon: Icons.verified_user_outlined, title: 'Auth', description: 'Login pengguna host dan peserta.'),
                  _FeatureCard(icon: Icons.pin_outlined, title: 'Room Code', description: 'Kode unik untuk setiap sesi kuis.'),
                  _FeatureCard(icon: Icons.leaderboard_outlined, title: 'Leaderboard', description: 'Skor peserta otomatis terurut.'),
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
