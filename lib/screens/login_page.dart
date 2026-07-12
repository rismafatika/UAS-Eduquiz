import 'dart:async';
import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../services/supabase_service.dart';
import 'home_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/eduquiz_logo.dart';

// ─────────────────────────────────────────────────────────────
// WARNA TEMA
// ─────────────────────────────────────────────────────────────
class _EduColors {
  static const primary = Color(0xFF4F46E5);
  static const secondary = Color(0xFF7C3AED);
  static const bgStart = Color(0xFF1A1A6E);
  static const bgMid = Color(0xFF3B1FA3);
  static const bgEnd = Color(0xFFA855F7);
  static const textDark = Color(0xFF0F172A);
  static const textMuted = Color(0xFF64748B);
  static const inputBg = Color(0xFFF9FAFB);
  static const inputBorder = Color(0xFFE5E7EB);
  static const hostText = Color(0xFF4F46E5);
  static const hostChip = Color(0xFFEDE9FE);
  static const pesertaText = Color(0xFF0369A1);
  static const pesertaChip = Color(0xFFE0F2FE);
}

// ─────────────────────────────────────────────────────────────
// MODE FORM: login atau register
// ─────────────────────────────────────────────────────────────
enum _FormMode { login, register }

// ─────────────────────────────────────────────────────────────
// LOGIN PAGE
// ─────────────────────────────────────────────────────────────
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _pageController = PageController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  UserRole _role = UserRole.participant;
  bool _obscurePw = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  _FormMode _formMode = _FormMode.login;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _goToForm({_FormMode mode = _FormMode.login}) {
    setState(() => _formMode = mode);
    _pageController.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  void _goBack() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  void _switchMode(_FormMode mode) {
    setState(() {
      _formMode = mode;
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _confirmController.clear();
    });
  }

  // ── LOGIN dengan Supabase Auth ──
  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty || !email.contains('@')) {
      _showSnack('Email dan password wajib diisi dengan benar.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final supaUser = res.user;
      if (supaUser == null) throw Exception('Login gagal.');

      // Ambil nama & role dari metadata user
      final meta = supaUser.userMetadata ?? {};
      final name = (meta['full_name'] as String?)?.isNotEmpty == true
          ? meta['full_name'] as String
          : email.split('@').first;
      final roleStr = meta['role'] as String? ?? 'participant';
      final role = roleStr == 'host' ? UserRole.host : UserRole.participant;

      // ═══════════════════════════════════════════════════════════
      // 🔧 PERBAIKAN 1: Tambahkan id pada AppUser
      // ═══════════════════════════════════════════════════════════
      final user = AppUser(
        id: supaUser.id, // ← TAMBAHKAN INI
        name: name,
        email: email,
        role: role,
      );
      unawaited(SupabaseService.instance.saveUser(user));

      if (!mounted) return;
      _navigateHome(user);
    } on AuthException catch (e) {
      if (!mounted) return;
      _showSnack(_authErrorMsg(e.message), isError: true);
    } catch (e) {
      if (!mounted) return;
      _showSnack('Terjadi kesalahan. Coba lagi.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── REGISTER dengan Supabase Auth ──
  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnack('Semua field wajib diisi.', isError: true);
      return;
    }
    if (!email.contains('@')) {
      _showSnack('Format email tidak valid.', isError: true);
      return;
    }
    if (password.length < 6) {
      _showSnack('Password minimal 6 karakter.', isError: true);
      return;
    }
    if (password != confirm) {
      _showSnack('Konfirmasi password tidak cocok.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': name,
          'role': _role == UserRole.host ? 'host' : 'participant',
        },
      );

      if (!mounted) return;

      if (res.user != null && res.session == null) {
        // Email konfirmasi dikirim
        _showSnack(
          'Akun berhasil dibuat! Cek email kamu untuk verifikasi.',
          isError: false,
        );
        _switchMode(_FormMode.login);
      } else if (res.session != null) {
        // Langsung masuk (email confirmation dimatikan di Supabase)
        // ═══════════════════════════════════════════════════════════
        // 🔧 PERBAIKAN 2: Tambahkan id pada AppUser
        // ═══════════════════════════════════════════════════════════
        final user = AppUser(
          id: res.user!.id, // ← TAMBAHKAN INI
          name: name,
          email: email,
          role: _role,
        );
        unawaited(SupabaseService.instance.saveUser(user));
        _navigateHome(user);
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      _showSnack(_authErrorMsg(e.message), isError: true);
    } catch (e) {
      if (!mounted) return;
      _showSnack('Terjadi kesalahan. Coba lagi.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── LUPA PASSWORD ──
  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showSnack('Masukkan email kamu dulu di kolom email.', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      if (!mounted) return;
      _showSnack('Link reset password dikirim ke $email', isError: false);
    } on AuthException catch (e) {
      if (!mounted) return;
      _showSnack(_authErrorMsg(e.message), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateHome(AppUser user) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, anim, __) => FadeTransition(
          opacity: anim,
          child: HomePage(user: user),
        ),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  String _authErrorMsg(String msg) {
    final m = msg.toLowerCase();
    if (m.contains('invalid login') || m.contains('invalid credentials')) {
      return 'Email atau password salah.';
    }
    if (m.contains('already registered') || m.contains('user already exists')) {
      return 'Email sudah terdaftar. Silakan login.';
    }
    if (m.contains('email not confirmed')) {
      return 'Email belum diverifikasi. Cek inbox kamu.';
    }
    if (m.contains('rate limit')) {
      return 'Terlalu banyak percobaan. Tunggu sebentar.';
    }
    return msg;
  }

  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(msg)),
        ]),
        backgroundColor:
            isError ? const Color(0xFFDC2626) : const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // ── Halaman 1: Intro ──
          _IntroScreen(
            isSupabaseReady: SupabaseService.instance.isReady,
            onLogin: () => _goToForm(mode: _FormMode.login),
            onRegister: () => _goToForm(mode: _FormMode.register),
          ),
          // ── Halaman 2: Form ──
          _FormScreen(
            formMode: _formMode,
            nameController: _nameController,
            emailController: _emailController,
            passwordController: _passwordController,
            confirmController: _confirmController,
            role: _role,
            obscurePw: _obscurePw,
            obscureConfirm: _obscureConfirm,
            isLoading: _isLoading,
            onRoleChanged: (r) => setState(() => _role = r),
            onTogglePw: () => setState(() => _obscurePw = !_obscurePw),
            onToggleConfirm: () =>
                setState(() => _obscureConfirm = !_obscureConfirm),
            onLogin: _login,
            onRegister: _register,
            onForgotPassword: _forgotPassword,
            onSwitchMode: _switchMode,
            onBack: _goBack,
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// HALAMAN 1 — INTRO
// ═════════════════════════════════════════════════════════════
class _IntroScreen extends StatefulWidget {
  const _IntroScreen({
    required this.isSupabaseReady,
    required this.onLogin,
    required this.onRegister,
  });
  final bool isSupabaseReady;
  final VoidCallback onLogin;
  final VoidCallback onRegister;

  @override
  State<_IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<_IntroScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _EduColors.bgStart,
            _EduColors.bgMid,
            _EduColors.secondary,
            _EduColors.bgEnd
          ],
          stops: [0.0, 0.3, 0.65, 1.0],
        ),
      ),
      child: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.3), width: 1.5),
                        ),
                        child: const EduQuizLogo(
                          size: 72,
                          borderRadius: 20,
                        ),
                      ),
                      const SizedBox(height: 32),

                      const Text(
                        'EduQuiz',
                        style: TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -1.5,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Platform kuis belajar interaktif',
                        style: TextStyle(
                            fontSize: 17,
                            color: Colors.white.withOpacity(0.7),
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Platform kuis kelas dengan room code, lobby peserta, leaderboard otomatis, review jawaban, dan dashboard host.',
                        style: TextStyle(
                            fontSize: 16,
                            height: 1.65,
                            color: Colors.white.withOpacity(0.75)),
                      ),
                      const SizedBox(height: 36),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _IntroBadge(
                              label: 'Live Quiz',
                              icon: Icons.bolt_rounded,
                              color: const Color(0xFF14B8A6)),
                          _IntroBadge(
                            label: widget.isSupabaseReady
                                ? 'Supabase aktif'
                                : 'Mode lokal',
                            icon: widget.isSupabaseReady
                                ? Icons.cloud_done_outlined
                                : Icons.storage_outlined,
                            color: widget.isSupabaseReady
                                ? const Color(0xFF4ADE80)
                                : const Color(0xFFFBBF24),
                          ),
                          _IntroBadge(
                              label: 'Leaderboard',
                              icon: Icons.emoji_events_outlined,
                              color: const Color(0xFFC084FC)),
                          _IntroBadge(
                              label: 'Real-time',
                              icon: Icons.sync_rounded,
                              color: const Color(0xFF60A5FA)),
                        ],
                      ),
                      const SizedBox(height: 56),

                      // Tombol Masuk
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: widget.onLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: _EduColors.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.login_rounded, size: 20),
                              SizedBox(width: 10),
                              Text('Masuk ke Akun',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Tombol Daftar
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: widget.onRegister,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                                color: Colors.white.withOpacity(0.5),
                                width: 1.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_add_outlined, size: 20),
                              SizedBox(width: 10),
                              Text('Daftar Akun Baru',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Center(
                        child: Text(
                          'Gratis · Tanpa iklan · Aman & terenkripsi',
                          style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.white.withOpacity(0.5)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// HALAMAN 2 — FORM (LOGIN / REGISTER)
// ═════════════════════════════════════════════════════════════
class _FormScreen extends StatefulWidget {
  const _FormScreen({
    required this.formMode,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmController,
    required this.role,
    required this.obscurePw,
    required this.obscureConfirm,
    required this.isLoading,
    required this.onRoleChanged,
    required this.onTogglePw,
    required this.onToggleConfirm,
    required this.onLogin,
    required this.onRegister,
    required this.onForgotPassword,
    required this.onSwitchMode,
    required this.onBack,
  });

  final _FormMode formMode;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final UserRole role;
  final bool obscurePw;
  final bool obscureConfirm;
  final bool isLoading;
  final ValueChanged<UserRole> onRoleChanged;
  final VoidCallback onTogglePw;
  final VoidCallback onToggleConfirm;
  final AsyncCallback onLogin;
  final AsyncCallback onRegister;
  final VoidCallback onForgotPassword;
  final ValueChanged<_FormMode> onSwitchMode;
  final VoidCallback onBack;

  @override
  State<_FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<_FormScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    WidgetsBinding.instance.addPostFrameCallback((_) => _ctrl.forward());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool get _isLogin => widget.formMode == _FormMode.login;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _EduColors.bgStart,
            _EduColors.bgMid,
            _EduColors.secondary,
            _EduColors.bgEnd
          ],
          stops: [0.0, 0.3, 0.65, 1.0],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.22),
                            blurRadius: 48,
                            offset: const Offset(0, 20)),
                        BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 14,
                            offset: const Offset(0, 6)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Header ──
                        Row(
                          children: [
                            GestureDetector(
                              onTap: widget.onBack,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _EduColors.inputBg,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: _EduColors.inputBorder,
                                      width: 1.5),
                                ),
                                child: const Icon(Icons.arrow_back_rounded,
                                    size: 20, color: _EduColors.textMuted),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isLogin
                                        ? 'Masuk ke Akun'
                                        : 'Buat Akun Baru',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: _EduColors.textDark,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  Text(
                                    _isLogin
                                        ? 'Masuk dengan akun yang sudah terdaftar'
                                        : 'Daftar dan mulai belajar sekarang',
                                    style: const TextStyle(
                                        fontSize: 12.5,
                                        color: _EduColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // ── Tab Switch Login / Daftar ──
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: _EduColors.inputBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: _EduColors.inputBorder, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                  child: _TabBtn(
                                label: 'Masuk',
                                icon: Icons.login_rounded,
                                isActive: _isLogin,
                                onTap: () =>
                                    widget.onSwitchMode(_FormMode.login),
                              )),
                              Expanded(
                                  child: _TabBtn(
                                label: 'Daftar',
                                icon: Icons.person_add_outlined,
                                isActive: !_isLogin,
                                onTap: () =>
                                    widget.onSwitchMode(_FormMode.register),
                              )),
                            ],
                          ),
                        ),

                        const SizedBox(height: 22),

                        // ── Field Nama (hanya register) ──
                        if (!_isLogin) ...[
                          _StyledInput(
                            controller: widget.nameController,
                            label: 'Nama Lengkap',
                            hint: 'Masukkan nama lengkap kamu',
                            icon: Icons.person_outline_rounded,
                          ),
                          const SizedBox(height: 13),
                        ],

                        // ── Email ──
                        _StyledInput(
                          controller: widget.emailController,
                          label: 'Email',
                          hint: 'nama@email.com',
                          icon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 13),

                        // ── Password ──
                        _StyledInput(
                          controller: widget.passwordController,
                          label: 'Password',
                          hint: _isLogin
                              ? 'Masukkan password'
                              : 'Minimal 6 karakter',
                          icon: Icons.lock_outline_rounded,
                          obscureText: widget.obscurePw,
                          suffixIcon: IconButton(
                            icon: Icon(
                              widget.obscurePw
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: _EduColors.textMuted,
                              size: 20,
                            ),
                            onPressed: widget.onTogglePw,
                            splashRadius: 20,
                          ),
                        ),

                        // ── Konfirmasi Password (hanya register) ──
                        if (!_isLogin) ...[
                          const SizedBox(height: 13),
                          _StyledInput(
                            controller: widget.confirmController,
                            label: 'Konfirmasi Password',
                            hint: 'Ulangi password kamu',
                            icon: Icons.lock_reset_outlined,
                            obscureText: widget.obscureConfirm,
                            suffixIcon: IconButton(
                              icon: Icon(
                                widget.obscureConfirm
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: _EduColors.textMuted,
                                size: 20,
                              ),
                              onPressed: widget.onToggleConfirm,
                              splashRadius: 20,
                            ),
                          ),
                        ],

                        // ── Lupa Password (hanya login) ──
                        if (_isLogin) ...[
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: widget.isLoading
                                  ? null
                                  : widget.onForgotPassword,
                              style: TextButton.styleFrom(
                                foregroundColor: _EduColors.primary,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 6),
                              ),
                              child: const Text(
                                'Lupa password?',
                                style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],

                        // ── Role Selector (hanya register) ──
                        if (!_isLogin) ...[
                          const SizedBox(height: 18),
                          const Text(
                            'Daftar sebagai',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _EduColors.textDark),
                          ),
                          const SizedBox(height: 10),
                          _RoleSelector(
                              selected: widget.role,
                              onChanged: widget.onRoleChanged),
                        ],

                        const SizedBox(height: 24),

                        // ── Tombol Aksi ──
                        SizedBox(
                          height: 52,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  _EduColors.primary,
                                  _EduColors.secondary
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: _EduColors.primary.withOpacity(0.45),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: widget.isLoading
                                  ? null
                                  : (_isLogin
                                      ? widget.onLogin
                                      : widget.onRegister),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                              ),
                              icon: widget.isLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5),
                                    )
                                  : Icon(
                                      _isLogin
                                          ? Icons.login_rounded
                                          : Icons.person_add_rounded,
                                      color: Colors.white,
                                    ),
                              label: Text(
                                widget.isLoading
                                    ? 'Memproses...'
                                    : (_isLogin
                                        ? 'Masuk ke EduQuiz'
                                        : 'Buat Akun Sekarang'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // ── Footer ──
                        Center(
                          child: Text.rich(
                            TextSpan(
                              style: const TextStyle(
                                  fontSize: 12, color: _EduColors.textMuted),
                              children: [
                                const TextSpan(text: 'Powered by '),
                                const TextSpan(
                                  text: 'EduQuiz',
                                  style: TextStyle(
                                      color: _EduColors.primary,
                                      fontWeight: FontWeight.w700),
                                ),
                                const TextSpan(text: '  ·  Aman & terenkripsi'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TAB BUTTON (switch login/register)
// ─────────────────────────────────────────────────────────────
class _TabBtn extends StatelessWidget {
  const _TabBtn({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isActive
              ? [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 16,
                color: isActive ? _EduColors.primary : _EduColors.textMuted),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: isActive ? _EduColors.primary : _EduColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ROLE SELECTOR
// ─────────────────────────────────────────────────────────────
class _RoleSelector extends StatelessWidget {
  const _RoleSelector({required this.selected, required this.onChanged});
  final UserRole selected;
  final ValueChanged<UserRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: _RoleCard(
          label: 'Peserta',
          description: 'Ikuti kuis & belajar',
          icon: Icons.groups_2_outlined,
          value: UserRole.participant,
          selected: selected,
          activeColor: _EduColors.pesertaText,
          activeBg: _EduColors.pesertaChip,
          onTap: () => onChanged(UserRole.participant),
        )),
        const SizedBox(width: 10),
        Expanded(
            child: _RoleCard(
          label: 'Host / Guru',
          description: 'Buat & kelola kuis',
          icon: Icons.dashboard_outlined,
          value: UserRole.host,
          selected: selected,
          activeColor: _EduColors.hostText,
          activeBg: _EduColors.hostChip,
          onTap: () => onChanged(UserRole.host),
        )),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.label,
    required this.description,
    required this.icon,
    required this.value,
    required this.selected,
    required this.activeColor,
    required this.activeBg,
    required this.onTap,
  });

  final String label, description;
  final IconData icon;
  final UserRole value, selected;
  final Color activeColor, activeBg;
  final VoidCallback onTap;

  bool get isSelected => selected == value;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: isSelected ? activeBg : _EduColors.inputBg,
        border: Border.all(
            color: isSelected ? activeColor : _EduColors.inputBorder,
            width: isSelected ? 2 : 1.5),
        borderRadius: BorderRadius.circular(14),
        boxShadow: isSelected
            ? [
                BoxShadow(
                    color: activeColor.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ]
            : [],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          child: Column(children: [
            Icon(icon,
                color: isSelected ? activeColor : _EduColors.textMuted,
                size: 28),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? activeColor : _EduColors.textDark),
                textAlign: TextAlign.center),
            const SizedBox(height: 2),
            Text(description,
                style:
                    const TextStyle(fontSize: 11, color: _EduColors.textMuted),
                textAlign: TextAlign.center),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// STYLED INPUT
// ─────────────────────────────────────────────────────────────
class _StyledInput extends StatelessWidget {
  const _StyledInput({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label, hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: _EduColors.textDark,
              letterSpacing: 0.1,
            )),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: const TextStyle(fontSize: 14.5, color: _EduColors.textDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFC4C4C4), fontSize: 14),
            prefixIcon: Icon(icon, size: 19, color: _EduColors.textMuted),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: _EduColors.inputBg,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide:
                  const BorderSide(color: _EduColors.inputBorder, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide:
                  const BorderSide(color: _EduColors.inputBorder, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide:
                  const BorderSide(color: _EduColors.secondary, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// INTRO BADGE
// ─────────────────────────────────────────────────────────────
class _IntroBadge extends StatelessWidget {
  const _IntroBadge(
      {required this.label, required this.icon, required this.color});
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 12.5, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// typedef helper
// ─────────────────────────────────────────────────────────────
typedef AsyncCallback = Future<void> Function();
