import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/date_formatter.dart';
import 'full_screen_image_screen.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  String _selectedFilter = 'Semua';
  String? _selectedYear;
  final List<String> _filters = [
    'Hari Ini',
    'Minggu Ini',
    'Bulan Ini',
    'Tahun Ini',
    'Semua',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Galeri Bukti Transaksi')),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(child: _buildGalleryGrid()),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: EdgeInsets.only(right: screenWidth * 0.02),
                  child: FilterChip(
                    label: Text(
                      filter,
                      style: TextStyle(fontSize: screenWidth * 0.035),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                        _selectedYear = null; // Reset tahun ketika ganti filter
                      });
                    },
                    selectedColor: AppConstants.primaryOrange.withOpacity(0.2),
                    checkmarkColor: AppConstants.primaryOrange,
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: screenWidth * 0.03),
          _buildYearDropdown(screenWidth),
        ],
      ),
    );
  }

  Widget _buildYearDropdown(double screenWidth) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        return FutureBuilder<List<String>>(
          future: _getAvailableYears(provider),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox.shrink();
            }

            final years = snapshot.data!;
            return Row(
              children: [
                Text(
                  'Filter Tahun: ',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: screenWidth * 0.02),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedYear,
                      hint: Text(
                        'Semua Tahun',
                        style: TextStyle(fontSize: screenWidth * 0.035),
                      ),
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text(
                            'Semua Tahun',
                            style: TextStyle(fontSize: screenWidth * 0.035),
                          ),
                        ),
                        ...years.map((year) {
                          return DropdownMenuItem<String>(
                            value: year,
                            child: Text(
                              year,
                              style: TextStyle(fontSize: screenWidth * 0.035),
                            ),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedYear = value;
                          _selectedFilter = 'Semua'; // Reset filter waktu
                        });
                      },
                      isExpanded: true,
                      dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<List<String>> _getAvailableYears(TransactionProvider provider) async {
    try {
      final transactions = await provider.getTransactionsWithImages(null, null);
      final years =
          transactions.map((t) => t.date.year.toString()).toSet().toList()
            ..sort(
              (a, b) => b.compareTo(a),
            ); // Sort descending (tahun terbaru dulu)
      return years;
    } catch (e) {
      return [];
    }
  }

  Widget _buildGalleryGrid() {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        return FutureBuilder<List<TransactionModel>>(
          future: _getFilteredTransactions(provider),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Terjadi kesalahan: ${snapshot.error}',
                  style: TextStyle(color: AppConstants.errorColor),
                ),
              );
            }

            final transactions = snapshot.data ?? [];

            if (transactions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo_library_outlined,
                      size: 64,
                      color: AppConstants.textSecondary,
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    Text(
                      'Tidak ada bukti transaksi',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppConstants.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    Text(
                      _getEmptyMessage(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppConstants.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            // Grid dengan 2 kolom
            final screenWidth = MediaQuery.of(context).size.width;
            final crossAxisCount = 2;
            final spacing = screenWidth * 0.03;
            final itemWidth =
                (screenWidth - (spacing * (crossAxisCount + 1))) /
                crossAxisCount;

            return GridView.builder(
              padding: EdgeInsets.all(spacing),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                childAspectRatio: itemWidth / (itemWidth * 1.3),
              ),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return _buildGalleryItem(transaction);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildGalleryItem(TransactionModel transaction) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageFile = File(transaction.imagePath!);
    final imageExists = imageFile.existsSync();

    if (!imageExists) {
      return const SizedBox.shrink(); // Skip gambar yang tidak ada
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullScreenImageScreen(
              imagePath: transaction.imagePath!,
              transaction: transaction,
            ),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(
                    imageFile,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppConstants.dividerColor,
                        child: const Icon(Icons.broken_image),
                      );
                    },
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.02,
                        vertical: screenWidth * 0.01,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusSmall,
                        ),
                      ),
                      child: Text(
                        DateFormatter.formatShortDate(transaction.date),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.025,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.025),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.category,
                    style: TextStyle(
                      fontSize: screenWidth * 0.032,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: screenWidth * 0.01),
                  Text(
                    CurrencyFormatter.formatCurrency(transaction.amount),
                    style: TextStyle(
                      fontSize: screenWidth * 0.028,
                      color: AppConstants.primaryOrange,
                      fontWeight: FontWeight.w500,
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

  Future<List<TransactionModel>> _getFilteredTransactions(
    TransactionProvider provider,
  ) async {
    DateTime? startDate;
    DateTime? endDate;

    switch (_selectedFilter) {
      case 'Hari Ini':
        startDate = DateFormatter.getStartOfDay(DateTime.now());
        endDate = DateFormatter.getEndOfDay(DateTime.now());
        break;
      case 'Minggu Ini':
        startDate = DateFormatter.getStartOfWeek(DateTime.now());
        endDate = DateFormatter.getEndOfWeek(DateTime.now());
        break;
      case 'Bulan Ini':
        startDate = DateFormatter.getStartOfMonth(DateTime.now());
        endDate = DateFormatter.getEndOfMonth(DateTime.now());
        break;
      case 'Tahun Ini':
        startDate = DateTime(DateTime.now().year, 1, 1);
        endDate = DateTime(DateTime.now().year, 12, 31, 23, 59, 59);
        break;
      case 'Semua':
      default:
        startDate = null;
        endDate = null;
        break;
    }

    var transactions = await provider.getTransactionsWithImages(
      startDate,
      endDate,
    );

    // Filter berdasarkan tahun jika dipilih
    if (_selectedYear != null) {
      final selectedYear = int.parse(_selectedYear!);
      transactions = transactions
          .where((t) => t.date.year == selectedYear)
          .toList();
    }

    return transactions;
  }

  String _getEmptyMessage() {
    if (_selectedYear != null) {
      return 'Belum ada bukti transaksi pada tahun $_selectedYear';
    }

    switch (_selectedFilter) {
      case 'Hari Ini':
        return 'Belum ada bukti transaksi hari ini';
      case 'Minggu Ini':
        return 'Belum ada bukti transaksi minggu ini';
      case 'Bulan Ini':
        return 'Belum ada bukti transaksi bulan ini';
      case 'Tahun Ini':
        return 'Belum ada bukti transaksi tahun ini';
      case 'Semua':
      default:
        return 'Mulai tambahkan bukti pada transaksi Anda';
    }
  }
}
