import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/item.dart';
import '../models/item_type.dart';
import '../models/expense.dart';
import '../models/expense_details.dart';

class MainDB {
  static const _dbName = 'expense_tracker.db';
  static const _version = 3;

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

  _onUpgrade(db, int oldVersion, int newVersion) async {}

  _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${ItemType.tblName} (
        ${ItemType.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${ItemType.colDescription} TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${Item.tblName} (
        ${Item.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Item.colItemTypeId} INTEGER NOT NULL,
        ${Item.colDescription} TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${Expense.tblName} (
        ${Expense.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Expense.colTitle} TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${ExpenseDetails.tblName} (
        ${ExpenseDetails.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${ExpenseDetails.colDate} TEXT NOT NULL,
        ${ExpenseDetails.colQuantity} INTEGER NOT NULL,
        ${ExpenseDetails.colPrice} REAL NOT NULL,
        ${ExpenseDetails.colItemId} INTEGER NOT NULL,
        ${ExpenseDetails.colExpenseId} INTEGER NOT NULL
      )
    ''');
  }

  //ITEM TYPES MANAGEMENT
  Future<List<ItemType>> getItemTypes() async {
    Database d = await db;
    List<Map> res = await d.query(ItemType.tblName);
    return res.length == 0 ? [] : res.map((e) => ItemType.fromMap(e)).toList();
  }

  Future<ItemType> getItemType(int id) async {
    Database d = await db;
    return await _getItemType(d, id);
  }

  Future<ItemType> _getItemType(Database d, int id) async {
    List<Map> res = await d.query(ItemType.tblName, where: '${ItemType.colId} = ?', whereArgs: [
      id
    ]);
    return res.length == 0 ? null : res.map((e) => ItemType.fromMap(e)).first;
  }

  Future<int> insertItemType(ItemType itemType) async {
    Database d = await db;
    return await d.insert(
      ItemType.tblName,
      itemType.toMap(),
    );
  }

  Future<int> updateItemType(ItemType itemType) async {
    Database d = await db;
    return await d.update(ItemType.tblName, itemType.toMap(), where: '${ItemType.colId} = ?', whereArgs: [
      itemType.id
    ]);
  }

  Future<int> deleteItemType(int id) async {
    Database d = await db;
    return await d.delete(ItemType.tblName, where: '${ItemType.colId} = ?', whereArgs: [
      id
    ]);
  }
  //END ITEM TYPES MANAGEMENT

  //ITEMS MANAGEMENT
  Future<List<Item>> getItems() async {
    Database d = await db;
    List<Map> res = await d.query(Item.tblName);
    List<Item> itms = [];
    if (res.length > 0)
      for (var r in res) {
        var i = Item.fromMap(r);
        i.itemType = await _getItemType(d, i.itemTypeId);
        itms.add(i);
      }
    return res.length == 0 ? [] : itms;
  }

  Future<Item> getItem(int id) async {
    Database d = await db;
    return await _getItem(d, id);
  }

  Future<Item> _getItem(Database d, int id) async {
    List<Map> res = await d.query(Item.tblName, where: '${Item.colId} = ?', whereArgs: [
      id
    ]);
    if (res.length > 0)
      for (var r in res) {
        var i = Item.fromMap(r);
        i.itemType = await _getItemType(d, i.itemTypeId);
        return i;
      }
    return null;
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
  //END ITEM MANAGEMENT

  //EXPENSES MANAGEMENT
  Future<List<Expense>> getExpenses() async {
    Database d = await db;
    List<Map> res = await d.query(Expense.tblName);
    List<Expense> exps = [];

    if (res.length > 0)
      for (var r in res) {
        var ex = Expense.fromMap(r);
        var exd = await getExpenseDetails(ex.id);
        if (exd.length > 0) {
          exd.sort((a, b) => a.date.compareTo(b.date));
          ex.dateFrom = exd.first.date;
          ex.dateTo = exd.last.date;
          ex.totalPrice = exd.fold(0, (previous, current) => previous + current.totalPrice);
        }
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
        return ex;
      }
    return null;
  }

  Future<int> insertExpense(Expense expense) async {
    Database d = await db;
    return await d.insert(Expense.tblName, expense.toMap());
  }

  Future<int> updateExpense(Expense expense) async {
    Database d = await db;
    return await d.update(Expense.tblName, expense.toMap(), where: '${Expense.colId} = ?', whereArgs: [
      expense.id
    ]);
  }

  Future<int> deleteExpense(int id) async {
    Database d = await db;
    return await d.delete(Expense.tblName, where: '${Expense.colId} = ?', whereArgs: [
      id
    ]);
  }
  //END EXPENSES MANAGEMENT

  //EXPENSE DETAILS MANAGEMENT
  Future<List<ExpenseDetails>> getExpenseDetails(int expenseId) async {
    Database d = await db;
    List<Map> res = await d.query(ExpenseDetails.tblName, where: '${ExpenseDetails.colExpenseId} = ?', whereArgs: [
      expenseId
    ]);
    List<ExpenseDetails> exps = [];
    if (res.length > 0)
      for (var r in res) {
        var ex = ExpenseDetails.fromMap(r);
        ex.item = await _getItem(d, ex.itemId);
        exps.add(ex);
      }
    return res.length == 0 ? [] : exps;
  }

  Future<ExpenseDetails> getExpenseDetail(int id) async {
    Database d = await db;
    List<Map> res = await d.query(ExpenseDetails.tblName, where: '${ExpenseDetails.colId} = ?', whereArgs: [
      id
    ]);
    if (res.length > 0)
      for (var r in res) {
        var ex = ExpenseDetails.fromMap(r);
        ex.item = await _getItem(d, ex.itemId);
        return ex;
      }
    return null;
  }

  Future<int> insertExpenseDetails(ExpenseDetails expenseDetail) async {
    Database d = await db;
    return await d.insert(ExpenseDetails.tblName, expenseDetail.toMap());
  }

  Future<int> updateExpenseDetails(ExpenseDetails expenseDetail) async {
    Database d = await db;
    return await d.update(ExpenseDetails.tblName, expenseDetail.toMap(), where: '${ExpenseDetails.colId} = ?', whereArgs: [
      expenseDetail.id
    ]);
  }

  Future<int> deleteExpenseDetails(int id) async {
    Database d = await db;
    return await d.delete(ExpenseDetails.tblName, where: '${ExpenseDetails.colId} = ?', whereArgs: [
      id
    ]);
  }
  //END EXPENSE DETAILS MANAGEMENT
}
