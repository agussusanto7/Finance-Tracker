import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants/app_constants.dart';
import '../../models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/budget_provider.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/date_formatter.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionType? initialType;
  const AddTransactionScreen({super.key, this.initialType});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  TransactionType _transactionType = TransactionType.expense;
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    if (widget.initialType != null) {
      _transactionType = widget.initialType!;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    _showImageSourceDialog();
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Sumber Gambar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () async {
                Navigator.pop(context);
                await _pickImageFromSource(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () async {
                Navigator.pop(context);
                await _pickImageFromSource(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _imagePath = image.path;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Gagal mengambil gambar')));
      }
    }
  }

  Future<void> _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih kategori terlebih dahulu')),
        );
        return;
      }

      final amount =
          double.tryParse(
            _amountController.text.replaceAll(RegExp(r'[Rp\s.]'), ''),
          ) ??
          0.0;

      if (amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Masukkan nominal yang valid')),
        );
        return;
      }

      // Validasi budget untuk pengeluaran
      if (_transactionType == TransactionType.expense) {
        final budgetProvider = context.read<BudgetProvider>();
        final budget = await budgetProvider.getBudgetByCategory(
          _selectedCategory!,
        );

        if (budget != null) {
          // Hitung total pengeluaran bulan ini untuk kategori ini
          final currentMonth = DateTime(
            _selectedDate.year,
            _selectedDate.month,
            1,
          );
          final currentExpense = await budgetProvider.getExpenseByCategory(
            _selectedCategory!,
            currentMonth,
          );

          // Cek apakah pengeluaran baru akan melebihi budget
          if (currentExpense + amount > budget.amountLimit) {
            final remainingBudget = budget.amountLimit - currentExpense;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Uang jatah bulanan Anda untuk kategori $_selectedCategory sudah limit!\n'
                  'Sisa budget: Rp ${CurrencyFormatter.formatCurrency(remainingBudget > 0 ? remainingBudget : 0)}',
                ),
                backgroundColor: AppConstants.errorColor,
                duration: const Duration(seconds: 4),
              ),
            );
            return;
          }
        }
      }

      final transaction = TransactionModel(
        amount: amount,
        type: _transactionType,
        category: _selectedCategory!,
        date: _selectedDate,
        note: _noteController.text.isEmpty ? null : _noteController.text,
        imagePath: _imagePath,
      );

      context.read<TransactionProvider>().addTransaction(transaction);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi berhasil disimpan')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _transactionType == TransactionType.income
              ? 'Tambah Pemasukan'
              : 'Tambah Pengeluaran',
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTypeSelector(),
              SizedBox(height: MediaQuery.of(context).size.width * 0.04),
              _buildAmountField(),
              SizedBox(height: MediaQuery.of(context).size.width * 0.04),
              _buildCategorySelector(),
              SizedBox(height: MediaQuery.of(context).size.width * 0.04),
              _buildDateSelector(),
              SizedBox(height: MediaQuery.of(context).size.width * 0.04),
              _buildNoteField(),
              SizedBox(height: MediaQuery.of(context).size.width * 0.04),
              _buildImagePicker(),
              SizedBox(height: MediaQuery.of(context).size.width * 0.08),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _transactionType = TransactionType.income;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
                  decoration: BoxDecoration(
                    color: _transactionType == TransactionType.income
                        ? AppConstants.successColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusMedium,
                    ),
                    border: Border.all(
                      color: _transactionType == TransactionType.income
                          ? AppConstants.successColor
                          : AppConstants.dividerColor,
                    ),
                  ),
                  child: Text(
                    'Pemasukan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _transactionType == TransactionType.income
                          ? Colors.white
                          : AppConstants.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: screenWidth * 0.035,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.04),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _transactionType = TransactionType.expense;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
                  decoration: BoxDecoration(
                    color: _transactionType == TransactionType.expense
                        ? AppConstants.errorColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusMedium,
                    ),
                    border: Border.all(
                      color: _transactionType == TransactionType.expense
                          ? AppConstants.errorColor
                          : AppConstants.dividerColor,
                    ),
                  ),
                  child: Text(
                    'Pengeluaran',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _transactionType == TransactionType.expense
                          ? Colors.white
                          : AppConstants.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: screenWidth * 0.035,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nominal',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontSize: screenWidth * 0.04),
            ),
            SizedBox(height: screenWidth * 0.02),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                _CurrencyInputFormatter(),
              ],
              decoration: InputDecoration(
                hintText: '0',
                prefixText: 'Rp ',
                contentPadding: EdgeInsets.all(screenWidth * 0.03),
              ),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.08,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Masukkan nominal';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kategori',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontSize: screenWidth * 0.04),
            ),
            SizedBox(height: screenWidth * 0.04),
            FutureBuilder(
              future: context.read<CategoryProvider>().getCategoriesByType(
                _transactionType,
              ),
              builder: (context, AsyncSnapshot<List> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return const Text('Gagal memuat kategori');
                }

                final categories = snapshot.data!;
                return Wrap(
                  spacing: screenWidth * 0.02,
                  runSpacing: screenWidth * 0.02,
                  children: categories.map((category) {
                    final isSelected = _selectedCategory == category.name;
                    return FilterChip(
                      label: Text(
                        category.name,
                        style: TextStyle(fontSize: screenWidth * 0.032),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category.name;
                        });
                      },
                      selectedColor: AppConstants.primaryOrange.withOpacity(
                        0.2,
                      ),
                      checkmarkColor: AppConstants.primaryOrange,
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.calendar_today),
        title: const Text('Tanggal'),
        subtitle: Text(DateFormatter.formatDate(_selectedDate)),
        trailing: const Icon(Icons.chevron_right),
        onTap: _selectDate,
      ),
    );
  }

  Widget _buildNoteField() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: TextFormField(
          controller: _noteController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Catatan (Opsional)',
            hintText: 'Tambahkan catatan...',
            contentPadding: EdgeInsets.all(screenWidth * 0.03),
            labelStyle: TextStyle(fontSize: screenWidth * 0.035),
          ),
          style: TextStyle(fontSize: screenWidth * 0.035),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bukti Transaksi (Opsional)',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontSize: screenWidth * 0.04),
            ),
            SizedBox(height: screenWidth * 0.04),
            if (_imagePath != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                child: Image.file(
                  File(_imagePath!),
                  height: screenWidth * 0.5,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return SizedBox(
                      height: screenWidth * 0.5,
                      child: Center(
                        child: Text(
                          'Gambar tidak dapat dimuat',
                          style: TextStyle(fontSize: screenWidth * 0.035),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: screenWidth * 0.04),
            ],
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: Icon(
                _imagePath == null ? Icons.add_a_photo : Icons.change_circle,
              ),
              label: Text(_imagePath == null ? 'Tambah Bukti' : 'Ganti Bukti'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenWidth * 0.03,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    final screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveTransaction,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
        ),
        child: Text(
          'Simpan Transaksi',
          style: TextStyle(fontSize: screenWidth * 0.04),
        ),
      ),
    );
  }
}

class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final value = int.tryParse(newValue.text) ?? 0;
    final formatted = CurrencyFormatter.formatCurrency(
      value.toDouble(),
    ).replaceAll('Rp ', '');

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
