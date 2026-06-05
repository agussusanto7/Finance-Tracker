import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';

class PdfReportService {
  static Future<Uint8List> generateMonthlyReport({
    required DateTime month,
    required List<TransactionModel> transactions,
    required double totalIncome,
    required double totalExpense,
    required Map<String, double> expenseByCategory,
    required Map<String, double> incomeByCategory,
    double? previousMonthIncome,
    double? previousMonthExpense,
  }) async {
    final pdf = pw.Document();
    final monthName = DateFormat('MMMM yyyy', 'id_ID').format(month);
    final balance = totalIncome - totalExpense;
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Calculate trends
    String incomeTrend = '';
    String expenseTrend = '';
    if (previousMonthIncome != null && previousMonthIncome > 0) {
      final change = ((totalIncome - previousMonthIncome) / previousMonthIncome * 100).round();
      incomeTrend = change >= 0 ? '+$change%' : '$change%';
    }
    if (previousMonthExpense != null && previousMonthExpense > 0) {
      final change = ((totalExpense - previousMonthExpense) / previousMonthExpense * 100).round();
      expenseTrend = change >= 0 ? '+$change%' : '$change%';
    }

    // Sort transactions by date (newest first)
    final sortedTransactions = List<TransactionModel>.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    // Colors
    const primaryColor = PdfColor.fromInt(0xFF5B61E0);
    const successColor = PdfColor.fromInt(0xFF2ED573);
    const errorColor = PdfColor.fromInt(0xFFFF4757);
    const textGrey = PdfColor.fromInt(0xFF8F95A3);
    const darkText = PdfColor.fromInt(0xFF1A1D26);
    const lightBg = PdfColor.fromInt(0xFFF4F5F9);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(monthName, primaryColor, textGrey),
        footer: (context) => _buildFooter(context, textGrey),
        build: (context) => [
          // Summary Cards
          _buildSummarySection(
            currencyFormat: currencyFormat,
            totalIncome: totalIncome,
            totalExpense: totalExpense,
            balance: balance,
            incomeTrend: incomeTrend,
            expenseTrend: expenseTrend,
            primaryColor: primaryColor,
            successColor: successColor,
            errorColor: errorColor,
            darkText: darkText,
            lightBg: lightBg,
            textGrey: textGrey,
          ),
          pw.SizedBox(height: 24),

          // Expense by Category
          if (expenseByCategory.isNotEmpty)
            _buildCategorySection(
              title: 'Pengeluaran per Kategori',
              categories: expenseByCategory,
              currencyFormat: currencyFormat,
              total: totalExpense,
              color: errorColor,
              primaryColor: primaryColor,
              darkText: darkText,
              textGrey: textGrey,
              lightBg: lightBg,
            ),
          if (expenseByCategory.isNotEmpty) pw.SizedBox(height: 20),

          // Income by Category
          if (incomeByCategory.isNotEmpty)
            _buildCategorySection(
              title: 'Pemasukan per Kategori',
              categories: incomeByCategory,
              currencyFormat: currencyFormat,
              total: totalIncome,
              color: successColor,
              primaryColor: primaryColor,
              darkText: darkText,
              textGrey: textGrey,
              lightBg: lightBg,
            ),
          if (incomeByCategory.isNotEmpty) pw.SizedBox(height: 20),

          // Transaction Table
          ..._buildTransactionTable(
            transactions: sortedTransactions,
            currencyFormat: currencyFormat,
            primaryColor: primaryColor,
            successColor: successColor,
            errorColor: errorColor,
            darkText: darkText,
            textGrey: textGrey,
            lightBg: lightBg,
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(
    String monthName,
    PdfColor primaryColor,
    PdfColor textGrey,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'LAPORAN KEUANGAN',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryColor,
                  letterSpacing: 1.5,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                monthName.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: 14,
                  color: textGrey,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'FinanceTracker',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Dicetak: ${DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(DateTime.now())}',
                style: pw.TextStyle(
                  fontSize: 9,
                  color: textGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context, PdfColor textGrey) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 12),
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColor.fromInt(0xFFE8E9EE), width: 0.5),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Dokumen ini digenerate otomatis oleh FinanceTracker',
            style: pw.TextStyle(fontSize: 8, color: textGrey),
          ),
          pw.Text(
            'Halaman ${context.pageNumber} dari ${context.pagesCount}',
            style: pw.TextStyle(fontSize: 8, color: textGrey),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummarySection({
    required NumberFormat currencyFormat,
    required double totalIncome,
    required double totalExpense,
    required double balance,
    required String incomeTrend,
    required String expenseTrend,
    required PdfColor primaryColor,
    required PdfColor successColor,
    required PdfColor errorColor,
    required PdfColor darkText,
    required PdfColor lightBg,
    required PdfColor textGrey,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: lightBg,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: const PdfColor.fromInt(0xFFE8E9EE), width: 0.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'RINGKASAN KEUANGAN',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: primaryColor,
              letterSpacing: 1,
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildSummaryCard(
                  label: 'Total Pemasukan',
                  value: currencyFormat.format(totalIncome),
                  trend: incomeTrend,
                  color: successColor,
                  darkText: darkText,
                  textGrey: textGrey,
                ),
              ),
              pw.SizedBox(width: 16),
              pw.Expanded(
                child: _buildSummaryCard(
                  label: 'Total Pengeluaran',
                  value: currencyFormat.format(totalExpense),
                  trend: expenseTrend,
                  color: errorColor,
                  darkText: darkText,
                  textGrey: textGrey,
                ),
              ),
              pw.SizedBox(width: 16),
              pw.Expanded(
                child: _buildSummaryCard(
                  label: 'Sisa Saldo',
                  value: currencyFormat.format(balance),
                  trend: '',
                  color: balance >= 0 ? primaryColor : errorColor,
                  darkText: darkText,
                  textGrey: textGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryCard({
    required String label,
    required String value,
    required String trend,
    required PdfColor color,
    required PdfColor darkText,
    required PdfColor textGrey,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: const PdfColor.fromInt(0xFFE8E9EE), width: 0.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontSize: 9, color: textGrey),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
          if (trend.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: pw.BoxDecoration(
                color: trend.startsWith('+')
                    ? const PdfColor.fromInt(0x1A2ED573)
                    : const PdfColor.fromInt(0x1AFF4757),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Text(
                '$trend dari bulan lalu',
                style: pw.TextStyle(
                  fontSize: 8,
                  color: trend.startsWith('+')
                      ? const PdfColor.fromInt(0xFF2ED573)
                      : const PdfColor.fromInt(0xFFFF4757),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildCategorySection({
    required String title,
    required Map<String, double> categories,
    required NumberFormat currencyFormat,
    required double total,
    required PdfColor color,
    required PdfColor primaryColor,
    required PdfColor darkText,
    required PdfColor textGrey,
    required PdfColor lightBg,
  }) {
    // Sort by value descending
    final sortedEntries = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: const PdfColor.fromInt(0xFFE8E9EE), width: 0.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title.toUpperCase(),
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: primaryColor,
              letterSpacing: 1,
            ),
          ),
          pw.SizedBox(height: 14),
          ...sortedEntries.map((entry) {
            final percentage = total > 0 ? (entry.value / total * 100) : 0.0;
            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        child: pw.Text(
                          entry.key,
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: darkText,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: pw.TextStyle(fontSize: 9, color: textGrey),
                      ),
                      pw.SizedBox(width: 8),
                      pw.Text(
                        currencyFormat.format(entry.value),
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  pw.ClipRRect(
                    horizontalRadius: 4,
                    verticalRadius: 4,
                    child: pw.LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: lightBg,
                      valueColor: color,
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

  static List<pw.Widget> _buildTransactionTable({
    required List<TransactionModel> transactions,
    required NumberFormat currencyFormat,
    required PdfColor primaryColor,
    required PdfColor successColor,
    required PdfColor errorColor,
    required PdfColor darkText,
    required PdfColor textGrey,
    required PdfColor lightBg,
  }) {
    return [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: primaryColor,
              borderRadius: const pw.BorderRadius.only(
                topLeft: pw.Radius.circular(12),
                topRight: pw.Radius.circular(12),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'DETAIL TRANSAKSI',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                    letterSpacing: 1,
                  ),
                ),
                pw.Text(
                  '${transactions.length} transaksi',
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.white,
                  ),
                ),
              ],
            ),
          ),
          if (transactions.isEmpty)
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(32),
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  left: const pw.BorderSide(color: PdfColor.fromInt(0xFFE8E9EE), width: 0.5),
                  right: const pw.BorderSide(color: PdfColor.fromInt(0xFFE8E9EE), width: 0.5),
                  bottom: const pw.BorderSide(color: PdfColor.fromInt(0xFFE8E9EE), width: 0.5),
                ),
                borderRadius: const pw.BorderRadius.only(
                  bottomLeft: pw.Radius.circular(12),
                  bottomRight: pw.Radius.circular(12),
                ),
              ),
              child: pw.Center(
                child: pw.Text(
                  'Tidak ada transaksi pada bulan ini',
                  style: pw.TextStyle(fontSize: 11, color: textGrey),
                ),
              ),
            )
          else
            pw.Table(
              border: const pw.TableBorder(
                left: pw.BorderSide(color: PdfColor.fromInt(0xFFE8E9EE), width: 0.5),
                right: pw.BorderSide(color: PdfColor.fromInt(0xFFE8E9EE), width: 0.5),
                bottom: pw.BorderSide(color: PdfColor.fromInt(0xFFE8E9EE), width: 0.5),
                verticalInside: pw.BorderSide.none,
                horizontalInside: pw.BorderSide(color: PdfColor.fromInt(0xFFE8E9EE), width: 0.5),
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(2.5),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(1),
                3: const pw.FlexColumnWidth(2),
                4: const pw.FlexColumnWidth(2),
              },
              children: [
                // Table Header
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: lightBg),
                  children: [
                    _tableHeaderCell('Tanggal'),
                    _tableHeaderCell('Kategori'),
                    _tableHeaderCell('Tipe'),
                    _tableHeaderCell('Keterangan'),
                    _tableHeaderCell('Nominal', align: pw.TextAlign.right),
                  ],
                ),
                // Table Rows
                ...transactions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final t = entry.value;
                  final isIncome = t.type == TransactionType.income;
                  final rowColor = index % 2 == 0
                      ? PdfColors.white
                      : lightBg;

                  return pw.TableRow(
                    decoration: pw.BoxDecoration(color: rowColor),
                    children: [
                      _tableCell(
                        DateFormat('dd/MM/yyyy HH:mm', 'id_ID').format(t.date),
                        darkText,
                      ),
                      _tableCell(t.category, darkText),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        child: pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: pw.BoxDecoration(
                            color: isIncome
                                ? const PdfColor.fromInt(0x1A2ED573)
                                : const PdfColor.fromInt(0x1AFF4757),
                            borderRadius: pw.BorderRadius.circular(4),
                          ),
                          child: pw.Text(
                            isIncome ? 'Masuk' : 'Keluar',
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                              color: isIncome ? successColor : errorColor,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                      ),
                      _tableCell(
                        t.note?.isNotEmpty == true ? t.note! : '-',
                        textGrey,
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        child: pw.Text(
                          currencyFormat.format(t.amount),
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: isIncome ? successColor : errorColor,
                          ),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
    ];
  }

  static pw.Widget _tableHeaderCell(String text, {pw.TextAlign? align}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          color: const PdfColor.fromInt(0xFF5B61E0),
        ),
        textAlign: align,
      ),
    );
  }

  static pw.Widget _tableCell(String text, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 9, color: color),
        maxLines: 2,
      ),
    );
  }
}
