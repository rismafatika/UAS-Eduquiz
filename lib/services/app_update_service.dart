import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_version.dart';
import '../models/app_release_info.dart';

class AppUpdateService {
  AppUpdateService._();

  static final AppUpdateService instance = AppUpdateService._();

  Future<AppReleaseInfo?> checkForUpdate() async {
    try {
      final rows = await Supabase.instance.client
          .from('app_releases')
          .select()
          .eq('is_active', true)
          .order('updated_at', ascending: false)
          .limit(1);

      if (rows.isEmpty) return null;

      final release =
          AppReleaseInfo.fromMap(Map<String, dynamic>.from(rows.first));
      if (release.version.isEmpty) return null;

      return _isNewerVersion(release.version, AppVersion.current)
          ? release
          : null;
    } catch (_) {
      return null;
    }
  }

  bool _isNewerVersion(String latest, String current) {
    final latestParts = _parseVersion(latest);
    final currentParts = _parseVersion(current);

    for (var i = 0; i < latestParts.length; i++) {
      if (latestParts[i] > currentParts[i]) return true;
      if (latestParts[i] < currentParts[i]) return false;
    }
    return false;
  }

  List<int> _parseVersion(String version) {
    final baseAndBuild = version.split('+');
    final core = baseAndBuild.first.split('.');
    final build = baseAndBuild.length > 1 ? int.tryParse(baseAndBuild[1]) ?? 0 : 0;

    return [
      int.tryParse(core.length > 0 ? core[0] : '0') ?? 0,
      int.tryParse(core.length > 1 ? core[1] : '0') ?? 0,
      int.tryParse(core.length > 2 ? core[2] : '0') ?? 0,
      build,
    ];
  }
}
