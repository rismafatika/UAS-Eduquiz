import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/participant.dart';
import '../models/quiz_question.dart';
import '../models/quiz_room.dart';
import '../services/room_service.dart';
import '../widgets/app_panel.dart';
import '../widgets/pro_page.dart';
import '../widgets/room_header.dart';
import '../widgets/section_title.dart';
import '../widgets/status_badge.dart';
import 'quiz_live_page.dart';
import 'review_page.dart';

class HostDashboardPage extends StatefulWidget {
  const HostDashboardPage({super.key, required this.user, required this.room});

  final AppUser user;
  final QuizRoom room;

  @override
  State<HostDashboardPage> createState() => _HostDashboardPageState();
}

class _HostDashboardPageState extends State<HostDashboardPage> {
  void _restartQuiz() {
    setState(() => RoomService.instance.startQuiz(widget.room));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => QuizLivePage(user: widget.user, room: widget.room)),
    );
  }

  void _openReview() {
    RoomService.instance.showReview(widget.room);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ReviewPage(user: widget.user, room: widget.room)),
    );
  }

  Future<void> _addQuestion() async {
    final question = await showDialog<QuizQuestion>(
      context: context,
      builder: (_) => const _QuestionEditorDialog(),
    );

    if (!mounted || question == null) return;
    setState(() => RoomService.instance.addQuestion(room: widget.room, question: question));
  }

  Future<void> _editQuestion(int index) async {
    final question = await showDialog<QuizQuestion>(
      context: context,
      builder: (_) => _QuestionEditorDialog(initialQuestion: widget.room.questions[index]),
    );

    if (!mounted || question == null) return;
    setState(() => RoomService.instance.updateQuestion(room: widget.room, index: index, question: question));
  }

  Future<void> _deleteQuestion(int index) async {
    if (widget.room.questions.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimal harus ada 1 soal.')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus soal?'),
        content: Text('Soal nomor ${index + 1} akan dihapus dari quiz.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;
    setState(() => RoomService.instance.deleteQuestion(room: widget.room, index: index));
  }

  @override
  Widget build(BuildContext context) {
    final totalAnswers = widget.room.participants.fold<int>(
      0,
      (sum, participant) => sum + participant.answers.length,
    );
    final maxAnswers = widget.room.participants.length * widget.room.questions.length;
    final averageScore = widget.room.participants.isEmpty
        ? 0
        : widget.room.participants.map((participant) => participant.score).reduce((a, b) => a + b) /
            widget.room.participants.length;
    final rankedParticipants = [...widget.room.participants]..sort((a, b) => b.score.compareTo(a.score));

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Admin')),
      body: ProPage(
        title: 'Dashboard Admin',
        subtitle: 'Kelola soal, pantau nilai peserta, dan kontrol jalannya sesi quiz dari satu halaman.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RoomHeader(room: widget.room),
            const SizedBox(height: 16),
            _MetricGrid(
              participantCount: widget.room.participants.length,
              questionCount: widget.room.questions.length,
              answerSummary: '$totalAnswers/$maxAnswers',
              averageScore: averageScore.toStringAsFixed(0),
            ),
            const SizedBox(height: 16),
            AppPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle(icon: Icons.tune, title: 'Kontrol Sesi'),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      FilledButton.icon(
                        onPressed: _restartQuiz,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Mulai Ulang Quiz'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _openReview,
                        icon: const Icon(Icons.rate_review_outlined),
                        label: const Text('Review Jawaban'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _addQuestion,
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('Tambah Soal'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _ScoreBoard(participants: rankedParticipants, questionCount: widget.room.questions.length),
            const SizedBox(height: 16),
            _QuestionManager(
              questions: widget.room.questions,
              onAdd: _addQuestion,
              onEdit: _editQuestion,
              onDelete: _deleteQuestion,
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({
    required this.participantCount,
    required this.questionCount,
    required this.answerSummary,
    required this.averageScore,
  });

  final int participantCount;
  final int questionCount;
  final String answerSummary;
  final String averageScore;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _MetricCard(label: 'Peserta', value: '$participantCount', icon: Icons.groups_2_outlined, color: const Color(0xFF1D4ED8)),
      _MetricCard(label: 'Soal', value: '$questionCount', icon: Icons.quiz_outlined, color: const Color(0xFF14B8A6)),
      _MetricCard(label: 'Jawaban', value: answerSummary, icon: Icons.checklist_rtl, color: const Color(0xFFF59E0B)),
      _MetricCard(label: 'Rata-rata', value: averageScore, icon: Icons.bar_chart, color: const Color(0xFF7C3AED)),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        if (compact) {
          return Column(
            children: cards.map((card) => Padding(padding: const EdgeInsets.only(bottom: 10), child: card)).toList(),
          );
        }

        return Row(
          children: cards.map((card) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 10), child: card))).toList(),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              Text(label, style: const TextStyle(color: Color(0xFF64748B))),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreBoard extends StatelessWidget {
  const _ScoreBoard({
    required this.participants,
    required this.questionCount,
  });

  final List<Participant> participants;
  final int questionCount;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(icon: Icons.leaderboard_outlined, title: 'Nilai Peserta'),
          const SizedBox(height: 12),
          if (participants.isEmpty)
            const Text('Belum ada peserta yang bergabung.')
          else
            for (var index = 0; index < participants.length; index++)
              _ScoreRow(
                rank: index + 1,
                participant: participants[index],
                questionCount: questionCount,
              ),
        ],
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({
    required this.rank,
    required this.participant,
    required this.questionCount,
  });

  final int rank;
  final Participant participant;
  final int questionCount;

  @override
  Widget build(BuildContext context) {
    final progress = questionCount == 0 ? 0.0 : participant.answers.length / questionCount;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: rank == 1 ? const Color(0xFFFFFBEB) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: rank == 1 ? const Color(0xFFFDE68A) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(width: 42, child: Text('#$rank', style: const TextStyle(fontWeight: FontWeight.w900))),
              Expanded(child: Text(participant.name, style: const TextStyle(fontWeight: FontWeight.w900))),
              StatusBadge(label: '${participant.score} poin', icon: Icons.star_outline, color: const Color(0xFFF59E0B)),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(value: progress.clamp(0.0, 1.0).toDouble()),
        ],
      ),
    );
  }
}

class _QuestionManager extends StatelessWidget {
  const _QuestionManager({
    required this.questions,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  final List<QuizQuestion> questions;
  final VoidCallback onAdd;
  final ValueChanged<int> onEdit;
  final ValueChanged<int> onDelete;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: SectionTitle(icon: Icons.quiz_outlined, title: 'Manajemen Soal')),
              IconButton.filledTonal(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                tooltip: 'Tambah soal',
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (var index = 0; index < questions.length; index++)
            _QuestionAdminCard(
              number: index + 1,
              question: questions[index],
              onEdit: () => onEdit(index),
              onDelete: () => onDelete(index),
            ),
        ],
      ),
    );
  }
}

class _QuestionAdminCard extends StatelessWidget {
  const _QuestionAdminCard({
    required this.number,
    required this.question,
    required this.onEdit,
    required this.onDelete,
  });

  final int number;
  final QuizQuestion question;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '$number. ${question.question}',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
              IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined), tooltip: 'Ubah soal'),
              IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline), tooltip: 'Hapus soal'),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var index = 0; index < question.options.length; index++)
                StatusBadge(
                  label: question.options[index],
                  icon: index == question.correctIndex ? Icons.check_circle_outline : Icons.circle_outlined,
                  color: index == question.correctIndex ? const Color(0xFF16A34A) : const Color(0xFF64748B),
                ),
            ],
          ),
          if (question.explanation.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(question.explanation, style: const TextStyle(color: Color(0xFF64748B))),
          ],
        ],
      ),
    );
  }
}

class _QuestionEditorDialog extends StatefulWidget {
  const _QuestionEditorDialog({this.initialQuestion});

  final QuizQuestion? initialQuestion;

  @override
  State<_QuestionEditorDialog> createState() => _QuestionEditorDialogState();
}

class _QuestionEditorDialogState extends State<_QuestionEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _questionController;
  late final List<TextEditingController> _optionControllers;
  late final TextEditingController _explanationController;
  late final TextEditingController _categoryController;
  late final TextEditingController _pointsController;
  late int _correctIndex;
  late int _colorValue;

  @override
  void initState() {
    super.initState();
    final question = widget.initialQuestion;
    _questionController = TextEditingController(text: question?.question ?? '');
    _optionControllers = List.generate(
      4,
      (index) => TextEditingController(text: question?.options[index] ?? ''),
    );
    _explanationController = TextEditingController(text: question?.explanation ?? '');
    _categoryController = TextEditingController(text: question?.category ?? 'Umum');
    _pointsController = TextEditingController(text: '${question?.points ?? 100}');
    _correctIndex = question?.correctIndex ?? 0;
    _colorValue = question?.color.toARGB32() ?? 0xFF1D4ED8;
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (final controller in _optionControllers) {
      controller.dispose();
    }
    _explanationController.dispose();
    _categoryController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.pop(
      context,
      QuizQuestion(
        question: _questionController.text.trim(),
        options: _optionControllers.map((controller) => controller.text.trim()).toList(),
        correctIndex: _correctIndex,
        explanation: _explanationController.text.trim(),
        category: _categoryController.text.trim(),
        points: int.tryParse(_pointsController.text.trim()) ?? 100,
        color: Color(_colorValue),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialQuestion == null ? 'Tambah Soal' : 'Ubah Soal'),
      content: SizedBox(
        width: 560,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _questionController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Pertanyaan'),
                  validator: _required,
                ),
                const SizedBox(height: 12),
                for (var index = 0; index < _optionControllers.length; index++) ...[
                  TextFormField(
                    controller: _optionControllers[index],
                    decoration: InputDecoration(labelText: 'Pilihan ${String.fromCharCode(65 + index)}'),
                    validator: _required,
                  ),
                  const SizedBox(height: 10),
                ],
                DropdownButtonFormField<int>(
                  initialValue: _correctIndex,
                  decoration: const InputDecoration(labelText: 'Jawaban benar'),
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('Pilihan A')),
                    DropdownMenuItem(value: 1, child: Text('Pilihan B')),
                    DropdownMenuItem(value: 2, child: Text('Pilihan C')),
                    DropdownMenuItem(value: 3, child: Text('Pilihan D')),
                  ],
                  onChanged: (value) => setState(() => _correctIndex = value ?? 0),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: 'Kategori'),
                  validator: _required,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _pointsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Poin'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Wajib diisi';
                    final points = int.tryParse(value.trim());
                    if (points == null || points <= 0) return 'Poin harus angka lebih dari 0';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: _colorValue,
                  decoration: const InputDecoration(labelText: 'Warna soal'),
                  items: const [
                    DropdownMenuItem(value: 0xFF1D4ED8, child: Text('Biru')),
                    DropdownMenuItem(value: 0xFF14B8A6, child: Text('Toska')),
                    DropdownMenuItem(value: 0xFFF59E0B, child: Text('Kuning')),
                    DropdownMenuItem(value: 0xFF7C3AED, child: Text('Ungu')),
                    DropdownMenuItem(value: 0xFF16A34A, child: Text('Hijau')),
                  ],
                  onChanged: (value) => setState(() => _colorValue = value ?? 0xFF1D4ED8),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _explanationController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Pembahasan'),
                  validator: _required,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        FilledButton.icon(onPressed: _save, icon: const Icon(Icons.save_outlined), label: const Text('Simpan')),
      ],
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Wajib diisi';
    }
    return null;
  }
}
