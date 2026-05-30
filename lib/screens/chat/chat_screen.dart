import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../constants/app_constants.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../models/transaction_model.dart';
import '../../utils/currency_formatter.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // API Key Gemini yang diambil dari .env
  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  late final GenerativeModel _model;
  late final ChatSession _chatSession;

  bool _isLoading = false;

  final List<Map<String, dynamic>> _messages = [
    {
      'isUser': false,
      'text':
          'Halo! Saya asisten keuangan cerdas Anda (Didukung oleh AI Gemini). Ada yang bisa saya bantu terkait pengelolaan uang atau konsultasi keuangan Anda hari ini?',
      'time':
          '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initGemini();
  }

  void _initGemini() {
    // Inisialisasi model Gemini 2.5 Flash
    _model = GenerativeModel(
      model: 'gemini-2.5-flash-lite',
      apiKey: _apiKey,
      systemInstruction: Content.system(
        'Kamu adalah asisten keuangan pribadi yang profesional, ramah, dan solutif. Tugasmu adalah membantu pengguna memberikan saran pengelolaan keuangan, tips berhemat, dan menjawab pertanyaan terkait keuangan pribadi dengan bahasa Indonesia yang mudah dipahami.',
      ),
      requestOptions: const RequestOptions(apiVersion: 'v1beta'),
    );
    // Mulai sesi chat
    _chatSession = _model.startChat();
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    // 1. Tambahkan pesan pengguna ke UI
    final currentTime =
        '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}';

    setState(() {
      _messages.add({'isUser': true, 'text': messageText, 'time': currentTime});
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // Cek apakah API Key belum diisi
    if (_apiKey == 'API_KEY_GEMINI_ANDA_DI_SINI') {
      setState(() {
        _messages.add({
          'isUser': false,
          'text':
              'Maaf, API Key Gemini belum diatur. Silakan ganti variabel _apiKey di file chat_screen.dart dengan API Key valid dari Google AI Studio.',
          'time': currentTime,
        });
        _isLoading = false;
      });
      _scrollToBottom();
      return;
    }

    try {
      final contextStr = _buildFinancialContext();
      final fullPrompt =
          '$contextStr\n\nPertanyaan Pengguna: $messageText\n\nInstruksi Tambahan: Jawablah pertanyaan pengguna berdasarkan data keuangan di atas. Berikan jawaban secara langsung dan ramah tanpa mengulangi konteks data yang kuberikan.';

      // 2. Kirim pesan ke API Gemini dengan konteks
      final response = await _chatSession.sendMessage(Content.text(fullPrompt));

      // 3. Tambahkan balasan AI ke UI
      setState(() {
        _messages.add({
          'isUser': false,
          'text': response.text ?? 'Maaf, saya tidak mengerti.',
          'time':
              '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        });
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      // Handle Error
      setState(() {
        _messages.add({
          'isUser': false,
          'text': 'Maaf, terjadi kesalahan saat menyambungkan ke server: $e',
          'time':
              '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        });
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _buildFinancialContext() {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final transactions = provider.transactions;

    double totalIncome = 0;
    double totalExpense = 0;

    for (var tx in transactions) {
      if (tx.type == TransactionType.income) {
        totalIncome += tx.amount;
      } else {
        totalExpense += tx.amount;
      }
    }

    final balance = CurrencyFormatter.formatCurrency(provider.totalBalance);
    final income = CurrencyFormatter.formatCurrency(totalIncome);
    final expense = CurrencyFormatter.formatCurrency(totalExpense);

    String contextStr =
        "KONTEKS DATA KEUANGAN PENGGUNA SAAT INI (JANGAN SEBUTKAN INI KE PENGGUNA SECARA EKSPLISIT, GUNAKAN SEBAGAI PENGETAHUAN):\n";
    contextStr += "- Saldo Saat Ini: $balance\n";
    contextStr += "- Total Pemasukan: $income\n";
    contextStr += "- Total Pengeluaran: $expense\n";
    contextStr += "- Total Riwayat Transaksi: ${transactions.length}\n";

    if (transactions.isNotEmpty) {
      contextStr += "\n5 Transaksi Terakhir:\n";
      // Ambil 5 transaksi teratas (sudah diurutkan dari terbaru di provider)
      final recentTx = transactions.take(5).toList();
      for (var tx in recentTx) {
        final type = tx.type == TransactionType.income
            ? 'Pemasukan'
            : 'Pengeluaran';
        final amt = CurrencyFormatter.formatCurrency(tx.amount);
        contextStr +=
            "- [${tx.date.toString().substring(0, 10)}] ${tx.category} ($type): $amt\n";
      }
    }

    return contextStr;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textPrimary = cs.onSurface;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              'Konsultasi AI',
              style: TextStyle(
                color: textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Powered by Gemini',
              style: TextStyle(
                color: AppConstants.primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['isUser'] as bool;

                return _buildChatBubble(
                  context: context,
                  text: message['text'] as String,
                  time: message['time'] as String,
                  isUser: isUser,
                );
              },
            ),
          ),

          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppConstants.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'AI sedang mengetik...',
                        style: TextStyle(
                          color: cs.onSurface.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          _buildMessageInput(context),
        ],
      ),
    );
  }

  Widget _buildChatBubble({
    required BuildContext context,
    required String text,
    required String time,
    required bool isUser,
  }) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
              child: Icon(
                Icons.smart_toy_rounded,
                color: AppConstants.primaryColor,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? AppConstants.primaryColor : cs.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  isUser
                      ? Text(
                          text,
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        )
                      : MarkdownBody(
                          data: text,
                          styleSheet: MarkdownStyleSheet(
                            p: TextStyle(color: cs.onSurface, fontSize: 14),
                            strong: TextStyle(
                              color: cs.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            listBullet: TextStyle(
                              color: cs.onSurface,
                              fontSize: 14,
                            ),
                          ),
                        ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: TextStyle(
                      color: isUser
                          ? Colors.white70
                          : cs.onSurface.withOpacity(0.5),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser)
            const SizedBox(width: 48), // Padding agar tidak mentok kiri
          if (!isUser)
            const SizedBox(width: 48), // Padding agar tidak mentok kanan
        ],
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                style: TextStyle(color: cs.onSurface),
                enabled: !_isLoading,
                decoration: InputDecoration(
                  hintText: _isLoading
                      ? 'Menunggu balasan...'
                      : 'Ketik pesan...',
                  hintStyle: TextStyle(color: cs.onSurface.withOpacity(0.5)),
                  filled: true,
                  fillColor: Theme.of(context).scaffoldBackgroundColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _isLoading ? null : _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isLoading
                      ? AppConstants.dividerColor
                      : AppConstants.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
