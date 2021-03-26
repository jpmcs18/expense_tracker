// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'income.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Income _$IncomeFromJson(Map<String, dynamic> json) {
  return Income(
    incomeTypeId: json['income_type_id'] as int?,
  )
    ..id = json['id'] as int?
    ..createdOn = DateTime.parse(json['created_on'] as String)
    ..modifiedOn = json['modified_on'] == null
        ? null
        : DateTime.parse(json['modified_on'] as String)
    ..date = DateTime.parse(json['date'] as String)
    ..amount = json['amount'] as num;
}

Map<String, dynamic> _$IncomeToJson(Income instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  val['created_on'] = instance.createdOn.toIso8601String();
  val['modified_on'] = instance.modifiedOn?.toIso8601String();
  val['date'] = instance.date.toIso8601String();
  val['amount'] = instance.amount;
  val['income_type_id'] = instance.incomeTypeId;
  return val;
}
