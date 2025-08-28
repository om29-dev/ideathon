import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart';
import '../models/budget.dart';
import '../models/financial_goal.dart';
import '../models/investment.dart';
import '../models/message.dart';

class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'ai_finance_buddy.db';
  static const int _databaseVersion = 2;

  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create expenses table
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        subcategory TEXT,
        payment_method TEXT,
        location TEXT,
        notes TEXT,
        receipt_image TEXT,
        is_recurring INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Create budgets table
    await db.execute('''
      CREATE TABLE budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        monthly_limit REAL NOT NULL,
        spent_amount REAL DEFAULT 0,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        is_active INTEGER DEFAULT 1,
        alert_threshold REAL DEFAULT 0.8,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Create financial goals table
    await db.execute('''
      CREATE TABLE financial_goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        target_amount REAL NOT NULL,
        current_amount REAL DEFAULT 0,
        target_date TEXT NOT NULL,
        priority TEXT DEFAULT 'medium',
        status TEXT DEFAULT 'active',
        category TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Create investments table
    await db.execute('''
      CREATE TABLE investments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        purchase_price REAL NOT NULL,
        current_price REAL NOT NULL,
        quantity REAL NOT NULL,
        purchase_date TEXT NOT NULL,
        broker TEXT,
        notes TEXT,
        is_active INTEGER DEFAULT 1,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Create categories table
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        type TEXT NOT NULL,
        icon TEXT,
        color TEXT,
        is_custom INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Create chat messages table
    await db.execute('''
      CREATE TABLE chat_messages (
        id INTEGER PRIMARY KEY,
        text TEXT NOT NULL,
        sender INTEGER NOT NULL,
        timestamp TEXT NOT NULL,
        has_expenses INTEGER DEFAULT 0,
        excel_data TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Insert default categories
    await _insertDefaultCategories(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades
    if (oldVersion < 2) {
      // Add chat messages table in version 2
      await db.execute('''
        CREATE TABLE chat_messages (
          id INTEGER PRIMARY KEY,
          text TEXT NOT NULL,
          sender INTEGER NOT NULL,
          timestamp TEXT NOT NULL,
          has_expenses INTEGER DEFAULT 0,
          excel_data TEXT,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP
        )
      ''');
    }
  }

  Future<void> _insertDefaultCategories(Database db) async {
    final defaultCategories = [
      {
        'name': 'Food & Dining',
        'type': 'expense',
        'icon': '🍕',
        'color': '#FF9800',
      },
      {
        'name': 'Transportation',
        'type': 'expense',
        'icon': '🚗',
        'color': '#2196F3',
      },
      {
        'name': 'Shopping',
        'type': 'expense',
        'icon': '🛍️',
        'color': '#E91E63',
      },
      {
        'name': 'Entertainment',
        'type': 'expense',
        'icon': '🎬',
        'color': '#9C27B0',
      },
      {
        'name': 'Bills & Utilities',
        'type': 'expense',
        'icon': '💡',
        'color': '#607D8B',
      },
      {
        'name': 'Healthcare',
        'type': 'expense',
        'icon': '🏥',
        'color': '#F44336',
      },
      {
        'name': 'Education',
        'type': 'expense',
        'icon': '📚',
        'color': '#3F51B5',
      },
      {'name': 'Gaming', 'type': 'expense', 'icon': '🎮', 'color': '#9C27B0'},
      {'name': 'Travel', 'type': 'expense', 'icon': '✈️', 'color': '#00BCD4'},
      {'name': 'Other', 'type': 'expense', 'icon': '📦', 'color': '#795548'},
      {'name': 'Salary', 'type': 'income', 'icon': '💰', 'color': '#4CAF50'},
      {
        'name': 'Investment Returns',
        'type': 'income',
        'icon': '📈',
        'color': '#4CAF50',
      },
      {
        'name': 'Freelancing',
        'type': 'income',
        'icon': '💻',
        'color': '#4CAF50',
      },
      {
        'name': 'Other Income',
        'type': 'income',
        'icon': '💵',
        'color': '#4CAF50',
      },
    ];

    for (var category in defaultCategories) {
      await db.insert('categories', category);
    }
  }

  // Expense operations
  Future<int> insertExpense(Expense expense) async {
    final db = await database;
    return await db.insert('expenses', expense.toMap());
  }

  Future<List<Expense>> getExpenses({String? category, int? limit}) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: category != null ? 'category = ?' : null,
      whereArgs: category != null ? [category] : null,
      orderBy: 'date DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  Future<double> getTotalExpensesByCategory(
    String category, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;
    String query =
        'SELECT SUM(amount) as total FROM expenses WHERE category = ?';
    List<dynamic> args = [category];

    if (startDate != null) {
      query += ' AND date >= ?';
      args.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      query += ' AND date <= ?';
      args.add(endDate.toIso8601String());
    }

    final result = await db.rawQuery(query, args);
    return result.first['total'] as double? ?? 0.0;
  }

  Future<Map<String, double>> getExpensesByCategory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;
    String query = 'SELECT category, SUM(amount) as total FROM expenses';
    List<dynamic> args = [];

    if (startDate != null || endDate != null) {
      query += ' WHERE';
      if (startDate != null) {
        query += ' date >= ?';
        args.add(startDate.toIso8601String());
        if (endDate != null) {
          query += ' AND';
        }
      }
      if (endDate != null) {
        query += ' date <= ?';
        args.add(endDate.toIso8601String());
      }
    }

    query += ' GROUP BY category';

    final result = await db.rawQuery(query, args);
    Map<String, double> categoryTotals = {};

    for (var row in result) {
      categoryTotals[row['category'] as String] = row['total'] as double;
    }

    return categoryTotals;
  }

  // Budget operations
  Future<int> insertBudget(Budget budget) async {
    final db = await database;
    return await db.insert('budgets', budget.toMap());
  }

  Future<List<Budget>> getBudgets() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('budgets');
    return List.generate(maps.length, (i) => Budget.fromMap(maps[i]));
  }

  Future<Budget?> getBudgetByCategory(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      where: 'category = ?',
      whereArgs: [category],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Budget.fromMap(maps.first);
    }
    return null;
  }

  Future<void> updateBudgetSpentAmount(String category, double amount) async {
    final db = await database;
    await db.update(
      'budgets',
      {'spent_amount': amount, 'updated_at': DateTime.now().toIso8601String()},
      where: 'category = ?',
      whereArgs: [category],
    );
  }

  Future<void> updateBudget(Budget budget) async {
    final db = await database;
    await db.update(
      'budgets',
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  Future<void> deleteBudget(int budgetId) async {
    final db = await database;
    await db.delete('budgets', where: 'id = ?', whereArgs: [budgetId]);
  }

  // Financial Goal operations
  Future<int> insertFinancialGoal(FinancialGoal goal) async {
    final db = await database;
    return await db.insert('financial_goals', goal.toMap());
  }

  Future<List<FinancialGoal>> getFinancialGoals() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('financial_goals');
    return List.generate(maps.length, (i) => FinancialGoal.fromMap(maps[i]));
  }

  Future<void> updateGoalProgress(int goalId, double currentAmount) async {
    final db = await database;
    await db.update(
      'financial_goals',
      {
        'current_amount': currentAmount,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [goalId],
    );
  }

  Future<int> updateFinancialGoal(FinancialGoal goal) async {
    final db = await database;
    return await db.update(
      'financial_goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<int> deleteFinancialGoal(int goalId) async {
    final db = await database;
    return await db.delete(
      'financial_goals',
      where: 'id = ?',
      whereArgs: [goalId],
    );
  }

  // Investment operations
  Future<int> insertInvestment(Investment investment) async {
    final db = await database;
    return await db.insert('investments', investment.toMap());
  }

  Future<List<Investment>> getInvestments() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('investments');
    return List.generate(maps.length, (i) => Investment.fromMap(maps[i]));
  }

  Future<double> getTotalInvestmentValue() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(current_price * quantity) as total FROM investments',
    );
    return result.first['total'] as double? ?? 0.0;
  }

  // Analytics and Reports
  Future<Map<String, dynamic>> getMonthlyAnalytics(int year, int month) async {
    final db = await database;
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0);

    // Total expenses
    final expenseResult = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE date >= ? AND date <= ?',
      [startDate.toIso8601String(), endDate.toIso8601String()],
    );
    final totalExpenses = expenseResult.first['total'] as double? ?? 0.0;

    // Category breakdown
    final categoryResult = await db.rawQuery(
      'SELECT category, SUM(amount) as total FROM expenses WHERE date >= ? AND date <= ? GROUP BY category',
      [startDate.toIso8601String(), endDate.toIso8601String()],
    );

    Map<String, double> categoryBreakdown = {};
    for (var row in categoryResult) {
      categoryBreakdown[row['category'] as String] = row['total'] as double;
    }

    // Daily expenses for the month
    final dailyResult = await db.rawQuery(
      'SELECT date, SUM(amount) as total FROM expenses WHERE date >= ? AND date <= ? GROUP BY DATE(date) ORDER BY date',
      [startDate.toIso8601String(), endDate.toIso8601String()],
    );

    List<Map<String, dynamic>> dailyExpenses = dailyResult
        .map((row) => {'date': row['date'], 'amount': row['total']})
        .toList();

    return {
      'totalExpenses': totalExpenses,
      'categoryBreakdown': categoryBreakdown,
      'dailyExpenses': dailyExpenses,
      'period':
          '${startDate.day}/${startDate.month}/${startDate.year} - ${endDate.day}/${endDate.month}/${endDate.year}',
    };
  }

  // Chat Messages operations
  Future<int> insertChatMessage(Message message) async {
    try {
      print('DatabaseService: Inserting chat message...');
      final db = await database;
      final result = await db.insert('chat_messages', {
        'id': message.id,
        'text': message.text,
        'sender': message.sender.index,
        'timestamp': message.timestamp.toIso8601String(),
        'has_expenses': message.hasExpenses ? 1 : 0,
        'excel_data': message.excelData != null
            ? json.encode(message.excelData)
            : null,
      });
      print('DatabaseService: Chat message inserted with rowid: $result');
      return result;
    } catch (e) {
      print('DatabaseService: Error inserting chat message: $e');
      rethrow;
    }
  }

  Future<List<Message>> getChatMessages() async {
    try {
      print('DatabaseService: Loading chat messages...');
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'chat_messages',
        orderBy: 'timestamp ASC',
      );

      print('DatabaseService: Found ${maps.length} chat messages in database');
      return List.generate(maps.length, (i) {
        final map = maps[i];
        return Message(
          id: map['id'],
          text: map['text'],
          sender: MessageSender.values[map['sender']],
          timestamp: DateTime.parse(map['timestamp']),
          hasExpenses: map['has_expenses'] == 1,
          excelData: map['excel_data'] != null
              ? json.decode(map['excel_data'])
              : null,
        );
      });
    } catch (e) {
      print('DatabaseService: Error loading chat messages: $e');
      rethrow;
    }
  }

  Future<void> deleteChatMessage(int messageId) async {
    final db = await database;
    await db.delete('chat_messages', where: 'id = ?', whereArgs: [messageId]);
  }

  Future<void> clearAllChatMessages() async {
    final db = await database;
    await db.delete('chat_messages');
  }

  // Utility methods
  Future<void> closeDatabase() async {
    final db = await database;
    db.close();
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('expenses');
      await txn.delete('budgets');
      await txn.delete('financial_goals');
      await txn.delete('investments');
    });
  }
}
