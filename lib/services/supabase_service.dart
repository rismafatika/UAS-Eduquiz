import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final client = Supabase.instance.client;

  static Future<List<Map<String, dynamic>>> getQuestions() async {
    final response = await client.from('questions').select();

    return List<Map<String, dynamic>>.from(response);
  }
}
