import 'package:flutter/material.dart';

import 'app.dart';
import 'services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.instance.initialize();

  runApp(const EduQuizApp());
}
