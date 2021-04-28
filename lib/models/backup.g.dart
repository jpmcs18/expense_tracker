// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Backup _$BackupFromJson(Map<String, dynamic> json) {
  return Backup(
    electricBill: (json['electric_bill'] as List<dynamic>?)
        ?.map((e) => ElectricBill.fromJson(e as Map<String, dynamic>))
        .toList(),
    electricReading: (json['electric_reading'] as List<dynamic>?)
        ?.map((e) => ElectricReading.fromJson(e as Map<String, dynamic>))
        .toList(),
    expense: (json['expense'] as List<dynamic>?)
        ?.map((e) => Expense.fromJson(e as Map<String, dynamic>))
        .toList(),
    expenseDetails: (json['expese_details'] as List<dynamic>?)
        ?.map((e) => ExpenseDetails.fromJson(e as Map<String, dynamic>))
        .toList(),
    income: (json['income'] as List<dynamic>?)
        ?.map((e) => Income.fromJson(e as Map<String, dynamic>))
        .toList(),
    incomeType: (json['income_type'] as List<dynamic>?)
        ?.map((e) => IncomeType.fromJson(e as Map<String, dynamic>))
        .toList(),
    item: (json['item'] as List<dynamic>?)
        ?.map((e) => Item.fromJson(e as Map<String, dynamic>))
        .toList(),
    itemType: (json['item_type'] as List<dynamic>?)
        ?.map((e) => ItemType.fromJson(e as Map<String, dynamic>))
        .toList(),
    person: (json['person'] as List<dynamic>?)
        ?.map((e) => Person.fromJson(e as Map<String, dynamic>))
        .toList(),
    waterBill: (json['water_bill'] as List<dynamic>?)
        ?.map((e) => WaterBill.fromJson(e as Map<String, dynamic>))
        .toList(),
    waterReading: (json['water_reading'] as List<dynamic>?)
        ?.map((e) => WaterReading.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$BackupToJson(Backup instance) => <String, dynamic>{
      'income': instance.income?.map((e) => e.toJson()).toList(),
      'income_type': instance.incomeType?.map((e) => e.toJson()).toList(),
      'person': instance.person?.map((e) => e.toJson()).toList(),
      'electric_bill': instance.electricBill?.map((e) => e.toJson()).toList(),
      'electric_reading':
          instance.electricReading?.map((e) => e.toJson()).toList(),
      'water_bill': instance.waterBill?.map((e) => e.toJson()).toList(),
      'water_reading': instance.waterReading?.map((e) => e.toJson()).toList(),
      'expense': instance.expense?.map((e) => e.toJson()).toList(),
      'expese_details':
          instance.expenseDetails?.map((e) => e.toJson()).toList(),
      'item': instance.item?.map((e) => e.toJson()).toList(),
      'item_type': instance.itemType?.map((e) => e.toJson()).toList(),
    };
