import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService._();

  static final instance = AuthService._();

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }

  Session? get currentSession => Supabase.instance.client.auth.currentSession;

  User? get currentUser => Supabase.instance.client.auth.currentUser;
}
