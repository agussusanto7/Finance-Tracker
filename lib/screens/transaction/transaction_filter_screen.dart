import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../utils/date_formatter.dart';
import 'transaction_result_screen.dart';

class TransactionFilterScreen extends StatefulWidget {
  const TransactionFilterScreen({super.key});

  @override
  State<TransactionFilterScreen> createState() => _TransactionFilterScreenState();
}

class _TransactionFilterScreenState extends State<TransactionFilterScreen> {
  String _selectedTransactionType = 'Semua Transaksi';
  final List<String> _transactionTypes = [
    'Semua Transaksi',
    'Pemasukan',
    'Pengeluaran'
  ];

  String _selectedPeriod = 'Hari Ini';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Filter'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Jenis Transaksi'),
              const SizedBox(height: 8),
              _buildDropdown(),
              const SizedBox(height: AppConstants.paddingLarge),
              _buildSectionTitle('Pilih Periode Pencarian'),
              const SizedBox(height: 8),
              _buildPeriodRadio('Hari Ini'),
              _buildDivider(),
              _buildPeriodRadio('1 Minggu'),
              _buildDivider(),
              _buildPeriodRadio('1 Bulan'),
              _buildDivider(),
              _buildPeriodRadio('Pilih Tanggal'),
              if (_selectedPeriod == 'Pilih Tanggal') ...[
                const SizedBox(height: 16),
                _buildDatePickers(),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedTransactionType,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          items: _transactionTypes.map((String type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(type),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedTransactionType = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildPeriodRadio(String title) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPeriod = title;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
            Icon(
              _selectedPeriod == title
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: _selectedPeriod == title
                  ? AppConstants.primaryColor
                  : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Colors.grey.shade200,
    );
  }

  Widget _buildDatePickers() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tanggal Awal', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _startDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: AppConstants.primaryColor,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (date != null) {
                    setState(() {
                      _startDate = date;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: AppConstants.primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        _startDate != null ? DateFormatter.formatShortDate(_startDate!) : 'Pilih',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text('-', style: TextStyle(fontSize: 24, color: Colors.grey)),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tanggal Akhir', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _endDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: AppConstants.primaryColor,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (date != null) {
                    setState(() {
                      _endDate = date;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: AppConstants.primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        _endDate != null ? DateFormatter.formatShortDate(_endDate!) : 'Pilih',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    return Container(
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
        onPressed: () {
          if (_selectedPeriod == 'Pilih Tanggal' && (_startDate == null || _endDate == null)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Silakan pilih Tanggal Awal dan Tanggal Akhir')),
            );
            return;
          }
          if (_selectedPeriod == 'Pilih Tanggal' && _startDate!.isAfter(_endDate!)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tanggal Awal tidak boleh lebih dari Tanggal Akhir')),
            );
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TransactionResultScreen(
                transactionType: _selectedTransactionType,
                period: _selectedPeriod,
                startDate: _startDate,
                endDate: _endDate,
              ),
            ),
          );
        },
        child: const Text(
          'Selanjutnya',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
