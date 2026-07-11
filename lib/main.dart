import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─── IMPORT AUTH_GATE ──────────────────────────────────────
import 'screens/auth_gate.dart'; // ← TAMBAHKAN INI

// ─── GANTI DENGAN DATA SUPABASE ANDA ──────────────────────
const String supabaseUrl = 'https://kuubwgcedzhetxowbpmu.supabase.co';
const String supabaseAnonKey = 'sb_publishable_QohMi69PpUtiLgNJakAE-g_wLrVzc2B';
// ─────────────────────────────────────────────────────────────

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  } catch (e) {
    print('Supabase initialization failed: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthGate(),
    );
  }
}
