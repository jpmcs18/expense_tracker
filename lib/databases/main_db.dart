import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/item.dart';
import '../models/expense.dart';

class MainDB {
  static const _dbName = 'expense_tracker.db';
  static const _version = 7;

  MainDB._();
  static final MainDB instance = MainDB._();

  Database _db;
  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await _initDatabase();
    return _db;
  }

  _initDatabase() async {
    Directory appDirectory = await getApplicationDocumentsDirectory();
    String dbPath = join(appDirectory.path, _dbName);
    return await openDatabase(dbPath, version: _version, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  _onUpgrade(db, int oldVersion, int newVersion) {
    // If you need to add a column
    if (newVersion > oldVersion) {
      db.execute("ALTER TABLE ${Expense.tblName} ADD COLUMN ${Expense.colDate} TEXT NULL");
    }
  }

  _onCreate(Database database, int version) async {
    await database.execute('''
      CREATE TABLE ${Item.tblName} (
        ${Item.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Item.colDescription} TEXT NOT NULL
      )
    ''');

    await database.execute('''
      CREATE TABLE ${Expense.tblName} (
        ${Expense.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Expense.colDate} TEXT NOT NULL,
        ${Expense.colItemId} INTEGER NOT NULL,
        ${Expense.colQuantity} INTEGER NOT NULL,
        ${Expense.colPrice} REAL NOT NULL
      )
    ''');
  }

  Future<List<Item>> getItems() async {
    Database d = await db;
    List<Map> res = await d.query(Item.tblName);
    return res.length == 0 ? [] : res.map((e) => Item.fromMap(e)).toList();
  }

  Future<Item> getItem(int id) async {
    Database d = await db;
    return await _getItem(d, id);
  }

  Future<Item> _getItem(Database d, int id) async {
    List<Map> res = await d.query(Item.tblName, where: '${Item.colId} = ?', whereArgs: [
      id
    ]);
    return res.length == 0 ? [] : res.map((e) => Item.fromMap(e)).first;
  }

  Future<int> insertItem(Item item) async {
    Database d = await db;
    return await d.insert(Item.tblName, item.toMap());
  }

  Future<int> updateItem(Item item) async {
    Database d = await db;
    return await d.update(Item.tblName, item.toMap(), where: '${Item.colId} = ?', whereArgs: [
      item.id
    ]);
  }

  Future<int> deleteItem(int id) async {
    Database d = await db;
    return await d.delete(Item.tblName, where: '${Item.colId} = ?', whereArgs: [
      id
    ]);
  }

  Future<List<Expense>> getExpenses() async {
    Database d = await db;
    List<Map> res = await d.query(Expense.tblName);
    List<Expense> exps = [];
    if (res.length > 0)
      for (var r in res) {
        var ex = Expense.fromMap(r);
        ex.item = await _getItem(d, ex.itemId);
        exps.add(ex);
      }
    return res.length == 0 ? [] : exps;
  }

  Future<Expense> getExpense(int id) async {
    Database d = await db;
    List<Map> res = await d.query(Expense.tblName, where: '${Expense.colId} = ?', whereArgs: [
      id
    ]);
     if (res.length > 0)
      for (var r in res) {
        var ex = Expense.fromMap(r);
        ex.item = await _getItem(d, ex.itemId);
        return ex;
      }
    return null;
  }

  Future<int> insertExpense(Expense expense) async {
    Database d = await db;
    return await d.insert(Expense.tblName, expense.toMap());
  }
}
