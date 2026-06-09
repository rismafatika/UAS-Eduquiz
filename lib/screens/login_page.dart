import 'package:flutter/material.dart';

import '../models/app_user.dart';
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
        builder: (_) => HomePage(user: AppUser(name: name, email: email, role: _role)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.school_outlined, color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: 14),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('EduQuiz', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
                          Text('Aplikasi kuis kelas real-time'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  AppPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Authentication Pengguna', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 18),
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nama',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.mail_outline),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SegmentedButton<UserRole>(
                          segments: const [
                            ButtonSegment(value: UserRole.participant, icon: Icon(Icons.groups_2_outlined), label: Text('Peserta')),
                            ButtonSegment(value: UserRole.host, icon: Icon(Icons.dashboard_outlined), label: Text('Host')),
                          ],
                          selected: {_role},
                          onSelectionChanged: (value) => setState(() => _role = value.first),
                        ),
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: _login,
                          icon: const Icon(Icons.login),
                          label: const Text('Masuk'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
