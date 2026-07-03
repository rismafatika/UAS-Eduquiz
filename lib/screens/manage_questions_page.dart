import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/quiz_question.dart';
import '../models/quiz_room.dart';
import '../services/room_service.dart';
import '../widgets/app_panel.dart';
import '../widgets/room_header.dart';
import '../widgets/section_title.dart';

class ManageQuestionsPage extends StatefulWidget {
  const ManageQuestionsPage({super.key, required this.user, required this.room});

  final AppUser user;
  final QuizRoom room;

  @override
  State<ManageQuestionsPage> createState() => _ManageQuestionsPageState();
}

class _ManageQuestionsPageState extends State<ManageQuestionsPage> {
  void _openQuestionForm({int? index}) async {
    final existing = index == null ? null : widget.room.questions[index];
    final question = await showDialog<QuizQuestion>(
      context: context,
      builder: (_) => _QuestionFormDialog(question: existing),
    );
    if (question == null) return;

    setState(() {
      if (index == null) {
        RoomService.instance.addQuestion(room: widget.room, question: question);
      } else {
        RoomService.instance.updateQuestion(
          room: widget.room,
          index: index,
          question: question,
        );
      }
    });
  }

  void _deleteQuestion(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus soal?'),
        content: const Text('Soal akan dihapus dari quiz aktif dan skor peserta akan dihitung ulang.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    setState(() => RoomService.instance.deleteQuestion(room: widget.room, index: index));
  }

  @override
  Widget build(BuildContext context) {
    final totalPoints = widget.room.questions.fold<int>(0, (sum, question) => sum + question.points);

    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Soal')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RoomHeader(room: widget.room),
                  const SizedBox(height: 16),
                  AppPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: SectionTitle(
                                icon: Icons.edit_note_outlined,
                                title: 'Kelola Soal',
                              ),
                            ),
                            FilledButton.icon(
                              onPressed: _openQuestionForm,
                              icon: const Icon(Icons.add),
                              label: const Text('Tambah Soal'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.room.questions.length} soal - $totalPoints poin dasar',
                          style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 14),
                        for (var i = 0; i < widget.room.questions.length; i++)
                          _QuestionRow(
                            number: i + 1,
                            question: widget.room.questions[i],
                            onEdit: () => _openQuestionForm(index: i),
                            onDelete: widget.room.questions.length == 1 ? null : () => _deleteQuestion(i),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuestionRow extends StatelessWidget {
  const _QuestionRow({
    required this.number,
    required this.question,
    required this.onEdit,
    required this.onDelete,
  });

  final int number;
  final QuizQuestion question;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: question.color.withOpacity(0.12),
            foregroundColor: question.color,
            child: Text('$number', style: const TextStyle(fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(label: Text(question.category)),
                    Chip(label: Text('${question.points} poin')),
                  ],
                ),
                const SizedBox(height: 8),
                Text(question.question, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text(
                  'Jawaban benar: ${question.options[question.correctIndex]}',
                  style: const TextStyle(color: Color(0xFF166534), fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Edit soal',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Hapus soal',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}

class _QuestionFormDialog extends StatefulWidget {
  const _QuestionFormDialog({this.question});

  final QuizQuestion? question;

  @override
  State<_QuestionFormDialog> createState() => _QuestionFormDialogState();
}

class _QuestionFormDialogState extends State<_QuestionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _questionController;
  late final TextEditingController _categoryController;
  late final TextEditingController _pointsController;
  late final TextEditingController _explanationController;
  late final List<TextEditingController> _optionControllers;
  late int _correctIndex;
  late Color _selectedColor;

  static const _colors = [
    Color(0xFF7C3AED),
    Color(0xFF0EA5E9),
    Color(0xFFF97316),
    Color(0xFF10B981),
    Color(0xFF2563EB),
    Color(0xFFDB2777),
  ];

  @override
  void initState() {
    super.initState();
    final question = widget.question;
    _questionController = TextEditingController(text: question?.question ?? '');
    _categoryController = TextEditingController(text: question?.category ?? 'Umum');
    _pointsController = TextEditingController(text: '${question?.points ?? 100}');
    _explanationController = TextEditingController(text: question?.explanation ?? '');
    final options = question?.options ?? const ['', '', '', ''];
    _optionControllers = List.generate(4, (index) => TextEditingController(text: index < options.length ? options[index] : ''));
    _correctIndex = question?.correctIndex ?? 0;
    _selectedColor = question?.color ?? _colors.first;
  }

  @override
  void dispose() {
    _questionController.dispose();
    _categoryController.dispose();
    _pointsController.dispose();
    _explanationController.dispose();
    for (final controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final points = int.tryParse(_pointsController.text.trim()) ?? 100;
    Navigator.pop(
      context,
      QuizQuestion(
        question: _questionController.text.trim(),
        options: _optionControllers.map((controller) => controller.text.trim()).toList(),
        correctIndex: _correctIndex,
        explanation: _explanationController.text.trim(),
        category: _categoryController.text.trim(),
        points: points,
        color: _selectedColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.question == null ? 'Tambah Soal' : 'Edit Soal'),
      content: SizedBox(
        width: 620,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _questionController,
                  decoration: const InputDecoration(labelText: 'Pertanyaan'),
                  maxLines: 3,
                  validator: _required,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _categoryController,
                        decoration: const InputDecoration(labelText: 'Kategori'),
                        validator: _required,
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 140,
                      child: TextFormField(
                        controller: _pointsController,
                        decoration: const InputDecoration(labelText: 'Poin'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          final points = int.tryParse(value?.trim() ?? '');
                          if (points == null || points <= 0) return 'Poin tidak valid';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                for (var i = 0; i < _optionControllers.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Radio<int>(
                          value: i,
                          groupValue: _correctIndex,
                          onChanged: (value) => setState(() => _correctIndex = value ?? 0),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _optionControllers[i],
                            decoration: InputDecoration(labelText: 'Pilihan ${String.fromCharCode(65 + i)}'),
                            validator: _required,
                          ),
                        ),
                      ],
                    ),
                  ),
                TextFormField(
                  controller: _explanationController,
                  decoration: const InputDecoration(labelText: 'Pembahasan'),
                  maxLines: 3,
                  validator: _required,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8,
                    children: [
                      for (final color in _colors)
                        ChoiceChip(
                          label: const SizedBox(width: 18, height: 18),
                          selected: _selectedColor.value == color.value,
                          selectedColor: color.withOpacity(0.18),
                          avatar: CircleAvatar(backgroundColor: color),
                          onSelected: (_) => setState(() => _selectedColor = color),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Simpan'),
        ),
      ],
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Wajib diisi';
    return null;
  }
}
