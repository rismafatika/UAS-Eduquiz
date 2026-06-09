# EduQuiz

EduQuiz adalah aplikasi Flutter untuk sesi kuis kelas dengan alur:

- Authentication pengguna.
- Sistem room code.
- Lobby room peserta.
- Quiz real-time.
- Leaderboard otomatis.
- Review jawaban.
- Dashboard host.

## Struktur Coding Per Halaman

- `lib/screens/login_page.dart`: halaman authentication pengguna.
- `lib/screens/home_page.dart`: halaman pilihan menu host atau peserta.
- `lib/screens/create_room_page.dart`: halaman host membuat room code.
- `lib/screens/join_room_page.dart`: halaman peserta memasukkan room code.
- `lib/screens/lobby_page.dart`: halaman lobby room peserta.
- `lib/screens/quiz_live_page.dart`: halaman quiz real-time.
- `lib/screens/leaderboard_page.dart`: halaman leaderboard otomatis.
- `lib/screens/review_page.dart`: halaman review jawaban.
- `lib/screens/host_dashboard_page.dart`: halaman dashboard host.

## Menjalankan

Jika folder ini belum pernah dibuat sebagai proyek Flutter lengkap, jalankan:

```bash
flutter create .
flutter pub get
flutter run
```

Versi ini memakai penyimpanan sementara di memori aplikasi agar semua fitur bisa dicoba tanpa backend.
