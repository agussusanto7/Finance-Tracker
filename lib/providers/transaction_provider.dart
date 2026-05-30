import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/firebase_service.dart';

class TransactionProvider with ChangeNotifier {
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  double _totalBalance = 0.0;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  double get totalBalance => _totalBalance;

  TransactionProvider() {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = await FirebaseService.instance.getAllTransactions();
      _totalBalance = await FirebaseService.instance.getTotalBalance();
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
      _totalBalance = await FirebaseService.instance.getTotalBalance();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading balance: $e');
    }
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      await FirebaseService.instance.createTransaction(transaction);
      await loadTransactions();
    } catch (e) {
      debugPrint('Error adding transaction: $e');
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      await FirebaseService.instance.updateTransaction(transaction);
      await loadTransactions();
    } catch (e) {
      debugPrint('Error updating transaction: $e');
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await FirebaseService.instance.deleteTransaction(id);
      await loadTransactions();
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
    }
  }

  // --- Helper Methods (In-memory filtering for speed and offline-first support) ---

  Future<List<TransactionModel>> getRecentTransactions(int limit) async {
    final list = List<TransactionModel>.from(_transactions);
    list.sort((a, b) => b.date.compareTo(a.date));
    return list.take(limit).toList();
  }

  Future<List<TransactionModel>> getTransactionsByDateRange(DateTime start, DateTime end) async {
    return _transactions.where((t) {
      return t.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
             t.date.isBefore(end.add(const Duration(seconds: 1)));
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<List<TransactionModel>> getTransactionsByType(TransactionType type) async {
    return _transactions.where((t) => t.type == type).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<double> getTotalIncomeByMonth(DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    
    double total = 0;
    for (var t in _transactions) {
      if (t.type == TransactionType.income && 
          t.date.isAfter(startOfMonth.subtract(const Duration(seconds: 1))) && 
          t.date.isBefore(endOfMonth)) {
        total += t.amount;
      }
    }
    return total;
  }

  Future<double> getTotalExpenseByMonth(DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    
    double total = 0;
    for (var t in _transactions) {
      if (t.type == TransactionType.expense && 
          t.date.isAfter(startOfMonth.subtract(const Duration(seconds: 1))) && 
          t.date.isBefore(endOfMonth)) {
        total += t.amount;
      }
    }
    return total;
  }

  Future<Map<String, double>> getExpensesByCategory(DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    
    Map<String, double> result = {};
    for (var t in _transactions) {
      if (t.type == TransactionType.expense && 
          t.date.isAfter(startOfMonth.subtract(const Duration(seconds: 1))) && 
          t.date.isBefore(endOfMonth)) {
        result[t.category] = (result[t.category] ?? 0) + t.amount;
      }
    }
    return result;
  }

  Future<List<TransactionModel>> getTransactionsWithImages(DateTime? startDate, DateTime? endDate) async {
    var withImages = _transactions.where((t) => t.imagePath != null && t.imagePath!.isNotEmpty).toList();
    
    if (startDate != null && endDate != null) {
      withImages = withImages.where((t) {
        return t.date.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
               t.date.isBefore(endDate.add(const Duration(seconds: 1)));
      }).toList();
    }
    
    withImages.sort((a, b) => b.date.compareTo(a.date));
    return withImages;
  }
}
