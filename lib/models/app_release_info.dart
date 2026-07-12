class AppReleaseInfo {
  const AppReleaseInfo({
    required this.version,
    required this.forceUpdate,
    required this.updatedAt,
    this.title = 'Update tersedia',
    this.releaseNotes = '',
    this.downloadUrl,
  });

  final String version;
  final String title;
  final String releaseNotes;
  final String? downloadUrl;
  final bool forceUpdate;
  final DateTime? updatedAt;

  factory AppReleaseInfo.fromMap(Map<String, dynamic> map) {
    final title = map['title']?.toString().trim() ?? '';
    final releaseNotes = map['release_notes']?.toString().trim() ?? '';
    final downloadUrl = map['download_url']?.toString().trim();

    return AppReleaseInfo(
      version: (map['version'] as String?)?.trim() ?? '',
      title: title.isNotEmpty ? title : 'Update tersedia',
      releaseNotes: releaseNotes,
      downloadUrl: downloadUrl?.isNotEmpty == true ? downloadUrl : null,
      forceUpdate: map['force_update'] as bool? ?? false,
      updatedAt: DateTime.tryParse(map['updated_at']?.toString() ?? ''),
    );
  }
}
