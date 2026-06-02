import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../providers/transaction_provider.dart';
import '../../models/transaction_model.dart';
import 'package:intl/intl.dart';

class ChatFotoScreen extends StatefulWidget {
  const ChatFotoScreen({super.key});

  @override
  State<ChatFotoScreen> createState() => _ChatFotoScreenState();
}

class _ChatFotoScreenState extends State<ChatFotoScreen> {
  bool _isLoading = false;
  String _statusMessage = '';

  final ImagePicker _picker = ImagePicker();
  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  Future<void> _processImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) return;

      setState(() {
        _isLoading = true;
        _statusMessage = 'Menganalisis gambar...';
      });

      final imageBytes = await image.readAsBytes();

      if (_apiKey.isEmpty || _apiKey == 'API_KEY_GEMINI_ANDA_DI_SINI') {
        _showError('API Key Gemini tidak ditemukan.');
        return;
      }

      final model = GenerativeModel(
        model: 'gemini-3.1-flash-lite',
        apiKey: _apiKey,
      );

      final prompt = TextPart('''
Periksa gambar ini. Apakah ini adalah gambar struk belanja, nota, faktur, atau bukti transfer/transaksi keuangan lainnya?
Jika IYA, ekstrak informasinya dan kembalikan HANYA dalam format JSON berikut:
{
  "is_receipt": true,
  "type": "<pemasukan atau pengeluaran. Struk belanja/bayar tagihan = pengeluaran. Bukti transfer ATM biasanya 'pengeluaran' (uang keluar). Jika jelas merupakan bukti gaji/terima uang, isi 'pemasukan'>",
  "amount": <angka total belanja/transfer tanpa pemisah ribuan, contoh: 50000>,
  "category": "<kategori pengeluaran/pemasukan singkat, contoh: Transfer, Makanan, Transportasi, Gaji>",
  "note": "<Tuliskan deskripsi selengkap-lengkapnya termasuk nama tujuan transfer/toko dan rinciannya, contoh: Transfer ATM ke Tumisri atau Belanja di Indomaret>"
}

Jika BUKAN struk (misalnya foto wajah orang, pemandangan, atau benda acak yang tidak berhubungan dengan transaksi), kembalikan HANYA dalam format JSON berikut:
{
  "is_receipt": false,
  "message": "Gambar tidak terdeteksi sebagai bukti transaksi."
}
Pastikan tidak ada teks lain selain JSON.
''');

      final imagePart = DataPart('image/jpeg', imageBytes);

      final response = await model.generateContent([
        Content.multi([prompt, imagePart])
      ]);

      final text = response.text;
      if (text != null) {
        // Membersihkan markdown JSON jika ada
        String jsonString = text.trim();
        if (jsonString.startsWith('```json')) {
          jsonString = jsonString.replaceAll('```json', '');
          jsonString = jsonString.replaceAll('```', '');
        } else if (jsonString.startsWith('```')) {
          jsonString = jsonString.replaceAll('```', '');
        }

        final data = jsonDecode(jsonString.trim());
        
        bool isReceipt = data['is_receipt'] ?? true;
        
        if (!isReceipt || data.containsKey('message') && data['amount'] == null) {
          _showError(data['message'] ?? 'Gambar yang diupload bukan struk transaksi.');
          return;
        }
        
        double amount = (data['amount'] as num).toDouble();
        String typeString = data['type']?.toString().toLowerCase() ?? 'pengeluaran';
        String category = data['category'] ?? 'Lainnya';
        String note = data['note'] ?? 'Dari Scan Foto';

        setState(() {
          _statusMessage = 'Menyimpan transaksi...';
        });

        TransactionType txType = (typeString == 'pemasukan') 
            ? TransactionType.income 
            : TransactionType.expense;

        // Simpan transaksi
        final transaction = TransactionModel(
          amount: amount,
          type: txType,
          category: category,
          date: DateTime.now(),
          note: note,
          imagePath: image.path,
        );

        final provider = Provider.of<TransactionProvider>(context, listen: false);
        await provider.addTransaction(transaction);

        if (mounted) {
          String typeName = txType == TransactionType.income ? 'pemasukan' : 'pengeluaran';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Berhasil menambahkan $typeName: Rp ${NumberFormat('#,###', 'id_ID').format(amount)}'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // Kembali setelah berhasil
        }
      } else {
        _showError('Gagal mendapatkan respon dari AI.');
      }
    } catch (e) {
      _showError('Terjadi kesalahan: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Bukti Transaksi'),
        backgroundColor: cs.surface,
        centerTitle: true,
      ),
      body: Center(
        child: _isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
                  ),
                  const SizedBox(height: 16),
                  Text(_statusMessage),
                ],
              )
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 80,
                      color: AppConstants.primaryColor,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Otomatis catat pengeluaran Anda dengan memfoto struk belanja.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 48),
                    ElevatedButton.icon(
                      onPressed: () => _processImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      label: const Text('Ambil Foto Kamera', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => _processImage(ImageSource.gallery),
                      icon: Icon(Icons.image, color: AppConstants.primaryColor),
                      label: Text('Pilih dari Galeri', style: TextStyle(color: AppConstants.primaryColor)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppConstants.primaryColor),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
