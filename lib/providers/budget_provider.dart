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
      
      // Sync dari Firebase ke Lokal secara background
      _syncBudgetsFromFirebase();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error loading budgets: $e');
    }
  }

  Future<void> _syncBudgetsFromFirebase() async {
    try {
      final firebaseBudgetsMap = await FirebaseService.instance.getAllBudgets();
      if (firebaseBudgetsMap.isNotEmpty) {
        for (var map in firebaseBudgetsMap) {
          final budget = BudgetModel.fromMap(map);
          // Cek apakah budget sudah ada di lokal
          final existing = await DatabaseHelper.instance.getBudgetByCategory(budget.category);
          if (existing == null) {
            await DatabaseHelper.instance.createBudget(budget);
          } else {
            // Update dengan ID lokal yang sudah ada
            await DatabaseHelper.instance.updateBudget(budget.copyWith(id: existing.id));
          }
        }
        // Refresh UI setelah sync selesai
        _budgets = await DatabaseHelper.instance.getAllBudgets();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error syncing budgets from Firebase: $e');
    }
  }

  Future<void> addBudget(BudgetModel budget) async {
    try {
      await DatabaseHelper.instance.createBudget(budget);
      await FirebaseService.instance.saveBudget(budget.toMap(), budget.category);
      await loadBudgets();
    } catch (e) {
      debugPrint('Error adding budget: $e');
    }
  }

  Future<void> updateBudget(BudgetModel budget) async {
    try {
      await DatabaseHelper.instance.updateBudget(budget);
      await FirebaseService.instance.saveBudget(budget.toMap(), budget.category);
      await loadBudgets();
    } catch (e) {
      debugPrint('Error updating budget: $e');
    }
  }

  Future<void> deleteBudget(int id) async {
    try {
      // Cari kategori budget sebelum dihapus untuk dihapus di Firebase
      final budgetToDelete = _budgets.firstWhere((b) => b.id == id);
      await DatabaseHelper.instance.deleteBudget(id);
      await FirebaseService.instance.deleteBudget(budgetToDelete.category);
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
