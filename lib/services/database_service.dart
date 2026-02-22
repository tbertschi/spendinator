import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../services/settings_service.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('spendinator.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        categoryId TEXT NOT NULL,
        date TEXT NOT NULL,
        description TEXT NOT NULL,
        amount REAL NOT NULL
      )
    ''');
  }

  Future<void> insertExpense(Expense expense) async {
    final db = await database;
    await db.insert(
      'expenses',
      {
        'id': expense.id,
        'categoryId': expense.categoryId,
        'date': expense.date.toIso8601String(),
        'description': expense.description,
        'amount': expense.amount,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateExpense(Expense expense) async {
    final db = await database;
    await db.update(
      'expenses',
      {
        'categoryId': expense.categoryId,
        'date': expense.date.toIso8601String(),
        'description': expense.description,
        'amount': expense.amount,
      },
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<void> deleteExpense(String id) async {
    final db = await database;
    await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Expense>> getExpensesByMonth(DateTime month) async {
    final db = await database;
    
    // Get first and last day of the month
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'date >= ? AND date <= ?',
      whereArgs: [
        firstDay.toIso8601String(),
        lastDay.toIso8601String(),
      ],
    );

    return maps.map((map) => Expense(
      id: map['id'] as String,
      categoryId: map['categoryId'] as String,
      date: DateTime.parse(map['date'] as String),
      description: map['description'] as String,
      amount: map['amount'] as double,
    )).toList();
  }

  Future<List<Expense>> getAllExpenses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('expenses');

    return maps.map((map) => Expense(
      id: map['id'] as String,
      categoryId: map['categoryId'] as String,
      date: DateTime.parse(map['date'] as String),
      description: map['description'] as String,
      amount: map['amount'] as double,
    )).toList();
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  Future<String> exportToCSV(dynamic l10n) async {
    // Get all expenses sorted by date
    final expenses = await getAllExpenses();
    expenses.sort((a, b) => a.date.compareTo(b.date));

    if (expenses.isEmpty) {
      throw Exception('No expenses to export');
    }

    // Get categories for name lookup
    final categories = getDefaultCategories();
    final categoryMap = {for (var cat in categories) cat.id: cat};

    // Build CSV content
    final buffer = StringBuffer();
    buffer.writeln('Date,Budget,Category,Description,Amount,Cumulative,Remaining');

    // Group by month to calculate cumulative and remaining
    String? currentMonthKey;
    double monthlyBudget = 0;
    double cumulative = 0;

    for (var expense in expenses) {
      final monthKey = '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
      
      // Reset cumulative when we enter a new month
      if (monthKey != currentMonthKey) {
        currentMonthKey = monthKey;
        cumulative = 0;
        
        // Get budget for this month
        final monthDate = DateTime(expense.date.year, expense.date.month);
        monthlyBudget = SettingsService.instance.getMonthlyBudget(monthDate) ?? 
                        SettingsService.instance.getDefaultBudget();
      }

      cumulative += expense.amount;
      final remaining = monthlyBudget - cumulative;

      // Get category name
      final category = categoryMap[expense.categoryId];
      final categoryName = category?.getLocalizedName(l10n) ?? expense.categoryId;

      // Format row: Date,Budget,Category,Description,Amount,Cumulative,Remaining
      buffer.writeln(
        '${_formatDate(expense.date)},'
        '${monthlyBudget.toStringAsFixed(2)},'
        '"$categoryName",'
        '"${expense.description}",'
        '${expense.amount.toStringAsFixed(2)},'
        '${cumulative.toStringAsFixed(2)},'
        '${remaining.toStringAsFixed(2)}'
      );
    }

    // Save to temporary file
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
    final file = File('${directory.path}/spendinator_export_$timestamp.csv');
    await file.writeAsString(buffer.toString());

    // Share the file
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Spendinator Export',
      text: 'Expense data exported from Spendinator',
    );

    return file.path;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
