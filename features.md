# Fitur Aplikasi — Marketplace KampSewa

> Dokumentasi alur (flow) sistem untuk setiap fitur aplikasi **KampSewa**.

---

## 1. Splash Screen

**File:** `lib/screens/splash_screen.dart`

Sistem berjalan → halaman Splash Screen muncul dengan animasi (background zoom, logo, teks, loading bar) selama ± 3,2 detik → sambil itu sistem membaca token dari penyimpanan lokal → setelah durasi selesai, sistem cek kondisi token:

- Jika token ada → berpindah ke halaman **Dashboard**
- Jika tidak ada → berpindah ke halaman **Onboarding**

Transisi menuju halaman tujuan menggunakan efek *fade*.

---

## 2. Onboarding

**File:** `lib/layouts/layout_onboarding.dart`

Sistem berjalan → halaman Onboarding tampil berisi **3 slide** pengenalan aplikasi:

1. **Temukan Peralatan** — pengguna bisa memilih peralatan sebelum berpetualang
2. **Sesuaikan Kebutuhan** — memilih peralatan sesuai kebutuhan di alam bebas
3. **Pergi Berpetualang** — berpetualang dengan peralatan yang memadai

Pengguna dapat berpindah antar slide dengan cara:

- **Geser** layar, atau
- Tekan tombol **Next**, atau
- Tekan tombol **Skip** untuk langsung lompat ke slide terakhir

Pada slide terakhir, muncul tombol **"Mulai Sekarang!"**. Saat ditekan, sistem menyimpan tanda onboarding selesai di penyimpanan lokal, lalu berpindah ke halaman **Login** dengan efek *fade*.

---
