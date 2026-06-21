# EduQuiz Google Play Testing Checklist

## Wajib sebelum upload internal testing

- Jalankan `flutter pub get`.
- Jalankan `SUPABASE_SCHEMA.sql` di SQL Editor Supabase.
- Build dengan `SUPABASE_URL` dan `SUPABASE_ANON_KEY`.
- Pastikan login host dan peserta bisa masuk.
- Host bisa membuat room code.
- Peserta bisa join room code.
- Host bisa mulai quiz.
- Peserta bisa menjawab quiz.
- Leaderboard muncul otomatis.
- Review jawaban bisa dibuka.
- Dashboard host menampilkan peserta, jawaban, rata-rata, dan progres.

## Build release

```bash
flutter build appbundle --release --dart-define=SUPABASE_URL=https://PROJECT_ID.supabase.co --dart-define=SUPABASE_ANON_KEY=ANON_KEY_KAMU
```

## Catatan Supabase

Policy di `SUPABASE_SCHEMA.sql` dibuat terbuka agar mudah untuk UAS dan internal testing. Untuk produksi publik, policy sebaiknya diperketat dengan Supabase Auth asli.
