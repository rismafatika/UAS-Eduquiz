import 'package:flutter/material.dart';

import '../models/quiz_question.dart';

const sampleQuestions = [
  QuizQuestion(
    question:
        'Saat guru membagikan kode kelas di EduQuiz, apa yang harus dilakukan peserta?',
    options: [
      'Memasukkan kode room lalu masuk ke lobby',
      'Membuat room baru sebagai host',
      'Menutup aplikasi dan login ulang',
      'Mengubah nama host di dashboard',
    ],
    correctIndex: 0,
    explanation:
        'Room code dipakai untuk menghubungkan peserta ke sesi kuis yang benar.',
    category: 'EduQuiz',
    points: 100,
    color: Color(0xFF7C3AED),
  ),
  QuizQuestion(
    question: 'Di sebuah kuis kelas, leaderboard sebaiknya menampilkan apa?',
    options: [
      'Urutan peserta berdasarkan skor tertinggi',
      'Daftar perangkat yang dipakai peserta',
      'Password akun peserta',
      'Riwayat browser host',
    ],
    correctIndex: 0,
    explanation:
        'Leaderboard membantu peserta melihat posisi dan membuat suasana kuis lebih kompetitif.',
    category: 'Kompetisi',
    points: 120,
    color: Color(0xFF0EA5E9),
  ),
  QuizQuestion(
    question:
        'Jika kamu menjawab benar beberapa soal berturut-turut, fitur apa yang paling cocok diberikan?',
    options: [
      'Streak bonus',
      'Hukuman skor',
      'Keluar otomatis',
      'Menghapus room',
    ],
    correctIndex: 0,
    explanation:
        'Streak bonus membuat peserta semakin termotivasi untuk mempertahankan jawaban benar.',
    category: 'Skor',
    points: 130,
    color: Color(0xFFF97316),
  ),
  QuizQuestion(
    question: 'Apa manfaat review jawaban setelah kuis selesai?',
    options: [
      'Peserta memahami jawaban benar dan pembahasannya',
      'Host tidak perlu melihat hasil',
      'Peserta tidak bisa belajar dari kesalahan',
      'Room langsung hilang dari aplikasi',
    ],
    correctIndex: 0,
    explanation:
        'Review jawaban mengubah kuis dari sekadar permainan menjadi proses belajar.',
    category: 'Belajar',
    points: 150,
    color: Color(0xFF10B981),
  ),
  QuizQuestion(
    question:
        'Dalam dashboard host, metrik apa yang paling membantu guru memantau kelas?',
    options: [
      'Jumlah jawaban, rata-rata skor, dan progres peserta',
      'Warna wallpaper peserta',
      'Ukuran layar setiap peserta',
      'Jumlah tombol di aplikasi',
    ],
    correctIndex: 0,
    explanation:
        'Guru butuh metrik yang langsung menggambarkan progres dan pemahaman peserta.',
    category: 'Dashboard',
    points: 140,
    color: Color(0xFF2563EB),
  ),
  QuizQuestion(
    question: 'Apa tanda kuis kelas terasa profesional untuk peserta?',
    options: [
      'Instruksi jelas, tombol berfungsi, skor terlihat, dan feedback cepat',
      'Banyak tombol yang tidak punya aksi',
      'Tidak ada pembahasan jawaban',
      'Peserta tidak tahu hasil akhirnya',
    ],
    correctIndex: 0,
    explanation:
        'Aplikasi kuis yang baik membuat peserta tahu apa yang harus dilakukan dan hasilnya.',
    category: 'UX',
    points: 160,
    color: Color(0xFFDB2777),
  ),
  QuizQuestion(
    question:
        'Jika peserta masuk setelah kuis sudah berjalan, halaman terbaik yang dibuka adalah...',
    options: [
      'Halaman quiz live sesuai fase room',
      'Halaman logout',
      'Halaman kosong',
      'Halaman schema database',
    ],
    correctIndex: 0,
    explanation:
        'Routing berdasarkan fase room membuat peserta tidak tersesat saat bergabung terlambat.',
    category: 'Realtime',
    points: 150,
    color: Color(0xFF0891B2),
  ),
  QuizQuestion(
    question:
        'Apa yang sebaiknya terjadi setelah peserta menyelesaikan semua soal?',
    options: [
      'Menampilkan skor, leaderboard, dan akses review jawaban',
      'Menghapus skor peserta',
      'Kembali ke login tanpa hasil',
      'Membiarkan layar tetap di soal terakhir',
    ],
    correctIndex: 0,
    explanation:
        'Peserta perlu melihat nilai yang didapat dan pembahasan agar pengalaman belajarnya selesai.',
    category: 'Hasil',
    points: 180,
    color: Color(0xFF65A30D),
  ),
];
