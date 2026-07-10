import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/app_panel.dart';
import '../widgets/pro_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();

  Future<void> sendReset() async {
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        emailController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Link reset password berhasil dikirim."),
        ),
      );

      Navigator.pop(context);
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Terjadi kesalahan."),
        ),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lupa Password")),
      body: ProPage(
        title: 'Reset Password',
        subtitle: 'Masukkan email kamu, lalu Supabase akan mengirim link reset ke inbox.',
        maxWidth: 640,
        child: AppPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Email akun',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: sendReset,
                child: const Text("Kirim Link Reset"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
