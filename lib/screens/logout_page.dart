import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class LogoutPage extends StatelessWidget {
  const LogoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Logout'),
      content: const Text(
        'Apakah kamu yakin ingin keluar?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () async {
            await AuthService.instance.signOut();
            if (context.mounted) {
              Navigator.pop(context);
            }
          },
          child: const Text('Logout'),
        ),
      ],
    );
  }
}
