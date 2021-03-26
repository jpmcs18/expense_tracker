// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'water_bill.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WaterBill _$WaterBillFromJson(Map<String, dynamic> json) {
  return WaterBill()
    ..id = json['id'] as int?
    ..createdOn = DateTime.parse(json['created_on'] as String)
    ..modifiedOn = json['modified_on'] == null
        ? null
        : DateTime.parse(json['modified_on'] as String)
    ..date = DateTime.parse(json['date'] as String)
    ..amount = json['amount'] as num;
}

Map<String, dynamic> _$WaterBillToJson(WaterBill instance) {
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
  return val;
}
