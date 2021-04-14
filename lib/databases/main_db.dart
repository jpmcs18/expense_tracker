import 'dart:io';

import 'package:expense_management/helpers/constants/format_constant.dart';
import 'package:expense_management/helpers/db_helpers/bills/electric_bill_helper.dart';
import 'package:expense_management/helpers/db_helpers/bills/electric_reading_helper.dart';
import 'package:expense_management/helpers/db_helpers/bills/person_helper.dart';
import 'package:expense_management/helpers/db_helpers/bills/water_bill_helper.dart';
import 'package:expense_management/helpers/db_helpers/bills/water_reading_helper.dart';
import 'package:expense_management/helpers/db_helpers/creation_helper.dart';
import 'package:expense_management/helpers/db_helpers/expenses/expense_details_helper.dart';
import 'package:expense_management/helpers/db_helpers/expenses/expense_helper.dart';
import 'package:expense_management/helpers/db_helpers/expenses/item_helper.dart';
import 'package:expense_management/helpers/db_helpers/expenses/item_type_helper.dart';
import 'package:expense_management/helpers/db_helpers/incomes/income_helper.dart';
import 'package:expense_management/helpers/db_helpers/incomes/income_type_helper.dart';
import 'package:expense_management/helpers/extensions/format_extension.dart';
import 'package:expense_management/models/bills/electric_bill.dart';
import 'package:expense_management/models/bills/electric_reading.dart';
import 'package:expense_management/models/bills/person.dart';
import 'package:expense_management/models/bills/water_bill.dart';
import 'package:expense_management/models/bills/water_reading.dart';
import 'package:expense_management/models/expenses/expense.dart';
import 'package:expense_management/models/expenses/expense_details.dart';
import 'package:expense_management/models/expenses/item.dart';
import 'package:expense_management/models/expenses/item_type.dart';
import 'package:expense_management/models/incomes/income.dart';
import 'package:expense_management/models/incomes/income_type.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class MainDB {
  static const _dbName = 'expense_management.db';
  static const _version = 6;

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

  _onUpgrade(Database db, int oldVersion, int newVersion) async {}

  _onCreate(Database db, int version) async {
    await _generateExpensesTables(db);
    await _generateBillsTables(db);
    await _generateIncomesTables(db);
  }

  Future _generateIncomesTables(Database db) async {
    await db.execute('''
      CREATE TABLE ${IncomeHelper.tblName} (
        ${CreationHelper.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${IncomeHelper.colDate} TEXT NOT NULL,
        ${IncomeHelper.colAmount} REAL NOT NULL,
        ${IncomeHelper.colIncomeTypeId} INT NOT NULL,
        ${CreationHelper.colCreatedOn} TEXT NOT NULL,
        ${CreationHelper.colModifiedOn} TEXT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${IncomeTypeHelper.tblName} (
        ${CreationHelper.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${IncomeTypeHelper.colDescription} TEXT UNIQUE NOT NULL,
        ${CreationHelper.colCreatedOn} TEXT NOT NULL,
        ${CreationHelper.colModifiedOn} TEXT NULL
      )
    ''');
  }

  Future _generateBillsTables(Database db) async {
    await db.execute('''
      CREATE TABLE ${PersonHelper.tblName} (
        ${CreationHelper.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${PersonHelper.colName} TEXT UNIQUE NOT NULL,
        ${CreationHelper.colCreatedOn} TEXT NOT NULL,
        ${CreationHelper.colModifiedOn} TEXT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${ElectricBillHelper.tblName} (
        ${CreationHelper.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${ElectricBillHelper.colDate} TEXT NOT NULL,
        ${ElectricBillHelper.colAmount} REAL NOT NULL,
        ${CreationHelper.colCreatedOn} TEXT NOT NULL,
        ${CreationHelper.colModifiedOn} TEXT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${WaterBillHelper.tblName} (
        ${CreationHelper.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${WaterBillHelper.colDate} TEXT NOT NULL,
        ${WaterBillHelper.colAmount} REAL NOT NULL,
        ${CreationHelper.colCreatedOn} TEXT NOT NULL,
        ${CreationHelper.colModifiedOn} TEXT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${ElectricReadingHelper.tblName} (
        ${CreationHelper.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${ElectricReadingHelper.colDate} TEXT NOT NULL,
        ${ElectricReadingHelper.colReading} INTEGER NOT NULL,
        ${WaterReadingHelper.colPersonId} INTEGER NOT NULL,
        ${CreationHelper.colCreatedOn} TEXT NOT NULL,
        ${CreationHelper.colModifiedOn} TEXT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${WaterReadingHelper.tblName} (
        ${CreationHelper.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${WaterReadingHelper.colDate} TEXT NOT NULL,
        ${WaterReadingHelper.colReading} INTEGER NOT NULL,
        ${WaterReadingHelper.colPersonId} INTEGER NOT NULL,
        ${CreationHelper.colCreatedOn} TEXT NOT NULL,
        ${CreationHelper.colModifiedOn} TEXT NULL
      )
    ''');
  }

  Future _generateExpensesTables(Database db) async {
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

  //START EXPENSES
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
      ORDER BY ${ItemTypeHelper.colDescription}
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
      ORDER BY ${ItemHelper.colItemTypeId}, ${ItemHelper.colDescription} 
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
    List<Map> res =
        await d.query(ExpenseHelper.tblName, orderBy: ExpenseHelper.colTitle);
    List<Expense> exps = [];

    if (res.length > 0)
      for (var r in res) {
        var ex = Expense.fromJson(r as Map<String, dynamic>);
        var exd = await getExpenseDetails(expenseId: ex.id ?? 0);
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
    return await _getExpense(d, id);
  }

  Future<Expense?> _getExpense(Database d, int id) async {
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
  Future<List<ExpenseDetails>> getExpenseDetails({int? expenseId}) async {
    Database d = (await db)!;
    List<Map> res = await d.query(ExpenseDetailsHelper.tblName,
        where: expenseId == null
            ? null
            : '${ExpenseDetailsHelper.colExpenseId} = ?',
        whereArgs: expenseId == null ? null : [expenseId],
        orderBy: '${ExpenseDetailsHelper.colDate} DESC');
    List<ExpenseDetails> exps = [];
    if (res.length > 0)
      for (var r in res) {
        var ex = ExpenseDetails.fromJson(r as Map<String, dynamic>);
        ex.item = await _getItem(d, ex.itemId ?? 0);
        ex.expense = await _getExpense(d, ex.expenseId ?? 0);
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
  //END EXPENSES

  //START BILLS
  //PERSON MANAGEMENT
  Future<List<Person>> getPersons() async {
    Database d = (await db)!;
    List<Map> res = await d.rawQuery('''
      SELECT *,
        (
          SELECT COUNT(${CreationHelper.colId})
          FROM ${ElectricReadingHelper.tblName}
          WHERE ${ElectricReadingHelper.colPersonId} = ${PersonHelper.tblName}.${CreationHelper.colId}
        ) elec,
        (
          SELECT COUNT(${CreationHelper.colId})
          FROM ${WaterReadingHelper.tblName}
          WHERE ${WaterReadingHelper.colPersonId} = ${PersonHelper.tblName}.${CreationHelper.colId}
        ) water
      FROM ${PersonHelper.tblName}
      ORDER BY ${PersonHelper.colName}
    ''');
    return res.length == 0
        ? []
        : res.map<Person>((e) {
            var i = Person.fromJson(e as Map<String, dynamic>);
            i.reference = (e['elec'] as int) + (e['water'] as int);
            return i;
          }).toList();
  }

  Future<Person?> getPerson(int id) async {
    Database d = (await db)!;
    return await _getPerson(d, id);
  }

  Future<Person?> _getPerson(Database d, int id) async {
    List<Map> res = await d.query(PersonHelper.tblName,
        where: '${CreationHelper.colId} = ?', whereArgs: [id]);
    return res.length == 0
        ? null
        : res
            .map<Person>((e) => Person.fromJson(e as Map<String, dynamic>))
            .first;
  }

  Future<int> insertPerson(Person person) async {
    Database d = (await db)!;
    return await d.insert(
      PersonHelper.tblName,
      person.toJson(),
    );
  }

  Future<int> updatePerson(Person person) async {
    Database d = (await db)!;
    person.modifiedOn = DateTime.now();
    return await d.update(PersonHelper.tblName, person.toJson(),
        where: '${CreationHelper.colId} = ?', whereArgs: [person.id]);
  }

  Future<int> deletePerson(int id) async {
    Database d = (await db)!;
    return await d.delete(PersonHelper.tblName,
        where: '${CreationHelper.colId} = ?', whereArgs: [id]);
  }
  //END PERSON MANAGEMENT

  //ELECTRIC BILL MANAGEMENT
  Future<List<ElectricBill>> getElectricBills() async {
    Database d = (await db)!;
    List<Map> res = await d.query(ElectricBillHelper.tblName,
        orderBy: '${ElectricBillHelper.colDate} DESC');
    return res.length == 0
        ? []
        : res
            .map<ElectricBill>(
                (e) => ElectricBill.fromJson(e as Map<String, dynamic>))
            .toList();
  }

  Future<ElectricBill?> getElectricBill(int id) async {
    Database d = (await db)!;
    return await _getElectricBill(d, id);
  }

  Future<ElectricBill?> _getElectricBill(Database d, int id) async {
    List<Map> res = await d.query(ElectricBillHelper.tblName,
        where: '${CreationHelper.colId} = ?', whereArgs: [id]);
    return res.length == 0
        ? null
        : res
            .map<ElectricBill>(
                (e) => ElectricBill.fromJson(e as Map<String, dynamic>))
            .first;
  }

  Future<int> insertElectricBill(ElectricBill electricBill) async {
    Database d = (await db)!;
    return await d.insert(
      ElectricBillHelper.tblName,
      electricBill.toJson(),
    );
  }

  Future<int> updateElectricBill(ElectricBill electricBill) async {
    Database d = (await db)!;
    electricBill.modifiedOn = DateTime.now();
    return await d.update(ElectricBillHelper.tblName, electricBill.toJson(),
        where: '${CreationHelper.colId} = ?', whereArgs: [electricBill.id]);
  }

  Future<int> deleteElectricBill(int id) async {
    Database d = (await db)!;
    return await d.delete(ElectricBillHelper.tblName,
        where: '${CreationHelper.colId} = ?', whereArgs: [id]);
  }
  //END ELECTRIC BILL MANAGEMENT

  //WATER BILL MANAGEMENT
  Future<List<WaterBill>> getWaterBills() async {
    Database d = (await db)!;
    List<Map> res = await d.query(WaterBillHelper.tblName,
        orderBy: '${WaterBillHelper.colDate} DESC');
    return res.length == 0
        ? []
        : res
            .map<WaterBill>(
                (e) => WaterBill.fromJson(e as Map<String, dynamic>))
            .toList();
  }

  Future<WaterBill?> getWaterBill(int id) async {
    Database d = (await db)!;
    return await _getWaterBill(d, id);
  }

  Future<WaterBill?> _getWaterBill(Database d, int id) async {
    List<Map> res = await d.query(WaterBillHelper.tblName,
        where: '${CreationHelper.colId} = ?', whereArgs: [id]);
    return res.length == 0
        ? null
        : res
            .map<WaterBill>(
                (e) => WaterBill.fromJson(e as Map<String, dynamic>))
            .first;
  }

  Future<int> insertWaterBill(WaterBill waterBill) async {
    Database d = (await db)!;
    return await d.insert(
      WaterBillHelper.tblName,
      waterBill.toJson(),
    );
  }

  Future<int> updateWaterBill(WaterBill waterBill) async {
    Database d = (await db)!;
    waterBill.modifiedOn = DateTime.now();
    return await d.update(WaterBillHelper.tblName, waterBill.toJson(),
        where: '${CreationHelper.colId} = ?', whereArgs: [waterBill.id]);
  }

  Future<int> deleteWaterBill(int id) async {
    Database d = (await db)!;
    return await d.delete(WaterBillHelper.tblName,
        where: '${CreationHelper.colId} = ?', whereArgs: [id]);
  }
  //END WATER BILL MANAGEMENT

  //ELECTRIC READING MANAGEMENT
  Future<List<ElectricReading>> getElectricReadings() async {
    Database d = (await db)!;
    List<Map> res = await d.query(ElectricReadingHelper.tblName,
        orderBy:
            '${ElectricReadingHelper.colPersonId}, ${ElectricReadingHelper.colDate} DESC');
    List<ElectricReading> ers = [];
    if (res.length > 0) {
      for (var r in res) {
        var er = ElectricReading.fromJson(r as Map<String, dynamic>);
        er.person = await _getPerson(d, er.personId ?? 0);
        ers.add(er);
      }
    }
    return res.length == 0 ? [] : ers;
  }

  Future<ElectricReading?> getElectricReading(int id) async {
    Database d = (await db)!;
    return await _getElectricReading(d, id);
  }

  Future<ElectricReading?> _getElectricReading(Database d, int id) async {
    List<Map> res = await d.query(ElectricReadingHelper.tblName,
        where: '${CreationHelper.colId} = ?', whereArgs: [id]);
    if (res.length > 0)
      for (var r in res) {
        var er = ElectricReading.fromJson(r as Map<String, dynamic>);
        er.person = await _getPerson(d, er.personId ?? 0);
        return er;
      }
    return null;
  }

  Future<int> insertElectricReading(ElectricReading electricReading) async {
    Database d = (await db)!;
    return await d.insert(
      ElectricReadingHelper.tblName,
      electricReading.toJson(),
    );
  }

  Future<int> updateElectricReading(ElectricReading electricReading) async {
    Database d = (await db)!;
    electricReading.modifiedOn = DateTime.now();
    return await d.update(
        ElectricReadingHelper.tblName, electricReading.toJson(),
        where: '${CreationHelper.colId} = ?', whereArgs: [electricReading.id]);
  }

  Future<int> deleteElectricReading(int id) async {
    Database d = (await db)!;
    return await d.delete(ElectricReadingHelper.tblName,
        where: '${CreationHelper.colId} = ?', whereArgs: [id]);
  }
  //END ELECTRIC READING MANAGEMENT

  //WATER READING MANAGEMENT
  Future<List<WaterReading>> getWaterReadings() async {
    Database d = (await db)!;
    List<Map> res = await d.query(WaterReadingHelper.tblName,
        orderBy:
            '${WaterReadingHelper.colPersonId}, ${WaterReadingHelper.colDate} DESC');
    List<WaterReading> ers = [];
    if (res.length > 0) {
      for (var r in res) {
        var er = WaterReading.fromJson(r as Map<String, dynamic>);
        er.person = await _getPerson(d, er.personId ?? 0);
        ers.add(er);
      }
      // ers.sort((x, y) => x.date.add(Duration(days: (360 * (x.personId ?? 1)))).compareTo(y.date.add(Duration(days: (360 * (y.personId ?? 1))))));
    }
    return res.length == 0 ? [] : ers;
  }

  Future<WaterReading?> getWaterReading(int id) async {
    Database d = (await db)!;
    return await _getWaterReading(d, id);
  }

  Future<WaterReading?> _getWaterReading(Database d, int id) async {
    List<Map> res = await d.query(WaterReadingHelper.tblName,
        where: '${CreationHelper.colId} = ?', whereArgs: [id]);
    if (res.length > 0)
      for (var r in res) {
        var er = WaterReading.fromJson(r as Map<String, dynamic>);
        er.person = await _getPerson(d, er.personId ?? 0);
        return er;
      }
    return null;
  }

  Future<int> insertWaterReading(WaterReading waterReading) async {
    Database d = (await db)!;
    return await d.insert(
      WaterReadingHelper.tblName,
      waterReading.toJson(),
    );
  }

  Future<int> updateWaterReading(WaterReading waterReading) async {
    Database d = (await db)!;
    waterReading.modifiedOn = DateTime.now();
    return await d.update(WaterReadingHelper.tblName, waterReading.toJson(),
        where: '${CreationHelper.colId} = ?', whereArgs: [waterReading.id]);
  }

  Future<int> deleteWaterReading(int id) async {
    Database d = (await db)!;
    return await d.delete(WaterReadingHelper.tblName,
        where: '${CreationHelper.colId} = ?', whereArgs: [id]);
  }
  //END WATER READING MANAGEMENT
  //END BILLS

  //START INCOME
  //INCOME TYPE MANAGEMENT
  Future<List<IncomeType>> getIncomeTypes() async {
    Database d = (await db)!;
    List<Map> res = await d.rawQuery('''
      SELECT *,
        (
          SELECT COUNT(${CreationHelper.colId})
          FROM ${IncomeHelper.tblName}
          WHERE ${IncomeHelper.colIncomeTypeId} = ${IncomeTypeHelper.tblName}.${CreationHelper.colId}
        ) reference
      FROM ${IncomeTypeHelper.tblName}
      ORDER BY ${IncomeTypeHelper.colDescription}
    ''');
    return res.length == 0
        ? []
        : res.map<IncomeType>((e) {
            var i = IncomeType.fromJson(e as Map<String, dynamic>);
            i.reference = e['reference'] as int;
            return i;
          }).toList();
  }

  Future<IncomeType?> getIncomeType(int id) async {
    Database d = (await db)!;
    return await _getIncomeType(d, id);
  }

  Future<IncomeType?> _getIncomeType(Database d, int id) async {
    List<Map> res = await d.query(IncomeTypeHelper.tblName,
        where: '${CreationHelper.colId} = ?', whereArgs: [id]);
    return res.length == 0
        ? null
        : res
            .map<IncomeType>(
                (e) => IncomeType.fromJson(e as Map<String, dynamic>))
            .first;
  }

  Future<int> insertIncomeType(IncomeType incomeType) async {
    Database d = (await db)!;
    return await d.insert(
      IncomeTypeHelper.tblName,
      incomeType.toJson(),
    );
  }

  Future<int> updateIncomeType(IncomeType incomeType) async {
    Database d = (await db)!;
    incomeType.modifiedOn = DateTime.now();
    return await d.update(IncomeTypeHelper.tblName, incomeType.toJson(),
        where: '${CreationHelper.colId} = ?', whereArgs: [incomeType.id]);
  }

  Future<int> deleteIncomeType(int id) async {
    Database d = (await db)!;
    return await d.delete(IncomeTypeHelper.tblName,
        where: '${CreationHelper.colId} = ?', whereArgs: [id]);
  }
  //END INCOME TYPE MANAGEMENT

  //WATER READING MANAGEMENT
  Future<List<Income>> getIncomes() async {
    Database d = (await db)!;
    List<Map> res = await d.query(IncomeHelper.tblName,
        orderBy:
            '${IncomeHelper.colIncomeTypeId}, ${IncomeHelper.colDate} DESC');
    List<Income> ers = [];
    if (res.length > 0) {
      for (var r in res) {
        var er = Income.fromJson(r as Map<String, dynamic>);
        er.incomeType = await _getIncomeType(d, er.incomeTypeId ?? 0);
        ers.add(er);
      }
    }
    return res.length == 0 ? [] : ers;
  }

  Future<Income?> getIncome(int id) async {
    Database d = (await db)!;
    return await _getIncome(d, id);
  }

  Future<Income?> _getIncome(Database d, int id) async {
    List<Map> res = await d.query(IncomeHelper.tblName,
        where: '${CreationHelper.colId} = ?', whereArgs: [id]);
    if (res.length > 0)
      for (var r in res) {
        var er = Income.fromJson(r as Map<String, dynamic>);
        er.incomeType = await _getIncomeType(d, er.incomeTypeId ?? 0);
        return er;
      }
    return null;
  }

  Future<int> insertIncome(Income income) async {
    Database d = (await db)!;
    return await d.insert(
      IncomeHelper.tblName,
      income.toJson(),
    );
  }

  Future<int> updateIncome(Income income) async {
    Database d = (await db)!;
    income.modifiedOn = DateTime.now();
    return await d.update(IncomeHelper.tblName, income.toJson(),
        where: '${CreationHelper.colId} = ?', whereArgs: [income.id]);
  }

  Future<int> deleteIncome(int id) async {
    Database d = (await db)!;
    return await d.delete(IncomeHelper.tblName,
        where: '${CreationHelper.colId} = ?', whereArgs: [id]);
  }
  //END WATER READING MANAGEMENT
  //END INCOMES
}
