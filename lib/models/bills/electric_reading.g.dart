// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'electric_reading.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ElectricReading _$ElectricReadingFromJson(Map<String, dynamic> json) {
  return ElectricReading()
    ..id = json['id'] as int?
    ..createdOn = DateTime.parse(json['created_on'] as String)
    ..modifiedOn = json['modified_on'] == null
        ? null
        : DateTime.parse(json['modified_on'] as String)
    ..date = DateTime.parse(json['date'] as String)
    ..reading = json['reading'] as int
    ..personId = json['person_id'] as int?;
}

Map<String, dynamic> _$ElectricReadingToJson(ElectricReading instance) {
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
  val['reading'] = instance.reading;
  val['person_id'] = instance.personId;
  return val;
}
