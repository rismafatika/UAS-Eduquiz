import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/app_panel.dart';
import '../widgets/section_title.dart';
import '../widgets/status_badge.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final auth = Supabase.instance.client.auth;

      await auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        data: {
          'full_name': _nameController.text.trim(),
          'role': 'participant',
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi berhasil. Cek email untuk verifikasi atau lanjut login.'),
        ),
      );

      Navigator.pop(context);
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFF3F6FF),
                Color(0xFFF8FBFF),
                Color(0xFFFFFFFF),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxWidth < 900;

                    final hero = _HeroPanel(
                      isCompact: isCompact,
                    );
                    final form = _FormPanel(
                      formKey: _formKey,
                      nameController: _nameController,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      loading: _loading,
                      onSubmit: register,
                    );

                    if (isCompact) {
                      return Column(
                        children: [
                          hero,
                          const SizedBox(height: 16),
                          form,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: hero),
                        const SizedBox(width: 18),
                        Expanded(flex: 4, child: form),
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

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isCompact ? null : 740,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1D4ED8),
            Color(0xFF5B5FEF),
            Color(0xFF8B5CF6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B5FEF).withOpacity(.24),
            blurRadius: 36,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -20,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(.10),
              ),
            ),
          ),
          Positioned(
            left: -24,
            bottom: 40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(.08),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.16),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.school_rounded, color: Colors.white, size: 34),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Gabung ke EduQuiz',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Buat akun untuk ikut kuis, melihat rekap nilai, dan membaca pembahasan setelah sesi selesai.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(.80),
                      fontSize: 16,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      StatusBadge(
                        label: 'Akses peserta',
                        icon: Icons.groups_2_outlined,
                        color: Color(0xFFDBEAFE),
                      ),
                      StatusBadge(
                        label: 'OTP email',
                        icon: Icons.mark_email_read_outlined,
                        color: Color(0xFFA7F3D0),
                      ),
                      StatusBadge(
                        label: 'Rekap nilai',
                        icon: Icons.bar_chart_rounded,
                        color: Color(0xFFFDE68A),
                      ),
                    ],
                  ),
                ],
              ),
              if (!isCompact) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _FeatureTile(
                        icon: Icons.flash_on_rounded,
                        title: 'Cepat masuk',
                        description: 'Login dan register dibuat simpel agar peserta langsung siap bermain.',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _FeatureTile(
                        icon: Icons.fact_check_outlined,
                        title: 'Hasil lengkap',
                        description: 'Peserta bisa melihat skor, peringkat, dan pembahasan dengan nyaman.',
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _FormPanel extends StatelessWidget {
  const _FormPanel({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.loading,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool loading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionTitle(
              icon: Icons.person_add_alt_1_outlined,
              title: 'Buat Akun Peserta',
            ),
            const SizedBox(height: 10),
            const Text(
              'Lengkapi data berikut untuk mulai memakai akun peserta.',
              style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StatusBadge(
                  label: 'Tampilan modern',
                  icon: Icons.auto_awesome_outlined,
                  color: Color(0xFF5B5FEF),
                ),
                StatusBadge(
                  label: 'Email verifikasi',
                  icon: Icons.email_outlined,
                  color: Color(0xFF14B8A6),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nama lengkap',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Nama wajib diisi';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Email wajib diisi';
                if (!text.contains('@')) return 'Format email tidak valid';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              validator: (value) {
                if (value == null || value.trim().length < 6) {
                  return 'Password minimal 6 karakter';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: loading ? null : onSubmit,
              icon: loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.verified_user_outlined),
              label: Text(loading ? 'Memproses...' : 'Daftar Sekarang'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.12),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 15.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              color: Colors.white.withOpacity(.78),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
