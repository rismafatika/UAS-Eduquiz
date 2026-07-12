import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';

class EmailOtpVerificationPage extends StatefulWidget {
  const EmailOtpVerificationPage({super.key, required this.email});

  final String email;

  @override
  State<EmailOtpVerificationPage> createState() =>
      _EmailOtpVerificationPageState();
}

class _EmailOtpVerificationPageState extends State<EmailOtpVerificationPage> {
  final _tokenController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final token = _tokenController.text.trim();
    if (token.length != 8) {
      _showMessage('Masukkan kode OTP 8 digit dari email.', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await AuthService.instance.verifyEmailOtp(
        email: widget.email,
        token: token,
      );
      final user = response.user;
      if (user != null) {
        final metadata = user.userMetadata ?? {};
        final roleName = metadata['role'] as String?;
        await SupabaseService.instance.saveUser(
          AppUser(
            uid: user.id,
            name: (metadata['full_name'] as String?) ??
                (metadata['name'] as String?) ??
                widget.email.split('@').first,
            email: user.email ?? widget.email,
            role: roleName == UserRole.host.name
                ? UserRole.host
                : UserRole.participant,
          ),
        );
      }
      if (!mounted) return;
      _showMessage('Email berhasil diverifikasi.', isError: false);
      Navigator.pop(context);
    } on AuthException catch (error) {
      if (!mounted) return;
      _showMessage(error.message, isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resend() async {
    setState(() => _isLoading = true);
    try {
      await AuthService.instance.resendSignupOtp(widget.email);
      if (!mounted) return;
      _showMessage('Kode OTP baru telah dikirim.', isError: false);
    } on AuthException catch (error) {
      if (!mounted) return;
      _showMessage(error.message, isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verifikasi Email')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Masukkan kode 8 digit yang dikirim ke ${widget.email}.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _tokenController,
              autofocus: true,
              enabled: !_isLoading,
              keyboardType: TextInputType.number,
              maxLength: 8,
              decoration: const InputDecoration(
                labelText: 'Kode OTP',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _isLoading ? null : _verify,
              child: const Text('Verifikasi'),
            ),
            TextButton(
              onPressed: _isLoading ? null : _resend,
              child: const Text('Kirim ulang kode'),
            ),
          ],
        ),
      ),
    );
  }
}
