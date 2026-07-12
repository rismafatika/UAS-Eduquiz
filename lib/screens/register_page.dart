import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';
import 'email_otp_verification_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool loading = false;

  Future<void> register() async {
    setState(() {
      loading = true;
    });

    try {
      final response = await AuthService.instance.signUp(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        role: UserRole.participant,
      );

      if (response.session != null) {
        await SupabaseService.instance.saveUser(
          AppUser(
            uid: response.user?.id,
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            role: UserRole.participant,
          ),
        );
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.session == null
                  ? "Registrasi berhasil. Cek email untuk verifikasi."
                  : "Registrasi berhasil.",
            ),
          ),
        );

        if (response.session == null) {
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => EmailOtpVerificationPage(
                email: _emailController.text.trim(),
              ),
            ),
          );
        }
        if (!context.mounted) return;
        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Akun"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Nama",
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Email",
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : register,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Daftar"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
