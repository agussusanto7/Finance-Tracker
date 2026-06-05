import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import '../../constants/app_constants.dart';
import '../../providers/transaction_provider.dart';
import '../../models/transaction_model.dart';
import '../../utils/currency_formatter.dart';

class AudioDialogScreen extends StatefulWidget {
  const AudioDialogScreen({super.key});

  @override
  State<AudioDialogScreen> createState() => _AudioDialogScreenState();
}

class _AudioDialogScreenState extends State<AudioDialogScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  // STT (Ubah Suara ke Teks)
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _userSpokenText = "";

  // TTS (Ubah Teks ke Suara)
  final FlutterTts _flutterTts = FlutterTts();

  // Gemini AI
  late final GenerativeModel _model;
  late final ChatSession _chatSession;

  // Status UI
  String _statusText = "Inisialisasi Sistem...";
  bool _isListening = false;
  bool _isAiSpeaking = false;
  bool _isProcessing = false;
  bool _isLoudSpeaker = true; // Tambahan untuk kontrol volume

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _initAllSystems();
  }

  Future<void> _initAllSystems() async {
    try {
      // 1. Inisialisasi Speech to Text
      _speechEnabled = await _speechToText.initialize(
        onStatus: (status) {
          if (status == 'done' && _isListening) {
            _stopListeningAndProcess();
          }
        },
        onError: (errorNotification) {
          print("STT Error: $errorNotification");
          if (mounted) setState(() => _statusText = "Gagal menangkap suara");
          _stopListeningAndProcess(); // Paksa stop dan proses apa yang ada
        },
      );

      // 2. Inisialisasi Text to Speech
      await _flutterTts.setLanguage("id-ID");
      await _flutterTts.setSpeechRate(0.5); // Kecepatan bicara normal
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setStartHandler(() {
        if (mounted) setState(() => _isAiSpeaking = true);
      });

      _flutterTts.setCompletionHandler(() {
        if (mounted) {
          setState(() {
            _isAiSpeaking = false;
            _statusText = "Ketuk Ikon Mic untuk Bicara";
          });
        }
      });

      // 3. Inisialisasi Gemini (Mirip dengan text chat biasa)
      final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
      _model = GenerativeModel(
        model: 'gemini-3.1-flash-lite',
        apiKey: apiKey,
        systemInstruction: Content.system(
          'Kamu adalah asisten keuangan pribadi bernama "Finance Tracker AI". Jawab pertanyaan secara ramah, luwes, layaknya sedang menelepon. JANGAN berikan jawaban berupa tabel atau teks panjang markdown karena ini akan dibacakan oleh suara robot. Jawab dengan kalimat singkat yang enak diucap.',
        ),
        requestOptions: const RequestOptions(apiVersion: 'v1beta'),
      );
      _chatSession = _model.startChat();

      if (mounted) {
        setState(() {
          _statusText = _speechEnabled
              ? "Ketuk Ikon Mic untuk Bicara"
              : "Speech to Text tidak tersedia di HP ini";
        });
      }
    } catch (e) {
      if (mounted) setState(() => _statusText = "Error inisialisasi: $e");
    }
  }

  // ==========================================
  // LOGIKA MEREKAM SUARAA
  // ==========================================
  void _startListening() async {
    if (!_speechEnabled) return;

    // Hentikan AI yang sedang bicara jika kita mau ngomong
    if (_isAiSpeaking) {
      await _flutterTts.stop();
      setState(() => _isAiSpeaking = false);
    }

    setState(() {
      _isListening = true;
      _userSpokenText = "";
      _statusText = "Mendengarkan Anda...";
    });

    await _speechToText.listen(
      onResult: (result) {
        setState(() {
          _userSpokenText = result.recognizedWords;
          if (result.finalResult) {
            _stopListeningAndProcess();
          }
        });
      },
      localeId: "id_ID", // Paksa dengarkan bahasa Indonesia
    );
  }

  void _stopListeningAndProcess() async {
    if (!_isListening) return; // Mencegah double call

    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });

    if (_userSpokenText.isNotEmpty) {
      _processTextWithAI(_userSpokenText);
    } else {
      setState(() => _statusText = "Tidak mendengar suara. Coba lagi.");
    }
  }

  // ==========================================
  // LOGIKA MENGIRIM KE GEMINI DAN MEMBACA BALASAN
  // ==========================================
  Future<void> _processTextWithAI(String text) async {
    setState(() {
      _isProcessing = true;
      _statusText = "Memproses...";
    });

    try {
      // Ambil Konteks Keuangan
      final contextStr = _buildFinancialContext();
      final prompt =
          "$contextStr\n\nPertanyaan Pengguna dari Suara: $text\n\nIngat: Jawab dengan gaya bahasa lisan yang sangat ramah dan singkat karena jawabanmu akan dibacakan ke pengguna.";

      // Kirim ke Gemini
      final response = await _chatSession.sendMessage(Content.text(prompt));
      final replyText = response.text ?? "Maaf, saya tidak mengerti.";

      // Bersihkan teks dari simbol markdown (**, *, #, _, dll) agar tidak dibaca aneh oleh mesin TTS
      final cleanReplyText = replyText.replaceAll(RegExp(r'[*#_]'), '');

      setState(() {
        _isProcessing = false;
        _statusText = "AI Berbicara...";
      });

      // Bacakan Balasan yang sudah bersih!
      await _flutterTts.speak(cleanReplyText);
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _statusText = "Error AI: $e";
      });
    }
  }

  // Membangun string yang berisi saldo dan riwayat detail keuangan
  String _buildFinancialContext() {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final transactions = provider.transactions;
    final now = DateTime.now();

    double totalIncome = 0;
    double totalExpense = 0;
    double currentMonthIncome = 0;
    double currentMonthExpense = 0;

    // Untuk ringkasan per bulan
    Map<String, Map<String, double>> monthlySummary = {};

    for (var tx in transactions) {
      // Total keseluruhan
      if (tx.type == TransactionType.income) {
        totalIncome += tx.amount;
      } else {
        totalExpense += tx.amount;
      }

      // Bulan ini
      if (tx.date.year == now.year && tx.date.month == now.month) {
        if (tx.type == TransactionType.income) {
          currentMonthIncome += tx.amount;
        } else {
          currentMonthExpense += tx.amount;
        }
      }

      // Ringkasan per bulan
      String monthKey =
          '${tx.date.year}-${tx.date.month.toString().padLeft(2, '0')}';
      if (!monthlySummary.containsKey(monthKey)) {
        monthlySummary[monthKey] = {'income': 0.0, 'expense': 0.0};
      }
      if (tx.type == TransactionType.income) {
        monthlySummary[monthKey]!['income'] =
            monthlySummary[monthKey]!['income']! + tx.amount;
      } else {
        monthlySummary[monthKey]!['expense'] =
            monthlySummary[monthKey]!['expense']! + tx.amount;
      }
    }

    final balance = CurrencyFormatter.formatCurrency(provider.totalBalance);
    final income = CurrencyFormatter.formatCurrency(totalIncome);
    final expense = CurrencyFormatter.formatCurrency(totalExpense);
    final monthIncome = CurrencyFormatter.formatCurrency(currentMonthIncome);
    final monthExpense = CurrencyFormatter.formatCurrency(currentMonthExpense);

    String contextStr =
        "KONTEKS DATA KEUANGAN PENGGUNA SAAT INI (JADIKAN REFERENSI TAPI JANGAN SEBUTKAN SECARA EKSPLISIT KECUALI DITANYA):\n";
    contextStr += "- Waktu Saat Ini: ${now.toString()}\n";
    contextStr += "- Saldo Saat Ini (Total): $balance\n";
    contextStr += "- Pemasukan Bulan Ini: $monthIncome\n";
    contextStr += "- Pengeluaran Bulan Ini: $monthExpense\n";
    contextStr += "- Total Keseluruhan Pemasukan: $income\n";
    contextStr += "- Total Keseluruhan Pengeluaran: $expense\n";
    contextStr += "- Total Riwayat Transaksi: ${transactions.length}\n";

    if (monthlySummary.isNotEmpty) {
      contextStr += "\nRingkasan Per Bulan:\n";
      final sortedMonths = monthlySummary.keys.toList()
        ..sort((a, b) => b.compareTo(a));
      for (var month in sortedMonths.take(12)) {
        final inc = CurrencyFormatter.formatCurrency(
          monthlySummary[month]!['income']!,
        );
        final exp = CurrencyFormatter.formatCurrency(
          monthlySummary[month]!['expense']!,
        );
        contextStr += "- Bulan $month: Pemasukan $inc | Pengeluaran $exp\n";
      }
    }

    if (transactions.isNotEmpty) {
      contextStr += "\nRiwayat Detail (Maksimal 100 Transaksi Terakhir):\n";
      final recentTx = transactions.take(100).toList();
      for (var tx in recentTx) {
        final type = tx.type == TransactionType.income
            ? 'Pemasukan'
            : 'Pengeluaran';
        final amt = CurrencyFormatter.formatCurrency(tx.amount);
        final note = (tx.note?.isNotEmpty ?? false)
            ? ' (Catatan: ${tx.note})'
            : '';
        contextStr +=
            "- [${tx.date.toString().substring(0, 16)}] ${tx.category} ($type): $amt$note\n";
      }
    }

    return contextStr;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _speechToText.stop();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down, size: 32),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "Konsultasi Suara",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            const Spacer(),

            // Avatar AI
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                // Denyut animasi aktif jika AI sedang bicara, AI sedang memproses, atau sedang merekam
                final scale = (_isListening || _isAiSpeaking || _isProcessing)
                    ? _animationController.value
                    : 0.0;

                return Container(
                  width: 150 + (scale * 30),
                  height: 150 + (scale * 30),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppConstants.primaryColor.withOpacity(
                      0.1 + (scale * 0.15),
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppConstants.primaryColor,
                        boxShadow: [
                          BoxShadow(
                            color: AppConstants.primaryColor.withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isListening ? Icons.mic : Icons.smart_toy_rounded,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 40),

            // Text Tampilan apa yang diomongin User
            if (_userSpokenText.isNotEmpty && (_isListening || _isProcessing))
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  '"$_userSpokenText"',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: cs.onSurface.withOpacity(0.7),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // Teks Status
            Text(
              _statusText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const Spacer(),

            Container(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 40),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Tombol Loudspeaker / Pengatur Volume
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isLoudSpeaker = !_isLoudSpeaker;
                        // Ubah volume TTS: 1.0 (Maksimal/Loudspeaker), 0.3 (Kecil/Earpiece)
                        _flutterTts.setVolume(_isLoudSpeaker ? 1.0 : 0.3);
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isLoudSpeaker
                            ? AppConstants.primaryColor.withOpacity(0.2)
                            : cs.onSurface.withOpacity(0.05),
                      ),
                      child: Icon(
                        _isLoudSpeaker ? Icons.volume_up : Icons.volume_down,
                        color: _isLoudSpeaker
                            ? AppConstants.primaryColor
                            : cs.onSurface.withOpacity(0.5),
                        size: 28,
                      ),
                    ),
                  ),

                  // Tombol Utama (Bicara / Stop)
                  GestureDetector(
                    onTap: () {
                      if (_isListening) {
                        _stopListeningAndProcess();
                      } else if (!_isProcessing) {
                        _startListening();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isListening
                            ? Colors.red
                            : AppConstants.primaryColor,
                      ),
                      child: Icon(
                        _isListening ? Icons.stop : Icons.mic,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),

                  // Tombol Keluar
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red.withOpacity(0.1),
                      ),
                      child: const Icon(
                        Icons.call_end,
                        color: Colors.red,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
