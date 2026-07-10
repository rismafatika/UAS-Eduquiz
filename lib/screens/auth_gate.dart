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

        final metadata = session.user.userMetadata ?? const {};
        final name = (metadata['full_name'] as String?)?.trim().isNotEmpty == true
            ? metadata['full_name'] as String
            : (metadata['name'] as String?)?.trim().isNotEmpty == true
                ? metadata['name'] as String
                : (session.user.email?.split('@').first ?? 'User');
        final role = (metadata['role'] as String?) == 'host'
            ? UserRole.host
            : UserRole.participant;

        final user = AppUser(
          uid: session.user.id,
          name: name,
          email: session.user.email ?? '',
          role: role,
        );

        return HomePage(user: user);
      },
    );
  }
}
