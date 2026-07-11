import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../models/quiz_question.dart';
import '../models/quiz_room.dart';
import '../services/room_service.dart';

class KelolaSoalPage extends StatefulWidget {
  final AppUser user;
  final QuizRoom room;

  const KelolaSoalPage({super.key, required this.user, required this.room});

  @override
  State<KelolaSoalPage> createState() => _KelolaSoalPageState();
}

class _KelolaSoalPageState extends State<KelolaSoalPage> {
  // ─── State ──────────────────────────────────────────────
  List<QuizQuestion> _questions = [];
  String _searchQuery = '';
  bool _isLoading = true;

  // ─── Inisialisasi ────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);
    // PERBAIKAN 1: tambahkan await
    final room = await RoomService.instance.findRoomConnected(widget.room.code);
    if (room != null) {
      setState(() {
        _questions = List.from(room.questions);
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  // ─── Group soal berdasarkan kategori ────────────────────
  Map<String, List<QuizQuestion>> get _groupedQuestions {
    final map = <String, List<QuizQuestion>>{};
    for (var q in _questions) {
      final cat = q.category ?? 'Umum'; // Ganti subject → category
      map.putIfAbsent(cat, () => []).add(q);
    }
    return map;
  }

  List<String> get _categories =>
      _groupedQuestions.keys.toList()..sort(); // ganti nama

  // ─── Filter berdasarkan pencarian ────────────────────────
  List<QuizQuestion> get _filteredQuestions {
    if (_searchQuery.isEmpty) return _questions;
    return _questions
        .where((q) =>
                q.question.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                (q.category
                        ?.toLowerCase()
                        .contains(_searchQuery.toLowerCase()) ??
                    false) // Ganti subject → category
            )
        .toList();
  }

  // ─── Tambah / Edit Soal ──────────────────────────────────
  void _openQuestionForm({QuizQuestion? existingQuestion}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _QuestionFormSheet(
        user: widget.user,
        room: widget.room,
        existingQuestion: existingQuestion,
        onSaved: _loadQuestions,
      ),
    );
  }

  // ─── Hapus Soal ──────────────────────────────────────────
  Future<void> _deleteQuestion(QuizQuestion question) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Soal'),
        content: Text('Yakin ingin menghapus soal "${question.question}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final index = _questions.indexOf(question);
    await RoomService.instance.removeQuestion(widget.room, index);
    _loadQuestions();
  }

  // ─── Import / Export ──────────────────────────────────────
  void _importExcel() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur Import Excel akan segera hadir')),
    );
  }

  void _exportExcel() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur Export Excel akan segera hadir')),
    );
  }

  // ─── Build UI ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Kelola Soal'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF0D9488),
        actions: [
          IconButton(
            onPressed: _loadQuestions,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndAdd(),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _questions.isEmpty
                    ? _buildEmptyState()
                    : _buildQuestionList(),
          ),
          _buildImportExportButtons(),
        ],
      ),
    );
  }

  // ─── Search & Add ──────────────────────────────────────
  Widget _buildSearchAndAdd() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari soal....',
                prefixIcon:
                    const Icon(Icons.search_rounded, color: Color(0xFF0D9488)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () => _openQuestionForm(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('Tambah Soal'),
          ),
        ],
      ),
    );
  }

  // ─── Empty State ────────────────────────────────────────
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.quiz_outlined, size: 64, color: Color(0xFF94A3B8)),
          SizedBox(height: 12),
          Text(
            'Belum ada soal',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF334155)),
          ),
          SizedBox(height: 4),
          Text(
            'Klik "Tambah Soal" untuk mulai membuat bank soal',
            style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  // ─── Daftar Soal per Kategori ──────────────────────────
  Widget _buildQuestionList() {
    final filtered = _filteredQuestions;
    if (filtered.isEmpty && _searchQuery.isNotEmpty) {
      return const Center(
        child: Text('Tidak ada soal yang cocok',
            style: TextStyle(color: Color(0xFF94A3B8))),
      );
    }

    final Map<String, List<QuizQuestion>> grouped = {};
    for (var q in filtered) {
      final cat = q.category ?? 'Umum'; // Ganti subject → category
      grouped.putIfAbsent(cat, () => []).add(q);
    }
    final categories = grouped.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final questions = grouped[category]!;
        return _CategoryCard(
          // Ganti nama widget
          category: category,
          questionCount: questions.length,
          onEdit: () => _openQuestionForm(existingQuestion: questions.first),
          onDelete: () => _deleteQuestion(questions.first),
        );
      },
    );
  }

  // ─── Import / Export ─────────────────────────────────────
  Widget _buildImportExportButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _importExcel,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0D9488),
                side: const BorderSide(color: Color(0xFF0D9488)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.upload_file_rounded),
              label: const Text('Import Excel'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _exportExcel,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0D9488),
                side: const BorderSide(color: Color(0xFF0D9488)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.download_rounded),
              label: const Text('Export Excel'),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── CARD PER KATEGORI ────────────────────────────────────
class _CategoryCard extends StatelessWidget {
  // Ganti nama dari _SubjectCard
  final String category;
  final int questionCount;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryCard({
    required this.category,
    required this.questionCount,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.book_rounded,
                  color: const Color(0xFF0D9488),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      '$questionCount Soal',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: onEdit,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF0D9488),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Edit',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 4),
                  TextButton(
                    onPressed: onDelete,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red.shade600,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Hapus',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── FORM TAMBAH / EDIT SOAL ──────────────────────────────
class _QuestionFormSheet extends StatefulWidget {
  final AppUser user;
  final QuizRoom room;
  final QuizQuestion? existingQuestion;
  final VoidCallback onSaved;

  const _QuestionFormSheet({
    required this.user,
    required this.room,
    this.existingQuestion,
    required this.onSaved,
  });

  @override
  State<_QuestionFormSheet> createState() => _QuestionFormSheetState();
}

class _QuestionFormSheetState extends State<_QuestionFormSheet> {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _optionAController = TextEditingController();
  final TextEditingController _optionBController = TextEditingController();
  final TextEditingController _optionCController = TextEditingController();
  final TextEditingController _optionDController = TextEditingController();
  final TextEditingController _weightController =
      TextEditingController(text: '5');

  String _selectedCorrect = 'A';
  bool _isLoading = false;
  final List<String> _letters = ['A', 'B', 'C', 'D'];

  @override
  void initState() {
    super.initState();
    if (widget.existingQuestion != null) {
      final q = widget.existingQuestion!;
      _questionController.text = q.question;
      if (q.options.length >= 4) {
        _optionAController.text = q.options[0];
        _optionBController.text = q.options[1];
        _optionCController.text = q.options[2];
        _optionDController.text = q.options[3];
      }
      _selectedCorrect = _letters[q.correctIndex];
      _weightController.text = '${q.points ?? 5}';
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _optionAController.dispose();
    _optionBController.dispose();
    _optionCController.dispose();
    _optionDController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_questionController.text.trim().isEmpty ||
        _optionAController.text.trim().isEmpty ||
        _optionBController.text.trim().isEmpty ||
        _optionCController.text.trim().isEmpty ||
        _optionDController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua field wajib diisi!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final question = QuizQuestion(
      id: widget.existingQuestion?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      question: _questionController.text.trim(),
      options: [
        _optionAController.text.trim(),
        _optionBController.text.trim(),
        _optionCController.text.trim(),
        _optionDController.text.trim(),
      ],
      correctIndex: _letters.indexOf(_selectedCorrect),
      points: int.tryParse(_weightController.text) ?? 5,
      category: widget.room.title, // PERBAIKAN 2: ganti subject → category
    );

    try {
      if (widget.existingQuestion != null) {
        final index = widget.room.questions.indexOf(widget.existingQuestion!);
        await RoomService.instance.updateQuestion(widget.room, index, question);
      } else {
        await RoomService.instance.addQuestion(widget.room, question);
      }
      widget.onSaved();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
            widget.existingQuestion != null ? 'Edit Soal' : 'Tambah Soal',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: _questionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Pertanyaan',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _optionAController,
                    decoration: const InputDecoration(
                      labelText: 'Pilihan A',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.looks_one_rounded),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _optionBController,
                    decoration: const InputDecoration(
                      labelText: 'Pilihan B',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.looks_two_rounded),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _optionCController,
                    decoration: const InputDecoration(
                      labelText: 'Pilihan C',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.looks_3_rounded),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _optionDController,
                    decoration: const InputDecoration(
                      labelText: 'Pilihan D',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.looks_4_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedCorrect,
                          decoration: const InputDecoration(
                            labelText: 'Jawaban Benar',
                            border: OutlineInputBorder(),
                          ),
                          items: _letters.map((letter) {
                            return DropdownMenuItem(
                                value: letter, child: Text(letter));
                          }).toList(),
                          onChanged: (value) =>
                              setState(() => _selectedCorrect = value!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _weightController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Bobot Nilai',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Simpan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal',
                        style: TextStyle(color: Colors.grey)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
