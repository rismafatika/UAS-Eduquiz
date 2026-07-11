import 'package:flutter/material.dart';
import '../models/app_user.dart';
import 'join_room_page.dart';

class QuizRealtimePage extends StatefulWidget {
  final AppUser user;
  const QuizRealtimePage({super.key, required this.user});

  @override
  State<QuizRealtimePage> createState() => _QuizRealtimePageState();
}

class _QuizRealtimePageState extends State<QuizRealtimePage> {
  // Data dummy (nanti ganti dengan data dari Supabase)
  bool _isRoomActive = false; // true jika ada room aktif
  String _lastRoomCode = 'EDU-2345'; // kode room terakhir

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
          '⚡ Quiz Real-Time',
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── STATUS ROOM ──────────────────────────────────
              const Text(
                'Status Room',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF064E3B),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      _isRoomActive
                          ? Icons.circle_rounded
                          : Icons.circle_outlined,
                      color: _isRoomActive
                          ? const Color(0xFF059669)
                          : const Color(0xFFDC2626),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _isRoomActive
                          ? '🟢 Sedang berlangsung'
                          : '🔴 Belum ada room aktif',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _isRoomActive
                            ? const Color(0xFF059669)
                            : const Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ─── KODE ROOM TERAKHIR ─────────────────────────
              const Text(
                'Kode Room Terakhir',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF064E3B),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.key_rounded,
                        color: Color(0xFF0D9488), size: 24),
                    const SizedBox(width: 12),
                    Text(
                      _lastRoomCode,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF064E3B),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ─── TOMBOL GABUNG ────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _isRoomActive
                      ? () {
                          // Navigasi ke halaman gabung room
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  JoinRoomPage(user: widget.user),
                            ),
                          );
                        }
                      : null, // disabled jika tidak ada room aktif
                  icon: const Icon(Icons.login_rounded, color: Colors.white),
                  label: const Text(
                    'Gabung Sekarang',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRoomActive
                        ? const Color(0xFF0D9488)
                        : Colors.grey.shade400,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                    shadowColor: _isRoomActive
                        ? const Color(0xFF0D9488).withOpacity(0.3)
                        : Colors.transparent,
                  ),
                ),
              ),

              if (!_isRoomActive) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Color(0xFF6B7280), size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Belum ada room aktif. Tunggu guru membuat room.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
