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
import 'package:json_annotation/json_annotation.dart';

part 'backup.g.dart';

@JsonSerializable(explicitToJson: true)
class Backup {
  List<Income>? income;
  @JsonKey(name: 'income_type')
  List<IncomeType>? incomeType;

  List<Person>? person;
  @JsonKey(name: 'electric_bill')
  List<ElectricBill>? electricBill;
  @JsonKey(name: 'electric_reading')
  List<ElectricReading>? electricReading;
  @JsonKey(name: 'water_bill')
  List<WaterBill>? waterBill;
  @JsonKey(name: 'water_reading')
  List<WaterReading>? waterReading;

  List<Expense>? expense;
  @JsonKey(name: 'expese_details')
  List<ExpenseDetails>? expenseDetails;
  List<Item>? item;
  @JsonKey(name: 'item_type')
  List<ItemType>? itemType;

  Backup({
    this.electricBill,
    this.electricReading,
    this.expense,
    this.expenseDetails,
    this.income,
    this.incomeType,
    this.item,
    this.itemType,
    this.person,
    this.waterBill,
    this.waterReading,
  });

  factory Backup.fromJson(Map<String, dynamic> json) => _$BackupFromJson(json);
  Map<String, dynamic> toJson() => _$BackupToJson(this);
}
