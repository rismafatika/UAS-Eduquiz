class SupabaseConfig {
  const SupabaseConfig._();

  static const String url = 'https://kuubwgcedzhetxowbpmu.supabase.co';
  static const String anonKey =
      'sb_publishable_QohMi69PpUtiLgNJakAE-g_wLrVzc2B';

  static bool get isConfigured =>
      url.startsWith('https://') && anonKey.isNotEmpty;
}
