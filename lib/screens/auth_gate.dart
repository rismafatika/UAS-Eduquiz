import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_user.dart';
import 'home_page.dart';
import 'login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session;

        if (session == null) {
          return const LoginPage();
        }

        final user = AppUser(
          id: session.user.id,
          name: session.user.userMetadata?['name'] ?? 'User',
          email: session.user.email ?? '',
          role: UserRole.participant,
        );

        return HomePage(user: user);
      },
    );
  }
}
