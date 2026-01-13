import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../database/database_helper.dart';

class CategoryProvider with ChangeNotifier {
  List<CategoryModel> _categories = [];
  bool _isLoading = false;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;

  CategoryProvider() {
    loadCategories();
  }

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      _categories = await DatabaseHelper.instance.getAllCategories();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error loading categories: $e');
    }
  }

  Future<List<CategoryModel>> getCategoriesByType(TransactionType type) async {
    try {
      return await DatabaseHelper.instance.getCategoriesByType(type);
    } catch (e) {
      debugPrint('Error loading categories by type: $e');
      return [];
    }
  }

  Future<void> addCategory(CategoryModel category) async {
    try {
      await DatabaseHelper.instance.createCategory(category);
      await loadCategories();
    } catch (e) {
      debugPrint('Error adding category: $e');
    }
  }

  Future<void> updateCategory(CategoryModel category) async {
    try {
      await DatabaseHelper.instance.updateCategory(category);
      await loadCategories();
    } catch (e) {
      debugPrint('Error updating category: $e');
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await DatabaseHelper.instance.deleteCategory(id);
      await loadCategories();
    } catch (e) {
      debugPrint('Error deleting category: $e');
    }
  }

  CategoryModel? getCategoryByName(String name) {
    try {
      return _categories.firstWhere((cat) => cat.name == name);
    } catch (e) {
      return null;
    }
  }
}
