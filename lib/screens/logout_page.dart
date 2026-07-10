import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'login_page.dart';

class LogoutPage extends StatelessWidget {
  const LogoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      title: const Text('Keluar akun?'),
      content: const Text(
        'Kamu akan diarahkan kembali ke halaman masuk setelah logout.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () async {
            await AuthService.instance.signOut();
            if (!context.mounted) return;
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
            );
          },
          child: const Text('Logout'),
        ),
      ],
    );
  }
}
