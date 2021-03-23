import 'dart:io';

import 'package:expense_management/helpers/constants/format_constant.dart';
import 'package:expense_management/helpers/db_helpers/creation_helper.dart';
import 'package:expense_management/helpers/db_helpers/expense_details_helper.dart';
import 'package:expense_management/helpers/db_helpers/expense_helper.dart';
import 'package:expense_management/helpers/db_helpers/item_helper.dart';
import 'package:expense_management/helpers/db_helpers/item_type_helper.dart';
import 'package:expense_management/helpers/extensions/format_extension.dart';
import 'package:expense_management/models/expense.dart';
import 'package:expense_management/models/expense_details.dart';
import 'package:expense_management/models/item.dart';
import 'package:expense_management/models/item_type.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class MainDB {
  static const _dbName = 'expense_management.db';
  static const _version = 1;

  MainDB._();
  static final MainDB instance = MainDB._();

  Database? _db;
  Future<Database?> get db async {
    if (_db != null) return _db;
    _db = await _initDatabase();
    return _db;
  }

  _initDatabase() async {
    Directory appDirectory = await getApplicationDocumentsDirectory();
    String dbPath = join(appDirectory.path, _dbName);
    return await openDatabase(dbPath,
        version: _version, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  _onUpgrade(db, int oldVersion, int newVersion) async {}

  _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${ItemTypeHelper.tblName} (
        ${CreationHelper.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${ItemTypeHelper.colDescription} TEXT UNIQUE NOT NULL,
        ${CreationHelper.colCreatedOn} TEXT NOT NULL,
        ${CreationHelper.colModifiedOn} TEXT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${ItemHelper.tblName} (
        ${CreationHelper.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${ItemHelper.colItemTypeId} INTEGER NOT NULL,
        ${ItemHelper.colDescription} TEXT UNIQUE NOT NULL,
        ${ItemHelper.colAmount} REAL NOT NULL,
        ${CreationHelper.colCreatedOn} TEXT NOT NULL,
        ${CreationHelper.colModifiedOn} TEXT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${ExpenseDetailsHelper.tblName} (
        ${CreationHelper.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${ExpenseDetailsHelper.colDate} TEXT NOT NULL,
        ${ExpenseDetailsHelper.colQuantity} INTEGER NOT NULL,
        ${ExpenseDetailsHelper.colPrice} REAL NOT NULL,
        ${ExpenseDetailsHelper.colItemId} INTEGER NOT NULL,
        ${ExpenseDetailsHelper.colExpenseId} INTEGER NOT NULL,
        ${CreationHelper.colCreatedOn} TEXT NOT NULL,
        ${CreationHelper.colModifiedOn} TEXT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${ExpenseHelper.tblName} (
        ${CreationHelper.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${ExpenseHelper.colTitle} TEXT UNIQUE NOT NULL,
        ${CreationHelper.colCreatedOn} TEXT NOT NULL,
        ${CreationHelper.colModifiedOn} TEXT NULL
      )
    ''');
  }

  //ITEM TYPES MANAGEMENT
  Future<List<ItemType>> getItemTypes() async {
    Database d = (await db)!;
    List<Map> res = await d.rawQuery('''
      SELECT *,
        (
          SELECT COUNT(${CreationHelper.colId})
          FROM ${ItemHelper.tblName}
          WHERE ${ItemHelper.colItemTypeId} = ${ItemTypeHelper.tblName}.${CreationHelper.colId}
        ) reference
      FROM ${ItemTypeHelper.tblName}
    ''');
    return res.length == 0
        ? []
        : res.map<ItemType>((e) {
            var i = ItemType.fromJson(e as Map<String, dynamic>);
            i.reference = e['reference'] as int;
            return i;
          }).toList();
  }

  Future<ItemType?> getItemType(int id) async {
    Database d = (await db)!;
    return await _getItemType(d, id);
  }

  Future<ItemType?> _getItemType(Database d, int id) async {
    List<Map> res = await d.query(ItemTypeHelper.tblName,
        where: '${CreationHelper.colId} = ?', whereArgs: [id]);
    return res.length == 0
        ? null
        : res
            .map<ItemType>((e) => ItemType.fromJson(e as Map<String, dynamic>))
            .first;
  }

  Future<int> insertItemType(ItemType itemType) async {
    Database d = (await db)!;
    return await d.insert(
      ItemTypeHelper.tblName,
      itemType.toJson(),
    );
  }

  Future<int> updateItemType(ItemType itemType) async {
    Database d = (await db)!;
    itemType.modifiedOn = DateTime.now();
    return await d.update(ItemTypeHelper.tblName, itemType.toJson(),
        where: '${CreationHelper.colId} = ?', whereArgs: [itemType.id]);
  }

  Future<int> deleteItemType(int id) async {
    Database d = (await db)!;
    return await d.delete(ItemTypeHelper.tblName,
        where: '${CreationHelper.colId} = ?', whereArgs: [id]);
  }
  //END ITEM TYPES MANAGEMENT

  //ITEMS MANAGEMENT
  Future<List<Item>> getItems() async {
    Database d = (await db)!;
    List<Map> res = await d.rawQuery('''
      SELECT *,
        (
          SELECT COUNT(${CreationHelper.colId})
          FROM ${ExpenseDetailsHelper.tblName}
          WHERE ${ExpenseDetailsHelper.colItemId} = ${ItemHelper.tblName}.${CreationHelper.colId}
        ) reference
      FROM ${ItemHelper.tblName}
    ''');
    List<Item> itms = [];
    if (res.length > 0)
      for (var r in res) {
        var i = Item.fromJson(r as Map<String, dynamic>);
        i.itemType = await _getItemType(d, i.itemTypeId ?? 0);
        i.reference = r['reference'];
        itms.add(i);
      }
    return res.length == 0 ? [] : itms;
  }

  Future<Item?> getItem(int id) async {
    Database d = (await db)!;
    return await _getItem(d, id);
  }

  Future<Item?> _getItem(Database d, int id) async {
    List<Map> res = await d.query(ItemHelper.tblName,
        where: '${CreationHelper.colId} = ?', whereArgs: [id]);
    if (res.length > 0)
      for (var r in res) {
        var i = Item.fromJson(r as Map<String, dynamic>);
        i.itemType = await _getItemType(d, i.itemTypeId ?? 0);
        return i;
      }
    return null;
  }

  Future<int> insertItem(Item item) async {
    Database d = (await db)!;
    return await d.insert(ItemHelper.tblName, item.toJson());
  }

  Future<int> updateItem(Item item) async {
    Database d = (await db)!;
    item.modifiedOn = DateTime.now();
    return await d.update(ItemHelper.tblName, item.toJson(),
        where: '${CreationHelper.colId} = ?', whereArgs: [item.id]);
  }

  Future<int> deleteItem(int id) async {
    Database d = (await db)!;
    return await d.delete(ItemHelper.tblName,
        where: '${CreationHelper.colId} = ?', whereArgs: [id]);
  }
  //END ITEM MANAGEMENT

  //EXPENSES MANAGEMENT
  Future<List<Expense>> getExpenses() async {
    Database d = (await db)!;
    List<Map> res = await d.query(ExpenseHelper.tblName);
    List<Expense> exps = [];

    if (res.length > 0)
      for (var r in res) {
        var ex = Expense.fromJson(r as Map<String, dynamic>);
        var exd = await getExpenseDetails(ex.id ?? 0);
        ex.dateRange = FormatConstant.date;
        if (exd.length > 0) {
          exd.sort((a, b) => a.date.compareTo(b.date));
          ex.reference = exd.length;
          ex.dateRange =
              DateRangeFormatter.format(exd.first.date, exd.last.date);
          ex.totalPrice =
              exd.fold(0, (previous, current) => previous + current.totalPrice);
        }
        exps.add(ex);
      }
    return res.length == 0 ? [] : exps;
  }

  Future<Expense?> getExpense(int id) async {
    Database d = (await db)!;
    List<Map> res = await d.query(ExpenseHelper.tblName,
        where: '${CreationHelper.colId} = ?', whereArgs: [id]);
    if (res.length > 0)
      for (var r in res) {
        var ex = Expense.fromJson(r as Map<String, dynamic>);
        return ex;
      }
    return null;
  }

  Future<int> insertExpense(Expense expense) async {
    Database d = (await db)!;
    return await d.insert(ExpenseHelper.tblName, expense.toJson());
  }

  Future<int> updateExpense(Expense expense) async {
    Database d = (await db)!;
    expense.modifiedOn = DateTime.now();
    return await d.update(ExpenseHelper.tblName, expense.toJson(),
        where: '${CreationHelper.colId} = ?', whereArgs: [expense.id]);
  }

  Future<int> deleteExpense(int id) async {
    Database d = (await db)!;
    return await d.delete(ExpenseHelper.tblName,
        where: '${CreationHelper.colId} = ?', whereArgs: [id]);
  }
  //END EXPENSES MANAGEMENT

  //EXPENSE DETAILS MANAGEMENT
  Future<List<ExpenseDetails>> getExpenseDetails(int expenseId) async {
    Database d = (await db)!;
    List<Map> res = await d.query(ExpenseDetailsHelper.tblName,
        where: '${ExpenseDetailsHelper.colExpenseId} = ?',
        whereArgs: [expenseId],
        orderBy: '${ExpenseDetailsHelper.colDate} DESC');
    List<ExpenseDetails> exps = [];
    if (res.length > 0)
      for (var r in res) {
        var ex = ExpenseDetails.fromJson(r as Map<String, dynamic>);
        ex.item = await _getItem(d, ex.itemId ?? 0);
        exps.add(ex);
      }
    return res.length == 0 ? [] : exps;
  }

  Future<ExpenseDetails?> getExpenseDetail(int id) async {
    Database d = (await db)!;
    List<Map> res = await d.query(ExpenseDetailsHelper.tblName,
        where: '${CreationHelper.colId} = ?', whereArgs: [id]);
    if (res.length > 0)
      for (var r in res) {
        var ex = ExpenseDetails.fromJson(r as Map<String, dynamic>);
        ex.item = await _getItem(d, ex.itemId ?? 0);
        return ex;
      }
    return null;
  }

  Future<int> insertExpenseDetails(ExpenseDetails expenseDetail) async {
    Database d = (await db)!;
    return await d.insert(ExpenseDetailsHelper.tblName, expenseDetail.toJson());
  }

  Future<int> updateExpenseDetails(ExpenseDetails expenseDetail) async {
    Database d = (await db)!;
    expenseDetail.modifiedOn = DateTime.now();
    return await d.update(ExpenseDetailsHelper.tblName, expenseDetail.toJson(),
        where: '${CreationHelper.colId} = ?', whereArgs: [expenseDetail.id]);
  }

  Future<int> deleteExpenseDetails(int id) async {
    Database d = (await db)!;
    return await d.delete(ExpenseDetailsHelper.tblName,
        where: '${CreationHelper.colId} = ?', whereArgs: [id]);
  }
  //END EXPENSE DETAILS MANAGEMENT
}
