import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/supabase_service.dart';
import '../widgets/app_panel.dart';
import '../widgets/section_title.dart';
import '../widgets/status_badge.dart';
import 'create_room_page.dart';
import 'join_room_page.dart';
import 'logout_page.dart';

// ─────────────────────────────────────────────────────────────
// WARNA TEMA
// ─────────────────────────────────────────────────────────────
class _C {
  // Peserta: teal
  static const teal = Color(0xFF0D9488);
  static const tealBg = Color(0xFFCCFBF1);
  // Host: orange
  static const orange = Color(0xFFEA580C);
  static const orangeBg = Color(0xFFFEF3C7);
  // Netral
  static const bg = Color(0xFFF8FAFC);
  static const card = Color(0xFFFFFFFF);
  static const dark = Color(0xFF0F172A);
  static const body = Color(0xFF334155);
  static const muted = Color(0xFF94A3B8);
  static const border = Color(0xFFE2E8F0);
  static const inputBg = Color(0xFFF1F5F9);
}

// ─────────────────────────────────────────────────────────────
// HOME PAGE
// ─────────────────────────────────────────────────────────────
class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.user});
  final AppUser user;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tab = 0; // 0=Beranda 1=Fitur 2=Rekap

  bool get _isHost => widget.user.role == UserRole.host;
  Color get _primary => _isHost ? _C.orange : _C.teal;

  Future<void> _confirmLogout() async {
    final logout = await showDialog<bool>(
      context: context,
      builder: (_) => const LogoutPage(),
    );
    if (logout == true && mounted) {
      await SupabaseService.instance.signOut();
      if (mounted)
        Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _buildTabContent(),
            ),
          ),
        ],
      ),
      floatingActionButton: _tab == 0 ? _buildFAB() : null,
    );
  }

  // ── Header gradient ──
  Widget _buildHeader() {
    final initials = widget.user.name.trim().isEmpty
        ? '?'
        : widget.user.name
            .trim()
            .split(' ')
            .take(2)
            .map((w) => w[0].toUpperCase())
            .join();

    final hour = DateTime.now().hour;
    final greeting = hour < 11
        ? 'Selamat pagi'
        : hour < 15
            ? 'Selamat siang'
            : hour < 18
                ? 'Selamat sore'
                : 'Selamat malam';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isHost
              ? [const Color(0xFFEA580C), const Color(0xFFD97706)]
              : [const Color(0xFF0D9488), const Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
              color: _primary.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8))
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.school_outlined,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                const Text('EduQuiz',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
                const Spacer(),
                GestureDetector(
                  onTap: _showProfile,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.1), blurRadius: 6)
                      ],
                    ),
                    child: Center(
                        child: Text(initials,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: _primary))),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _confirmLogout,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.logout_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('$greeting,',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.8), fontSize: 14)),
            const SizedBox(height: 2),
            Text(
              widget.user.name.isNotEmpty ? widget.user.name : 'Pengguna',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                      _isHost
                          ? Icons.dashboard_outlined
                          : Icons.groups_2_outlined,
                      color: Colors.white,
                      size: 14),
                  const SizedBox(width: 5),
                  Text(_isHost ? 'Host / Guru' : 'Peserta',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tab bar ──
  Widget _buildTabBar() {
    final tabs = _isHost
        ? [
            ('Beranda', Icons.home_outlined),
            ('Fitur', Icons.star_outline_rounded),
            ('Rekap Kelas', Icons.analytics_outlined)
          ]
        : [
            ('Beranda', Icons.home_outlined),
            ('Fitur', Icons.star_outline_rounded),
            ('Riwayat', Icons.history_edu_outlined)
          ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final active = _tab == i;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _tab = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? _primary : _C.inputBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(tabs[i].$2,
                        size: 15, color: active ? Colors.white : _C.muted),
                    const SizedBox(width: 5),
                    Text(tabs[i].$1,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: active ? Colors.white : _C.muted,
                        )),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Konten per tab ──
  Widget _buildTabContent() {
    switch (_tab) {
      case 1:
        return _FiturTab(isHost: _isHost, primary: _primary);
      case 2:
        return _isHost
            ? _RekapKelasTab(primary: _primary)
            : _RiwayatTab(primary: _primary);
      default:
        return _BerandaTab(
          user: widget.user,
          isHost: _isHost,
          primary: _primary,
          onGabungRoom: _goGabungRoom,
          onBuatRoom: _goBuatRoom,
        );
    }
  }

  // ── FAB ──
  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: _isHost ? _goBuatRoom : _goGabungRoom,
      backgroundColor: _primary,
      icon: Icon(_isHost ? Icons.add_rounded : Icons.login_rounded,
          color: Colors.white),
      label: Text(_isHost ? 'Buat Room' : 'Gabung Room',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700)),
    );
  }

  void _goBuatRoom() {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => CreateRoomPage(user: widget.user)));
  }

  void _goGabungRoom() {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => JoinRoomPage(user: widget.user)));
  }

  void _showProfile() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProfileSheet(
          user: widget.user, primary: _primary, onLogout: _confirmLogout),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TAB BERANDA
// ─────────────────────────────────────────────────────────────
class _BerandaTab extends StatelessWidget {
  const _BerandaTab({
    required this.user,
    required this.isHost,
    required this.primary,
    required this.onGabungRoom,
    required this.onBuatRoom,
  });
  final AppUser user;
  final bool isHost;
  final Color primary;
  final VoidCallback onGabungRoom, onBuatRoom;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        // Tips card
        _TipsCard(isHost: isHost, primary: primary),
        const SizedBox(height: 16),

        // Quick stats row
        SizedBox(
          height: 92,
          child: Row(
            children: isHost
                ? [
                    Expanded(
                        child: _QuickStat(
                            icon: Icons.meeting_room_outlined,
                            label: 'Room Aktif',
                            value: '3',
                            color: primary)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _QuickStat(
                            icon: Icons.group_outlined,
                            label: 'Peserta',
                            value: '47',
                            color: const Color(0xFF8B5CF6))),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _QuickStat(
                            icon: Icons.quiz_outlined,
                            label: 'Total Soal',
                            value: '120',
                            color: const Color(0xFFF59E0B))),
                  ]
                : [
                    Expanded(
                        child: _QuickStat(
                            icon: Icons.quiz_outlined,
                            label: 'Kuis Diikuti',
                            value: '5',
                            color: primary)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _QuickStat(
                            icon: Icons.emoji_events_outlined,
                            label: 'Skor Tertinggi',
                            value: '90',
                            color: const Color(0xFFF59E0B))),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _QuickStat(
                            icon: Icons.military_tech_outlined,
                            label: 'Rank Terbaik',
                            value: '#2',
                            color: const Color(0xFF8B5CF6))),
                  ],
          ),
        ),
        const SizedBox(height: 20),

        // Menu grid
        Text(isHost ? 'Menu Host' : 'Menu Utama',
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _C.dark,
                letterSpacing: -0.3)),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: isHost
              ? [
                  _MenuTile(
                      icon: Icons.add_circle_outline_rounded,
                      label: 'Buat Room',
                      desc: 'Mulai sesi kuis baru',
                      color: primary,
                      onTap: onBuatRoom),
                  _MenuTile(
                      icon: Icons.edit_rounded,
                      label: 'Kelola Soal',
                      desc: 'Tambah & edit soal',
                      color: const Color(0xFF8B5CF6),
                      onTap: () {}),
                  _MenuTile(
                      icon: Icons.people_outline_rounded,
                      label: 'Rekap Nilai',
                      desc: 'Nilai semua peserta',
                      color: const Color(0xFF0EA5E9),
                      onTap: () {}),
                  _MenuTile(
                      icon: Icons.analytics_outlined,
                      label: 'Statistik',
                      desc: 'Performa kelas',
                      color: const Color(0xFFF59E0B),
                      onTap: () {}),
                ]
              : [
                  _MenuTile(
                      icon: Icons.login_rounded,
                      label: 'Gabung Room',
                      desc: 'Masuk kuis dengan kode',
                      color: primary,
                      onTap: onGabungRoom),
                  _MenuTile(
                      icon: Icons.edit_note_rounded,
                      label: 'Latihan Soal',
                      desc: 'Latihan mandiri',
                      color: const Color(0xFF8B5CF6),
                      onTap: () {}),
                  _MenuTile(
                      icon: Icons.history_edu_outlined,
                      label: 'Riwayat',
                      desc: 'Rekap nilai kamu',
                      color: const Color(0xFF0EA5E9),
                      onTap: () {}),
                  _MenuTile(
                      icon: Icons.bar_chart_rounded,
                      label: 'Statistik',
                      desc: 'Perkembangan belajar',
                      color: const Color(0xFFF59E0B),
                      onTap: () {}),
                ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TAB FITUR
// ─────────────────────────────────────────────────────────────
class _FiturTab extends StatelessWidget {
  const _FiturTab({required this.isHost, required this.primary});
  final bool isHost;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionLabel(label: 'Fitur Unggulan'),
        const SizedBox(height: 12),
        _FeatureBanner(
          icon: Icons.bolt_rounded,
          title: 'Quiz Real-Time',
          desc:
              'Peserta menjawab soal secara langsung dan skor diperbarui otomatis tiap jawaban.',
          color: const Color(0xFF14B8A6),
        ),
        const SizedBox(height: 10),
        _FeatureBanner(
          icon: Icons.leaderboard_outlined,
          title: 'Leaderboard Otomatis',
          desc:
              'Peringkat peserta tampil langsung setelah semua menjawab tanpa perlu hitung manual.',
          color: const Color(0xFF8B5CF6),
        ),
        const SizedBox(height: 10),
        _FeatureBanner(
          icon: Icons.fact_check_outlined,
          title: 'Review Jawaban',
          desc:
              'Peserta bisa melihat jawaban benar/salah lengkap dengan penjelasan setelah kuis.',
          color: const Color(0xFF0EA5E9),
        ),
        const SizedBox(height: 10),
        _FeatureBanner(
          icon: Icons.pin_outlined,
          title: 'Room Code Unik',
          desc:
              'Setiap sesi mendapat kode unik sehingga hanya peserta yang diundang bisa masuk.',
          color: primary,
        ),
        const SizedBox(height: 20),
        _SectionLabel(label: 'Status Sistem'),
        const SizedBox(height: 12),
        _StatusCard(),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TAB RIWAYAT (Peserta)
// ─────────────────────────────────────────────────────────────
class _RiwayatTab extends StatelessWidget {
  const _RiwayatTab({required this.primary});
  final Color primary;

  @override
  Widget build(BuildContext context) {
    // Data dummy — ganti dengan data real dari Supabase
    final histories = [
      _HistoryData(
          title: 'Matematika Dasar',
          score: 85,
          benar: 8,
          total: 10,
          rank: 2,
          date: DateTime.now().subtract(const Duration(days: 1))),
      _HistoryData(
          title: 'IPA Kelas 7',
          score: 60,
          benar: 6,
          total: 10,
          rank: 5,
          date: DateTime.now().subtract(const Duration(days: 3))),
      _HistoryData(
          title: 'Bahasa Indonesia',
          score: 92,
          benar: 9,
          total: 10,
          rank: 1,
          date: DateTime.now().subtract(const Duration(days: 7))),
      _HistoryData(
          title: 'PKN Semester 1',
          score: 70,
          benar: 7,
          total: 10,
          rank: 3,
          date: DateTime.now().subtract(const Duration(days: 14))),
    ];

    final avg = histories.map((h) => h.score).reduce((a, b) => a + b) /
        histories.length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Ringkasan
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primary, primary.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: primary.withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6))
            ],
          ),
          child: Row(
            children: [
              Expanded(
                  child: _SummaryItem(
                      label: 'Kuis Diikuti',
                      value: '${histories.length}',
                      icon: Icons.quiz_outlined)),
              _VDivider(),
              Expanded(
                  child: _SummaryItem(
                      label: 'Rata-rata',
                      value: avg.toStringAsFixed(1),
                      icon: Icons.trending_up_rounded)),
              _VDivider(),
              Expanded(
                  child: _SummaryItem(
                      label: 'Tertinggi',
                      value:
                          '${histories.map((h) => h.score).reduce((a, b) => a > b ? a : b)}',
                      icon: Icons.emoji_events_outlined)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _SectionLabel(label: 'Riwayat Kuis'),
        const SizedBox(height: 12),
        ...histories.map((h) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _HistoryCard(data: h),
            )),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TAB REKAP KELAS (Host)
// ─────────────────────────────────────────────────────────────
class _RekapKelasTab extends StatelessWidget {
  const _RekapKelasTab({required this.primary});
  final Color primary;

  @override
  Widget build(BuildContext context) {
    // Data dummy — ganti dengan data real dari Supabase
    final peserta = [
      _PesertaData(
          nama: 'Dian Sari',
          email: 'dian@gmail.com',
          score: 92,
          benar: 9,
          total: 10,
          rank: 1),
      _PesertaData(
          nama: 'Budi Santoso',
          email: 'budi@gmail.com',
          score: 80,
          benar: 8,
          total: 10,
          rank: 2),
      _PesertaData(
          nama: 'Citra Lestari',
          email: 'citra@gmail.com',
          score: 70,
          benar: 7,
          total: 10,
          rank: 3),
      _PesertaData(
          nama: 'Ahmad Fauzi',
          email: 'ahmad@gmail.com',
          score: 60,
          benar: 6,
          total: 10,
          rank: 4),
      _PesertaData(
          nama: 'Siti Rahayu',
          email: 'siti@gmail.com',
          score: 50,
          benar: 5,
          total: 10,
          rank: 5),
    ];

    final avg =
        peserta.map((p) => p.score).reduce((a, b) => a + b) / peserta.length;
    final lulus = peserta.where((p) => p.score >= 70).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Ringkasan kelas
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primary, primary.withOpacity(0.75)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: primary.withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6))
            ],
          ),
          child: Row(
            children: [
              Expanded(
                  child: _SummaryItem(
                      label: 'Total Peserta',
                      value: '${peserta.length}',
                      icon: Icons.group_outlined)),
              _VDivider(),
              Expanded(
                  child: _SummaryItem(
                      label: 'Rata Kelas',
                      value: avg.toStringAsFixed(1),
                      icon: Icons.bar_chart_rounded)),
              _VDivider(),
              Expanded(
                  child: _SummaryItem(
                      label: 'Lulus (≥70)',
                      value: '$lulus',
                      icon: Icons.check_circle_outline)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Progress bar lulus
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Tingkat Kelulusan',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _C.dark)),
                Text('${(lulus / peserta.length * 100).round()}%',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: primary)),
              ]),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: lulus / peserta.length,
                  backgroundColor: primary.withOpacity(0.12),
                  valueColor: AlwaysStoppedAnimation(primary),
                  minHeight: 10,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        _SectionLabel(label: 'Peringkat Peserta'),
        const SizedBox(height: 12),
        ...peserta.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _PesertaCard(data: p, primary: primary),
            )),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// WIDGET KECIL
// ─────────────────────────────────────────────────────────────
class _TipsCard extends StatefulWidget {
  const _TipsCard({required this.isHost, required this.primary});
  final bool isHost;
  final Color primary;
  @override
  State<_TipsCard> createState() => _TipsCardState();
}

class _TipsCardState extends State<_TipsCard> {
  int _i = 0;
  final _pesertaTips = const [
    (
      '💡 Tips Belajar',
      'Ulangi materi yang salah dalam 24 jam pertama — memori lebih cepat terbentuk!'
    ),
    (
      '⏱ Manajemen Waktu',
      'Jika tidak yakin, lewati soal dan kembali di akhir untuk nilai lebih optimal.'
    ),
    (
      '📈 Tingkatkan Skor',
      'Latihan 15 menit sehari lebih efektif dari belajar 2 jam sekaligus sebelum kuis.'
    ),
  ];
  final _hostTips = const [
    (
      '✏️ Buat Soal Efektif',
      'Gunakan 4 pilihan jawaban dengan distractor masuk akal untuk mengukur pemahaman.'
    ),
    (
      '👥 Kelola Kelas',
      'Umumkan kode room 5 menit sebelum kuis agar semua peserta siap bersamaan.'
    ),
    (
      '📊 Analisis Hasil',
      'Soal dengan % salah tinggi = sinyal materi yang perlu dijelaskan ulang.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final tips = widget.isHost ? _hostTips : _pesertaTips;
    final tip = tips[_i];
    return GestureDetector(
      onTap: () => setState(() => _i = (_i + 1) % tips.length),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Container(
          key: ValueKey(_i),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.primary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: widget.primary.withOpacity(0.15), width: 1.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: widget.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.lightbulb_outline_rounded,
                    color: widget.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(tip.$1,
                        style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: widget.primary)),
                    const Spacer(),
                    Text('${_i + 1}/${tips.length}',
                        style: TextStyle(
                            fontSize: 11,
                            color: widget.primary.withOpacity(0.6))),
                    const SizedBox(width: 4),
                    Icon(Icons.touch_app_outlined,
                        size: 12, color: widget.primary.withOpacity(0.5)),
                  ]),
                  const SizedBox(height: 5),
                  Text(tip.$2,
                      style: const TextStyle(
                          fontSize: 12.5, color: _C.body, height: 1.5)),
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  const _QuickStat(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});
  final IconData icon;
  final String label, value;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 20),
        const Spacer(),
        Text(value,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: color,
                letterSpacing: -0.5)),
        Text(label, style: const TextStyle(fontSize: 11, color: _C.muted)),
      ]),
    );
  }
}

class _MenuTile extends StatefulWidget {
  const _MenuTile(
      {required this.icon,
      required this.label,
      required this.desc,
      required this.color,
      required this.onTap});
  final IconData icon;
  final String label, desc;
  final Color color;
  final VoidCallback onTap;
  @override
  State<_MenuTile> createState() => _MenuTileState();
}

class _MenuTileState extends State<_MenuTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _s;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _s = Tween<double>(begin: 1, end: 0.95)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _c.forward(),
      onTapUp: (_) {
        _c.reverse();
        widget.onTap();
      },
      onTapCancel: () => _c.reverse(),
      child: ScaleTransition(
        scale: _s,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ]),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(widget.icon, color: widget.color, size: 22)),
            const Spacer(),
            Text(widget.label,
                style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: _C.dark)),
            const SizedBox(height: 2),
            Text(widget.desc,
                style: const TextStyle(fontSize: 11, color: _C.muted),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ]),
        ),
      ),
    );
  }
}

class _FeatureBanner extends StatelessWidget {
  const _FeatureBanner(
      {required this.icon,
      required this.title,
      required this.desc,
      required this.color});
  final IconData icon;
  final String title, desc;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.15), width: 1.5),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ]),
      child: Row(children: [
        Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 24)),
        const SizedBox(width: 14),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 14.5, fontWeight: FontWeight.w800, color: _C.dark)),
          const SizedBox(height: 4),
          Text(desc,
              style:
                  const TextStyle(fontSize: 12.5, color: _C.body, height: 1.5)),
        ])),
      ]),
    );
  }
}

class _StatusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ]),
      child: Wrap(spacing: 8, runSpacing: 8, children: [
        StatusBadge(
            label: 'Quiz real-time',
            icon: Icons.bolt,
            color: const Color(0xFF14B8A6)),
        StatusBadge(
            label: 'Review jawaban',
            icon: Icons.fact_check_outlined,
            color: const Color(0xFF1D4ED8)),
        StatusBadge(
          label: SupabaseService.instance.isReady
              ? 'Database aktif'
              : 'Database belum dikonfigurasi',
          icon: SupabaseService.instance.isReady
              ? Icons.cloud_done_outlined
              : Icons.cloud_off_outlined,
          color: SupabaseService.instance.isReady
              ? const Color(0xFF16A34A)
              : const Color(0xFFF59E0B),
        ),
      ]),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.data});
  final _HistoryData data;

  Color get _scoreColor {
    if (data.score >= 80) return const Color(0xFF059669);
    if (data.score >= 60) return const Color(0xFFF59E0B);
    return const Color(0xFFDC2626);
  }

  String get _scoreLabel {
    if (data.score >= 80) return 'Bagus!';
    if (data.score >= 60) return 'Cukup';
    return 'Perlu latihan';
  }

  @override
  Widget build(BuildContext context) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    final d = data.date;
    final dateStr = '${d.day} ${months[d.month - 1]} ${d.year}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 3))
          ]),
      child: Row(children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: _scoreColor.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: _scoreColor.withOpacity(0.3), width: 2),
          ),
          child: Center(
              child: Text('${data.score}',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: _scoreColor))),
        ),
        const SizedBox(width: 14),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(data.title,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: _C.dark),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Row(children: [
            Icon(Icons.check_circle_outline, size: 13, color: _C.muted),
            const SizedBox(width: 3),
            Text('${data.benar}/${data.total} benar',
                style: const TextStyle(fontSize: 12, color: _C.muted)),
            const SizedBox(width: 10),
            Icon(Icons.military_tech_outlined, size: 13, color: _C.muted),
            const SizedBox(width: 3),
            Text('Rank #${data.rank}',
                style: const TextStyle(fontSize: 12, color: _C.muted)),
          ]),
          const SizedBox(height: 3),
          Text(dateStr, style: const TextStyle(fontSize: 11, color: _C.muted)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
              color: _scoreColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20)),
          child: Text(_scoreLabel,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _scoreColor)),
        ),
      ]),
    );
  }
}

class _PesertaCard extends StatelessWidget {
  const _PesertaCard({required this.data, required this.primary});
  final _PesertaData data;
  final Color primary;

  Color get _rankColor {
    if (data.rank == 1) return const Color(0xFFF59E0B);
    if (data.rank == 2) return const Color(0xFF94A3B8);
    if (data.rank == 3) return const Color(0xFFCD7F32);
    return _C.muted;
  }

  @override
  Widget build(BuildContext context) {
    final initials = data.nama
        .trim()
        .split(' ')
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: data.rank <= 3
            ? Border.all(color: _rankColor.withOpacity(0.4), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Row(children: [
        // Rank badge
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
              color: _rankColor.withOpacity(0.12), shape: BoxShape.circle),
          child: Center(
              child: data.rank <= 3
                  ? Icon(Icons.emoji_events_rounded,
                      color: _rankColor, size: 18)
                  : Text('#${data.rank}',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: _rankColor))),
        ),
        const SizedBox(width: 10),
        // Avatar
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient:
                LinearGradient(colors: [primary, primary.withOpacity(0.7)]),
            shape: BoxShape.circle,
          ),
          child: Center(
              child: Text(initials,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white))),
        ),
        const SizedBox(width: 10),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(data.nama,
              style: const TextStyle(
                  fontSize: 13.5, fontWeight: FontWeight.w700, color: _C.dark)),
          Text(data.email,
              style: const TextStyle(fontSize: 11.5, color: _C.muted)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${data.score}',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w900, color: primary)),
          Text('${data.benar}/${data.total} benar',
              style: const TextStyle(fontSize: 10.5, color: _C.muted)),
        ]),
      ]),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem(
      {required this.label, required this.value, required this.icon});
  final String label, value;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
      const SizedBox(height: 6),
      Text(value,
          style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5)),
      const SizedBox(height: 2),
      Text(label,
          style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.7)),
          textAlign: TextAlign.center),
    ]);
  }
}

class _VDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
      width: 1,
      height: 44,
      color: Colors.white.withOpacity(0.25),
      margin: const EdgeInsets.symmetric(horizontal: 6));
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: _C.dark,
            letterSpacing: -0.3));
  }
}

// ─────────────────────────────────────────────────────────────
// PROFILE SHEET
// ─────────────────────────────────────────────────────────────
class _ProfileSheet extends StatelessWidget {
  const _ProfileSheet(
      {required this.user, required this.primary, required this.onLogout});
  final AppUser user;
  final Color primary;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final initials = user.name.trim().isEmpty
        ? '?'
        : user.name
            .trim()
            .split(' ')
            .take(2)
            .map((w) => w[0].toUpperCase())
            .join();
    final isHost = user.role == UserRole.host;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(99))),
        const SizedBox(height: 24),
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            gradient:
                LinearGradient(colors: [primary, primary.withOpacity(0.7)]),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: primary.withOpacity(0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8))
            ],
          ),
          child: Center(
              child: Text(initials,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white))),
        ),
        const SizedBox(height: 14),
        Text(user.name.isNotEmpty ? user.name : 'Pengguna',
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.w900, color: _C.dark)),
        const SizedBox(height: 4),
        Text(user.email,
            style: const TextStyle(fontSize: 13.5, color: _C.muted)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20)),
          child: Text(isHost ? 'Host / Guru' : 'Peserta',
              style: TextStyle(
                  fontSize: 12.5, fontWeight: FontWeight.w700, color: primary)),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              onLogout();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFDC2626),
              side: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Logout',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// DATA MODELS (dummy — ganti dengan Supabase)
// ─────────────────────────────────────────────────────────────
class _HistoryData {
  const _HistoryData(
      {required this.title,
      required this.score,
      required this.benar,
      required this.total,
      required this.rank,
      required this.date});
  final String title;
  final int score, benar, total, rank;
  final DateTime date;
}

class _PesertaData {
  const _PesertaData(
      {required this.nama,
      required this.email,
      required this.score,
      required this.benar,
      required this.total,
      required this.rank});
  final String nama, email;
  final int score, benar, total, rank;
}
