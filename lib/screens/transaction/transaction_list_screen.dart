import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../constants/app_constants.dart';
import '../../models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/date_formatter.dart';
import 'add_transaction_screen.dart';
import 'transaction_filter_screen.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  String _selectedFilter = 'Semua';
  final List<String> _filters = ['Semua', 'Pemasukan', 'Pengeluaran'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export Filter',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TransactionFilterScreen(),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => _filters.map((filter) {
              return PopupMenuItem<String>(
                value: filter,
                child: Text(filter),
              );
            }).toList(),
            child: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: _buildTransactionList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'transaction_list_fab',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChips() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters.map((filter) {
            final isSelected = _selectedFilter == filter;
            return Padding(
              padding: EdgeInsets.only(right: screenWidth * 0.02),
              child: FilterChip(
                label: Text(filter, style: TextStyle(fontSize: screenWidth * 0.035)),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
                selectedColor: AppConstants.primaryOrange.withOpacity(0.2),
                checkmarkColor: AppConstants.primaryOrange,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        List<TransactionModel> filteredTransactions = provider.transactions;

        if (_selectedFilter == 'Pemasukan') {
          filteredTransactions = filteredTransactions
              .where((t) => t.type == TransactionType.income)
              .toList();
        } else if (_selectedFilter == 'Pengeluaran') {
          filteredTransactions = filteredTransactions
              .where((t) => t.type == TransactionType.expense)
              .toList();
        }

        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (filteredTransactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 64,
                  color: AppConstants.textSecondary,
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                Text(
                  'Tidak ada transaksi',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppConstants.textSecondary,
                      ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
          itemCount: filteredTransactions.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final transaction = filteredTransactions[index];
            return _buildTransactionItem(transaction, provider);
          },
        );
      },
    );
  }

  Widget _buildTransactionItem(
      TransactionModel transaction, TransactionProvider provider) {
    final isExpense = transaction.type == TransactionType.expense;
    final screenWidth = MediaQuery.of(context).size.width;

    return Slidable(
      key: ValueKey(transaction.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              _showDeleteConfirmation(transaction, provider);
            },
            backgroundColor: AppConstants.errorColor,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Hapus',
          ),
        ],
      ),
      child: Card(
        child: ListTile(
          leading: Container(
            width: screenWidth * 0.11,
            height: screenWidth * 0.11,
            decoration: BoxDecoration(
              color: isExpense
                  ? AppConstants.errorColor.withOpacity(0.1)
                  : AppConstants.successColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isExpense ? Icons.arrow_upward : Icons.arrow_downward,
              color: isExpense
                  ? AppConstants.errorColor
                  : AppConstants.successColor,
              size: screenWidth * 0.05,
            ),
          ),
          title: Text(
            transaction.category,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: screenWidth * 0.04,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormatter.formatRelativeDate(transaction.date),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: screenWidth * 0.03,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (transaction.note != null && transaction.note!.isNotEmpty)
                Text(
                  transaction.note!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppConstants.textSecondary,
                        fontSize: screenWidth * 0.03,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
          trailing: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: screenWidth * 0.35),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                '${isExpense ? '-' : '+'}${CurrencyFormatter.formatCurrency(transaction.amount)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isExpense
                          ? AppConstants.errorColor
                          : AppConstants.successColor,
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.035,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
      TransactionModel transaction, TransactionProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Transaksi'),
        content: const Text('Apakah Anda yakin ingin menghapus transaksi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteTransaction(transaction.id!);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Transaksi berhasil dihapus')),
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
