# Finance Tracker - Aplikasi Management Keuangan Pribadi

Aplikasi manajemen keuangan pribadi yang dikembangkan dengan Flutter, featuring UI modern bergaya BNI Mobile Banking.

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

## 🎯 Fitur Utama

### ✅ Dashboard (Home)
- **Summary Saldo Total**: Tampilan saldo dengan opsi hide/show
- **Grafik Pie Chart**: Visualisasi pengeluaran per kategori bulan ini
- **Grafik Bar Chart**: Perbandingan pemasukan vs pengeluaran
- **Quick Action Buttons**: Tambah pemasukan/pengeluaran dengan cepat
- **List Transaksi Terbaru**: 5 transaksi terakhir

### ✅ Transaksi
- **Form Input Transaksi**: Tambah pemasukan/pengeluaran dengan mudah
- **Kategori**: Pilihan kategori lengkap (Makanan, Transport, Belanja, dll)
- **Format Rupiah**: Input nominal dengan format mata uang otomatis
- **DatePicker**: Pilih tanggal transaksi
- **Catatan**: Tambahkan catatan opsional
- **List & Filter**: Lihat semua transaksi dengan filter berdasarkan tipe
- **Swipe to Delete**: Hapus transaksi dengan mudah

### ✅ Statistik & Laporan
- **Periode Pilihan**: Harian, Mingguan, Bulanan, Tahunan
- **Bar Chart**: Visualisasi pemasukan vs pengeluaran
- **Pie Chart**: Breakdown pengeluaran per kategori
- **Top Kategori**: Daftar kategori pengeluaran terbesar

### ✅ Budget Planning
- **Set Budget Bulanan**: Tentukan batas pengeluaran per kategori
- **Progress Bar**: Visualisasi sisa budget
- **Warning System**: Notifikasi visual saat budget mencapai 80% dan 100%
- **Budget Management**: Tambah dan hapus budget

### ✅ Pengaturan
- **Profil User**: Kelola nama dan foto profil
- **Hide/Show Balance**: Sembunyikan atau tampilkan saldo
- **PIN Security**: Keamanan dengan 6-digit PIN
- **Biometric Support**: Opsional autentikasi sidik jari

### ✅ UI/UX
- **BNI Mobile Banking Style**: Gradasi orange ke merah
- **Material Design 3**: Modern rounded corners
- **Dark Mode Support**: Theme gelap dan terang
- **Smooth Animations**: Transisi 60fps
- **Card-based Layout**: Desain modular dan bersih

## 🛠️ Teknologi yang Digunakan

### State Management
- **Provider** (^6.1.2)

### Database
- **SQLite** (sqflite ^2.3.3+2)
- **Shared Preferences** untuk settings

### UI Components
- **fl_chart** (^0.68.0) - Grafik dan charts
- **flutter_slidable** (^3.1.1) - Swipe actions
- **shimmer** (^3.0.0) - Loading skeleton
- **google_fonts** (^6.2.1) - Typography Poppins

### Utilities
- **intl** (^0.19.0) - Format currency dan date
- **image_picker** (^1.1.2) - Upload foto bukti
- **local_auth** (^2.3.0) - Biometric authentication

## 📦 Instalasi

### Prasyarat
- Flutter SDK (^3.9.2)
- Android Studio / VS Code
- Android SDK 21+ atau iOS 12+

### Langkah Instalasi

1. **Clone repository**
   ```bash
   git clone <repository-url>
   cd flutter_application_1
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run aplikasi**
   ```bash
   # Untuk Android/iOS
   flutter run

   # Atau pilih device
   flutter devices
   flutter run -d <device-id>
   ```

4. **Build APK (untuk distribusi)**
   ```bash
   # Debug APK
   flutter build apk --debug

   # Release APK
   flutter build apk --release

   # App Bundle (untuk Play Store)
   flutter build appbundle --release
   ```

## 📂 Struktur Project

```
lib/
├── constants/
│   ├── app_constants.dart      # Konstanta app (warna, ukuran, dll)
│   └── app_theme.dart          # Theme configuration
├── database/
│   └── database_helper.dart    # SQLite helper
├── models/
│   ├── budget_model.dart       # Model budget
│   ├── category_model.dart     # Model kategori
│   ├── transaction_model.dart  # Model transaksi
│   └── user_model.dart         # Model user
├── providers/
│   ├── budget_provider.dart    # Budget state management
│   ├── category_provider.dart  # Category state management
│   ├── transaction_provider.dart # Transaction state management
│   └── user_provider.dart      # User state management
├── screens/
│   ├── auth/
│   │   ├── pin_screen.dart       # PIN verification
│   │   └── pin_setup_screen.dart # PIN setup
│   ├── budget/
│   │   └── budget_screen.dart    # Budget management
│   ├── dashboard/
│   │   └── dashboard_screen.dart # Main dashboard
│   ├── home/
│   │   └── main_screen.dart      # Bottom navigation
│   ├── onboarding/
│   │   └── onboarding_screen.dart # Onboarding screens
│   ├── settings/
│   │   └── settings_screen.dart  # Settings
│   ├── splash_screen.dart        # Splash screen
│   ├── statistics/
│   │   └── statistics_screen.dart # Statistics & reports
│   └── transaction/
│       ├── add_transaction_screen.dart  # Add transaction form
│       └── transaction_list_screen.dart # Transaction list
├── utils/
│   ├── currency_formatter.dart  # Format mata uang
│   └── date_formatter.dart      # Format tanggal
└── main.dart                    # Entry point
```

## 🎨 Customization

### Warna Theme
Edit di `lib/constants/app_constants.dart`:
```dart
static const Color primaryOrange = Color(0xFFFF6B00);
static const Color primaryRed = Color(0xFFE63946);
```

### Kategori Default
Edit di `lib/constants/app_constants.dart`:
```dart
static const List<Map<String, dynamic>> defaultExpenseCategories = [
  {'name': 'Makanan', 'icon': 'restaurant', 'color': '#FF6B00'},
  // Tambah kategori lain di sini
];
```

## 📝 Cara Penggunaan

### 1. First Time Setup
- Buka aplikasi → Onboarding screens
- Setup 6-digit PIN untuk keamanan
- Masukkan PIN untuk login selanjutnya

### 2. Dashboard
- Lihat saldo total di card atas
- Tap icon mata untuk hide/show saldo
- Gunakan quick action buttons untuk tambah transaksi

### 3. Tambah Transaksi
- Tap tombol + di bottom navigation
- Pilih tipe: Pemasukan/Pengeluaran
- Input nominal (format otomatis Rupiah)
- Pilih kategori
- Set tanggal (default: hari ini)
- Tambah catatan opsional
- Tap "Simpan Transaksi"

### 4. Lihat Transaksi
- Tab "Transaksi" di bottom navigation
- Filter: Semua/Pemasukan/Pengeluaran
- Swipe kiri untuk delete

### 5. Statistik
- Tab "Statistik" di bottom navigation
- Pilih periode: Minggu Ini/Bulan Ini/Tahun Ini
- Lihat charts dan breakdown

### 6. Budget
- Dari Settings → Kelola Budget
- Tap tombol + untuk tambah budget
- Pilih kategori dan nominal limit
- Progress bar akan menunjukkan penggunaan

### 7. Settings
- Tap tab "Pengaturan"
- Edit profil dan nama
- Toggle hide/show balance
- Enable/disable biometric

## 🔒 Keamanan

- **PIN Protection**: 6-digit PIN untuk login
- **Biometric**: Opsional fingerprint/face recognition
- **Local Storage**: Semua data tersimpan di device (offline-first)
- **No Internet**: Tidak memerlukan koneksi internet

## 🐛 Troubleshooting

### Issue: Database error
```bash
# Uninstall app dan install ulang
flutter clean
flutter pub get
flutter run
```

### Issue: Charts tidak muncul
- Pastikan package fl_chart terinstall: `flutter pub get`
- Restart aplikasi

### Issue: PIN lupa
- Uninstall aplikasi dan install ulang
- Semua data akan hilang

## 📄 Lisensi

Aplikasi ini dikembangkan untuk tujuan edukasi dan penggunaan pribadi.

## 👨‍💻 Developer

Dibuat dengan Flutter dan ❤️

---

## 📞 Support

Untuk pertanyaan atau issues, silakan buka issue di repository.

---

**Catatan**: Aplikasi ini masih dalam pengembangan. Fitur tambahan akan ditambahkan secara berkala.
