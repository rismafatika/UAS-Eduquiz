import 'package:eduquiz/services/room_service.dart';
import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/supabase_service.dart';
import '../widgets/eduquiz_logo.dart';
import 'create_room_page.dart';
import 'join_room_page.dart';
import 'logout_page.dart';
import 'latihan_page.dart';
import 'riwayat_page.dart';
import 'statistik_page.dart';
import 'quiz_realtime_page.dart';
import 'leaderboard_preview_page.dart';
import 'review_dashboard_page.dart';
import 'room_code_page.dart';
import 'host_dashboard_page.dart';
import 'kelola_soal_page.dart';
import 'rekap_nilai_page.dart';

// ─── PALET WARNA ──────────────────────────────────────────
class _EduColors {
  static const primary = Color(0xFF0D9488);
  static const primaryDark = Color(0xFF0F766E);
  static const bg = Color(0xFFF0FDF4);
  static const dark = Color(0xFF064E3B);
  static const body = Color(0xFF065F46);
  static const muted = Color(0xFF6B7280);
  static const shadow = Color(0x1A000000);
  static const white = Color(0xFFFFFFFF);
}

// ─── HOME PAGE ────────────────────────────────────────────
class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.user});
  final AppUser user;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _currentTab = 0;
  late final TabController _tabController;

  bool get _isHost => widget.user.role == UserRole.host;
  Color get _primary => _EduColors.primary;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(() => setState(() => _currentTab = _tabController.index));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _confirmLogout() async {
    final logout = await showDialog<bool>(
      context: context,
      builder: (_) => const LogoutPage(),
    );
    if (logout == true && mounted) {
      await SupabaseService.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _EduColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _BerandaTab(
                    user: widget.user,
                    isHost: _isHost,
                    primary: _primary,
                    onGabungRoom: _goGabungRoom,
                    onBuatRoom: _goBuatRoom,
                  ),
                  _FiturTab(primary: _primary, user: widget.user),
                  _isHost
                      ? _RekapKelasTab(primary: _primary)
                      : _RiwayatTab(primary: _primary),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _currentTab == 0 ? _buildFAB() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // ─── HEADER ──────────────────────────────────────────────
  Widget _buildHeader() {
    final initials = widget.user.name.trim().isEmpty
        ? '?'
        : widget.user.name
            .trim()
            .split(' ')
            .take(2)
            .map((e) => e[0].toUpperCase())
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
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_EduColors.primary, _EduColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _EduColors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const EduQuizLogo(
                  size: 42,
                  borderRadius: 12,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'EduQuiz',
                style: TextStyle(
                  color: _EduColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _showProfile,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _EduColors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _EduColors.shadow,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _EduColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _confirmLogout,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _EduColors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.logout_rounded,
                      color: _EduColors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '$greeting,',
            style: TextStyle(
                color: _EduColors.white.withOpacity(0.8), fontSize: 14),
          ),
          const SizedBox(height: 2),
          Text(
            widget.user.name.isNotEmpty ? widget.user.name : 'Pengguna',
            style: const TextStyle(
              color: _EduColors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.user.email,
            style: TextStyle(
                color: _EduColors.white.withOpacity(0.7), fontSize: 13),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: _EduColors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _EduColors.white.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isHost ? Icons.dashboard_outlined : Icons.groups_2_outlined,
                  color: _EduColors.white,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  _isHost ? 'Host / Guru' : 'Peserta',
                  style: const TextStyle(
                    color: _EduColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── TAB BAR ──────────────────────────────────────────────
  Widget _buildTabBar() {
    final tabs = _isHost
        ? const ['Beranda', 'Fitur', 'Rekap Kelas']
        : const ['Beranda', 'Fitur', 'Riwayat'];
    final icons = _isHost
        ? [
            Icons.home_outlined,
            Icons.star_outline_rounded,
            Icons.analytics_outlined
          ]
        : [
            Icons.home_outlined,
            Icons.star_outline_rounded,
            Icons.history_edu_outlined
          ];

    return Container(
      color: _EduColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: _EduColors.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: _EduColors.white,
        unselectedLabelColor: _EduColors.muted,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        unselectedLabelStyle:
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        tabs: List.generate(
          tabs.length,
          (i) => Tab(icon: Icon(icons[i], size: 18), text: tabs[i]),
        ),
      ),
    );
  }

  // ─── FAB ──────────────────────────────────────────────────
  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: _isHost ? _goBuatRoom : _goGabungRoom,
      backgroundColor: _EduColors.primary,
      elevation: 4,
      icon: Icon(_isHost ? Icons.add_rounded : Icons.login_rounded,
          color: _EduColors.white, size: 22),
      label: Text(
        _isHost ? 'Buat Room' : 'Gabung Room',
        style: const TextStyle(
            color: _EduColors.white, fontWeight: FontWeight.w700, fontSize: 15),
      ),
    );
  }

  void _goBuatRoom() => Navigator.push(context,
      MaterialPageRoute(builder: (_) => CreateRoomPage(user: widget.user)));
  void _goGabungRoom() => Navigator.push(context,
      MaterialPageRoute(builder: (_) => JoinRoomPage(user: widget.user)));

  void _showProfile() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ProfileSheet(
          user: widget.user, primary: _primary, onLogout: _confirmLogout),
    );
  }
}

// ─── TAB BERANDA ───────────────────────────────────────────
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
  final VoidCallback onGabungRoom;
  final VoidCallback onBuatRoom;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom + 80.0;
    return ListView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPad),
      children: [
        _GreetingCard(isHost: isHost, primary: primary),
        const SizedBox(height: 16),
        _QuizOfTheDay(primary: primary, user: user),
        const SizedBox(height: 16),
        _StatsRow(isHost: isHost, primary: primary),
        const SizedBox(height: 16),
        _AchievementRow(primary: primary),
        const SizedBox(height: 16),
        _ActivitySection(isHost: isHost, primary: primary),
        const SizedBox(height: 20),
        _LearningRecommendation(primary: primary),
        const SizedBox(height: 20),
        _MenuGrid(
          isHost: isHost,
          primary: primary,
          user: user,
          onGabungRoom: onGabungRoom,
          onBuatRoom: onBuatRoom,
        ),
      ],
    );
  }
}

// ─── GREETING CARD ──────────────────────────────────────────
class _GreetingCard extends StatelessWidget {
  const _GreetingCard({required this.isHost, required this.primary});
  final bool isHost;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final tips = isHost
        ? 'Kelola kelas dengan mudah dan pantau perkembangan siswa'
        : 'Tingkatkan pemahamanmu dengan kuis interaktif setiap hari';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary.withOpacity(0.08), primary.withOpacity(0.02)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withOpacity(0.12), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isHost ? Icons.auto_awesome_rounded : Icons.rocket_rounded,
              color: primary,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHost ? '🎯 Dashboard Host' : '🚀 Selamat Belajar!',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tips,
                  style:
                      const TextStyle(fontSize: 12.5, color: _EduColors.body),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Kuis Hari Ini ──────────────────────────────────────────
class _QuizOfTheDay extends StatelessWidget {
  const _QuizOfTheDay({required this.primary, required this.user});
  final Color primary;
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.today_rounded, color: _EduColors.white, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kuis Hari Ini',
                  style: TextStyle(
                    color: _EduColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Matematika Dasar • 10 soal',
                  style: TextStyle(
                    color: _EduColors.white.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LatihanPage(user: user),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _EduColors.white,
              foregroundColor: primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Mulai',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ─── STATISTIK ROW ──────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.isHost, required this.primary});
  final bool isHost;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final rooms = RoomService.instance.getAllRooms();
    final totalRoom = rooms.length;
    final totalPeserta = rooms.fold(0, (sum, r) => sum + r.participants.length);
    final totalSoal = rooms.fold(0, (sum, r) => sum + r.questions.length);

    if (isHost) {
      return Row(
        children: [
          _StatCard(
              icon: Icons.meeting_room_outlined,
              label: 'Room Aktif',
              value: '$totalRoom',
              color: primary),
          const SizedBox(width: 10),
          _StatCard(
              icon: Icons.group_outlined,
              label: 'Peserta',
              value: '$totalPeserta',
              color: const Color(0xFF8B5CF6)),
          const SizedBox(width: 10),
          _StatCard(
              icon: Icons.quiz_outlined,
              label: 'Total Soal',
              value: '$totalSoal',
              color: const Color(0xFFF59E0B)),
        ],
      );
    }
    return Row(
      children: [
        _StatCard(
            icon: Icons.quiz_outlined,
            label: 'Kuis Diikuti',
            value: '5',
            color: primary),
        const SizedBox(width: 10),
        _StatCard(
            icon: Icons.emoji_events_outlined,
            label: 'Skor Tertinggi',
            value: '90',
            color: const Color(0xFFF59E0B)),
        const SizedBox(width: 10),
        _StatCard(
            icon: Icons.military_tech_outlined,
            label: 'Rank',
            value: '#2',
            color: const Color(0xFF8B5CF6)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});
  final IconData icon;
  final String label, value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _EduColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: _EduColors.shadow,
                blurRadius: 10,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: color,
                  letterSpacing: -0.5),
            ),
            Text(label,
                style: const TextStyle(fontSize: 11, color: _EduColors.muted)),
          ],
        ),
      ),
    );
  }
}

// ─── Pencapaian ──────────────────────────────────────────────
class _AchievementRow extends StatelessWidget {
  const _AchievementRow({required this.primary});
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final achievements = [
      {'icon': '🏆', 'label': 'Juara Kuis'},
      {'icon': '⭐', 'label': '10 Kuis'},
      {'icon': '🔥', 'label': 'Streak 5'},
      {'icon': '📚', 'label': 'Pelajar Aktif'},
    ];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _EduColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _EduColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events_outlined, color: primary, size: 18),
              const SizedBox(width: 6),
              const Text(
                'Pencapaian',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: achievements.map((item) {
              return Column(
                children: [
                  Text(item['icon']!, style: const TextStyle(fontSize: 28)),
                  const SizedBox(height: 4),
                  Text(item['label']!,
                      style: const TextStyle(
                          fontSize: 11, color: _EduColors.muted)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─── ACTIVITY SECTION ──────────────────────────────────────
class _ActivitySection extends StatelessWidget {
  const _ActivitySection({required this.isHost, required this.primary});
  final bool isHost;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    if (isHost) {
      return _HostActivity(primary: primary);
    }
    return _ParticipantProgress(primary: primary);
  }
}

class _HostActivity extends StatelessWidget {
  const _HostActivity({required this.primary});
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final rooms = RoomService.instance.getAllRooms();
    final lastRoom = rooms.isNotEmpty ? rooms.last : null;
    final activities = lastRoom != null
        ? [
            {'title': lastRoom.title, 'time': 'Sekarang', 'status': 'Aktif'},
          ]
        : [
            {'title': 'Belum ada aktivitas', 'time': '-', 'status': '-'}
          ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _EduColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: _EduColors.shadow,
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, color: primary, size: 20),
              const SizedBox(width: 8),
              const Text('Aktivitas Terakhir',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              const Spacer(),
              Text('Lihat semua',
                  style: TextStyle(
                      fontSize: 12,
                      color: primary,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          ...activities.map(
            (act) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                      child: Text(act['title']!,
                          style: const TextStyle(fontSize: 13))),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: act['status'] == 'Aktif'
                          ? Colors.green.shade100
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      act['status']!,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: act['status'] == 'Aktif'
                            ? Colors.green.shade800
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(act['time']!,
                      style: const TextStyle(
                          fontSize: 11, color: _EduColors.muted)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticipantProgress extends StatelessWidget {
  const _ParticipantProgress({required this.primary});
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _EduColors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                    color: _EduColors.shadow,
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 60,
                      width: 60,
                      child: CircularProgressIndicator(
                        value: 0.78,
                        strokeWidth: 6,
                        backgroundColor: primary.withOpacity(0.15),
                        valueColor: AlwaysStoppedAnimation(primary),
                      ),
                    ),
                    Text('78',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: primary)),
                  ],
                ),
                const SizedBox(height: 6),
                const Text('Rata-rata Skor',
                    style: TextStyle(fontSize: 11, color: _EduColors.muted)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _EduColors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                    color: _EduColors.shadow,
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.leaderboard_outlined, color: primary, size: 18),
                    const SizedBox(width: 6),
                    const Text('Leaderboard',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 6),
                ...['Budi', 'Ani', 'Citra'].asMap().entries.map(
                  (e) {
                    final idx = e.key;
                    final name = e.value;
                    final scores = [92, 88, 85];
                    final colors = [
                      const Color(0xFFF59E0B),
                      const Color(0xFF94A3B8),
                      const Color(0xFFCD7F32)
                    ];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Text(
                            '${idx + 1}',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: colors[idx]),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(name,
                                  style: const TextStyle(fontSize: 13))),
                          Text('${scores[idx]}',
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    );
                  },
                ).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Rekomendasi Belajar ────────────────────────────────────
class _LearningRecommendation extends StatelessWidget {
  const _LearningRecommendation({required this.primary});
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final tips = [
      '📖 Baca ulang materi yang salah',
      '⏳ Latihan 15 menit setiap hari',
      '📝 Catat rumus penting',
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _EduColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _EduColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded, color: primary, size: 18),
              const SizedBox(width: 6),
              const Text(
                'Rekomendasi Belajar',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...tips.map((tip) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_right_rounded,
                        color: _EduColors.muted),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(tip,
                          style: const TextStyle(
                              fontSize: 13, color: _EduColors.body)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ─── MENU GRID ──────────────────────────────────────────────
class _MenuGrid extends StatelessWidget {
  const _MenuGrid({
    required this.isHost,
    required this.primary,
    required this.user,
    required this.onGabungRoom,
    required this.onBuatRoom,
  });
  final bool isHost;
  final Color primary;
  final AppUser user;
  final VoidCallback onGabungRoom;
  final VoidCallback onBuatRoom;

  @override
  Widget build(BuildContext context) {
    final items = isHost
        ? [
            _MenuItem(
                icon: Icons.add_circle_outline_rounded,
                label: 'Buat Room',
                desc: 'Mulai kuis baru',
                color: primary,
                onTap: onBuatRoom),
            _MenuItem(
                icon: Icons.edit_rounded,
                label: 'Kelola Soal',
                desc: 'Tambah & edit soal',
                color: const Color(0xFF8B5CF6),
                onTap: () {
                  final rooms = RoomService.instance.getAllRooms();
                  final room = rooms.isNotEmpty ? rooms.last : null;
                  if (room != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => KelolaSoalPage(user: user, room: room),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Belum ada room yang dibuat'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                }),
            _MenuItem(
                icon: Icons.people_outline_rounded,
                label: 'Rekap Nilai',
                desc: 'Nilai peserta',
                color: const Color(0xFF0EA5E9),
                onTap: () {
                  final rooms = RoomService.instance.getAllRooms();
                  final room = rooms.isNotEmpty ? rooms.last : null;
                  if (room != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RekapNilaiPage(user: user, room: room),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Belum ada room yang dibuat'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                }),
            _MenuItem(
                icon: Icons.analytics_outlined,
                label: 'Statistik',
                desc: 'Performa kelas',
                color: const Color(0xFFF59E0B),
                onTap: () {
                  final rooms = RoomService.instance.getAllRooms();
                  final room = rooms.isNotEmpty ? rooms.last : null;
                  if (room != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            HostDashboardPage(user: user, room: room),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Belum ada room yang dibuat'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                }),
          ]
        : [
            _MenuItem(
                icon: Icons.login_rounded,
                label: 'Gabung Room',
                desc: 'Masuk dengan kode',
                color: primary,
                onTap: onGabungRoom),
            _MenuItem(
                icon: Icons.edit_note_rounded,
                label: 'Latihan Soal',
                desc: 'Latihan mandiri',
                color: const Color(0xFF8B5CF6),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LatihanPage(user: user),
                    ),
                  );
                }),
            _MenuItem(
                icon: Icons.history_edu_outlined,
                label: 'Riwayat',
                desc: 'Rekap nilai kamu',
                color: const Color(0xFF0EA5E9),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RiwayatPage(user: user),
                    ),
                  );
                }),
            _MenuItem(
                icon: Icons.bar_chart_rounded,
                label: 'Statistik',
                desc: 'Perkembangan',
                color: const Color(0xFFF59E0B),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StatistikPage(user: user),
                    ),
                  );
                }),
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isHost ? 'Menu Host' : 'Menu Utama',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _EduColors.dark),
            ),
            Text(
              'Lihat semua',
              style: TextStyle(
                  fontSize: 11,
                  color: _EduColors.primary,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.45,
          children: items.map((item) => _MenuTile(item: item)).toList(),
        ),
      ],
    );
  }
}

class _MenuItem {
  const _MenuItem(
      {required this.icon,
      required this.label,
      required this.desc,
      required this.color,
      required this.onTap});
  final IconData icon;
  final String label, desc;
  final Color color;
  final VoidCallback onTap;
}

class _MenuTile extends StatefulWidget {
  const _MenuTile({required this.item});
  final _MenuItem item;

  @override
  State<_MenuTile> createState() => _MenuTileState();
}

class _MenuTileState extends State<_MenuTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(begin: 1, end: 0.97).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.item.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: widget.item.color.withOpacity(.12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: widget.item.color.withOpacity(.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  widget.item.icon,
                  color: widget.item.color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.item.label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _EduColors.dark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              Text(
                widget.item.desc,
                style: const TextStyle(
                  fontSize: 12,
                  color: _EduColors.muted,
                ),
                maxLines: 2,
              ),
              const Spacer(),
              Row(
                children: [
                  Text(
                    "Buka",
                    style: TextStyle(
                      color: widget.item.color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: widget.item.color,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── TAB FITUR ──────────────────────────────────────────────
class _FiturTab extends StatelessWidget {
  const _FiturTab({required this.primary, required this.user});
  final Color primary;
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Fitur Unggulan',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: _EduColors.dark,
          ),
        ),
        const SizedBox(height: 12),
        _FeatureCard(
          icon: Icons.bolt_rounded,
          title: 'Quiz Real-Time',
          desc: 'Jawaban langsung dan skor otomatis.',
          color: const Color(0xFF14B8A6),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QuizRealtimePage(user: user),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        _FeatureCard(
          icon: Icons.leaderboard_outlined,
          title: 'Leaderboard',
          desc: 'Peringkat instan setelah kuis.',
          color: const Color(0xFF8B5CF6),
          onTap: () {
            final rooms = RoomService.instance.getAllRooms();
            final lastRoom = rooms.isNotEmpty ? rooms.last : null;
            if (lastRoom != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LeaderboardPreviewPage(
                    user: user,
                    room: lastRoom,
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Belum ada room yang tersedia'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          },
        ),
        const SizedBox(height: 10),
        _FeatureCard(
          icon: Icons.fact_check_outlined,
          title: 'Review Jawaban',
          desc: 'Lihat jawaban benar/salah + penjelasan.',
          color: const Color(0xFF0EA5E9),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReviewDashboardPage(user: user),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        _FeatureCard(
          icon: Icons.pin_outlined,
          title: 'Room Code Unik',
          desc: 'Setiap sesi memiliki kode sendiri.',
          color: primary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RoomCodePage(user: user),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        const Text(
          'Tips Penggunaan',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: _EduColors.dark,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _EduColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _EduColors.shadow,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _TipItem(text: 'Host: Buat room & bagikan kode ke peserta.'),
              const Divider(),
              _TipItem(text: 'Peserta: Masukkan kode untuk bergabung.'),
              const Divider(),
              _TipItem(text: 'Cek riwayat untuk lihat hasil kuis.'),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── FEATURE CARD ─────────────────────────────────────────────
class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.desc,
    required this.color,
    this.onTap,
  });
  final IconData icon;
  final String title, desc;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _EduColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.15), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: _EduColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _EduColors.dark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: _EduColors.body,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: _EduColors.muted,
            ),
          ],
        ),
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  const _TipItem({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 18, color: _EduColors.muted),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: _EduColors.body,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── TAB RIWAYAT (Peserta) ──────────────────────────────────
class _RiwayatTab extends StatelessWidget {
  const _RiwayatTab({required this.primary});
  final Color primary;

  @override
  Widget build(BuildContext context) {
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

    if (histories.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_edu_outlined, size: 64, color: _EduColors.muted),
            SizedBox(height: 12),
            Text('Belum ada riwayat',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _EduColors.dark)),
            SizedBox(height: 4),
            Text('Ikuti kuis untuk mulai mencatat skor',
                style: TextStyle(fontSize: 13, color: _EduColors.muted)),
          ],
        ),
      );
    }

    final avg = histories.map((h) => h.score).reduce((a, b) => a + b) /
        histories.length;
    final highest =
        histories.map((h) => h.score).reduce((a, b) => a > b ? a : b);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primary, primary.withOpacity(0.8)],
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
              _SummaryItem(
                  label: 'Kuis',
                  value: '${histories.length}',
                  icon: Icons.quiz_outlined),
              _VDivider(),
              _SummaryItem(
                  label: 'Rata-rata',
                  value: avg.toStringAsFixed(1),
                  icon: Icons.trending_up_rounded),
              _VDivider(),
              _SummaryItem(
                  label: 'Tertinggi',
                  value: '$highest',
                  icon: Icons.emoji_events_outlined),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text('Riwayat Kuis',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: _EduColors.dark)),
        const SizedBox(height: 12),
        ...histories.map((h) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _HistoryCard(data: h))),
      ],
    );
  }
}

// ─── WIDGET RIWAYAT CARD ──────────────────────────────────
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
        color: _EduColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: _EduColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
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
                      color: _scoreColor)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _EduColors.dark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 13, color: _EduColors.muted),
                    const SizedBox(width: 4),
                    Text('${data.benar}/${data.total} benar',
                        style: const TextStyle(
                            fontSize: 12, color: _EduColors.muted)),
                    const SizedBox(width: 12),
                    Icon(Icons.military_tech_outlined,
                        size: 13, color: _EduColors.muted),
                    const SizedBox(width: 4),
                    Text('Rank #${data.rank}',
                        style: const TextStyle(
                            fontSize: 12, color: _EduColors.muted)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(dateStr,
                    style:
                        const TextStyle(fontSize: 11, color: _EduColors.muted)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _scoreColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(_scoreLabel,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _scoreColor)),
          ),
        ],
      ),
    );
  }
}

// ─── TAB REKAP KELAS ────────────────────────────────────────
class _RekapKelasTab extends StatelessWidget {
  const _RekapKelasTab({required this.primary});
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final rooms = RoomService.instance.getAllRooms();
    final lastRoom = rooms.isNotEmpty ? rooms.last : null;
    List<_PesertaData> peserta = [];
    if (lastRoom != null) {
      final sorted = List.from(lastRoom.participants)
        ..sort((a, b) => b.score.compareTo(a.score));
      for (int i = 0; i < sorted.length; i++) {
        final p = sorted[i];
        int benar = 0;
        for (int j = 0; j < lastRoom.questions.length; j++) {
          final answer = p.answers[j];
          if (answer != null && answer == lastRoom.questions[j].correctIndex) {
            benar++;
          }
        }
        peserta.add(_PesertaData(
          nama: p.name,
          email: '${p.name.toLowerCase()}@gmail.com',
          score: p.score,
          benar: benar,
          total: lastRoom.questions.length,
          rank: i + 1,
        ));
      }
    }

    if (peserta.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: _EduColors.muted),
            SizedBox(height: 12),
            Text('Belum ada peserta',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _EduColors.dark)),
            SizedBox(height: 4),
            Text('Tunggu peserta bergabung di room',
                style: TextStyle(fontSize: 13, color: _EduColors.muted)),
          ],
        ),
      );
    }

    final avg =
        peserta.map((p) => p.score).reduce((a, b) => a + b) / peserta.length;
    final lulus = peserta.where((p) => p.score >= 70).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primary, primary.withOpacity(0.8)],
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
              _SummaryItem(
                  label: 'Peserta',
                  value: '${peserta.length}',
                  icon: Icons.group_outlined),
              _VDivider(),
              _SummaryItem(
                  label: 'Rata-rata',
                  value: avg.toStringAsFixed(1),
                  icon: Icons.bar_chart_rounded),
              _VDivider(),
              _SummaryItem(
                  label: 'Lulus ≥70',
                  value: '$lulus',
                  icon: Icons.check_circle_outline),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _EduColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: _EduColors.shadow,
                  blurRadius: 8,
                  offset: const Offset(0, 3))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Tingkat Kelulusan',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _EduColors.dark)),
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
        const Text('Peringkat Peserta',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: _EduColors.dark)),
        const SizedBox(height: 12),
        ...peserta.map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _PesertaCard(data: p, primary: primary))),
      ],
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
    return _EduColors.muted;
  }

  @override
  Widget build(BuildContext context) {
    final initials = data.nama
        .trim()
        .split(' ')
        .take(2)
        .map((e) => e[0].toUpperCase())
        .join();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _EduColors.white,
        borderRadius: BorderRadius.circular(14),
        border: data.rank <= 3
            ? Border.all(color: _rankColor.withOpacity(0.4), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
              color: _EduColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
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
                          color: _rankColor)),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 34,
            height: 34,
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
                      color: _EduColors.white)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.nama,
                    style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: _EduColors.dark)),
                Text(data.email,
                    style: const TextStyle(
                        fontSize: 11.5, color: _EduColors.muted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${data.score}',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: primary)),
              Text('${data.benar}/${data.total} benar',
                  style:
                      const TextStyle(fontSize: 10.5, color: _EduColors.muted)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── SHARED WIDGETS ─────────────────────────────────────────
class _SummaryItem extends StatelessWidget {
  const _SummaryItem(
      {required this.label, required this.value, required this.icon});
  final String label, value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: _EduColors.white.withOpacity(0.8), size: 22),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: _EduColors.white,
                  letterSpacing: -0.5)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: _EduColors.white.withOpacity(0.7)),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _VDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 1,
        height: 44,
        color: _EduColors.white.withOpacity(0.25),
        margin: const EdgeInsets.symmetric(horizontal: 8));
  }
}

// ─── PROFILE SHEET ──────────────────────────────────────────
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
            .map((e) => e[0].toUpperCase())
            .join();
    final isHost = user.role == UserRole.host;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: const BoxDecoration(
        color: _EduColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(99))),
          const SizedBox(height: 24),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient:
                  LinearGradient(colors: [primary, primary.withOpacity(0.7)]),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: primary.withOpacity(0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 8))
              ],
            ),
            child: Center(
                child: Text(initials,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: _EduColors.white))),
          ),
          const SizedBox(height: 14),
          Text(user.name.isNotEmpty ? user.name : 'Pengguna',
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: _EduColors.dark)),
          const SizedBox(height: 4),
          Text(user.email,
              style: const TextStyle(fontSize: 14, color: _EduColors.muted)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20)),
            child: Text(isHost ? 'Host / Guru' : 'Peserta',
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700, color: primary)),
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
                foregroundColor: Colors.red.shade700,
                side: BorderSide(color: Colors.red.shade700, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Logout',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── DATA MODELS ─────────────────────────────────────────────
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
