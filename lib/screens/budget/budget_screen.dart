import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../models/budget_model.dart';
import '../../models/transaction_model.dart';
import '../../providers/budget_provider.dart';
import '../../providers/category_provider.dart';
import '../../utils/currency_formatter.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rencana Budget')),
      body: Consumer<BudgetProvider>(
        builder: (context, budgetProvider, child) {
          if (budgetProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (budgetProvider.budgets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    size: 64,
                    color: AppConstants.textSecondary,
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Text(
                    'Belum ada budget',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppConstants.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  ElevatedButton.icon(
                    onPressed: () => _showAddBudgetDialog(budgetProvider),
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Budget'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
            itemCount: budgetProvider.budgets.length,
            separatorBuilder: (context, index) =>
                SizedBox(height: MediaQuery.of(context).size.width * 0.03),
            itemBuilder: (context, index) {
              final budget = budgetProvider.budgets[index];
              return _buildBudgetCard(budget, budgetProvider);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'budget_fab',
        onPressed: () {
          final budgetProvider = Provider.of<BudgetProvider>(
            context,
            listen: false,
          );
          _showAddBudgetDialog(budgetProvider);
        },
        child: const Icon(Icons.add),
      ),
    );
  }


  Widget _buildBudgetCard(BudgetModel budget, BudgetProvider budgetProvider) {
    final screenWidth = MediaQuery.of(context).size.width;
    return FutureBuilder<double>(
      future: budgetProvider.getExpenseByCategory(
        budget.category,
        DateTime.now(),
      ),
      builder: (context, snapshot) {
        final expense = snapshot.data ?? 0.0;
        final remaining = budget.amountLimit - expense;
        final percentage = (expense / budget.amountLimit * 100).clamp(0, 100);

        Color progressColor;
        if (percentage >= 100) {
          progressColor = AppConstants.errorColor;
        } else if (percentage >= 80) {
          progressColor = AppConstants.warningColor;
        } else {
          progressColor = AppConstants.successColor;
        }

        return Card(
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        budget.category,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: screenWidth * 0.045,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          _showDeleteBudgetDialog(budget, budgetProvider),
                      icon: const Icon(
                        Icons.delete,
                        color: AppConstants.errorColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenWidth * 0.04),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Terpakai',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppConstants.textSecondary,
                                fontSize: screenWidth * 0.03,
                              ),
                        ),
                        Text(
                          CurrencyFormatter.formatCurrency(expense),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppConstants.errorColor,
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.04,
                              ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Sisa',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppConstants.textSecondary,
                                fontSize: screenWidth * 0.03,
                              ),
                        ),
                        Text(
                          CurrencyFormatter.formatCurrency(remaining),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: remaining < 0
                                    ? AppConstants.errorColor
                                    : AppConstants.successColor,
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.04,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: screenWidth * 0.04),
                LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: AppConstants.dividerColor,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  minHeight: screenWidth * 0.02,
                ),
                SizedBox(height: screenWidth * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${percentage.toStringAsFixed(0)}% dari budget',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppConstants.textSecondary,
                        fontSize: screenWidth * 0.03,
                      ),
                    ),
                    Text(
                      'Limit: ${CurrencyFormatter.formatCurrency(budget.amountLimit)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppConstants.textSecondary,
                        fontSize: screenWidth * 0.03,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddBudgetDialog(BudgetProvider budgetProvider) {
    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );
    String? selectedCategory;
    final amountController = TextEditingController();
    final screenWidth = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Tambah Budget',
            style: TextStyle(fontSize: screenWidth * 0.045),
          ),
          content: SizedBox(
            width: screenWidth * 0.8,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kategori',
                    style: TextStyle(fontSize: screenWidth * 0.035),
                  ),
                  SizedBox(height: screenWidth * 0.02),
                  FutureBuilder(
                    future: categoryProvider.getCategoriesByType(
                      TransactionType.expense,
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
                          final isSelected = selectedCategory == category.name;
                          return FilterChip(
                            label: Text(
                              category.name,
                              style: TextStyle(fontSize: screenWidth * 0.032),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              setDialogState(() {
                                selectedCategory = category.name;
                              });
                            },
                            selectedColor: AppConstants.primaryOrange
                                .withOpacity(0.2),
                            checkmarkColor: AppConstants.primaryOrange,
                          );
                        }).toList(),
                      );
                    },
                  ),
                  SizedBox(height: screenWidth * 0.04),
                  Text(
                    'Nominal Limit',
                    style: TextStyle(fontSize: screenWidth * 0.035),
                  ),
                  SizedBox(height: screenWidth * 0.02),
                  TextField(
                    controller: amountController,
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
                    style: TextStyle(fontSize: screenWidth * 0.04),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: TextStyle(fontSize: screenWidth * 0.035),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedCategory == null || amountController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lengkapi semua data')),
                  );
                  return;
                }

                final amount = double.tryParse(
                  amountController.text.replaceAll(RegExp(r'[Rp\s.]'), ''),
                );

                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Masukkan nominal yang valid'),
                    ),
                  );
                  return;
                }

                final budget = BudgetModel(
                  category: selectedCategory!,
                  amountLimit: amount,
                  period: BudgetPeriod.monthly,
                );

                budgetProvider.addBudget(budget);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Budget berhasil ditambahkan')),
                );
              },
              child: Text(
                'Simpan',
                style: TextStyle(fontSize: screenWidth * 0.035),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteBudgetDialog(
    BudgetModel budget,
    BudgetProvider budgetProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Budget'),
        content: Text(
          'Apakah Anda yakin ingin menghapus budget ${budget.category}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              budgetProvider.deleteBudget(budget.id!);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Budget berhasil dihapus')),
              );
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppConstants.errorColor),
            ),
          ),
        ],
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
