import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../constants/app_constants.dart';
import '../models/transaction_model.dart';
import '../models/budget_model.dart';
import '../models/category_model.dart';
import '../models/user_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(AppConstants.databaseName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Create User table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        photo_path TEXT,
        pin TEXT,
        biometric_enabled INTEGER DEFAULT 0,
        balance_hidden INTEGER DEFAULT 0,
        currency TEXT DEFAULT 'IDR',
        created_at TEXT NOT NULL
      )
    ''');

    // Create Categories table
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        color TEXT NOT NULL,
        type TEXT NOT NULL
      )
    ''');

    // Create Transactions table
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        image_path TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Create Budgets table
    await db.execute('''
      CREATE TABLE budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        amount_limit REAL NOT NULL,
        period TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Insert default categories
    await _insertDefaultCategories(db);
  }

  Future<void> _insertDefaultCategories(Database db) async {
    // Insert default expense categories
    for (var category in AppConstants.defaultExpenseCategories) {
      await db.insert('categories', {
        'name': category['name'],
        'icon': category['icon'],
        'color': category['color'],
        'type': 'expense',
      });
    }

    // Insert default income categories
    for (var category in AppConstants.defaultIncomeCategories) {
      await db.insert('categories', {
        'name': category['name'],
        'icon': category['icon'],
        'color': category['color'],
        'type': 'income',
      });
    }
  }

  // ==================== USER OPERATIONS ====================

  Future<int> createUser(UserModel user) async {
    final db = await instance.database;
    return await db.insert('users', user.toMap());
  }

  Future<UserModel?> getUser(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<UserModel?> getFirstUser() async {
    final db = await instance.database;
    final maps = await db.query('users', limit: 1);

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateUser(UserModel user) async {
    final db = await instance.database;
    return await db.update(
      'users',
      user.toMapForUpdate(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await instance.database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== CATEGORY OPERATIONS ====================

  Future<List<CategoryModel>> getAllCategories() async {
    final db = await instance.database;
    final maps = await db.query('categories');
    return maps.map((map) => CategoryModel.fromMap(map)).toList();
  }

  Future<List<CategoryModel>> getCategoriesByType(TransactionType type) async {
    final db = await instance.database;
    final maps = await db.query(
      'categories',
      where: 'type = ?',
      whereArgs: [type.name],
    );
    return maps.map((map) => CategoryModel.fromMap(map)).toList();
  }

  Future<int> createCategory(CategoryModel category) async {
    final db = await instance.database;
    return await db.insert('categories', category.toMap());
  }

  Future<int> updateCategory(CategoryModel category) async {
    final db = await instance.database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await instance.database;
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== TRANSACTION OPERATIONS ====================

  Future<int> createTransaction(TransactionModel transaction) async {
    final db = await instance.database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<TransactionModel?> getTransaction(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return TransactionModel.fromMap(maps.first);
    }
    return null;
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await instance.database;
    final maps = await db.query(
      'transactions',
      orderBy: 'date DESC',
    );
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  Future<List<TransactionModel>> getTransactionsByDateRange(
      DateTime start, DateTime end) async {
    final db = await instance.database;
    final maps = await db.query(
      'transactions',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  Future<List<TransactionModel>> getTransactionsByType(TransactionType type) async {
    final db = await instance.database;
    final maps = await db.query(
      'transactions',
      where: 'type = ?',
      whereArgs: [type.name],
      orderBy: 'date DESC',
    );
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  Future<List<TransactionModel>> getRecentTransactions(int limit) async {
    final db = await instance.database;
    final maps = await db.query(
      'transactions',
      orderBy: 'date DESC',
      limit: limit,
    );
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  Future<int> updateTransaction(TransactionModel transaction) async {
    final db = await instance.database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await instance.database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<double> getTotalBalance() async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT
        SUM(CASE WHEN type = 'income' THEN amount ELSE 0 END) as income,
        SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END) as expense
      FROM transactions
    ''');

    if (result.isNotEmpty) {
      final income = (result.first['income'] as num?)?.toDouble() ?? 0.0;
      final expense = (result.first['expense'] as num?)?.toDouble() ?? 0.0;
      return income - expense;
    }
    return 0.0;
  }

  Future<double> getTotalIncomeByMonth(DateTime month) async {
    final db = await instance.database;
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    final result = await db.rawQuery('''
      SELECT SUM(amount) as total
      FROM transactions
      WHERE type = 'income'
      AND date BETWEEN ? AND ?
    ''', [startOfMonth.toIso8601String(), endOfMonth.toIso8601String()]);

    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble();
    }
    return 0.0;
  }

  Future<double> getTotalExpenseByMonth(DateTime month) async {
    final db = await instance.database;
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    final result = await db.rawQuery('''
      SELECT SUM(amount) as total
      FROM transactions
      WHERE type = 'expense'
      AND date BETWEEN ? AND ?
    ''', [startOfMonth.toIso8601String(), endOfMonth.toIso8601String()]);

    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble();
    }
    return 0.0;
  }

  Future<Map<String, double>> getExpensesByCategory(DateTime month) async {
    final db = await instance.database;
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    final result = await db.rawQuery('''
      SELECT category, SUM(amount) as total
      FROM transactions
      WHERE type = 'expense'
      AND date BETWEEN ? AND ?
      GROUP BY category
    ''', [startOfMonth.toIso8601String(), endOfMonth.toIso8601String()]);

    Map<String, double> expensesByCategory = {};
    for (var row in result) {
      expensesByCategory[row['category'] as String] = (row['total'] as num).toDouble();
    }
    return expensesByCategory;
  }

  // ==================== BUDGET OPERATIONS ====================

  Future<int> createBudget(BudgetModel budget) async {
    final db = await instance.database;
    return await db.insert('budgets', budget.toMap());
  }

  Future<BudgetModel?> getBudget(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return BudgetModel.fromMap(maps.first);
    }
    return null;
  }

  Future<List<BudgetModel>> getAllBudgets() async {
    final db = await instance.database;
    final maps = await db.query('budgets');
    return maps.map((map) => BudgetModel.fromMap(map)).toList();
  }

  Future<BudgetModel?> getBudgetByCategory(String category) async {
    final db = await instance.database;
    final maps = await db.query(
      'budgets',
      where: 'category = ?',
      whereArgs: [category],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return BudgetModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateBudget(BudgetModel budget) async {
    final db = await instance.database;
    return await db.update(
      'budgets',
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  Future<int> deleteBudget(int id) async {
    final db = await instance.database;
    return await db.delete(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<double> getExpenseByCategory(String category, DateTime month) async {
    final db = await instance.database;
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    final result = await db.rawQuery('''
      SELECT SUM(amount) as total
      FROM transactions
      WHERE type = 'expense'
      AND category = ?
      AND date BETWEEN ? AND ?
    ''', [category, startOfMonth.toIso8601String(), endOfMonth.toIso8601String()]);

    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble();
    }
    return 0.0;
  }

  // ==================== CLOSE DATABASE ====================

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}
