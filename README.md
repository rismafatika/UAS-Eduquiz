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

## Menghubungkan Supabase

1. Buka Supabase, buat project baru.
2. Buka menu SQL Editor.
3. Jalankan isi file `SUPABASE_SCHEMA.sql`.
4. Ambil Project URL dan anon public key dari Project Settings > API.
5. Jalankan aplikasi dengan:

```bash
flutter run --dart-define=SUPABASE_URL=https://PROJECT_ID.supabase.co --dart-define=SUPABASE_ANON_KEY=ANON_KEY_KAMU
```

Jika URL dan anon key belum diisi, aplikasi tetap berjalan dalam mode lokal.

## Build untuk Google Play Testing

Pastikan schema Supabase sudah dijalankan, lalu build AAB untuk internal testing:

```bash
flutter clean
flutter pub get
flutter build appbundle --release --dart-define=SUPABASE_URL=https://PROJECT_ID.supabase.co --dart-define=SUPABASE_ANON_KEY=ANON_KEY_KAMU
```

Output AAB berada di:

```bash
build/app/outputs/bundle/release/app-release.aab
```

Package Android sudah disiapkan sebagai:

```bash
com.uas.eduquiz
```

## Catatan Backend

Data yang dikirim ke Supabase:

- `app_users`: data pengguna yang login.
- `rooms`: room code, judul kuis, host, dan fase room.
- `participants`: peserta dan skor.
- `answers`: jawaban peserta per soal.
