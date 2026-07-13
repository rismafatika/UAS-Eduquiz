import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/auth_gate.dart';
import 'services/supabase_service.dart';
import 'widgets/app_update_gate.dart';

const String supabaseUrl = 'https://kuubwgcedzhetxowbpmu.supabase.co';
const String supabaseAnonKey = 'sb_publishable_QohMi69PpUtiLgNJakAE-g_wLrVzc2B';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    await SupabaseService.instance.initialize();
  } catch (e) {
    // Ignore startup failures so the app can still open in local mode.
    debugPrint('Supabase initialization failed: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AppUpdateGate(child: AuthGate()),
    );
  }
}
