import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_version.dart';
import '../models/app_release_info.dart';
import '../services/app_update_service.dart';
import '../utils/app_reloader.dart';
import 'eduquiz_logo.dart';

class AppUpdateGate extends StatefulWidget {
  const AppUpdateGate({super.key, required this.child});

  final Widget child;

  @override
  State<AppUpdateGate> createState() => _AppUpdateGateState();
}

class _AppUpdateGateState extends State<AppUpdateGate> {
  bool _checked = false;
  bool _dialogOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkForUpdate());
  }

  Future<void> _checkForUpdate() async {
    if (_checked) return;
    _checked = true;

    final update = await AppUpdateService.instance.checkForUpdate();
    if (!mounted || update == null || _dialogOpen) return;

    _dialogOpen = true;
    await showDialog<void>(
      context: context,
      barrierDismissible: !update.forceUpdate,
      builder: (dialogContext) {
        return _UpdateDialog(
          update: update,
          onUpdate: () => _openUpdate(dialogContext, update),
          canDismiss: !update.forceUpdate,
        );
      },
    );
    _dialogOpen = false;
  }

  Future<void> _openUpdate(BuildContext dialogContext, AppReleaseInfo update) async {
    final url = update.downloadUrl?.trim();
    if (url != null && url.isNotEmpty) {
      await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      return;
    }

    if (kIsWeb) {
      reloadApp();
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tautan update belum diisi di Supabase.'),
      ),
    );
    Navigator.of(dialogContext).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class _UpdateDialog extends StatelessWidget {
  const _UpdateDialog({
    required this.update,
    required this.onUpdate,
    required this.canDismiss,
  });

  final AppReleaseInfo update;
  final VoidCallback onUpdate;
  final bool canDismiss;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      title: Row(
        children: [
          const EduQuizLogo(size: 56, borderRadius: 16),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  update.title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                const Text('Versi baru tersedia'),
              ],
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Versi saat ini: ${AppVersion.current}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Versi terbaru: ${update.version}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            if (update.releaseNotes.isNotEmpty) ...[
              const Text(
                'Catatan rilis',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(update.releaseNotes),
              const SizedBox(height: 8),
            ],
            if (update.updatedAt != null)
              Text(
                'Diperbarui: ${update.updatedAt!.toLocal()}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            if (update.forceUpdate) ...[
              const SizedBox(height: 8),
              const Text(
                'Pembaruan ini wajib dipasang untuk melanjutkan.',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (canDismiss)
          TextButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Text('Nanti'),
          ),
        FilledButton.icon(
          onPressed: onUpdate,
          icon: const Icon(Icons.system_update_alt),
          label: const Text('Update Sekarang'),
        ),
      ],
    );
  }
}
