import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../database/database_helper.dart';

class TransactionProvider with ChangeNotifier {
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  double _totalBalance = 0.0;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  double get totalBalance => _totalBalance;

  TransactionProvider() {
    loadTransactions();
    loadTotalBalance();
  }

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = await DatabaseHelper.instance.getAllTransactions();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error loading transactions: $e');
    }
  }

  Future<void> loadTotalBalance() async {
    try {
      _totalBalance = await DatabaseHelper.instance.getTotalBalance();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading balance: $e');
    }
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      await DatabaseHelper.instance.createTransaction(transaction);
      await loadTransactions();
      await loadTotalBalance();
    } catch (e) {
      debugPrint('Error adding transaction: $e');
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      await DatabaseHelper.instance.updateTransaction(transaction);
      await loadTransactions();
      await loadTotalBalance();
    } catch (e) {
      debugPrint('Error updating transaction: $e');
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await DatabaseHelper.instance.deleteTransaction(id);
      await loadTransactions();
      await loadTotalBalance();
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
    }
  }

  Future<List<TransactionModel>> getRecentTransactions(int limit) async {
    try {
      return await DatabaseHelper.instance.getRecentTransactions(limit);
    } catch (e) {
      debugPrint('Error loading recent transactions: $e');
      return [];
    }
  }

  Future<List<TransactionModel>> getTransactionsByDateRange(
      DateTime start, DateTime end) async {
    try {
      return await DatabaseHelper.instance.getTransactionsByDateRange(start, end);
    } catch (e) {
      debugPrint('Error loading transactions by date range: $e');
      return [];
    }
  }

  Future<List<TransactionModel>> getTransactionsByType(
      TransactionType type) async {
    try {
      return await DatabaseHelper.instance.getTransactionsByType(type);
    } catch (e) {
      debugPrint('Error loading transactions by type: $e');
      return [];
    }
  }

  Future<double> getTotalIncomeByMonth(DateTime month) async {
    try {
      return await DatabaseHelper.instance.getTotalIncomeByMonth(month);
    } catch (e) {
      debugPrint('Error loading income: $e');
      return 0.0;
    }
  }

  Future<double> getTotalExpenseByMonth(DateTime month) async {
    try {
      return await DatabaseHelper.instance.getTotalExpenseByMonth(month);
    } catch (e) {
      debugPrint('Error loading expense: $e');
      return 0.0;
    }
  }

  Future<Map<String, double>> getExpensesByCategory(DateTime month) async {
    try {
      return await DatabaseHelper.instance.getExpensesByCategory(month);
    } catch (e) {
      debugPrint('Error loading expenses by category: $e');
      return {};
    }
  }

  Future<List<TransactionModel>> getTransactionsWithImages(
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    try {
      final allTransactions = await DatabaseHelper.instance.getAllTransactions();

      // Filter transaksi yang punya imagePath
      final withImages = allTransactions.where((t) => t.imagePath != null && t.imagePath!.isNotEmpty).toList();

      // Filter berdasarkan tanggal jika diberikan
      if (startDate != null && endDate != null) {
        return withImages.where((t) {
          return t.date.isAfter(startDate.subtract(const Duration(microseconds: 1))) &&
                 t.date.isBefore(endDate.add(const Duration(microseconds: 1)));
        }).toList();
      }

      return withImages;
    } catch (e) {
      debugPrint('Error loading transactions with images: $e');
      return [];
    }
  }
}
