import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../models/participant.dart';
import '../models/quiz_room.dart';
import 'review_page.dart';

class RekapNilaiPage extends StatefulWidget {
  const RekapNilaiPage({super.key, required this.user, required this.room});
  final AppUser user;
  final QuizRoom room;

  @override
  State<RekapNilaiPage> createState() => _RekapNilaiPageState();
}

class _RekapNilaiPageState extends State<RekapNilaiPage> {
  String _searchQuery = '';

  List<Participant> get _sortedParticipants {
    // Hanya peserta yang sudah menjawab semua soal
    final list = widget.room.participants
        .where((p) => p.answers.length == widget.room.questions.length)
        .toList();
    list.sort((a, b) => b.score.compareTo(a.score));
    if (_searchQuery.isNotEmpty) {
      return list
          .where(
              (p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    return list;
  }

  double get _average {
    final list = _sortedParticipants;
    if (list.isEmpty) return 0;
    final total = list.fold(0, (sum, p) => sum + p.score);
    return total / list.length;
  }

  int get _highest {
    final list = _sortedParticipants;
    if (list.isEmpty) return 0;
    return list.map((p) => p.score).reduce((a, b) => a > b ? a : b);
  }

  int get _lowest {
    final list = _sortedParticipants;
    if (list.isEmpty) return 0;
    return list.map((p) => p.score).reduce((a, b) => a < b ? a : b);
  }

  Map<String, int> _countCorrectWrong(Participant p) {
    int correct = 0;
    for (int i = 0; i < widget.room.questions.length; i++) {
      final answer = p.answers[i];
      if (answer != null && answer == widget.room.questions[i].correctIndex) {
        correct++;
      }
    }
    final wrong = widget.room.questions.length - correct;
    return {'correct': correct, 'wrong': wrong};
  }

  void _showParticipantDetail(Participant p) {
    final stats = _countCorrectWrong(p);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              p.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              'Quiz: ${widget.room.title}',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _infoTile('Nilai', '${p.score}'),
                const SizedBox(width: 12),
                _infoTile('Benar', '${stats['correct']}'),
                const SizedBox(width: 12),
                _infoTile('Salah', '${stats['wrong']}'),
                const SizedBox(width: 12),
                _infoTile('Durasi', '12 menit'), // dummy
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReviewPage(
                        user: widget.user,
                        room: widget.room,
                        targetParticipant: p,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('Lihat Jawaban'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          Text(label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  void _exportExcel() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur Export Excel akan segera hadir')),
    );
  }

  void _exportPDF() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur Export PDF akan segera hadir')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final participants = _sortedParticipants;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('📊 Rekap Nilai'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF0D9488),
        actions: [
          IconButton(
            onPressed: _exportExcel,
            icon: const Icon(Icons.upload_file_rounded),
            tooltip: 'Export Excel',
          ),
          IconButton(
            onPressed: _exportPDF,
            icon: const Icon(Icons.picture_as_pdf_rounded),
            tooltip: 'Export PDF',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari Peserta....',
                prefixIcon:
                    const Icon(Icons.search_rounded, color: Color(0xFF0D9488)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child: participants.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada peserta yang menyelesaikan kuis',
                      style: TextStyle(color: Color(0xFF94A3B8)),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: participants.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final p = participants[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 4),
                        leading: CircleAvatar(
                          backgroundColor:
                              const Color(0xFF0D9488).withOpacity(0.1),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(color: Color(0xFF0D9488)),
                          ),
                        ),
                        title: Text(
                          p.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        trailing: Text(
                          '${p.score}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0D9488),
                          ),
                        ),
                        onTap: () => _showParticipantDetail(p),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statItem('Rata-rata', '${_average.toStringAsFixed(0)}'),
                _statItem('Nilai Tertinggi', '$_highest'),
                _statItem('Nilai Terendah', '$_lowest'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0D9488),
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
