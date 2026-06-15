import 'dart:async';

import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/supabase_service.dart';
import '../widgets/app_panel.dart';
import '../widgets/status_badge.dart';
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

    final user = AppUser(name: name, email: email, role: _role);
    unawaited(SupabaseService.instance.saveUser(user));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomePage(user: user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1020),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 820;
                  final intro = _IntroPanel(isSupabaseReady: SupabaseService.instance.isReady);
                  final form = _LoginForm(
                    nameController: _nameController,
                    emailController: _emailController,
                    role: _role,
                    onRoleChanged: (role) => setState(() => _role = role),
                    onSubmit: _login,
                  );

                  if (compact) {
                    return Column(
                      children: [
                        intro,
                        const SizedBox(height: 16),
                        form,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: intro),
                      const SizedBox(width: 18),
                      Expanded(child: form),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IntroPanel extends StatelessWidget {
  const _IntroPanel({required this.isSupabaseReady});

  final bool isSupabaseReady;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.school_outlined, color: Colors.white, size: 34),
          ),
          const SizedBox(height: 18),
          const Text(
            'EduQuiz',
            style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Platform kuis kelas dengan room code, lobby peserta, leaderboard otomatis, review jawaban, dan dashboard host.',
            style: TextStyle(fontSize: 16, height: 1.45, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              const StatusBadge(label: 'Live Quiz', icon: Icons.bolt, color: Color(0xFF14B8A6)),
              StatusBadge(
                label: isSupabaseReady ? 'Supabase aktif' : 'Mode lokal',
                icon: isSupabaseReady ? Icons.cloud_done_outlined : Icons.storage_outlined,
                color: isSupabaseReady ? const Color(0xFF16A34A) : const Color(0xFFF59E0B),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.nameController,
    required this.emailController,
    required this.role,
    required this.onRoleChanged,
    required this.onSubmit,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final UserRole role;
  final ValueChanged<UserRole> onRoleChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Authentication Pengguna', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 18),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Nama', prefixIcon: Icon(Icons.person_outline)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.mail_outline)),
          ),
          const SizedBox(height: 16),
          SegmentedButton<UserRole>(
            segments: const [
              ButtonSegment(value: UserRole.participant, icon: Icon(Icons.groups_2_outlined), label: Text('Peserta')),
              ButtonSegment(value: UserRole.host, icon: Icon(Icons.dashboard_outlined), label: Text('Host')),
            ],
            selected: {role},
            onSelectionChanged: (value) => onRoleChanged(value.first),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(onPressed: onSubmit, icon: const Icon(Icons.login), label: const Text('Masuk')),
        ],
      ),
    );
  }
}
