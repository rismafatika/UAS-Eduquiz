import '../models/quiz_question.dart';

const sampleQuestions = [
  QuizQuestion(
    question: 'Apa fungsi utama room code pada EduQuiz?',
    options: [
      'Menghubungkan peserta ke room kuis yang benar',
      'Menghapus akun peserta',
      'Mengubah warna aplikasi',
      'Menutup dashboard host',
    ],
    correctIndex: 0,
    explanation:
        'Room code dipakai peserta untuk masuk ke sesi kuis yang dibuat host.',
  ),
  QuizQuestion(
    question: 'Halaman apa yang dipakai peserta sebelum kuis dimulai?',
    options: [
      'Lobby room',
      'Review jawaban',
      'Login admin',
      'Riwayat nilai',
    ],
    correctIndex: 0,
    explanation:
        'Lobby room menampilkan peserta yang sudah bergabung dan menunggu host mulai.',
  ),
  QuizQuestion(
    question: 'Leaderboard otomatis menampilkan data apa?',
    options: [
      'Peringkat peserta berdasarkan skor',
      'Daftar email host',
      'Kode sumber aplikasi',
      'Tema pilihan peserta',
    ],
    correctIndex: 0,
    explanation: 'Leaderboard mengurutkan peserta berdasarkan skor tertinggi.',
  ),
  QuizQuestion(
    question: 'Mengapa review jawaban dibutuhkan setelah kuis?',
    options: [
      'Agar peserta paham jawaban benar dan pembahasannya',
      'Agar room langsung terhapus',
      'Agar host tidak melihat hasil',
      'Agar peserta login ulang',
    ],
    correctIndex: 0,
    explanation: 'Review jawaban membantu proses belajar setelah kuis selesai.',
  ),
];
