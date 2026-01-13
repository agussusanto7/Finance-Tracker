# Sistem Manajemen Keuangan Pribadi Berbasis Mobile untuk Mendukung Literasi Keuangan


Disusun Oleh:
Azis Disha Rono Suryo
202310370311300





PROGRAM STUDI INFORMATIKA
FAKULTAS TEKNIK
UNIVERSITAS MUHAMMADIYAH MALANG
2026

## ABSTRAK

Perkembangan teknologi mobile telah membuka peluang besar dalam pengembangan aplikasi manajemen keuangan pribadi. Tingkat literasi keuangan yang masih rendah di Indonesia menyebabkan banyak individu kesulitan dalam mengelola pendapatan dan pengeluaran secara efektif. Penelitian ini bertujuan untuk mengembangkan sistem manajemen keuangan pribadi berbasis mobile yang dapat membantu pengguna melakukan pelacakan keuangan, perencanaan anggaran, dan analisis pengeluaran secara sistematis. Metode yang digunakan adalah Research and Development (R&D) dengan pendekatan Software Development Life Cycle (SDLC) menggunakan model Agile. Aplikasi dikembangkan menggunakan framework Flutter dengan bahasa pemrograman Dart, serta database SQLite untuk penyimpanan data lokal. Fitur utama yang diimplementasikan meliputi dashboard ringkasan saldo, pencatatan transaksi pemasukan dan pengeluaran, visualisasi data menggunakan grafik, perencanaan anggaran kategori, serta sistem keamanan menggunakan PIN dan biometrik. Pengujian aplikasi dilakukan untuk memastikan fungsionalitas berjalan sesuai kebutuhan pengguna. Hasil penelitian berupa aplikasi mobile dengan antarmuka user-friendly yang mendukung pengelolaan keuangan pribadi secara efektif dan aman.

Kata kunci: manajemen keuangan, mobile application, Flutter, literasi keuangan, budgeting.

## ABSTRACT

The development of mobile technology has opened up great opportunities in the development of personal financial management applications. The still low level of financial literacy in Indonesia causes many individuals to struggle with managing income and expenses effectively. This research aims to develop a mobile-based personal financial management system that can help users track finances, plan budgets, and analyze expenses systematically. The method used is Research and Development (R&D) with a Software Development Life Cycle (SDLC) approach using the Agile model. The application is developed using the Flutter framework with the Dart programming language, as well as SQLite database for local data storage. The main features implemented include a balance summary dashboard, recording income and expense transactions, data visualization using charts, category budget planning, and a security system using PIN and biometrics. Application testing is conducted to ensure functionality runs according to user needs. The research results are a mobile application with a user-friendly interface that supports effective and secure personal financial management.

Keywords: financial management, mobile application, Flutter, financial literacy, budgeting.

## DAFTAR ISI

DAFTAR ISI	iii
BAB I	1
PENDAHULUAN	1
1.1 Latar Belakang	1
1.2 Identifikasi Masalah	1
1.3 Rumusan Masalah	2
1.4 Tujuan Penelitian	2
1.5 Manfaat Penelitian	2
1.6 Ruang Lingkup Penelitian	2
BAB II	3
TINJAUAN PUSTAKA	3
2.1 Penelitian Terdahulu	3
2.2 Landasan Teori	3
2.3 Kerangka Teori	4
2.4 Kerangka Konseptual	4
BAB III	5
METODE PENELITIAN	5
3.1 Pendekatan Penelitian	5
3.2 Objek dan Subjek Penelitian	5
3.3 Lokasi dan Waktu Penelitian	5
3.4 Teknik Pengumpulan Data	5
3.5 Teknik Analisis Data	6
3.6 Validitas Data	7
3.7 Alur Penelitian	7
BAB IV	8
HASIL DAN PEMBAHASAN	8
4.1 Deskripsi Aplikasi	8
4.2 Implementasi Fitur	8
4.3 Hasil Pengujian	8
4.4 Pembahasan	9
BAB V	10
PENUTUP	10
5.1 Kesimpulan	10
5.2 Saran	10
DAFTAR PUSTAKA	11

---

## BAB I
PENDAHULUAN

### 1.1 Latar Belakang

Literasi keuangan merupakan kemampuan penting yang dimiliki individu untuk mengelola keuangan pribadi secara efektif. Berdasarkan survei Otoritas Jasa Keuangan (OJK), tingkat literasi keuangan di Indonesia masih berada pada angka yang memprihatinkan, yaitu sekitar 49,68% pada tahun 2024. Rendahnya literasi keuangan ini berdampak pada buruknya manajemen keuangan masyarakat, seperti ketidakmampuan mencatat pengeluaran, tidak memiliki perencanaan anggaran, serta kesulitan dalam memisahkan kebutuhan dan keinginan.

Perkembangan teknologi smartphone yang pesat di Indonesia memberikan peluang untuk mengembangkan solusi digital dalam bidang manajemen keuangan. Data dari Asosiasi Penyelenggara Jasa Internet Indonesia (APJII) menunjukkan bahwa lebih dari 70% penduduk Indonesia telah menggunakan smartphone. Hal ini memungkinkan pengembangan aplikasi mobile yang dapat membantu individu mengelola keuangan secara praktis dan dapat diakses kapan saja.

Pengembangan aplikasi manajemen keuangan pribadi berbasis mobile menjadi salah satu solusi yang tepat untuk meningkatkan literasi keuangan masyarakat. Aplikasi semacam ini dapat membantu pengguna dalam mencatat transaksi keuangan, memvisualisasikan pola pengeluaran melalui grafik, serta memberikan peringatan ketika pengeluaran melebihi batas anggaran yang telah ditetapkan.

### 1.2 Identifikasi Masalah

Berdasarkan latar belakang tersebut, permasalahan yang dapat diidentifikasi adalah sebagai berikut:
- Tingkat literasi keuangan masyarakat Indonesia masih rendah.
- Banyak individu kesulitan dalam mencatat dan mengelola pendapatan serta pengeluaran secara sistematis.
- Kurangnya kesadaran masyarakat dalam melakukan perencanaan anggaran keuangan.
- Kebutuhan akan aplikasi manajemen keuangan yang user-friendly dan sesuai dengan kebutuhan pengguna Indonesia.

### 1.3 Rumusan Masalah

Adapun rumusan masalah dalam penelitian ini adalah:
- Bagaimana merancang dan mengembangkan aplikasi manajemen keuangan pribadi berbasis mobile?
- Fitur-fitur apa saja yang diperlukan untuk mendukung pengelolaan keuangan pribadi yang efektif?
- Bagaimana implementasi keamanan data dalam aplikasi manajemen keuangan berbasis mobile?

### 1.4 Tujuan Penelitian

- Mengembangkan aplikasi manajemen keuangan pribadi berbasis mobile menggunakan framework Flutter.
- Mengimplementasikan fitur pelacakan transaksi, visualisasi data, dan perencanaan anggaran.
- Menjamin keamanan data pengguna melalui sistem autentikasi PIN dan biometrik.

### 1.5 Manfaat Penelitian

**Manfaat Teoretis**: Menambah kajian ilmiah mengenai pengembangan aplikasi mobile untuk literasi keuangan serta implementasi framework Flutter dalam pembangunan aplikasi finansial.

**Manfaat Praktis**: Memberikan solusi praktis bagi masyarakat dalam mengelola keuangan pribadi, membantu meningkatkan literasi keuangan, serta mendukung pengambilan keputusan finansial yang lebih baik.

### 1.6 Ruang Lingkup Penelitian

Penelitian ini dibatasi pada pengembangan aplikasi manajemen keuangan pribadi berbasis mobile dengan platform Android. Aplikasi berfokus pada fitur pencatatan transaksi, visualisasi data, perencanaan anggaran, dan keamanan data menggunakan penyimpanan lokal (SQLite). Penelitian tidak membahas integrasi dengan sistem perbankan atau payment gateway.

---

## BAB II
TINJAUAN PUSTAKA

### 2.1 Penelitian Terdahulu

Penelitian mengenai pengembangan aplikasi manajemen keuangan telah banyak dilakukan sebelumnya. Wulandari dan Pratama (2023) mengembangkan aplikasi pencatat keuangan berbasis Android menggunakan Java dan menemukan bahwa aplikasi membantu pengguna dalam mengelola pengeluaran harian. Namun, penelitian tersebut belum memiliki fitur visualisasi data yang komprehensif.

Saputra et al. (2024) dalam Jurnal Teknologi Informasi dan Komunikasi mengembangkan aplikasi manajemen keuangan dengan fitur budgeting menggunakan React Native. Hasil penelitian menunjukkan bahwa fitur perencanaan anggaran membantu pengguna mengontrol pengeluaran secara lebih efektif. Penelitian ini mengindikasikan pentingnya fitur visualisasi dalam aplikasi keuangan.

Rahmawati dan Susanto (2024) menerapkan sistem keamanan menggunakan biometrik pada aplikasi manajemen keuangan. Penelitian tersebut menunjukkan bahwa autentikasi biometrik meningkatkan kepercayaan pengguna dalam menyimpan data finansial secara digital.

Berdasarkan penelitian-penelitian terdahulu tersebut, penelitian ini mengembangkan aplikasi manajemen keuangan yang mengintegrasikan fitur pelacakan transaksi, visualisasi data yang komprehensif, perencanaan anggaran, serta keamanan data menggunakan framework Flutter.

### 2.2 Landasan Teori

**Manajemen Keuangan Pribadi** adalah proses perencanaan, pengorganisasian, pengendalian, dan pengawasan penggunaan uang individu untuk mencapai tujuan keuangan yang telah ditetapkan. Aspek utama dalam manajemen keuangan pribadi meliputi pencatatan transaksi, perencanaan anggaran, dan evaluasi keuangan secara berkala.

**Literasi Keuangan** adalah pengetahuan dan kemampuan individu untuk memahami konsep keuangan serta membuat keputusan finansial yang tepat. Literasi keuangan mencakup kemampuan dalam mengelola pendapatan, pengeluaran, investasi, dan perlindungan keuangan.

**Framework Flutter** adalah SDK (Software Development Kit) berbasis UI yang dikembangkan oleh Google untuk membangun aplikasi mobile yang kompatibel dengan berbagai platform dari satu codebase. Flutter menggunakan bahasa pemrograman Dart dan menerapkan konsep widget untuk membangun antarmuka pengguna.

### 2.3 Kerangka Teori

Secara teoritis, aplikasi manajemen keuangan pribadi harus memiliki kemampuan dalam mencatat semua transaksi keuangan, memvisualisasikan data untuk memudahkan analisis, serta memberikan peringatan ketika pengeluaran melebihi batas anggaran. Sistem keamanan yang baik juga diperlukan untuk melindungi data sensitif pengguna.

### 2.4 Kerangka Konseptual

Kerangka konseptual penelitian ini menggambarkan hubungan antara fitur-fitur aplikasi (pencatatan transaksi, visualisasi data, budgeting, dan keamanan) dengan peningkatan literasi keuangan pengguna. Aplikasi berperan sebagai media yang membantu pengguna dalam mengelola keuangan secara sistematis dan terencana.

---

## BAB III
METODE PENELITIAN

### 3.1 Pendekatan Penelitian

Penelitian ini menggunakan pendekatan Research and Development (R&D) dengan model Software Development Life Cycle (SDLC) menggunakan metode Agile. Pendekatan Agile dipilih karena memungkinkan pengembangan aplikasi secara iteratif dan dapat beradaptasi dengan kebutuhan pengguna yang berkembang.

### 3.2 Objek dan Subjek Penelitian

Objek penelitian adalah aplikasi manajemen keuangan pribadi berbasis mobile yang dikembangkan menggunakan framework Flutter. Subjek penelitian meliputi fitur-fitur utama aplikasi, yaitu sistem pencatatan transaksi, visualisasi data, perencanaan anggaran, dan sistem keamanan data.

### 3.3 Lokasi dan Waktu Penelitian

Penelitian ini dilaksanakan di Universitas Muhammadiyah Malang dengan durasi pelaksanaan selama satu semester akademik. Perencanaan penelitian dimulai dari tahap analisis kebutuhan, desain antarmuka, implementasi fitur, pengujian, hingga penyusunan laporan penelitian.

### 3.4 Teknik Pengumpulan Data

Teknik pengumpulan data dalam penelitian ini meliputi:
- **Studi Pustaka**: Mengumpulkan referensi dari jurnal ilmiah, buku, dan dokumentasi teknis terkait pengembangan aplikasi mobile dan manajemen keuangan.
- **Analisis Kebutuhan**: Mengidentifikasi fitur-fitur yang diperlukan dalam aplikasi manajemen keuangan berdasarkan kebutuhan pengguna.

### 3.5 Teknik Analisis Data

Teknik analisis dan pengembangan aplikasi dilakukan melalui beberapa tahapan:

**Perancangan Antarmuka (UI/UX Design)**
- Desain antarmuka dibuat dengan prinsip user-friendly dan intuitif.
- Adopsi desain modern yang terinspirasi dari aplikasi perbankan (BNI Mobile Banking).
- Penggunaan font Poppins dan skema warna yang nyaman untuk mata.

**Implementasi Fitur Utama**
- **Dashboard**: Menampilkan saldo total, grafik pengeluaran, dan transaksi terbaru.
- **Pencatatan Transaksi**: Form untuk input pemasukan dan pengeluaran dengan kategori.
- **Visualisasi Data**: Grafik batang dan pie chart untuk analisis pengeluaran.
- **Perencanaan Anggaran**: Fitur budgeting per kategori dengan indikator penggunaan.
- **Keamanan**: Sistem autentikasi menggunakan PIN dan biometrik (fingerprint/face recognition).

**Pengembangan Teknis**
- Framework: Flutter SDK ^3.9.2
- Bahasa Pemrograman: Dart
- Database: SQLite (sqflite ^2.3.3+2)
- State Management: Provider (^6.1.2)
- Visualisasi: fl_chart untuk grafik dan chart
- Lokalisasi: Format mata uang Rupiah dan Bahasa Indonesia

**Pengujian Aplikasi**
- Pengujian fungsionalitas untuk memastikan setiap fitur berjalan sesuai kebutuhan.
- Pengujian antarmuka untuk memastikan UI responsif dan mudah digunakan.
- Pengujian keamanan untuk memastikan data pengguna terlindungi.

### 3.6 Validitas Data

Validitas pengembangan aplikasi dijaga melalui proses testing yang menyeluruh, meliputi unit testing untuk setiap fungsi, integration testing untuk memastikan modul-modul saling terintegrasi, dan user acceptance testing untuk memastikan aplikasi memenuhi kebutuhan pengguna.

### 3.7 Alur Penelitian

Alur penelitian dalam penelitian ini dapat dijelaskan sebagai berikut:
- Identifikasi masalah dan studi literatur
- Analisis kebutuhan aplikasi
- Perancangan antarmuka dan arsitektur sistem
- Implementasi fitur-fitur aplikasi
- Pengujian fungsionalitas dan performa
- Evaluasi hasil dan perbaikan
- Penyusunan kesimpulan dan laporan

---

## BAB IV
HASIL DAN PEMBAHASAN

### 4.1 Deskripsi Aplikasi

Aplikasi manajemen keuangan pribadi yang dikembangkan bernama "Finance Tracker" dengan konsep modern dan user-friendly. Aplikasi ini memiliki desain antarmuka yang terinspirasi dari aplikasi perbankan profesional, namun tetap sederhana dan mudah digunakan.

### 4.2 Implementasi Fitur

**Fitur 1: Dashboard Utama**
- Menampilkan total saldo dengan fitur show/hide untuk privasi
- Grafik pie chart untuk distribusi kategori pengeluaran bulanan
- Grafik batang untuk perbandingan pemasukan vs pengeluaran
- Daftar transaksi terbaru
- Tombol quick action untuk input transaksi cepat

**Fitur 2: Manajemen Transaksi**
- Form input untuk pemasukan dan pengeluaran
- Pilihan kategori transaksi (makanan, transportasi, hiburan, dll)
- Format mata uang Rupiah otomatis
- Date picker untuk memilih tanggal transaksi
- Opsional: catatan dan lampiran gambar
- Filter dan hapus transaksi dengan swipe gesture

**Fitur 3: Statistik dan Laporan**
- Visualisasi data untuk periode harian, mingguan, bulanan, dan tahunan
- Grafik batang perbandingan income vs expense
- Grafik pie untuk breakdown kategori pengeluaran
- Tampilan kategori pengeluaran terbesar

**Fitur 4: Perencanaan Anggaran**
- Pengaturan budget bulanan per kategori
- Progress bar untuk memvisualisasikan penggunaan budget
- Peringatan pada 80% dan 100% penggunaan budget
- Manajemen budget (tambah/hapus)

**Fitur 5: Keamanan dan Pengaturan**
- Sistem keamanan menggunakan PIN 6 digit
- Opsional: autentikasi biometrik (fingerprint/face)
- Profil pengguna
- Support tema dark/light mode
- Toggle visibilitas saldo

### 4.3 Hasil Pengujian

Hasil pengujian menunjukkan bahwa aplikasi berjalan dengan baik dan fungsional. Semua fitur utama seperti pencatatan transaksi, visualisasi data, budgeting, dan keamanan berfungsi sesuai kebutuhan. Antarmuka aplikasi responsif dan mudah digunakan dengan desain yang modern dan intuitif. Penyimpanan data menggunakan SQLite berjalan efektif untuk menyimpan data secara lokal di perangkat pengguna.

### 4.4 Pembahasan

Hasil pengembangan aplikasi menunjukkan bahwa penggunaan framework Flutter sangat efektif dalam membangun aplikasi manajemen keuangan dengan antarmuka yang modern dan performa yang baik. Implementasi State Management menggunakan Provider membantu dalam mengelola state aplikasi secara efisien.

Fitur visualisasi data menggunakan grafik membantu pengguna dalam memahami pola pengeluaran secara visual, yang berkontribusi pada peningkatan literasi keuangan. Fitur budgeting dengan sistem peringatan juga terbukti efektif membantu pengguna mengontrol pengeluaran agar tidak melebihi batas anggaran yang telah ditetapkan.

Sistem keamanan berlapis menggunakan PIN dan biometrik memberikan rasa aman bagi pengguna dalam menyimpan data finansial secara digital. Lokalisasi aplikasi dengan format Rupiah dan Bahasa Indonesia membuat aplikasi lebih relevan dan mudah digunakan oleh pengguna Indonesia.

---

## BAB V
PENUTUP

### 5.1 Kesimpulan

Berdasarkan hasil penelitian dan pengembangan yang telah dilakukan, dapat disimpulkan bahwa:

1. Aplikasi manajemen keuangan pribadi berbasis mobile berhasil dikembangkan menggunakan framework Flutter dengan fitur-fitur lengkap yang mendukung pengelolaan keuangan pribadi secara efektif.

2. Fitur-fitur utama seperti pencatatan transaksi, visualisasi data menggunakan grafik, perencanaan anggaran, dan sistem keamanan berjalan sesuai fungsionalitas yang diharapkan.

3. Aplikasi memiliki antarmuka yang user-friendly dengan desain modern dan intuitif, sehingga mudah digunakan oleh berbagai kalangan pengguna.

4. Implementasi keamanan data menggunakan PIN dan biometrik serta penyimpanan lokal menggunakan SQLite memberikan perlindungan yang memadai untuk data finansial pengguna.

### 5.2 Saran

Penelitian selanjutnya disarankan untuk:
- Menambahkan fitur ekspor laporan keuangan dalam format PDF atau Excel.
- Mengintegrasikan aplikasi dengan sistem perbankan atau payment gateway untuk sinkronisasi otomatis.
- Mengembangkan fitur prediksi pengeluaran berbasis data historis.
- Menambahkan fitur kolaborasi untuk pengelolaan keuangan keluarga atau bersama pasangan.
- Menerapkan cloud sync untuk memungkinkan akses data dari multiple device.
- Melakukan pengujian usability dengan jumlah pengguna yang lebih besar untuk mendapatkan feedback yang lebih komprehensif.

---

## DAFTAR PUSTAKA

Flutter Documentation. (2024). Flutter SDK: Build cross-platform apps. Diakses dari https://flutter.dev/docs

Otoritas Jasa Keuangan. (2024). Survei Nasional Literasi dan Inklusi Keuangan (SNLIK) 2024. Jakarta: OJK.

Rahmawati, S., & Susanto, A. (2024). Implementasi biometrik pada aplikasi manajemen keuangan. Jurnal Teknologi Informasi dan Komunikasi, 8(2), 112–120.

Saputra, D., Pratama, B., & Wijaya, R. (2024). Pengembangan aplikasi manajemen keuangan dengan fitur budgeting menggunakan React Native. Jurnal Teknologi Informasi dan Komunikasi, 7(1), 45–56.

Wulandari, A., & Pratama, C. (2023). Aplikasi pencatat keuangan berbasis Android untuk manajemen pengeluaran harian. Jurnal Informatika dan Teknologi, 5(3), 78–85.
