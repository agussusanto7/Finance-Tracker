import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../constants/app_constants.dart';
import '../../models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/date_formatter.dart';

class TransactionResultScreen extends StatefulWidget {
  final String transactionType;
  final String period;
  final DateTime? startDate;
  final DateTime? endDate;

  const TransactionResultScreen({
    super.key,
    required this.transactionType,
    required this.period,
    this.startDate,
    this.endDate,
  });

  @override
  State<TransactionResultScreen> createState() => _TransactionResultScreenState();
}

class _TransactionResultScreenState extends State<TransactionResultScreen> {
  List<TransactionModel> _getFilteredTransactions(TransactionProvider provider) {
    List<TransactionModel> filtered = List.from(provider.transactions);

    // Filter by type
    if (widget.transactionType == 'Pemasukan') {
      filtered = filtered.where((t) => t.type == TransactionType.income).toList();
    } else if (widget.transactionType == 'Pengeluaran') {
      filtered = filtered.where((t) => t.type == TransactionType.expense).toList();
    }

    // Filter by date
    final now = DateTime.now();
    DateTime start = DateTime(2000);
    DateTime end = DateFormatter.getEndOfDay(now);

    if (widget.period == 'Hari Ini') {
      start = DateFormatter.getStartOfDay(now);
    } else if (widget.period == '1 Minggu') {
      start = DateFormatter.getStartOfDay(now.subtract(const Duration(days: 7)));
    } else if (widget.period == '1 Bulan') {
      start = DateFormatter.getStartOfDay(DateTime(now.year, now.month - 1, now.day));
    } else if (widget.period == 'Pilih Tanggal') {
      start = DateFormatter.getStartOfDay(widget.startDate ?? now);
      end = DateFormatter.getEndOfDay(widget.endDate ?? now);
    }

    filtered = filtered.where((t) => t.date.isAfter(start) && (t.date.isBefore(end) || t.date.isAtSameMomentAs(end))).toList();

    // Sort descending by date
    filtered.sort((a, b) => b.date.compareTo(a.date));

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat'),
        centerTitle: true,
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          final transactions = _getFilteredTransactions(provider);

          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Expanded(
                child: transactions.isEmpty
                    ? Center(
                        child: Text(
                          'Tidak ada transaksi',
                          style: TextStyle(color: AppConstants.textSecondary),
                        ),
                      )
                    : _buildTable(transactions),
              ),
              _buildDownloadButton(transactions),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTable(List<TransactionModel> transactions) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(AppConstants.primaryColor),
          headingTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          columnSpacing: 20,
          columns: const [
            DataColumn(label: Text('Uraian')),
            DataColumn(label: Text('Tipe')),
            DataColumn(label: Text('Nominal')),
            DataColumn(label: Text('Tanggal')),
          ],
          rows: transactions.map((t) {
            final isIncome = t.type == TransactionType.income;
            return DataRow(
              cells: [
                DataCell(
                  Container(
                    width: 150,
                    child: Text(
                      '${t.category}\n${t.note ?? ''}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    isIncome ? 'K' : 'D',
                    style: TextStyle(
                      color: isIncome ? AppConstants.successColor : AppConstants.errorColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    CurrencyFormatter.formatCurrency(t.amount),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                DataCell(
                  Text(
                    DateFormatter.formatDateTime(t.date),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDownloadButton(List<TransactionModel> transactions) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: transactions.isEmpty ? null : () => _exportTransactions(transactions),
        child: const Text(
          'Download',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _exportTransactions(List<TransactionModel> transactionsToExport) async {
    final action = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ekspor Transaksi'),
        content: const Text('Pilih metode ekspor data transaksi Anda:'),
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

    try {
      List<List<dynamic>> rows = [
        ["Uraian", "Kategori", "Tipe", "Tanggal", "Nominal"]
      ];

      for (var t in transactionsToExport) {
        rows.add([
          t.note ?? '',
          t.category,
          t.type == TransactionType.income ? 'Pemasukan' : 'Pengeluaran',
          DateFormatter.formatDateTime(t.date),
          CurrencyFormatter.formatCurrency(t.amount)
        ]);
      }

      String csvString = Csv().encode(rows);
      
      if (action == 'save') {
        final bytes = Uint8List.fromList(utf8.encode(csvString));
        final result = await FileSaver.instance.saveAs(
          name: 'transaksi_keuangan',
          bytes: bytes,
          fileExtension: 'csv',
          mimeType: MimeType.csv,
        );
        if (context.mounted && result != null && result.isNotEmpty) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Berhasil'),
              content: const Text('File berhasil disimpan ke perangkat Anda.'),
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
        final path = "${directory.path}/transaksi_keuangan.csv";
        final file = File(path);
        await file.writeAsString(csvString);
        
        final shareResult = await SharePlus.instance.share(
          ShareParams(
            files: [XFile(path)], 
            text: 'Berikut adalah data transaksi Anda.',
          ),
        );

        if (context.mounted && shareResult.status != ShareResultStatus.dismissed) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Berhasil'),
              content: const Text('Data transaksi berhasil dibagikan.'),
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengekspor data: $e')),
        );
      }
    }
  }
}
