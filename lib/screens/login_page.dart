import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../widgets/app_background.dart';
import '../widgets/app_panel.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  UserRole _role = UserRole.participant;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _login() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty || email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi nama dan email yang valid.')),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            HomePage(user: AppUser(name: name, email: email, role: _role)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 920),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 760;
                    final hero = _LoginHero(compact: compact);
                    final form = AppPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('Masuk Pengguna',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 6),
                          const Text(
                              'Pilih role agar menu yang muncul sesuai kebutuhan kelas.',
                              style: TextStyle(color: Color(0xFF64748B))),
                          const SizedBox(height: 18),
                          TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Nama',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.mail_outline),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SegmentedButton<UserRole>(
                            segments: const [
                              ButtonSegment(
                                  value: UserRole.participant,
                                  icon: Icon(Icons.groups_2_outlined),
                                  label: Text('Peserta')),
                              ButtonSegment(
                                  value: UserRole.host,
                                  icon: Icon(Icons.dashboard_outlined),
                                  label: Text('Host')),
                            ],
                            selected: {_role},
                            onSelectionChanged: (value) =>
                                setState(() => _role = value.first),
                          ),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: _login,
                            icon: const Icon(Icons.login_rounded),
                            label: const Text('Masuk ke EduQuiz'),
                          ),
                        ],
                      ),
                    );

                    if (compact) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          hero,
                          const SizedBox(height: 22),
                          form,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: hero),
                        const SizedBox(width: 28),
                        Expanded(child: form),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginHero extends StatelessWidget {
  const _LoginHero({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.25),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: const Icon(Icons.school_outlined,
                  color: Colors.white, size: 34),
            ),
            const SizedBox(width: 14),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('EduQuiz',
                    style:
                        TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
                Text('Kuis kelas real-time',
                    style: TextStyle(
                        color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
        SizedBox(height: compact ? 22 : 34),
        const Text(
          'Buat kelas lebih hidup dengan room code, quiz live, leaderboard, dan review jawaban.',
          style: TextStyle(
              fontSize: 34, fontWeight: FontWeight.w900, height: 1.12),
        ),
        const SizedBox(height: 16),
        const Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _HeroPill(icon: Icons.meeting_room_outlined, label: 'Room code'),
            _HeroPill(icon: Icons.play_circle_outline, label: 'Quiz live'),
            _HeroPill(icon: Icons.leaderboard_outlined, label: 'Leaderboard'),
          ],
        ),
      ],
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 7),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
