import 'package:flutter/material.dart';

import '../screens/login_page.dart';

class LogoutAction extends StatelessWidget {
  const LogoutAction({super.key});

  void _logout(BuildContext context) {
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
