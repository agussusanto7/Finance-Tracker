import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/app_constants.dart';
import '../../models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/currency_formatter.dart';
import '../../services/pdf_report_service.dart';

class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({super.key});

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  DateTime _selectedMonth = DateTime.now();
  bool _isGenerating = false;

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + delta);
    });
  }

  List<TransactionModel> _filterByMonth(List<TransactionModel> all, DateTime month) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    return all.where((t) =>
      t.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
      t.date.isBefore(end.add(const Duration(seconds: 1)))
    ).toList();
  }

  double _sumByType(List<TransactionModel> txns, TransactionType type) {
    return txns.where((t) => t.type == type).fold(0.0, (sum, t) => sum + t.amount);
  }

  Map<String, double> _groupByCategory(List<TransactionModel> txns, TransactionType type) {
    final map = <String, double>{};
    for (var t in txns.where((t) => t.type == type)) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
  }

  Future<void> _generatePdf(List<TransactionModel> allTransactions) async {
    final action = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ekspor Laporan'),
        content: const Text('Pilih metode ekspor data laporan Anda:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'share'),
            child: const Text('Bagikan'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'save'),
            child: const Text('Simpan ke HP'),
          ),
        ],
      ),
    );

    if (action == null) return;

    setState(() => _isGenerating = true);

    try {
      final txns = _filterByMonth(allTransactions, _selectedMonth);
      final income = _sumByType(txns, TransactionType.income);
      final expense = _sumByType(txns, TransactionType.expense);
      final expByCat = _groupByCategory(txns, TransactionType.expense);
      final incByCat = _groupByCategory(txns, TransactionType.income);

      final prevMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
      final prevTxns = _filterByMonth(allTransactions, prevMonth);
      final prevIncome = _sumByType(prevTxns, TransactionType.income);
      final prevExpense = _sumByType(prevTxns, TransactionType.expense);

      final pdfBytes = await PdfReportService.generateMonthlyReport(
        month: _selectedMonth,
        transactions: txns,
        totalIncome: income,
        totalExpense: expense,
        expenseByCategory: expByCat,
        incomeByCategory: incByCat,
        previousMonthIncome: prevIncome,
        previousMonthExpense: prevExpense,
      );

      if (!mounted) return;

      final monthStr = DateFormat('MMMM_yyyy', 'id_ID').format(_selectedMonth);
      
      if (action == 'save') {
        final result = await FileSaver.instance.saveAs(
          name: 'laporan_keuangan_$monthStr',
          bytes: pdfBytes,
          fileExtension: 'pdf',
          mimeType: MimeType.pdf,
        );
        
        if (mounted && result != null && result.isNotEmpty) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Berhasil'),
              content: const Text('Laporan PDF berhasil disimpan ke perangkat Anda.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } else if (action == 'share') {
        final directory = await getApplicationDocumentsDirectory();
        final path = "${directory.path}/laporan_keuangan_$monthStr.pdf";
        final file = File(path);
        await file.writeAsBytes(pdfBytes);
        
        final shareResult = await SharePlus.instance.share(
          ShareParams(
            files: [XFile(path)], 
            text: 'Berikut adalah laporan keuangan bulanan Anda.',
          ),
        );

        if (mounted && shareResult.status != ShareResultStatus.dismissed) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Berhasil'),
              content: const Text('Laporan berhasil dibagikan.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat PDF: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _previewPdf(List<TransactionModel> allTransactions) async {
    final txns = _filterByMonth(allTransactions, _selectedMonth);
    final income = _sumByType(txns, TransactionType.income);
    final expense = _sumByType(txns, TransactionType.expense);
    final expByCat = _groupByCategory(txns, TransactionType.expense);
    final incByCat = _groupByCategory(txns, TransactionType.income);

    final prevMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    final prevTxns = _filterByMonth(allTransactions, prevMonth);
    final prevIncome = _sumByType(prevTxns, TransactionType.income);
    final prevExpense = _sumByType(prevTxns, TransactionType.expense);

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Preview PDF')),
          body: PdfPreview(
            build: (_) => PdfReportService.generateMonthlyReport(
              month: _selectedMonth,
              transactions: txns,
              totalIncome: income,
              totalExpense: expense,
              expenseByCategory: expByCat,
              incomeByCategory: incByCat,
              previousMonthIncome: prevIncome,
              previousMonthExpense: prevExpense,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final textPrimary = cs.onSurface;
    final textSecondary = cs.onSurface.withValues(alpha: 0.55);

    return Scaffold(
      appBar: AppBar(title: const Text('Laporan Keuangan'), centerTitle: true),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          final txns = _filterByMonth(provider.transactions, _selectedMonth);
          final income = _sumByType(txns, TransactionType.income);
          final expense = _sumByType(txns, TransactionType.expense);
          final balance = income - expense;
          final expByCat = _groupByCategory(txns, TransactionType.expense);
          final incByCat = _groupByCategory(txns, TransactionType.income);

          // Trend calculation
          final prevMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
          final prevTxns = _filterByMonth(provider.transactions, prevMonth);
          final prevIncome = _sumByType(prevTxns, TransactionType.income);
          final prevExpense = _sumByType(prevTxns, TransactionType.expense);

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Month Selector
                _buildMonthSelector(textPrimary),
                const SizedBox(height: 20),

                // Summary Cards
                _buildSummaryCards(income, expense, balance, prevIncome, prevExpense, cardBg, textSecondary),
                const SizedBox(height: 20),

                // Category Breakdown
                if (expByCat.isNotEmpty)
                  _buildCategoryCard('Pengeluaran per Kategori', expByCat, expense, AppConstants.errorColor, cardBg, textPrimary, textSecondary),
                if (expByCat.isNotEmpty) const SizedBox(height: 16),
                if (incByCat.isNotEmpty)
                  _buildCategoryCard('Pemasukan per Kategori', incByCat, income, AppConstants.successColor, cardBg, textPrimary, textSecondary),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _previewPdf(provider.transactions),
                        icon: const Icon(Icons.visibility_rounded),
                        label: const Text('Preview'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: AppConstants.primaryColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _isGenerating ? null : () => _generatePdf(provider.transactions),
                        icon: _isGenerating
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : SvgPicture.asset(
                                'assets/svg/pdf-svgrepo-com.svg',
                                width: 22,
                                height: 22,
                                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                              ),
                        label: Text(
                          _isGenerating ? 'Membuat PDF...' : 'Download / Share PDF',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMonthSelector(Color textPrimary) {
    final monthStr = DateFormat('MMMM yyyy', 'id_ID').format(_selectedMonth);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded, size: 28),
            onPressed: () => _changeMonth(-1),
            color: AppConstants.primaryColor,
          ),
          Text(
            monthStr,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: textPrimary),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded, size: 28),
            onPressed: DateTime(_selectedMonth.year, _selectedMonth.month + 1).isAfter(DateTime.now())
                ? null
                : () => _changeMonth(1),
            color: AppConstants.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(double income, double expense, double balance, double prevIncome, double prevExpense, Color cardBg, Color textSecondary) {
    String trendText(double current, double previous) {
      if (previous <= 0) return '';
      final pct = ((current - previous) / previous * 100).round();
      return pct >= 0 ? '+$pct%' : '$pct%';
    }

    return Column(
      children: [
        // Balance Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppConstants.primaryColor, AppConstants.gradientEnd]),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [BoxShadow(color: AppConstants.primaryColor.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 8))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sisa Saldo Bulan Ini', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  CurrencyFormatter.formatCurrency(balance),
                  style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${txnCount(income, expense)} transaksi bulan ini',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _buildMiniCard('Pemasukan', income, trendText(income, prevIncome), AppConstants.successColor, cardBg, textSecondary)),
            const SizedBox(width: 12),
            Expanded(child: _buildMiniCard('Pengeluaran', expense, trendText(expense, prevExpense), AppConstants.errorColor, cardBg, textSecondary)),
          ],
        ),
      ],
    );
  }

  String txnCount(double income, double expense) {
    final txns = _filterByMonth(
      Provider.of<TransactionProvider>(context, listen: false).transactions,
      _selectedMonth,
    );
    return '${txns.length}';
  }

  Widget _buildMiniCard(String label, double amount, String trend, Color color, Color cardBg, Color textSecondary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                child: Icon(
                  label == 'Pemasukan' ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                  color: color, size: 16,
                ),
              ),
              const Spacer(),
              if (trend.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: trend.startsWith('+') ? AppConstants.successColor.withValues(alpha: 0.1) : AppConstants.errorColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    trend,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold,
                      color: trend.startsWith('+') ? AppConstants.successColor : AppConstants.errorColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(label, style: TextStyle(color: textSecondary, fontSize: 12)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              CurrencyFormatter.formatCurrency(amount),
              style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String title, Map<String, double> categories, double total, Color color, Color cardBg, Color textPrimary, Color textSecondary) {
    final sorted = categories.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textPrimary)),
          const SizedBox(height: 16),
          ...sorted.map((e) {
            final pct = total > 0 ? e.value / total : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(e.key, style: TextStyle(fontSize: 13, color: textPrimary))),
                      Text('${(pct * 100).toStringAsFixed(1)}%', style: TextStyle(fontSize: 11, color: textSecondary)),
                      const SizedBox(width: 8),
                      Text(CurrencyFormatter.formatCompact(e.value), style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: color.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation(color),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
