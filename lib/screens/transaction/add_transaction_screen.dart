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

  // ─── Init / Dispose ────────────────────────────────────────────────────────

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

  // ─── Computed getters ──────────────────────────────────────────────────────

  bool get _isIncome => _transactionType == TransactionType.income;
  Color get _primaryColor =>
      _isIncome ? AppConstants.successColor : AppConstants.errorColor;

  IconData _iconFor(String name) {
    const map = <String, IconData>{
      'Gaji': Icons.account_balance_wallet_outlined,
      'Bonus': Icons.card_giftcard_outlined,
      'Investasi': Icons.trending_up_outlined,
      'Hadiah': Icons.redeem_outlined,
      'Makanan': Icons.restaurant_outlined,
      'Makan': Icons.restaurant_outlined,
      'Transport': Icons.directions_car_outlined,
      'Transportasi': Icons.directions_car_outlined,
      'Belanja': Icons.shopping_bag_outlined,
      'Hiburan': Icons.movie_outlined,
      'Kesehatan': Icons.favorite_border,
      'Tagihan': Icons.receipt_outlined,
      'Pendidikan': Icons.school_outlined,
      'Olahraga': Icons.fitness_center_outlined,
      'Liburan': Icons.flight_outlined,
      'Rumah': Icons.home_outlined,
      'Lainnya': Icons.more_horiz,
    };
    return map[name] ?? Icons.category_outlined;
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  SEMUA LOGIC DI BAWAH INI IDENTIK 100% DENGAN KODE ASLI — TIDAK DIUBAH
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && mounted) {
      // Setelah pilih tanggal, tampilkan time picker untuk memilih jam
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          );
        },
      );
      setState(() {
        if (pickedTime != null) {
          // Gabungkan tanggal + jam yang dipilih
          _selectedDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        } else {
          // Jika user skip time picker, gunakan jam saat ini
          final now = DateTime.now();
          _selectedDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            now.hour,
            now.minute,
          );
        }
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

  /// ⚠️ TIDAK ADA SATU KARAKTER PUN YANG BERUBAH DARI KODE ASLI
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

  // ─── Category Bottom Sheet ─────────────────────────────────────────────────

  void _showCategoryBottomSheet(List categories, double sw, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final sheetBg = isDark ? const Color(0xFF1E1E2E) : Colors.white;
        return Container(
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.fromLTRB(
            sw * 0.05,
            sw * 0.03,
            sw * 0.05,
            MediaQuery.of(context).padding.bottom + sw * 0.06,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: sw * 0.1,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: sw * 0.05),
              Text(
                'Pilih Kategori',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: sw * 0.048,
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                ),
              ),
              SizedBox(height: sw * 0.01),
              Text(
                _isIncome ? 'Kategori pemasukan' : 'Kategori pengeluaran',
                style: TextStyle(
                  fontSize: sw * 0.032,
                  color: isDark ? Colors.white38 : Colors.grey[500],
                ),
              ),
              SizedBox(height: sw * 0.05),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 0.82,
                  crossAxisSpacing: sw * 0.02,
                  mainAxisSpacing: sw * 0.025,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = _selectedCategory == cat.name;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedCategory = cat.name);
                      Navigator.pop(context);
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: sw * 0.148,
                          height: sw * 0.148,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _primaryColor
                                : _primaryColor.withOpacity(isDark ? 0.2 : 0.1),
                            borderRadius: BorderRadius.circular(sw * 0.04),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: _primaryColor.withOpacity(0.4),
                                      blurRadius: sw * 0.025,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Icon(
                            _iconFor(cat.name),
                            color: isSelected ? Colors.white : _primaryColor,
                            size: sw * 0.065,
                          ),
                        ),
                        SizedBox(height: sw * 0.015),
                        Text(
                          cat.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: sw * 0.028,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: isSelected
                                ? _primaryColor
                                : (isDark
                                      ? Colors.white60
                                      : const Color(0xFF555555)),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: sw * 0.02),
            ],
          ),
        );
      },
    );
  }

  // ─── BUILD ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Warna adaptif — otomatis menyesuaikan light/dark mode
    final cardBg = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final bgColor = isDark ? const Color(0xFF12121C) : const Color(0xFFF0F2F5);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final labelColor = isDark ? Colors.white38 : Colors.grey[500]!;
    final dividerClr = isDark ? Colors.white12 : Colors.grey[100]!;

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: Padding(
          padding: EdgeInsets.all(sw * 0.026),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(sw * 0.03),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: sw * 0.044,
                color: Colors.white,
              ),
            ),
          ),
        ),
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Text(
            _isIncome ? 'Tambah Pemasukan' : 'Tambah Pengeluaran',
            key: ValueKey(_transactionType),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: sw * 0.044,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildAmountHeader(sw),
              SizedBox(height: sw * 0.05),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
                child: Column(
                  children: [
                    _buildTypeSelector(sw, cardBg, isDark),
                    SizedBox(height: sw * 0.035),
                    _buildCategorySelector(
                      sw,
                      cardBg,
                      isDark,
                      textPrimary,
                      labelColor,
                    ),
                    SizedBox(height: sw * 0.035),
                    _buildDetailsCard(
                      sw,
                      cardBg,
                      isDark,
                      textPrimary,
                      labelColor,
                      dividerClr,
                    ),
                    SizedBox(height: sw * 0.035),
                    _buildImagePickerCard(sw, cardBg, isDark, textPrimary),
                    SizedBox(height: sw * 0.07),
                    _buildSaveButton(sw),
                    SizedBox(height: sw * 0.09),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Amount Header (nominal di atas gradient) ──────────────────────────────

  Widget _buildAmountHeader(double sw) {
    final topPadding = MediaQuery.of(context).padding.top;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        sw * 0.06,
        topPadding + kToolbarHeight + sw * 0.02,
        sw * 0.06,
        sw * 0.09,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _primaryColor,
            Color.lerp(_primaryColor, Colors.white, 0.2)!,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(sw * 0.09),
          bottomRight: Radius.circular(sw * 0.09),
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.4),
            blurRadius: sw * 0.07,
            offset: Offset(0, sw * 0.04),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _isIncome
                    ? Icons.arrow_circle_down_rounded
                    : Icons.arrow_circle_up_rounded,
                color: Colors.white70,
                size: sw * 0.038,
              ),
              SizedBox(width: sw * 0.015),
              Text(
                _isIncome ? 'Jumlah Pemasukan' : 'Jumlah Pengeluaran',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: sw * 0.033,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: sw * 0.025),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Rp ',
                style: TextStyle(
                  // Selalu putih — tidak diambil dari tema
                  color: Colors.white,
                  fontSize: sw * 0.075,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  cursorColor: Colors.white,
                  // ⬇ Paksa putih — tidak terpengaruh dark/light mode sistem
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: sw * 0.09,
                    fontWeight: FontWeight.bold,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _CurrencyInputFormatter(),
                  ],
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(
                      color: Colors.white38,
                      fontSize: sw * 0.09,
                    ),
                    // Hapus semua dekorasi bawaan tema
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    errorStyle: TextStyle(
                      color: Colors.white70,
                      fontSize: sw * 0.028,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan nominal';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: sw * 0.025),
          Container(height: 1, color: Colors.white24),
        ],
      ),
    );
  }

  // ─── Type Selector ─────────────────────────────────────────────────────────

  Widget _buildTypeSelector(double sw, Color cardBg, bool isDark) {
    return Container(
      height: sw * 0.135,
      padding: EdgeInsets.all(sw * 0.01),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(sw * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: sw * 0.025,
            offset: Offset(0, sw * 0.005),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Pemasukan tab ──────────────────────────────────────────────
          Expanded(
            child: GestureDetector(
              onTap: () {
                // ⬇ SAMA PERSIS DENGAN KODE ASLI — hanya set tipe, tidak reset kategori
                setState(() {
                  _transactionType = TransactionType.income;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: _isIncome
                      ? AppConstants.successColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(sw * 0.03),
                  boxShadow: _isIncome
                      ? [
                          BoxShadow(
                            color: AppConstants.successColor.withOpacity(0.35),
                            blurRadius: sw * 0.02,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.south_rounded,
                      size: sw * 0.035,
                      color: _isIncome
                          ? Colors.white
                          : (isDark ? Colors.white38 : Colors.grey[400]),
                    ),
                    SizedBox(width: sw * 0.015),
                    Text(
                      'Pemasukan',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: sw * 0.033,
                        color: _isIncome
                            ? Colors.white
                            : (isDark ? Colors.white38 : Colors.grey[400]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // ── Pengeluaran tab ────────────────────────────────────────────
          Expanded(
            child: GestureDetector(
              onTap: () {
                // ⬇ SAMA PERSIS DENGAN KODE ASLI — hanya set tipe, tidak reset kategori
                setState(() {
                  _transactionType = TransactionType.expense;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: !_isIncome
                      ? AppConstants.errorColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(sw * 0.03),
                  boxShadow: !_isIncome
                      ? [
                          BoxShadow(
                            color: AppConstants.errorColor.withOpacity(0.35),
                            blurRadius: sw * 0.02,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.north_rounded,
                      size: sw * 0.035,
                      color: !_isIncome
                          ? Colors.white
                          : (isDark ? Colors.white38 : Colors.grey[400]),
                    ),
                    SizedBox(width: sw * 0.015),
                    Text(
                      'Pengeluaran',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: sw * 0.033,
                        color: !_isIncome
                            ? Colors.white
                            : (isDark ? Colors.white38 : Colors.grey[400]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Category Selector ─────────────────────────────────────────────────────

  Widget _buildCategorySelector(
    double sw,
    Color cardBg,
    bool isDark,
    Color textPrimary,
    Color labelColor,
  ) {
    return FutureBuilder(
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

        return GestureDetector(
          onTap: () => _showCategoryBottomSheet(categories, sw, isDark),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: sw * 0.04,
              vertical: sw * 0.035,
            ),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(sw * 0.04),
              border: Border.all(
                color: _selectedCategory != null
                    ? _primaryColor.withOpacity(0.5)
                    : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                  blurRadius: sw * 0.025,
                  offset: Offset(0, sw * 0.005),
                ),
              ],
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: sw * 0.115,
                  height: sw * 0.115,
                  decoration: BoxDecoration(
                    color: _selectedCategory != null
                        ? _primaryColor.withOpacity(isDark ? 0.25 : 0.12)
                        : (isDark
                              ? Colors.white.withOpacity(0.08)
                              : const Color(0xFFF0F0F0)),
                    borderRadius: BorderRadius.circular(sw * 0.033),
                  ),
                  child: Icon(
                    _selectedCategory != null
                        ? _iconFor(_selectedCategory!)
                        : Icons.grid_view_rounded,
                    color: _selectedCategory != null
                        ? _primaryColor
                        : (isDark ? Colors.white38 : Colors.grey[400]),
                    size: sw * 0.055,
                  ),
                ),
                SizedBox(width: sw * 0.035),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kategori',
                        style: TextStyle(
                          fontSize: sw * 0.028,
                          color: labelColor,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(height: sw * 0.008),
                      Text(
                        _selectedCategory ?? 'Pilih kategori transaksi',
                        style: TextStyle(
                          fontSize: sw * 0.038,
                          fontWeight: _selectedCategory != null
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: _selectedCategory != null
                              ? textPrimary
                              : (isDark ? Colors.white30 : Colors.grey[400]),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: sw * 0.08,
                  height: sw * 0.08,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.07)
                        : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(sw * 0.025),
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: isDark ? Colors.white38 : Colors.grey[500],
                    size: sw * 0.05,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Details Card (Tanggal + Catatan) ──────────────────────────────────────

  Widget _buildDetailsCard(
    double sw,
    Color cardBg,
    bool isDark,
    Color textPrimary,
    Color labelColor,
    Color dividerClr,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(sw * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: sw * 0.025,
            offset: Offset(0, sw * 0.005),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Tanggal ───────────────────────────────────────────────────
          InkWell(
            onTap: _selectDate,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(sw * 0.04),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: sw * 0.04,
                vertical: sw * 0.035,
              ),
              child: Row(
                children: [
                  Container(
                    width: sw * 0.115,
                    height: sw * 0.115,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1A237E).withOpacity(0.4)
                          : const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(sw * 0.033),
                    ),
                    child: Icon(
                      Icons.calendar_month_outlined,
                      color: const Color(0xFF4361EE),
                      size: sw * 0.055,
                    ),
                  ),
                  SizedBox(width: sw * 0.035),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tanggal & Jam Transaksi',
                          style: TextStyle(
                            fontSize: sw * 0.028,
                            color: labelColor,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(height: sw * 0.008),
                        Text(
                          DateFormatter.formatDateTime(_selectedDate),
                          style: TextStyle(
                            fontSize: sw * 0.038,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: sw * 0.08,
                    height: sw * 0.08,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.07)
                          : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(sw * 0.025),
                    ),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: isDark ? Colors.white38 : Colors.grey[400],
                      size: sw * 0.045,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Divider
          Padding(
            padding: EdgeInsets.only(left: sw * 0.185, right: sw * 0.04),
            child: Divider(height: 1, color: dividerClr),
          ),
          // ── Catatan ───────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: sw * 0.04,
              vertical: sw * 0.035,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: sw * 0.115,
                  height: sw * 0.115,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF4A1A7E).withOpacity(0.4)
                        : const Color(0xFFF3E8FF),
                    borderRadius: BorderRadius.circular(sw * 0.033),
                  ),
                  child: Icon(
                    Icons.edit_note_rounded,
                    color: const Color(0xFF7C3AED),
                    size: sw * 0.055,
                  ),
                ),
                SizedBox(width: sw * 0.035),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Catatan',
                        style: TextStyle(
                          fontSize: sw * 0.028,
                          color: labelColor,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(height: sw * 0.01),
                      TextFormField(
                        controller: _noteController,
                        maxLines: 2,
                        // ⬇ Warna teks ikut tema — adaptif light/dark
                        style: TextStyle(
                          fontSize: sw * 0.036,
                          color: textPrimary,
                          height: 1.45,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Tambahkan catatan... (opsional)',
                          hintStyle: TextStyle(
                            color: isDark ? Colors.white30 : Colors.grey[400],
                            fontSize: sw * 0.034,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          filled: false,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Image Picker Card ─────────────────────────────────────────────────────

  Widget _buildImagePickerCard(
    double sw,
    Color cardBg,
    bool isDark,
    Color textPrimary,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(sw * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: sw * 0.025,
            offset: Offset(0, sw * 0.005),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(
              sw * 0.04,
              sw * 0.035,
              sw * 0.04,
              sw * 0.03,
            ),
            child: Row(
              children: [
                Container(
                  width: sw * 0.115,
                  height: sw * 0.115,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF7C2D00).withOpacity(0.4)
                        : const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(sw * 0.033),
                  ),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    color: const Color(0xFFF97316),
                    size: sw * 0.055,
                  ),
                ),
                SizedBox(width: sw * 0.035),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bukti Transaksi',
                        style: TextStyle(
                          fontSize: sw * 0.038,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                      Text(
                        'Foto struk atau bukti pembayaran',
                        style: TextStyle(
                          fontSize: sw * 0.028,
                          color: isDark ? Colors.white38 : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.02,
                    vertical: sw * 0.01,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.07)
                        : const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(sw * 0.02),
                  ),
                  child: Text(
                    'Opsional',
                    style: TextStyle(
                      fontSize: sw * 0.028,
                      color: isDark ? Colors.white38 : Colors.grey[500],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Preview gambar
          if (_imagePath != null)
            Padding(
              padding: EdgeInsets.fromLTRB(sw * 0.04, 0, sw * 0.04, sw * 0.03),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(sw * 0.03),
                    child: Image.file(
                      File(_imagePath!),
                      height: sw * 0.45,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: sw * 0.45,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.06)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(sw * 0.03),
                        ),
                        child: Center(
                          child: Text(
                            'Gambar tidak dapat dimuat',
                            style: TextStyle(
                              color: isDark ? Colors.white38 : Colors.grey[400],
                              fontSize: sw * 0.033,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: sw * 0.02,
                    right: sw * 0.02,
                    child: GestureDetector(
                      onTap: () => setState(() => _imagePath = null),
                      child: Container(
                        padding: EdgeInsets.all(sw * 0.013),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(sw * 0.05),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: sw * 0.035,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Tombol tambah/ganti foto
          Padding(
            padding: EdgeInsets.fromLTRB(sw * 0.04, 0, sw * 0.04, sw * 0.04),
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: sw * 0.033),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(sw * 0.03),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.grey[200]!,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _imagePath == null
                          ? Icons.add_photo_alternate_outlined
                          : Icons.swap_horiz_rounded,
                      color: isDark ? Colors.white38 : Colors.grey[500],
                      size: sw * 0.05,
                    ),
                    SizedBox(width: sw * 0.02),
                    Text(
                      _imagePath == null ? 'Tambah Foto Bukti' : 'Ganti Foto',
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                        fontSize: sw * 0.035,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Save Button ───────────────────────────────────────────────────────────

  Widget _buildSaveButton(double sw) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: sw * 0.142,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _primaryColor,
            Color.lerp(_primaryColor, Colors.white, 0.2)!,
          ],
        ),
        borderRadius: BorderRadius.circular(sw * 0.04),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.45),
            blurRadius: sw * 0.04,
            offset: Offset(0, sw * 0.015),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _saveTransaction,
          borderRadius: BorderRadius.circular(sw * 0.04),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: sw * 0.05,
              ),
              SizedBox(width: sw * 0.02),
              Text(
                'Simpan Transaksi',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: sw * 0.041,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Currency Input Formatter — identik dengan kode asli ───────────────────

class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

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
