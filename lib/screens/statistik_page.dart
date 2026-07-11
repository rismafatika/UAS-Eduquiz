import 'package:flutter/material.dart';
import '../models/app_user.dart';

class StatistikPage extends StatefulWidget {
  final AppUser user;
  const StatistikPage({super.key, required this.user});

  @override
  State<StatistikPage> createState() => _StatistikPageState();
}

class _StatistikPageState extends State<StatistikPage> {
  // ─── DATA DUMMY ──────────────────────────────────────────────
  final Map<String, dynamic> _statistik = {
    'totalQuiz': 25,
    'quizSelesai': 22,
    'rataNilai': 91,
    'progress': 0.88,
    'mataPelajaran': [
      {'nama': 'Matematika', 'nilai': 95},
      {'nama': 'IPA', 'nilai': 90},
      {'nama': 'B. Indo', 'nilai': 89},
      {'nama': 'B. Inggris', 'nilai': 92},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0D9488)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '📊 Statistik',
          style: TextStyle(
            color: Color(0xFF0D9488),
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── 1. STATISTIK UTAMA ────────────────────────────
              Row(
                children: [
                  _StatCard(
                    icon: Icons.quiz_outlined,
                    label: 'Total Quiz',
                    value: '${_statistik['totalQuiz']}',
                    color: const Color(0xFF0D9488),
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    icon: Icons.check_circle_outlined,
                    label: 'Quiz Selesai',
                    value: '${_statistik['quizSelesai']}',
                    color: const Color(0xFF059669),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _StatCard(
                    icon: Icons.trending_up_rounded,
                    label: 'Rata-rata Nilai',
                    value: '${_statistik['rataNilai']}',
                    color: const Color(0xFF8B5CF6),
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    icon: Icons.emoji_events_outlined,
                    label: 'Tertinggi',
                    value: '100',
                    color: const Color(0xFFF59E0B),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ─── 2. PROGRESS BAR ──────────────────────────────
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Progress Belajar',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF064E3B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: LinearProgressIndicator(
                              value: _statistik['progress'],
                              backgroundColor: Colors.grey.shade200,
                              valueColor: const AlwaysStoppedAnimation(
                                Color(0xFF0D9488),
                              ),
                              minHeight: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${(_statistik['progress'] * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0D9488),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_statistik['quizSelesai']} dari ${_statistik['totalQuiz']} quiz selesai',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ─── 3. MATA PELAJARAN ────────────────────────────
              const Text(
                'Mata Pelajaran',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF064E3B),
                ),
              ),
              const SizedBox(height: 12),
              ...(_statistik['mataPelajaran'] as List).map((item) {
                return _MataPelajaranCard(
                  nama: item['nama'],
                  nilai: item['nilai'],
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── WIDGET STAT CARD ──────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: color,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── WIDGET MATA PELAJARAN CARD ────────────────────────────
class _MataPelajaranCard extends StatelessWidget {
  final String nama;
  final int nilai;

  const _MataPelajaranCard({
    required this.nama,
    required this.nilai,
  });

  Color get _nilaiColor {
    if (nilai >= 90) return const Color(0xFF059669);
    if (nilai >= 75) return const Color(0xFF0D9488);
    if (nilai >= 60) return const Color(0xFFF59E0B);
    return const Color(0xFFDC2626);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 30,
            decoration: BoxDecoration(
              color: _nilaiColor,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              nama,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF064E3B),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _nilaiColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$nilai',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: _nilaiColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
