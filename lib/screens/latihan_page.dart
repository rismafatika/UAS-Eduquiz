import 'package:flutter/material.dart';
import '../models/app_user.dart';

class LatihanPage extends StatefulWidget {
  final AppUser user;
  const LatihanPage({super.key, required this.user});

  @override
  State<LatihanPage> createState() => _LatihanPageState();
}

class _LatihanPageState extends State<LatihanPage> {
  // ─── DATA DUMMY ──────────────────────────────────────────────
  // Data kategori
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Matematika', 'icon': '🟣', 'color': const Color(0xFF8B5CF6)},
    {'name': 'IPA', 'icon': '🔵', 'color': const Color(0xFF0EA5E9)},
    {
      'name': 'Bahasa Indonesia',
      'icon': '🟢',
      'color': const Color(0xFF059669)
    },
    {'name': 'Bahasa Inggris', 'icon': '🟠', 'color': const Color(0xFFF59E0B)},
  ];

  // Data latihan soal (untuk daftar di bawah)
  final List<Map<String, dynamic>> _latihan = [
    {
      'title': 'Matematika',
      'total': 120,
      'progress': 0.7,
      'color': const Color(0xFF8B5CF6),
      'status': 'Lanjutkan',
    },
    {
      'title': 'IPA',
      'total': 80,
      'progress': 0.45,
      'color': const Color(0xFF0EA5E9),
      'status': 'Lanjutkan',
    },
    {
      'title': 'Bahasa Inggris',
      'total': 65,
      'progress': 1.0,
      'color': const Color(0xFFF59E0B),
      'status': 'Selesai',
    },
  ];

  // ─── DATA LATIHAN TERBARU (TAMBAHAN) ────────────────────────
  final List<Map<String, dynamic>> _recentLatihan = [
    {'title': 'Persamaan Linear', 'completed': true},
    {'title': 'Sistem Persamaan', 'completed': true},
    {'title': 'Kalimat Efektif', 'completed': true},
    {'title': 'Gerak Lurus', 'completed': false},
  ];

  int _selectedCategoryIndex = 0;

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
          '📚 Latihan Soal',
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
              // ─── 1. KATEGORI ──────────────────────────────────
              const Text(
                'Kategori',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF064E3B),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = _selectedCategoryIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedCategoryIndex = index);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? cat['color'] : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? cat['color']
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: cat['color'].withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                        ),
                        child: Row(
                          children: [
                            Text(
                              cat['icon'],
                              style: const TextStyle(fontSize: 22),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              cat['name'],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? Colors.white : cat['color'],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // ─── 2. DAFTAR LATIHAN SOAL ──────────────────────
              const Text(
                'Daftar Latihan',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF064E3B),
                ),
              ),
              const SizedBox(height: 12),
              ..._latihan.map((item) => _LatihanCard(
                    data: item,
                    onTap: () {
                      // Aksi ketika tombol ditekan
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Mulai latihan ${item['title']}'),
                          backgroundColor: item['color'],
                        ),
                      );
                    },
                  )),

              // ─── 3. LATIHAN TERBARU (TAMBAHAN) ──────────────
              const SizedBox(height: 24),
              const Text(
                'Latihan Terbaru',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF064E3B),
                ),
              ),
              const SizedBox(height: 12),
              ..._recentLatihan.map((item) => _RecentLatihanTile(item: item)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── WIDGET KARTU LATIHAN ──────────────────────────────────
class _LatihanCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;

  const _LatihanCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final progress = data['progress'] as double;
    final isCompleted = progress >= 1.0;
    final statusText = data['status'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
        border: Border.all(
          color: data['color'].withOpacity(0.15),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: data['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    data['title'][0],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: data['color'],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF064E3B),
                      ),
                    ),
                    Text(
                      '${data['total']} Soal',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              // Tombol status
              ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isCompleted ? const Color(0xFF059669) : data['color'],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 0,
                ),
                child: Text(
                  statusText,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress ${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  if (isCompleted)
                    const Icon(Icons.check_circle_rounded,
                        color: Color(0xFF059669), size: 16),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: data['color'].withOpacity(0.15),
                  valueColor: AlwaysStoppedAnimation(data['color']),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── WIDGET LATIHAN TERBARU ──────────────────────────────────
class _RecentLatihanTile extends StatelessWidget {
  final Map<String, dynamic> item;

  const _RecentLatihanTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final isCompleted = item['completed'] as bool;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle_rounded : Icons.pending_rounded,
            color:
                isCompleted ? const Color(0xFF059669) : const Color(0xFFF59E0B),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item['title'],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isCompleted
                    ? const Color(0xFF064E3B)
                    : const Color(0xFF6B7280),
              ),
            ),
          ),
          if (isCompleted)
            const Text(
              'Selesai',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF059669),
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}
