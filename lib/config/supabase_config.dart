class SupabaseConfig {
  const SupabaseConfig._();

  static const url = 'https://kuubwgcedzhetxowbpmu.supabase.co';

  static const anonKey = 'sb_publishable_QohMi69PpUtiLgNJakAE-g_wLrVzc2B';

  static bool get isConfigured {
    return url.isNotEmpty && anonKey.isNotEmpty;
  }
}
