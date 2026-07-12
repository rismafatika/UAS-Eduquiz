import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';
import 'home_page.dart';
import 'login_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late Session? _session;
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    _session = AuthService.instance.currentSession;
    _authSubscription = AuthService.instance.authStateChanges.listen((state) {
      if (!mounted) return;
      setState(() => _session = state.session);
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    if (session == null) {
      return const LoginPage();
    }

    return FutureBuilder<AppUser>(
      future: _buildAppUser(session),
      builder: (context, snapshot) {
        final user = snapshot.data ?? _userFromSession(session);
        return HomePage(user: user);
      },
    );
  }

  Future<AppUser> _buildAppUser(Session session) async {
    final fallback = _userFromSession(session);
    final savedUser = await SupabaseService.instance.findUserByEmail(
      fallback.email,
    );
    return savedUser?.copyWith(uid: session.user.id) ?? fallback;
  }

  AppUser _userFromSession(Session session) {
    final metadata = session.user.userMetadata ?? {};
    final email = session.user.email ?? '';
    final name = _metadataString(metadata, 'full_name') ??
        _metadataString(metadata, 'name') ??
        (email.isEmpty ? 'User' : email.split('@').first);
    final roleName =
        _metadataString(metadata, 'role') ?? UserRole.participant.name;

    return AppUser(
      uid: session.user.id,
      name: name,
      email: email,
      role: UserRole.values.firstWhere(
        (role) => role.name == roleName,
        orElse: () => UserRole.participant,
      ),
    );
  }

  String? _metadataString(Map<String, dynamic> metadata, String key) {
    final value = metadata[key];
    if (value is! String || value.trim().isEmpty) return null;
    return value.trim();
  }
}
