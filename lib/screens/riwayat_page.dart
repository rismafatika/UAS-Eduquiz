import 'package:flutter/material.dart';
import '../models/app_user.dart';

class RiwayatPage extends StatefulWidget {
  final AppUser user;
  const RiwayatPage({super.key, required this.user});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  // ─── DATA DUMMY ──────────────────────────────────────────────
  final List<Map<String, dynamic>> _riwayat = [
    {
      'title': 'Matematika Bab 4',
      'score': 95,
      'bintang': 5,
      'tanggal': DateTime(2026, 6, 15),
    },
    {
      'title': 'Bahasa Inggris',
      'score': 88,
      'bintang': 4,
      'tanggal': DateTime(2026, 6, 13),
    },
    {
      'title': 'IPA',
      'score': 100,
      'bintang': 5,
      'tanggal': DateTime(2026, 6, 11),
    },
    {
      'title': 'Matematika Bab 3',
      'score': 70,
      'bintang': 3,
      'tanggal': DateTime(2026, 6, 8),
    },
    {
      'title': 'Bahasa Indonesia',
      'score': 85,
      'bintang': 4,
      'tanggal': DateTime(2026, 6, 5),
    },
  ];

  // ─── FILTER (menggunakan indeks, bukan enum) ──────────────
  int _filterIndex = 0; // 0=Semua, 1=Minggu Ini, 2=Bulan Ini
  final List<String> _filterLabels = ['Semua', 'Minggu Ini', 'Bulan Ini'];

  List<Map<String, dynamic>> get _filteredRiwayat {
    final now = DateTime.now();
    return _riwayat.where((item) {
      final tgl = item['tanggal'] as DateTime;
      switch (_filterIndex) {
        case 1: // Minggu Ini
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          return tgl.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
              tgl.isBefore(now.add(const Duration(days: 1)));
        case 2: // Bulan Ini
          return tgl.year == now.year && tgl.month == now.month;
        default:
          return true;
      }
    }).toList();
  }

  // ─── HELPER ──────────────────────────────────────────────────
  Color _getScoreColor(int score) {
    if (score >= 90) return const Color(0xFF059669);
    if (score >= 75) return const Color(0xFF0D9488);
    if (score >= 60) return const Color(0xFFF59E0B);
    return const Color(0xFFDC2626);
  }

  String _monthName(int month) {
    const months = [
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
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredRiwayat;

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
          '📜 Riwayat Quiz',
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
        child: Column(
          children: [
            // ─── HEADER ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quiz Terakhir',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF064E3B),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ─── FILTER (ChoiceChip bawaan Flutter) ──────
                  Wrap(
                    spacing: 8,
                    children: List.generate(_filterLabels.length, (index) {
                      return ChoiceChip(
                        label: Text(_filterLabels[index]),
                        selected: _filterIndex == index,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _filterIndex = index);
                          }
                        },
                        selectedColor: const Color(0xFF0D9488),
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: _filterIndex == index
                              ? Colors.white
                              : const Color(0xFF6B7280),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                        side: BorderSide(
                          color: _filterIndex == index
                              ? const Color(0xFF0D9488)
                              : Colors.grey.shade300,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ─── DAFTAR RIWAYAT ─────────────────────────────────
            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history_edu_outlined,
                              size: 64, color: Color(0xFF6B7280)),
                          SizedBox(height: 12),
                          Text(
                            'Belum ada riwayat untuk filter ini',
                            style: TextStyle(
                                fontSize: 16, color: Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return _RiwayatCard(
                          title: item['title'],
                          score: item['score'],
                          bintang: item['bintang'],
                          tanggal: item['tanggal'],
                          scoreColor: _getScoreColor(item['score']),
                          monthName: _monthName,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── WIDGET KARTU RIWAYAT ──────────────────────────────────
class _RiwayatCard extends StatelessWidget {
  final String title;
  final int score;
  final int bintang;
  final DateTime tanggal;
  final Color scoreColor;
  final String Function(int) monthName;

  const _RiwayatCard({
    required this.title,
    required this.score,
    required this.bintang,
    required this.tanggal,
    required this.scoreColor,
    required this.monthName,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        '${tanggal.day} ${monthName(tanggal.month)} ${tanggal.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF064E3B),
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: scoreColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: scoreColor.withOpacity(0.3)),
                ),
                child: Text(
                  '$score',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: scoreColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              ...List.generate(5, (index) {
                final isFilled = index < bintang;
                return Icon(
                  isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                  color:
                      isFilled ? const Color(0xFFF59E0B) : Colors.grey.shade300,
                  size: 20,
                );
              }),
              const Spacer(),
              Text(
                formattedDate,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
