import 'package:flutter/material.dart';

import '../screens/login_page.dart';

class LogoutAction extends StatelessWidget {
  const LogoutAction({super.key});

  Future<void> _logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(Icons.logout_rounded),
          title: const Text('Logout dari EduQuiz?'),
          content: const Text(
              'Sesi lokal akan ditutup dan kamu akan kembali ke halaman masuk.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true || !context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Logout',
      child: IconButton(
        onPressed: () => _logout(context),
        icon: const Icon(Icons.logout_rounded),
      ),
    );
  }
}
