import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/expense.dart';

class DatabaseHelper {
  static Database? _database;

  // DB 가져오기
  static Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await initDatabase();
    return _database!;
  }

  // DB 생성 및 버전 관리
  static Future<Database> initDatabase() async {
    final path = join(await getDatabasesPath(), 'account_book.db');

    return await openDatabase(
      path,
      version: 2,

      // 신규 DB 생성
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE expenses(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            amount INTEGER,
            memo TEXT,
            date TEXT,
            payment_method TEXT NOT NULL DEFAULT 'card'
          )
        ''');
      },

      // 기존 DB 업데이트
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            ALTER TABLE expenses
            ADD COLUMN payment_method TEXT NOT NULL DEFAULT 'card'
          ''');
        }
      },
    );
  }

  // 지출 저장
  static Future<void> insertExpense(Expense expense) async {
    final db = await database;

    await db.insert('expenses', {
      'amount': expense.amount,
      'memo': expense.memo,
      'date': expense.date.toIso8601String(),
      'payment_method': expense.paymentMethod,
    });
  }

  // 지출 조회
  static Future<List<Expense>> getExpenses(DateTime month) async {
    final db = await database;

    final startDate = DateTime(month.year, month.month, 1);
    final endDate = DateTime(month.year, month.month + 1, 1);

    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'date >= ? AND date < ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (index) {
      return Expense(
        id: maps[index]['id'],
        amount: maps[index]['amount'],
        memo: maps[index]['memo'],
        date: DateTime.parse(maps[index]['date']),
        paymentMethod: maps[index]['payment_method'] ?? 'card',
      );
    });
  }

  // 지출 삭제
  static Future<void> deleteExpense(int id) async {
    final db = await database;

    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  // 지출 수정
  static Future<void> updateExpense(Expense expense) async {
    final db = await database;

    await db.update(
      'expenses',
      {
        'amount': expense.amount,
        'memo': expense.memo,
        'date': expense.date.toIso8601String(),
        'payment_method': expense.paymentMethod,
      },
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }
}
