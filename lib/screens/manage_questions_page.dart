import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/app_user.dart';
import '../models/quiz_question.dart';
import '../models/quiz_room.dart';
import '../services/room_service.dart';

class ManageQuestionsPage extends StatefulWidget {
  final AppUser user;
  const ManageQuestionsPage({super.key, required this.user});

  @override
  State<ManageQuestionsPage> createState() => _ManageQuestionsPageState();
}

class _ManageQuestionsPageState extends State<ManageQuestionsPage> {
  List<QuizQuestion> _questions = [];
  List<QuizQuestion> _filteredQuestions = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  // Untuk form tambah/edit
  bool _isEditing = false;
  int? _editingIndex;
  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers =
      List.generate(4, (_) => TextEditingController());
  int _selectedCorrectIndex = 0;
  final TextEditingController _scoreController =
      TextEditingController(text: '5');
  final TextEditingController _subjectController = TextEditingController();

  QuizRoom? _currentRoom;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);
    // Ambil semua room, lalu ambil soal dari room terakhir (atau gabungkan)
    final rooms = RoomService.instance.getAllRooms();
    if (rooms.isNotEmpty) {
      _currentRoom = rooms.last;
      _questions = List.from(_currentRoom!.questions);
    } else {
      // Jika belum ada room, buat room dummy untuk menyimpan soal? Atau ambil dari sample?
      // Lebih baik buat room baru dengan judul "Bank Soal"
      final room = await RoomService.instance.createRoom(
        title: 'Bank Soal',
        hostName: widget.user.name,
      );
      _currentRoom = room;
      _questions = List.from(room.questions);
    }
    _filteredQuestions = List.from(_questions);
    setState(() => _isLoading = false);
  }

  void _filterQuestions(String keyword) {
    if (keyword.isEmpty) {
      setState(() => _filteredQuestions = List.from(_questions));
    } else {
      setState(() {
        _filteredQuestions = _questions
            .where((q) =>
                q.question.toLowerCase().contains(keyword.toLowerCase()) ||
                (q.category?.toLowerCase().contains(keyword.toLowerCase()) ??
                    false))
            .toList();
      });
    }
  }

  // ─── TAMBAH / EDIT ────────────────────────────────────────
  void _openForm({int? index}) {
    _isEditing = index != null;
    _editingIndex = index;
    if (index != null) {
      final q = _questions[index];
      _questionController.text = q.question;
      for (int i = 0; i < 4; i++) {
        _optionControllers[i].text = q.options[i];
      }
      _selectedCorrectIndex = q.correctIndex;
      _scoreController.text = (q.points ?? 5).toString();
      _subjectController.text = q.category ?? '';
    } else {
      _questionController.clear();
      for (var c in _optionControllers) c.clear();
      _selectedCorrectIndex = 0;
      _scoreController.text = '5';
      _subjectController.clear();
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isEditing ? 'Edit Soal' : 'Tambah Soal',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _questionController,
                decoration: const InputDecoration(
                  labelText: 'Pertanyaan',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Mata Pelajaran',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.book),
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(
                  4,
                  (i) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TextField(
                          controller: _optionControllers[i],
                          decoration: InputDecoration(
                            labelText: 'Pilihan ${String.fromCharCode(65 + i)}',
                            border: const OutlineInputBorder(),
                            prefixIcon: Text('${String.fromCharCode(65 + i)}.',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      )),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedCorrectIndex,
                      decoration: const InputDecoration(
                        labelText: 'Jawaban Benar',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(
                          4,
                          (i) => DropdownMenuItem(
                                value: i,
                                child: Text('${String.fromCharCode(65 + i)}'),
                              )),
                      onChanged: (val) =>
                          setState(() => _selectedCorrectIndex = val!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _scoreController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Bobot Nilai',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.star),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(_isEditing ? 'Update Soal' : 'Simpan Soal'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveQuestion() async {
    if (_questionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Pertanyaan tidak boleh kosong'),
            backgroundColor: Colors.red),
      );
      return;
    }
    for (var c in _optionControllers) {
      if (c.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Semua pilihan harus diisi'),
              backgroundColor: Colors.red),
        );
        return;
      }
    }
    final question = QuizQuestion(
      id: _isEditing
          ? _questions[_editingIndex!].id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      question: _questionController.text,
      options: _optionControllers.map((c) => c.text).toList(),
      correctIndex: _selectedCorrectIndex,
      points: int.tryParse(_scoreController.text) ?? 5,
      category:
          _subjectController.text.isNotEmpty ? _subjectController.text : null,
    );

    if (_currentRoom == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Tidak ada room aktif'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_isEditing) {
      // Update
      await RoomService.instance
          .updateQuestion(_currentRoom!, _editingIndex!, question);
      _questions[_editingIndex!] = question;
    } else {
      // Tambah
      await RoomService.instance.addQuestion(_currentRoom!, question);
      _questions.add(question);
    }
    _filteredQuestions = List.from(_questions);
    setState(() {});
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(_isEditing ? 'Soal diperbarui' : 'Soal ditambahkan'),
          backgroundColor: Colors.green),
    );
  }

  Future<void> _deleteQuestion(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Soal'),
        content: const Text('Yakin ingin menghapus soal ini?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true && _currentRoom != null) {
      await RoomService.instance.removeQuestion(_currentRoom!, index);
      _questions.removeAt(index);
      _filteredQuestions = List.from(_questions);
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Soal dihapus'), backgroundColor: Colors.red),
      );
    }
  }

  // ─── IMPORT / EXPORT ──────────────────────────────────────
  void _importExcel() {
    // Placeholder: nanti bisa implementasi dengan file_picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur Import Excel (coming soon)')),
    );
  }

  void _exportExcel() {
    // Placeholder
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur Export Excel (coming soon)')),
    );
  }

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
            onPressed: _importExcel,
            icon: const Icon(Icons.upload_file),
            tooltip: 'Import Excel',
          ),
          IconButton(
            onPressed: _exportExcel,
            icon: const Icon(Icons.download),
            tooltip: 'Export Excel',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ─── PENCARIAN ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterQuestions,
                      decoration: InputDecoration(
                        hintText: 'Cari soal....',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => _openForm(index: null),
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Soal'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ─── DAFTAR SOAL ──────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredQuestions.isEmpty
                      ? const Center(
                          child: Text('Belum ada soal',
                              style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredQuestions.length,
                          itemBuilder: (context, index) {
                            final q = _filteredQuestions[index];
                            // Cari indeks asli di _questions untuk operasi edit/hapus
                            final realIndex = _questions.indexOf(q);
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0D9488)
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            q.category ?? 'Umum',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF0D9488),
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        IconButton(
                                          onPressed: () =>
                                              _openForm(index: realIndex),
                                          icon: const Icon(Icons.edit,
                                              color: Colors.blue),
                                          tooltip: 'Edit',
                                        ),
                                        IconButton(
                                          onPressed: () =>
                                              _deleteQuestion(realIndex),
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          tooltip: 'Hapus',
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      q.question,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 8,
                                      children:
                                          q.options.asMap().entries.map((e) {
                                        final isCorrect =
                                            e.key == q.correctIndex;
                                        return Chip(
                                          label: Text(
                                              '${String.fromCharCode(65 + e.key)}. ${e.value}'),
                                          backgroundColor: isCorrect
                                              ? Colors.green.shade100
                                              : Colors.grey.shade100,
                                          labelStyle: TextStyle(
                                            color: isCorrect
                                                ? Colors.green.shade800
                                                : Colors.grey.shade800,
                                            fontWeight: isCorrect
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                          avatar: isCorrect
                                              ? const Icon(Icons.check_circle,
                                                  size: 16, color: Colors.green)
                                              : null,
                                        );
                                      }).toList(),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Bobot: ${q.points ?? 5}',
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
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
