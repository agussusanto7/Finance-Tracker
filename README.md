<![CDATA[# 💰 FinanceTracker — Smart Personal Finance Manager

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.9.2-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.9-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Supabase](https://img.shields.io/badge/Supabase-Storage-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![Gemini AI](https://img.shields.io/badge/Gemini%20AI-2.5%20Flash-4285F4?style=for-the-badge&logo=google&logoColor=white)

**Aplikasi manajemen keuangan pribadi berbasis Flutter dengan fitur AI Consultation, Cloud Sync, dan UI premium yang modern.**

[Fitur](#-fitur-lengkap) • [Teknologi](#%EF%B8%8F-tech-stack) • [Instalasi](#-instalasi) • [Arsitektur](#-arsitektur-project) • [Panduan](#-panduan-penggunaan)

</div>

---

## 📸 Gallery Screenshots

<div align="center">
  <img src="assets/dashboard/WhatsApp%20Image%202026-05-30%20at%2014.12.06.jpeg" width="24%" style="border-radius: 10px; margin: 5px;">
  <img src="assets/dashboard/WhatsApp%20Image%202026-05-30%20at%2014.12.07.jpeg" width="24%" style="border-radius: 10px; margin: 5px;">
  <img src="assets/dashboard/WhatsApp%20Image%202026-05-30%20at%2014.12.07%20(1).jpeg" width="24%" style="border-radius: 10px; margin: 5px;">
  <img src="assets/dashboard/WhatsApp%20Image%202026-05-30%20at%2014.12.07%20(2).jpeg" width="24%" style="border-radius: 10px; margin: 5px;">
</div>
<div align="center">
  <img src="assets/dashboard/WhatsApp%20Image%202026-05-30%20at%2014.12.08.jpeg" width="24%" style="border-radius: 10px; margin: 5px;">
  <img src="assets/dashboard/WhatsApp%20Image%202026-05-30%20at%2014.12.08%20(1).jpeg" width="24%" style="border-radius: 10px; margin: 5px;">
  <img src="assets/dashboard/WhatsApp%20Image%202026-05-30%20at%2014.12.08%20(2).jpeg" width="24%" style="border-radius: 10px; margin: 5px;">
  <img src="assets/dashboard/WhatsApp%20Image%202026-05-30%20at%2014.12.09.jpeg" width="24%" style="border-radius: 10px; margin: 5px;">
</div>
<div align="center">
  <img src="assets/dashboard/WhatsApp%20Image%202026-05-30%20at%2014.12.09%20(1).jpeg" width="24%" style="border-radius: 10px; margin: 5px;">
  <img src="assets/dashboard/WhatsApp%20Image%202026-05-30%20at%2014.21.43.jpeg" width="24%" style="border-radius: 10px; margin: 5px;">
  <img src="assets/dashboard/WhatsApp%20Image%202026-05-30%20at%2014.12.10.jpeg" width="24%" style="border-radius: 10px; margin: 5px;">
  <img src="assets/dashboard/WhatsApp%20Image%202026-05-30%20at%2014.12.10%20(1).jpeg" width="24%" style="border-radius: 10px; margin: 5px;">
</div>

---

## ✨ Fitur Lengkap

### 🔐 Autentikasi & Keamanan
| Fitur | Deskripsi |
|-------|-----------|
| **Firebase Authentication** | Login/Register dengan Email & Password |
| **Google Sign-In** | Satu klik masuk menggunakan akun Google |
| **6-Digit PIN** | Keamanan lokal dengan PIN 6 digit |
| **Biometric Auth** | Dukungan sidik jari / Face ID |
| **Reset Password** | Lupa kata sandi via email Firebase |
| **Session Management** | Auto-logout & sesi aman |

### 📊 Dashboard Responsif
| Fitur | Deskripsi |
|-------|-----------|
| **Saldo Total** | Tampilan saldo real-time dengan opsi hide/show |
| **Pie Chart Ringkasan** | Visualisasi perbandingan pemasukan vs pengeluaran bulan ini |
| **Quick Action Buttons** | Akses cepat ke Pemasukan, Pengeluaran, dan Budget |
| **Transaksi Terbaru** | 5 transaksi terakhir langsung di dashboard |
| **Avatar Profil** | Foto profil di header, klik langsung ke Pengaturan |
| **Responsive Layout** | Otomatis menyesuaikan untuk HP kecil (Oppo A5s), HP besar, tablet, dan desktop |
| **Konsultasi Banner** | Akses cepat ke AI Consultant dari dashboard |

### 💳 Manajemen Transaksi
| Fitur | Deskripsi |
|-------|-----------|
| **Tambah Pemasukan/Pengeluaran** | Form input lengkap dengan format Rupiah otomatis |
| **Kategori Kustom** | Kelola kategori pemasukan & pengeluaran sendiri |
| **DatePicker** | Pilih tanggal transaksi (default: hari ini) |
| **Catatan & Bukti Foto** | Lampirkan catatan dan foto bukti transaksi |
| **Upload ke Cloud** | Foto bukti otomatis diupload ke Supabase Storage |
| **Swipe to Delete** | Hapus transaksi dengan geser ke kiri |
| **Filter & Pencarian** | Filter berdasarkan tipe (Semua/Pemasukan/Pengeluaran) |

### 📈 Statistik & Laporan
| Fitur | Deskripsi |
|-------|-----------|
| **Multi-Periode** | Analisis Harian, Mingguan, Bulanan, dan Tahunan |
| **Bar Chart** | Perbandingan visual pemasukan vs pengeluaran |
| **Pie Chart** | Breakdown pengeluaran per kategori |
| **Top Kategori** | Ranking kategori pengeluaran terbesar |

### 💼 Budget Planning
| Fitur | Deskripsi |
|-------|-----------|
| **Budget per Kategori** | Tentukan batas pengeluaran per kategori per bulan |
| **Progress Bar Visual** | Indikator visual sisa budget |
| **Warning System** | Peringatan otomatis saat budget 80% dan 100% |
| **Cloud Backup** | Budget otomatis di-backup ke Firebase Firestore |

### 🤖 AI Financial Consultant (Gemini AI)
| Fitur | Deskripsi |
|-------|-----------|
| **Powered by Gemini 2.5 Flash** | Konsultasi keuangan dengan AI Google terbaru |
| **Konteks Data Real-time** | AI membaca data keuangan Anda untuk saran personal |
| **Chat Interface** | UI chat modern dengan bubble dan markdown support |
| **Saran Cerdas** | Tips berhemat, analisis pengeluaran, dan perencanaan keuangan |

### 🧮 Kalkulator Keuangan
| Fitur | Deskripsi |
|-------|-----------|
| **Desain ala iPhone** | UI kalkulator premium dengan tombol bulat |
| **Operasi Lengkap** | Tambah, kurang, kali, bagi, persen, dan negasi |
| **Format Angka Indonesia** | Titik sebagai pemisah ribuan, koma sebagai desimal |
| **Riwayat Perhitungan** | Histori kalkulasi yang persistent |
| **Auto-Resize Font** | Ukuran angka otomatis menyesuaikan panjang ekspresi |

### 🖼️ Galeri Bukti Transaksi
| Fitur | Deskripsi |
|-------|-----------|
| **Grid Gallery** | Tampilan grid 2 kolom untuk semua bukti transaksi |
| **Multi-Filter** | Filter: Hari Ini, Minggu Ini, Bulan Ini, Tahun Ini, Semua |
| **Filter Tahun** | Dropdown untuk filter berdasarkan tahun spesifik |
| **Full-Screen Viewer** | Lihat gambar full-screen dengan detail transaksi |
| **Cloud & Local** | Mendukung gambar dari lokal dan URL cloud |

### ☁️ Cloud Sync (Firebase + Supabase)
| Fitur | Deskripsi |
|-------|-----------|
| **Firebase Firestore** | Sinkronisasi transaksi & budget ke cloud |
| **Supabase Storage** | Penyimpanan foto bukti transaksi & profil |
| **Document ID Deskriptif** | Prefix `pemasukan_` / `pengeluaran_` untuk organisasi data |
| **Cross-Device** | Akses data dari perangkat manapun |

### ⚙️ Pengaturan & Personalisasi
| Fitur | Deskripsi |
|-------|-----------|
| **Profil Pengguna** | Nama, foto profil (kamera/galeri/Google) |
| **Dark/Light Mode** | Toggle tema gelap dan terang |
| **Hide Balance** | Sembunyikan saldo di dashboard |
| **Kelola Kategori** | Tambah, edit, hapus kategori kustom |
| **Kelola Budget** | Manajemen budget per kategori |
| **Ubah PIN** | Ganti PIN keamanan dengan verifikasi PIN lama |
| **Logout** | Logout dari Firebase & Google Sign-In |

### 🎨 UI/UX Premium
| Fitur | Deskripsi |
|-------|-----------|
| **Gradient Design** | Purple-violet gradient yang elegan |
| **Material Design 3** | Rounded corners dan elevasi modern |
| **Responsive Design** | Adaptif untuk mobile, tablet, dan desktop |
| **Smooth Animations** | Transisi dan micro-animation 60fps |
| **Google Fonts (Poppins)** | Tipografi premium |
| **Adaptive Layout** | Bottom Nav (mobile), Navigation Rail (tablet), Sidebar (desktop) |

---

## 🛠️ Tech Stack

### Core Framework
| Teknologi | Versi | Fungsi |
|-----------|-------|--------|
| Flutter | ^3.9.2 | Framework UI cross-platform |
| Dart | ^3.9 | Bahasa pemrograman |

### State Management
| Package | Versi | Fungsi |
|---------|-------|--------|
| provider | ^6.1.2 | State management reactive |

### Backend & Cloud
| Service | Package | Fungsi |
|---------|---------|--------|
| Firebase Auth | firebase_auth ^6.5.1 | Autentikasi pengguna |
| Cloud Firestore | cloud_firestore ^6.4.1 | Database cloud NoSQL |
| Firebase Storage | firebase_storage ^13.4.1 | Penyimpanan file cloud |
| Supabase | supabase_flutter ^2.12.4 | Storage untuk foto |
| Google Sign-In | google_sign_in 6.2.1 | OAuth login Google |

### AI & Intelligence
| Package | Versi | Fungsi |
|---------|-------|--------|
| google_generative_ai | ^0.4.7 | Gemini AI API |
| flutter_markdown | ^0.7.7+1 | Render markdown dari respons AI |

### Database & Storage
| Package | Versi | Fungsi |
|---------|-------|--------|
| sqflite | ^2.3.3+2 | Database SQLite lokal |
| shared_preferences | ^2.3.3 | Key-value storage untuk settings |
| path_provider | ^2.1.4 | Akses path sistem |

### UI Components
| Package | Versi | Fungsi |
|---------|-------|--------|
| fl_chart | ^0.68.0 | Pie chart & bar chart interaktif |
| flutter_slidable | ^3.1.1 | Swipe-to-delete pada list |
| shimmer | ^3.0.0 | Loading skeleton premium |
| google_fonts | ^6.2.1 | Tipografi Poppins |
| flutter_svg | ^2.0.10+1 | Render ikon SVG |
| animations | ^2.0.11 | Animasi transisi halaman |

### Utilities
| Package | Versi | Fungsi |
|---------|-------|--------|
| intl | ^0.19.0 | Format currency Rupiah & tanggal |
| image_picker | ^1.1.2 | Ambil foto dari kamera/galeri |
| local_auth | ^2.3.0 | Biometric authentication |
| math_expressions | ^3.1.0 | Parser kalkulasi matematika |
| flutter_dotenv | ^6.0.1 | Environment variable (.env) |

---

## 📦 Instalasi

### Prasyarat
- **Flutter SDK** ^3.9.2
- **Android Studio** / **VS Code** dengan Flutter extension
- **Android SDK 21+** atau **iOS 12+**
- **Firebase Project** (untuk autentikasi & cloud sync)
- **Supabase Project** (untuk storage foto)
- **Gemini API Key** (untuk fitur AI Consultation)

### Langkah Instalasi

1. **Clone Repository**
   ```bash
   git clone https://github.com/agussusanto7/Finance-Tracker.git
   cd Finance-Tracker
   ```

2. **Setup Environment Variables**
   ```bash
   # Buat file .env di root project
   cp .env.example .env
   ```
   Isi file `.env` dengan konfigurasi:
   ```env
   GEMINI_API_KEY=your_gemini_api_key_here
   SUPABASE_URL=your_supabase_url_here
   SUPABASE_ANON_KEY=your_supabase_anon_key_here
   ```

3. **Setup Firebase**
   - Buat project di [Firebase Console](https://console.firebase.google.com/)
   - Aktifkan **Authentication** (Email/Password & Google)
   - Aktifkan **Cloud Firestore**
   - Download `google-services.json` → taruh di `android/app/`
   - Untuk iOS: download `GoogleService-Info.plist` → taruh di `ios/Runner/`

4. **Setup Supabase Storage**
   - Buat project di [Supabase Dashboard](https://supabase.com/)
   - Buat bucket `receipts` dan `profiles` (public)
   - Salin URL dan Anon Key ke file `.env`

5. **Install Dependencies**
   ```bash
   flutter pub get
   ```

6. **Generate Native Splash & Launcher Icons**
   ```bash
   dart run flutter_native_splash:create
   dart run flutter_launcher_icons
   ```

7. **Run Aplikasi**
   ```bash
   # Development
   flutter run

   # Pilih device tertentu
   flutter devices
   flutter run -d <device-id>
   ```

8. **Build APK (Distribusi)**
   ```bash
   # Debug APK
   flutter build apk --debug

   # Release APK
   flutter build apk --release

   # App Bundle (Play Store)
   flutter build appbundle --release
   ```

---

## 🏗️ Arsitektur Project

```
lib/
├── constants/
│   ├── app_constants.dart          # Konstanta (warna, ukuran, kategori)
│   └── app_theme.dart              # Konfigurasi tema (light & dark)
├── database/
│   └── database_helper.dart        # SQLite helper (CRUD lokal)
├── models/
│   ├── budget_model.dart           # Model data budget
│   ├── category_model.dart         # Model data kategori
│   ├── transaction_model.dart      # Model data transaksi
│   └── user_model.dart             # Model data pengguna
├── providers/
│   ├── budget_provider.dart        # State management budget
│   ├── category_provider.dart      # State management kategori
│   ├── theme_provider.dart         # State management tema
│   ├── transaction_provider.dart   # State management transaksi
│   └── user_provider.dart          # State management user & auth
├── services/
│   └── firebase_service.dart       # Firebase Firestore & Supabase Storage
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart         # Login (Email & Google)
│   │   ├── register_screen.dart      # Registrasi akun baru
│   │   ├── reset_password_screen.dart # Reset kata sandi
│   │   ├── pin_screen.dart           # Verifikasi PIN login
│   │   └── pin_setup_screen.dart     # Setup PIN pertama kali
│   ├── budget/
│   │   └── budget_screen.dart        # Manajemen budget
│   ├── calculator/
│   │   └── calculator_screen.dart    # Kalkulator keuangan
│   ├── category/
│   │   └── category_screen.dart      # Kelola kategori kustom
│   ├── chat/
│   │   └── chat_screen.dart          # AI Consultant (Gemini)
│   ├── dashboard/
│   │   └── dashboard_screen.dart     # Dashboard utama
│   ├── gallery/
│   │   ├── gallery_screen.dart       # Galeri bukti transaksi
│   │   └── full_screen_image_screen.dart # Viewer gambar full-screen
│   ├── home/
│   │   └── main_screen.dart          # Layout adaptif & navigasi
│   ├── onboarding/
│   │   └── onboarding_screen.dart    # Onboarding pertama kali
│   ├── settings/
│   │   └── settings_screen.dart      # Halaman pengaturan
│   ├── splash_screen.dart            # Splash screen
│   ├── statistics/
│   │   └── statistics_screen.dart    # Statistik & laporan
│   └── transaction/
│       ├── add_transaction_screen.dart  # Form tambah transaksi
│       └── transaction_list_screen.dart # Daftar semua transaksi
├── utils/
│   ├── currency_formatter.dart     # Format mata uang Rupiah
│   └── date_formatter.dart         # Format tanggal Indonesia
└── main.dart                       # Entry point aplikasi
```

---

## 📝 Panduan Penggunaan

### 1. 🔑 Registrasi & Login
- Buka aplikasi → Halaman Login
- **Daftar baru**: Tap "Daftar" → Isi nama, email, dan kata sandi
- **Login Google**: Tap "Masuk dengan Google" untuk login cepat
- **Lupa kata sandi**: Tap "Lupa kata sandi?" → Masukkan email → Cek inbox
- Setelah login, setup **6-digit PIN** untuk keamanan lokal

### 2. 📊 Dashboard
- Lihat **saldo total** di card gradien atas
- Tap ikon mata 👁️ untuk hide/show saldo
- Gunakan **Quick Action** untuk tambah pemasukan/pengeluaran/budget
- Lihat **Pie Chart** ringkasan bulan ini (pemasukan vs pengeluaran)
- Tap **avatar profil** (kanan atas) untuk langsung ke Pengaturan

### 3. ➕ Tambah Transaksi
- Tap tombol **Kalkulator** (FAB di tengah bottom nav) atau Quick Action
- Pilih tipe: **Pemasukan** / **Pengeluaran**
- Input nominal (format Rupiah otomatis)
- Pilih kategori → Set tanggal → Tambah catatan (opsional)
- Lampirkan **foto bukti** dari kamera/galeri (otomatis upload ke cloud)
- Tap **"Simpan Transaksi"**

### 4. 📋 Lihat & Kelola Transaksi
- Tab **"Transaksi"** di bottom navigation
- Filter: Semua / Pemasukan / Pengeluaran
- **Swipe kiri** pada transaksi untuk menghapus

### 5. 📈 Statistik
- Tab **"Statistik"** di bottom navigation
- Pilih periode: **Minggu Ini / Bulan Ini / Tahun Ini**
- Lihat **Bar Chart** perbandingan dan **Pie Chart** breakdown

### 6. 💼 Budget
- Dari Pengaturan → **Kelola Budget**
- Tap tombol **+** untuk tambah budget baru
- Pilih kategori dan nominal limit bulanan
- **Progress bar** menunjukkan penggunaan (hijau → kuning → merah)

### 7. 🤖 AI Consultation
- Dari dashboard, tap banner **"Ingin Konsultasi?"**
- Ketik pertanyaan keuangan Anda
- AI Gemini akan memberikan **saran personal** berdasarkan data keuangan Anda
- Contoh: _"Bagaimana cara menghemat pengeluaran bulan ini?"_

### 8. 🧮 Kalkulator
- Tap tombol **kalkulator** (FAB di tengah bawah)
- Gunakan untuk kalkulasi cepat sebelum input transaksi
- Riwayat perhitungan tersimpan selama sesi

### 9. 🖼️ Galeri Bukti
- Dari Pengaturan → **Galeri Bukti Transaksi**
- Lihat semua foto bukti transaksi dalam tampilan grid
- Filter berdasarkan periode atau tahun
- Tap gambar untuk **full-screen view**

### 10. ⚙️ Pengaturan
- Tab **"Pengaturan"** atau tap avatar di dashboard
- Edit nama & foto profil
- Toggle **tema gelap** / **sembunyikan saldo** / **biometrik**
- Kelola **kategori kustom** dan **budget**
- Lihat **info aplikasi** atau **logout**

---

## 🔒 Keamanan

| Lapisan | Metode |
|---------|--------|
| **Cloud Auth** | Firebase Authentication (Email/Google OAuth) |
| **Local Auth** | 6-digit PIN verification |
| **Biometric** | Fingerprint / Face ID (opsional) |
| **Data Sync** | Firestore dengan UID-based isolation |
| **Storage** | Supabase Storage dengan path per-user |
| **Env Vars** | API keys tersimpan di `.env` (tidak di-commit) |

---

## 🐛 Troubleshooting

| Masalah | Solusi |
|---------|--------|
| Database error | `flutter clean && flutter pub get && flutter run` |
| Charts tidak muncul | Pastikan `fl_chart` terinstall: `flutter pub get` |
| PIN lupa | Uninstall & install ulang aplikasi |
| Firebase error | Pastikan `google-services.json` ada di `android/app/` |
| Gemini AI tidak merespons | Cek API Key di file `.env` |
| Foto tidak terupload | Cek konfigurasi Supabase bucket (public access) |
| Login Google gagal | Pastikan SHA-1/SHA-256 terdaftar di Firebase Console |

---

## 📄 Lisensi

Aplikasi ini dikembangkan untuk tujuan **edukasi** dan **penggunaan pribadi** sebagai bagian dari mata kuliah **Metode Penelitian** Semester 5.

## 👨‍💻 Developer

**Agus Susanto** — Mahasiswa Informatika

Dibuat dengan **Flutter** dan ❤️

---

## 📞 Support

Untuk pertanyaan, bug report, atau fitur request, silakan buka **Issue** di repository ini.

---

<div align="center">

**FinanceTracker v1.0.0** — Smart Personal Finance Manager

_Powered by Flutter • Firebase • Supabase • Gemini AI_

</div>
]]>
