import 'package:flutter/material.dart';
import '../models/budget_model.dart';
import '../database/database_helper.dart';
import '../services/firebase_service.dart';

class BudgetProvider with ChangeNotifier {
  List<BudgetModel> _budgets = [];
  bool _isLoading = false;

  List<BudgetModel> get budgets => _budgets;
  bool get isLoading => _isLoading;

  BudgetProvider() {
    loadBudgets();
  }

  Future<void> loadBudgets() async {
    _isLoading = true;
    notifyListeners();

    try {
      _budgets = await DatabaseHelper.instance.getAllBudgets();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error loading budgets: $e');
    }
  }

  Future<void> addBudget(BudgetModel budget) async {
    try {
      await DatabaseHelper.instance.createBudget(budget);
      await loadBudgets();
    } catch (e) {
      debugPrint('Error adding budget: $e');
    }
  }

  Future<void> updateBudget(BudgetModel budget) async {
    try {
      await DatabaseHelper.instance.updateBudget(budget);
      await loadBudgets();
    } catch (e) {
      debugPrint('Error updating budget: $e');
    }
  }

  Future<void> deleteBudget(int id) async {
    try {
      await DatabaseHelper.instance.deleteBudget(id);
      await loadBudgets();
    } catch (e) {
      debugPrint('Error deleting budget: $e');
    }
  }

  Future<BudgetModel?> getBudgetByCategory(String category) async {
    try {
      return await DatabaseHelper.instance.getBudgetByCategory(category);
    } catch (e) {
      debugPrint('Error loading budget by category: $e');
      return null;
    }
  }

  Future<double> getExpenseByCategory(String category, DateTime month) async {
    try {
      // Menghitung pengeluaran berdasarkan transaksi di Firebase!
      return await FirebaseService.instance.getExpenseByCategory(category, month);
    } catch (e) {
      debugPrint('Error loading expense by category: $e');
      return 0.0;
    }
  }
}
