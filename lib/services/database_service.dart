import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart';

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
}
